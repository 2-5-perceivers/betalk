use cli::{CliArgs, Commands, Parser};

mod cli;

fn main() {
    let args = CliArgs::parse();

    match args.command {
        Commands::Run { port, address } => {
            println!(
                "Running server on port {:?} and address {:?}",
                port, address
            );
        }
    }
    println!("Hello, world!");
}
