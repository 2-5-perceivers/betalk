use anyhow::{Result, anyhow};
use chrono::DateTime;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum MessageType {
  UserMessage,
  SystemMessage,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct Message {
  pub id: String,
  pub author: Option<String>,
  pub text_content: Option<String>,
  pub file_content: Option<Vec<u8>>,
  pub time: DateTime<chrono::Utc>,
  #[serde(rename = "type")]
  pub message_type: MessageType,
}

impl Message {
  pub fn new_system_message(text_content: String) -> Self {
    Self {
      id: uuid::Uuid::new_v4().to_string(),
      author: None,
      text_content: Some(text_content),
      file_content: None,
      time: chrono::Utc::now(),
      message_type: MessageType::SystemMessage,
    }
  }

  pub fn assert(&self) -> Result<()> {
    if self.text_content.is_none() && self.file_content.is_none() {
      return Err(anyhow!("Message must contain either text or file content"));
    }

    Ok(())
  }
}
