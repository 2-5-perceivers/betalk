# BeTalk

A simple real-time chat application using sockets implemented in multiple languages.

## Implementations
- **Clients**: Flutter, Python
- **Servers**: Kotlin, Rust, Python

## Roadmap
- [ ] GO server implementation
- [ ] Login response handling
- [ ] Logout data packet support
- [ ] Client ID management
- [ ] File transfer improvements
- [ ] File transfer support in all clients

## Protocol Specification

Communication occurs over TCP using UTF-8 encoded JSON strings, terminated by newlines.

### Data Packet Structure

```json
{
  "id": "string",
  "message": {Message} | null,
  "loginName": "string" | null,
  "type": "LOGIN|MESSAGE"
}
```

### Message Structure

```json
{
  "id": "string",
  "author": "string" | null,
  "textContent": "string" | null,
  "fileContent": "base64EncodedBytes",
  "time": "2025-03-23T14:30:00Z",
  "type": "USER_MESSAGE|SYSTEM_MESSAGE"
}
```

### Connection Flow
1. Client establishes TCP connection
2. Client sends a LOGIN data packet
3. Client sends/receives MESSAGE data packets
4. Server only sends MESSAGE data packets to clients

## Server specifications

## Server Specifications

### Command Interface
- Each server implementation must provide a `run` subcommand
- Must support configurable IP address and port parameters

### Logging Requirements
Servers should log the following events:
- Server startup (with IP and port information)
- New client connections
- Client disconnections
- Server shutdown

### Graceful Shutdown
- All server implementations must handle graceful shutdown via `Ctrl+C`
- Should release all resources before terminating

---

BeTalk is designed for simplicity while supporting cross-platform communication across various language implementations.