use anyhow::{Result, anyhow};
use serde::{Deserialize, Serialize};

use super::message::Message;

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum DataPacketType {
  Login,
  Message,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(rename_all = "camelCase")]
pub struct DataPacket {
  pub id: String,
  pub message: Option<Message>,
  pub login_name: Option<String>,
  #[serde(rename = "type")]
  pub packet_type: DataPacketType,
}

impl DataPacket {
  pub fn new_message_dp(m: &Message) -> Self {
    Self {
      id: uuid::Uuid::new_v4().to_string(),
      message: m.clone().into(),
      login_name: None,
      packet_type: DataPacketType::Message,
    }
  }

  pub fn assert(&self) -> Result<()> {
    if self.login_name.is_some() && self.message.is_some() {
      return Err(anyhow!("Packet cannot contain both login name and message"));
    }

    match &self.packet_type {
      DataPacketType::Login => {
        if self.login_name.is_none() ||
          self
            .login_name
            .as_ref()
            .unwrap_or(&String::new())
            .is_empty()
        {
          return Err(anyhow!("Login packet must contain a login name"));
        }
      }
      DataPacketType::Message => {
        if self.message.is_none() {
          return Err(anyhow!("Message packet must contain a message"));
        }

        if let Err(e) = self.message.as_ref().unwrap().assert() {
          return Err(e.context("Message packet validation failed"));
        }
      }
    }

    Ok(())
  }
}
