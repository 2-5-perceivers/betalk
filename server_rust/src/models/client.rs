use std::collections::VecDeque;
use std::net::SocketAddr;

use anyhow::{Context, Result};
use tokio::io::BufReader;
use tokio::net::TcpStream;
use tokio::net::tcp::{OwnedReadHalf, OwnedWriteHalf};
use tokio::sync::RwLock;

use super::Message;

pub type ClientArc = std::sync::Arc<RwLock<Client>>;

#[derive(Debug)]
pub struct Client {
  pub name: String,
  pub addr: SocketAddr,
  pub sender: RwLock<OwnedWriteHalf>,
  pub receiver: RwLock<BufReader<OwnedReadHalf>>,
  pub messages: RwLock<VecDeque<Message>>,
}

impl Client {
  pub fn new(stream: TcpStream) -> Result<Self> {
    let addr = stream.peer_addr().context("Failed to get peer address")?;
    stream.set_nodelay(true).context("Failed to set nodelay")?;
    let (receiver, sender) = stream.into_split();

    Ok(Self {
      name: String::new(),
      addr,
      sender: RwLock::new(sender),
      receiver: RwLock::new(BufReader::new(receiver)),
      messages: RwLock::new(VecDeque::new()),
    })
  }
}
