use std::net::{Ipv4Addr, SocketAddr};
use std::ops::Deref;
use std::sync::Arc;

use anyhow::{Context, Result};
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::tcp::{OwnedReadHalf, OwnedWriteHalf};
use tokio::net::{TcpListener, TcpStream};
use tokio::signal;
use tokio::sync::RwLock;

use super::server_data::ServerData;
use super::server_trait::Server;
use crate::models::{Client, ClientArc, DataPacket, Message};

impl Server for Arc<ServerData> {
  fn new(port: Option<u16>, address: Option<String>) -> Self {
    let port = port.unwrap_or(9090);
    let address = address.unwrap_or(Ipv4Addr::LOCALHOST.to_string());
    let server_data = ServerData {
      port,
      address,
      clients: RwLock::new(Vec::new()),
      messages: RwLock::new(Vec::new()),
    };

    Arc::new(server_data)
  }

  async fn run(&mut self) -> Result<()> {
    log::info!("Server starting...");

    let listener = TcpListener::bind(format!("{}:{}", self.address, self.port))
      .await
      .context("Failed to bind to address")?;
    log::info!(
      "Server started on adress {}",
      listener
        .local_addr()
        .context("Failed to get address bound to")?
        .ip(),
    );
    log::info!("Use Ctrl+C to stop the server");

    // Set up graceful shutdown signal handler
    let shutdown_signal = signal::ctrl_c();
    tokio::pin!(shutdown_signal);

    'main_loop: loop {
      tokio::select! {
        result = listener.accept() => {
          self.accept_client(result)
            .context("Failed to accept client")?;
        }
        _ = &mut shutdown_signal => {
          log::warn!("Server is stopping...");
          break 'main_loop;
        }
      }
    }
    Ok(())
  }

  fn accept_client(
    &self,
    accept_result: Result<(TcpStream, SocketAddr), std::io::Error>,
  ) -> Result<()> {
    match accept_result {
      Ok((stream, _)) => {
        // Spawn a new task to handle the client
        let server_clone = Arc::clone(&self);
        let client = Client::new(stream).context("Failed to create client")?;

        let client_arc = Arc::new(RwLock::new(client));
        tokio::spawn(async move {
          if let Err(e) = server_clone.handle_client(client_arc).await {
            log::error!("Error handling client: {}", e);
          }
        });
      }
      Err(e) => {
        log::warn!("A connection attempt failed: {}", e);
      }
    }

    Ok(())
  }

  async fn handle_client(&self, client_arc: ClientArc) -> Result<()> {
    // Get a write lock as we need to modify the client name after login
    let mut client = client_arc.write().await;
    let dp;
    {
      let mut receiver_lock = client.receiver.write().await;
      dp = Self::receive(&mut receiver_lock)
        .await
        .context("Failed to get login data packet")?;
    }

    // Authenticate the client
    match dp.packet_type {
      crate::models::DataPacketType::Login => {
        client.name = dp
          .login_name
          .context("Login packet must contain a login name")?;
      }
      _ => {
        // Drops the client so it can be closed by the system
        drop(client);
        drop(client_arc);
        return Err(anyhow::anyhow!("Invalid packet type"));
      }
    }

    log::info!("Connected with {}", client.addr);
    log::info!("Nickname of client is {}", client.name);

    {
      let mut clients = self.clients.write().await;
      let mut messages = client.messages.write().await;
      clients.push(client_arc.clone());
      messages.append(&mut self.messages.read().await.deref().clone().into());
    }

    // Drop the write lock to allow other tasks to access the client
    drop(client);
    let client = client_arc.read().await;

    self
      .broadcast(Message::new_system_message(format!(
        "{} joined",
        client.name
      )))
      .await
      .context("Failed to broadcast join message")?;

    let client_arc_clone = client_arc.clone();

    let send_task = tokio::spawn(async move {
      let client = client_arc_clone.read().await;
      let mut sender = client.sender.write().await;
      loop {
        let mut message_queue = client.messages.write().await;
        if message_queue.len() > 0 {
          let message = message_queue.pop_front().unwrap();
          let dp = DataPacket::new_message_dp(&message);
          if let Err(e) = Self::send(&mut sender, &dp).await {
            log::error!("Failed to send message: {}", e);
            break;
          }
        } else {
          // Await 100ms to scale down the CPU usage
          tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
        }
      }
    });

    let mut receiver = client.receiver.write().await;
    'receive_loop: loop {
      let dp_result = Self::receive(&mut receiver).await;
      if dp_result.is_err() {
        // Gracefully handle the error and break the loop so that the client can be
        // removed
        log::warn!("{}", dp_result.unwrap_err());
        break 'receive_loop;
      }
      let dp = dp_result.unwrap();
      match dp.packet_type {
        crate::models::DataPacketType::Message => {
          let message = dp
            .message
            .context("Message packet must contain a message")?;
          self
            .broadcast(message)
            .await
            .context("Failed to broadcast received message")?;
        }
        _ => {
          log::error!("Invalid packet type");
          break;
        }
      }
    }

    // Remove the client from the active clients list
    let mut clients = self.clients.write().await;

    for (index, c) in clients.iter().enumerate() {
      if c.read().await.addr == client.addr {
        clients.remove(index);
        break;
      }
    }

    drop(clients);
    send_task.abort();

    self
      .broadcast(Message::new_system_message(format!("{} left", client.name)))
      .await
      .context("Failed to broadcast left message")?;

    log::info!("Client {} closed the connection", client.addr);

    Ok(())
  }

  async fn broadcast(&self, message: Message) -> Result<()> {
    let clients = self.clients.read().await;
    for client_arc in clients.iter() {
      let client = client_arc.read().await;
      let mut client_message_queue = client.messages.write().await;

      client_message_queue.push_back(message.clone());
    }

    self.messages.write().await.push(message);
    Ok(())
  }

  async fn receive(reader: &mut BufReader<OwnedReadHalf>) -> Result<DataPacket> {
    // Read a UTF-8 line from the reader
    let mut line = String::new();
    let bytes_read = reader
      .read_line(&mut line)
      .await
      .context("Failed to read line")?;
    if bytes_read == 0 {
      return Err(anyhow::anyhow!("Connection closed"));
    }

    // Parse the line into a DataPacket
    let data_packet: DataPacket =
      serde_json::from_str(&line).context("Failed to parse data packet")?;

    // Check if the packet is a valid message
    data_packet.assert().context("Invalid data packet")?;

    Ok(data_packet)
  }

  async fn send(sender: &mut OwnedWriteHalf, dp: &DataPacket) -> Result<()> {
    // Serialize the message to JSON
    let dp_json = serde_json::to_string(dp).context("Failed to serialize message")?;
    let dp_string = format!("{}\n", dp_json); // Store the string
    let dp_bytes = dp_string.as_bytes();
    // Send the message over the sender
    sender
      .write_all(dp_bytes)
      .await
      .context("Failed to send message")?;

    Ok(())
  }
}

impl Drop for ServerData {
  fn drop(&mut self) {
    log::warn!("Server has closed");
  }
}
