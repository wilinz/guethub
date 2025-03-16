use std::str::from_utf8;
use scraper::{Html, Selector};
use serde::Serialize;

#[derive(Serialize)]
#[flutter_rust_bridge::frb(ignore)]
pub struct GraduateInfoRust {
    pub degree: Option<String>,
    pub graduation: Option<String>,
    pub gpa: Option<String>,
    pub program_id: Option<String>,
}

#[flutter_rust_bridge::frb(dart_async)]
pub fn parse_graduate_info(html: &[u8]) -> Option<Vec<u8>> {

    let document = Html::parse_document(from_utf8(html).ok()?);
    let graduate_info_selector = Selector::parse(".graduate-info").ok()?;
    let p_selector = Selector::parse("p").ok()?;
    let strong_selector = Selector::parse("strong").ok()?;
    let span_selector = Selector::parse("span").ok()?;

    let graduate_info = document.select(&graduate_info_selector).next()?;
    let mut result = GraduateInfoRust {
        degree: None,
        graduation: None,
        gpa: None,
        program_id: None,
    };

    for item in graduate_info.select(&p_selector) {
        let key = item
            .select(&strong_selector)
            .next()?
            .text()
            .collect::<String>()
            .replace('：', "")
            .trim()
            .to_string();
        let mut value = item
            .select(&span_selector)
            .next()?
            .text()
            .collect::<String>()
            .trim()
            .to_string();

        if ["学位", "毕业", "学分绩"].contains(&key.as_str()) {
            value = value.replace(char::is_whitespace, "");
        }

        match key.as_str() {
            "学位" => result.degree = Some(value),
            "毕业" => result.graduation = Some(value),
            "学分绩" => result.gpa = Some(value),
            _ => {}
        }
    }

    let program_id_selector = Selector::parse(r#"input[name="targetProgramAssoc"]"#).ok()?;
    if let Some(program_id_element) = document.select(&program_id_selector).next() {
        if let Some(program_id) = program_id_element.value().attr("value") {
            result.program_id = Some(program_id.to_string());
        }
    }

    serde_json::to_vec(&result).ok()
}
