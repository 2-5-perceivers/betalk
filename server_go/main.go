package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/urfave/cli/v3"
)

func main() {
	var address string
	var port uint64

	// Create a new CLI application
	cmd := &cli.Command{
		Name:  "betalk",
		Usage: "The Go version of the BeTalk server",
		Commands: []*cli.Command{
			{
				Name:  "run",
				Usage: "Run the BeTalk server",
				Flags: []cli.Flag{
					&cli.StringFlag{
						Name:        "address",
						Usage:       "The address to listen on",
						Value:       "127.0.0.1",
						Destination: &address,
						Aliases:     []string{"i"},
					},
					&cli.UintFlag{
						Name:        "port",
						Usage:       "The port to listen on",
						Value:       9090,
						Destination: &port,
						Aliases:     []string{"p"},
					},
				},
				Action: func(ctx context.Context, cmd *cli.Command) error {
					// Print the address and port
					fmt.Printf("Should start server on %s:%d\n", address, port)
					// TODO: Implement the server
					return nil
				},
			},
		},
	}

	if err := cmd.Run(context.Background(), os.Args); err != nil {
		log.Fatal(err)
	}
}
