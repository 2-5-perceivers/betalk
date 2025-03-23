use tokio::sync::RwLock;

use crate::models::{ClientArc, Message};

/// Represents the server state and configuration.
///
/// This struct maintains the server's configuration (port and address)
/// as well as the runtime state including connected clients and message
/// history.
///
/// # Fields
/// * `port` - The port number on which the server listens for connections
/// * `address` - The network address the server binds to
/// * `clients` - Thread-safe storage for connected client references
/// * `messages` - Thread-safe storage for message history
pub struct ServerData {
  pub port: u16,
  pub address: String,
  pub clients: RwLock<Vec<ClientArc>>,
  pub messages: RwLock<Vec<Message>>,
}
