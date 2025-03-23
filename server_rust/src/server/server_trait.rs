use std::net::SocketAddr;

use anyhow::Result;
use tokio::io::BufReader;
use tokio::net::TcpStream;
use tokio::net::tcp::{OwnedReadHalf, OwnedWriteHalf};

use crate::models::{ClientArc, DataPacket, Message};

/// A trait defining server behavior for the messaging server
///
/// This trait outlines the required functionality for a server implementation
/// that handles client connections, message broadcasting, and communication
/// protocols.
///
/// Implementors of this trait should manage:
/// - Server initialization with configurable network settings
/// - Client connection lifecycle (accept, authenticate, communicate,
///   disconnect)
/// - Message distribution to connected clients
/// - Communication protocol for sending/receiving data packets
pub trait Server {
  /// Creates a new server instance
  ///
  /// # Arguments
  /// * `port` - Optional port number, defaults to 9090
  /// * `address` - Optional IP address, defaults to 127.0.0.1
  fn new(port: Option<u16>, address: Option<String>) -> Self;

  /// Starts the server and handles connections
  ///
  /// Listens for incoming connections and manages graceful shutdown
  async fn run(&mut self) -> Result<()>;

  /// Processes new client connection attempts by starting a new task to handle
  /// the client
  fn accept_client(
    &self,
    accept_result: Result<(TcpStream, SocketAddr), std::io::Error>,
  ) -> Result<()>;

  /// Handles communication with a connected client
  ///
  /// Process flow:
  /// 1. Authenticates client through login data
  /// 2. Adds client to active clients list
  /// 3. Sends message history to client
  /// 4. Sets up bidirectional communication:
  ///    - Listens for incoming client messages
  ///    - Delivers queued messages to client
  /// 5. Handles client disconnection by removing from active list
  /// 6. Manages any errors during communication
  async fn handle_client(&self, client: ClientArc) -> Result<()>;

  /// Sends a message to all connected clients
  ///
  /// Stores message in history and distributes to client queues
  async fn broadcast(&self, message: Message) -> Result<()>;

  async fn receive(reader: &mut BufReader<OwnedReadHalf>) -> Result<DataPacket>;
  async fn send(sender: &mut OwnedWriteHalf, message: &DataPacket) -> Result<()>;
}
