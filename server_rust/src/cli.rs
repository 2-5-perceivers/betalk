pub use clap::Parser;
use clap_derive::Subcommand;

/// Arguments to the server. Contains the option to use the run command, an
/// option to specify the port, and an option to specify the address.
#[derive(Parser, Debug)]
#[command(version, about, long_about = Some("The Rust server for BeTalk"))]
pub struct CliArgs {
  #[command(subcommand)]
  pub command: Commands,
}

/// Define available subcommands
#[derive(Subcommand, Debug, Clone)]
pub enum Commands {
  /// Run the server
  Run {
    /// The port to run the server on
    #[arg(short = 'p')]
    port: Option<u16>,
    /// The address to run the server on. Defaults to
    /// localhost.
    #[arg(short = 'i')]
    address: Option<String>,
  },
}
