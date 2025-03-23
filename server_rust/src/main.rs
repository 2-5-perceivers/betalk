use std::sync::Arc;

use anyhow::{Context, Result};
use cli::{CliArgs, Commands, Parser};
use server::{Server, ServerData};

mod cli;
mod models;
mod server;

#[tokio::main]
async fn main() -> Result<()> {
  let args = CliArgs::parse();
  simplelog::TermLogger::init(
    log::LevelFilter::Info,
    simplelog::Config::default(),
    simplelog::TerminalMode::Mixed,
    simplelog::ColorChoice::Always,
  )
  .context("Failed to set up logger")?;

  match args.command {
    Commands::Run { port, address } => {
      let mut server: Arc<ServerData> = Server::new(port, address);
      if let Err(e) = server.run().await {
        log::error!("Error running server: {}", e);
      }
    }
  }

  Ok(())
}
