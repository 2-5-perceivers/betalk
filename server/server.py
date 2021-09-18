import socket
import threading

HOST = socket.gethostbyname(socket.gethostname())
PORT = 9090
FORMAT = 'utf-8'

print("\n#  [STATUS] Server starting ... \n")

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((HOST, PORT))

server.listen()

clients = []
nicknames = []

def broadcast(message):
	for client in clients:
		client.send(message);

def handle(client):
	while True:
		try:
			message = client.recv(1024)
			print(f"c->  [CLIENT] {nicknames[clients.index(client)]} says {message}")
			broadcast(message)
		except:
			index = clients.index(client)
			nicknames.pop(index)
			clients.remove(client)
			break

def receive():
	while True:
		client, address = server.accept()
		print(f"c->  [CLIENT] Connected with {str(address)}!")

		client.send("__RCV__".encode(FORMAT))
		nickname = client.recv(1024)
		nicknames.append(nickname)
		clients.append(client)

		print(f"Nickname of the client is {nickname}")
		broadcast(f"c->  [CLIENT] {nickname} joined the chat\n".encode(FORMAT))
		client.send("Connected to the server".encode(FORMAT))
		thread  = threading.Thread(target=handle, args=(client,))
		thread.start()

print("##############################")
print("#  [STATUS] Server started!  #")
print("##############################\n")

print("[STATUS] Server running ... \n")

receive()
