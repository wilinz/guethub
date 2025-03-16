use chrono::{Datelike, NaiveDateTime};
use md5::{Digest, Md5};
use scraper::{Html, Selector};
use serde::Serialize;
use std::str::from_utf8;
use selectors::Element;

#[derive(Serialize)]
#[flutter_rust_bridge::frb(ignore)]
struct ExamScheduleItem {
    id: String,
    username: String,
    time: String,
    start_time: String,
    end_time: String,
    weekday: u32,
    section: u32,
    campus: String,
    building: String,
    room: String,
    course: String,
    tag: String,
    status: String,
    week: Option<u32>,
}

#[flutter_rust_bridge::frb(dart_async)]
pub fn parse_exam_schedules(html: &[u8]) -> Option<Vec<u8>> {
    let document = Html::parse_document(from_utf8(html).ok()?);
    let table_selector = Selector::parse("#exams").ok()?;
    let tr_selector = Selector::parse("tr[data-finished]").ok()?;
    let time_selector = Selector::parse(".time").ok()?;
    let span_selector = Selector::parse(".time ~ div span").ok()?;
    let course_selector = Selector::parse(".tag-span").ok()?;
    let status_selector = Selector::parse(".text-center").ok()?;

    let table = document.select(&table_selector).next()?;
    let mut result = vec![];

    for row in table.select(&tr_selector) {
        let time = row
            .select(&time_selector)
            .next()?
            .text()
            .collect::<String>()
            .trim()
            .to_string();

        // 解析 campus, building, room
        let spans: Vec<_> = row.select(&span_selector).collect();
        let campus = spans
            .get(0)
            .map(|e| e.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        let building = spans
            .get(1)
            .map(|e| e.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        let room = spans
            .get(2)
            .map(|e| e.text().collect::<String>().trim().to_string())
            .unwrap_or_default();

        // 解析 course 和 tag
        let course = row
            .select(&course_selector)
            .next()
            .and_then(|e| e.parent_element())
            .and_then(|p| p.parent_element())
            .and_then(|pp| {
                pp.select(&Selector::parse("div:first-child span").ok()?)
                    .next()
            })
            .map(|e| e.text().collect::<String>().trim().to_string())
            .unwrap_or_default();

        let tag: String = row
            .select(&course_selector)
            .next()
            .map(|e| e.text().collect::<String>().trim().to_string())
            .unwrap_or_default();

        let status = row
            .select(&status_selector)
            .next()
            .map(|e| e.text().collect::<String>().trim().to_string())
            .unwrap_or_default();

        // 解析时间段
        let (start_time, end_time) = parse_time(&time)?;
        let section =
            super::super::utils::section_finder::find_closest_section(&start_time, &end_time)
                .unwrap_or(1);

        // 生成 id
        let mut hasher = Md5::new();
        hasher.update(course.as_bytes());
        let id = format!("{:x}", hasher.finalize());

        result.push(ExamScheduleItem {
            id,
            username: "".to_string(),
            time,
            start_time: start_time.format("%Y-%m-%dT%H:%M:%S").to_string(),
            end_time: end_time.format("%Y-%m-%dT%H:%M:%S").to_string(),
            weekday: start_time.weekday().number_from_monday(),
            section,
            campus,
            building,
            room,
            course,
            tag,
            status,
            week: None,
        });
    }

    serde_json::to_vec(&result).ok()
}

// 解析 "2024-01-15 14:00~16:00" 这种时间格式
fn parse_time(time: &str) -> Option<(NaiveDateTime, NaiveDateTime)> {
    let parts: Vec<_> = time.split('~').collect();
    if parts.len() == 2 {
        let date_part = parts[0].split_whitespace().next()?;
        let start_time = parts[0].split_whitespace().nth(1)?;
        let end_time = parts[1].trim();

        let start = NaiveDateTime::parse_from_str(
            &format!("{} {}", date_part, start_time),
            "%Y-%m-%d %H:%M",
        )
        .ok()?;

        let end =
            NaiveDateTime::parse_from_str(&format!("{} {}", date_part, end_time), "%Y-%m-%d %H:%M")
                .ok()?;

        return Some((start, end));
    }
    None
}
