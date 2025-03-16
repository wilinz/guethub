use chrono::{NaiveTime, NaiveDateTime, DateTime};
use once_cell::sync::Lazy;

#[derive(Clone, Debug)]
#[flutter_rust_bridge::frb(ignore)]
struct SectionTime {
    pub section: u32,
    pub start: NaiveTime,
    pub end: NaiveTime,
}

// 只懒加载一次，后续复用
static SECTION_TIMES: Lazy<Vec<SectionTime>> = Lazy::new(|| {
    vec![
        SectionTime {
            section: 1,
            start: NaiveTime::from_hms_opt(8, 25, 0).unwrap(),
            end: NaiveTime::from_hms_opt(10, 0, 0).unwrap(),
        },
        SectionTime {
            section: 2,
            start: NaiveTime::from_hms_opt(10, 25, 0).unwrap(),
            end: NaiveTime::from_hms_opt(12, 0, 0).unwrap(),
        },
        SectionTime {
            section: 3,
            start: NaiveTime::from_hms_opt(14, 30, 0).unwrap(),
            end: NaiveTime::from_hms_opt(16, 5, 0).unwrap(),
        },
        SectionTime {
            section: 4,
            start: NaiveTime::from_hms_opt(16, 30, 0).unwrap(),
            end: NaiveTime::from_hms_opt(18, 5, 0).unwrap(),
        },
        SectionTime {
            section: 5,
            start: NaiveTime::from_hms_opt(19, 30, 0).unwrap(),
            end: NaiveTime::from_hms_opt(21, 10, 0).unwrap(),
        },
    ]
});

// 获取固定的 section 列表（只初始化一次）
fn get_section_times() -> &'static [SectionTime] {
    &SECTION_TIMES
}


// 查找最接近的 Section
#[flutter_rust_bridge::frb(ignore)]
pub fn find_closest_section(
    given_start_time: &NaiveDateTime,
    given_end_time: &NaiveDateTime,
) -> Option<u32> {
    let sections = get_section_times();
    let mut closest_section = None;
    let mut min_diff = i64::MAX;

    for section in sections {
        let start_time = NaiveDateTime::new(given_start_time.date(), section.start);
        let end_time = NaiveDateTime::new(given_start_time.date(), section.end);

        let start_diff = (given_start_time.and_utc().timestamp() - start_time.and_utc().timestamp()).abs();
        let end_diff = (given_end_time.and_utc().timestamp() - end_time.and_utc().timestamp()).abs();
        let total_diff = start_diff + end_diff;

        if total_diff < min_diff {
            min_diff = total_diff;
            closest_section = Some(section.section);
        }
    }

    closest_section
}

#[flutter_rust_bridge::frb(sync)]
pub fn find_closest_section_from_rfc3339(start_time_str: &str, end_time_str: &str) -> Option<u32> {
    // 尝试将 RFC3339 格式的字符串解析为 DateTime<Utc>
    let start_time = match DateTime::parse_from_rfc3339(start_time_str) {
        Ok(dt) => dt.naive_utc(),  // 将 DateTime 转换为 NaiveDateTime
        Err(_) => return None,     // 如果解析失败，返回 None
    };

    let end_time = match DateTime::parse_from_rfc3339(end_time_str) {
        Ok(dt) => dt.naive_utc(),  // 将 DateTime 转换为 NaiveDateTime
        Err(_) => return None,     // 如果解析失败，返回 None
    };

    // 调用现有的 find_closest_section 函数
    find_closest_section(&start_time, &end_time)
}