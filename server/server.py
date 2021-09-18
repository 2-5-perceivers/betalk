import socket
import sys
import threading
from utils.bcolors import bcolors

class Server:
	server: socket = None

	shouldClose: bool = False

	clients = []
	nicknames = []

	def __init__(self) -> None:
		self.HOST = socket.gethostbyname(socket.gethostname())
		self.PORT = 9090
		self.FORMAT = 'utf-8'

	def startServer(self) -> None:
		print("[STATUS] Server starting...")
		self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.server.bind((self.HOST, self.PORT))
		self.server.listen()
		print(bcolors.OKGREEN + "[STATUS] Server started!" + bcolors.ENDC)
		self.receive()

	def broadcast(self, message) -> None:
		for client in self.clients:
			client.send(message);

	def handle(self, client) -> None:
		while not self.shouldClose:
			try:
				message = client.recv(1024)
				print(f"c->  [CLIENT] {self.nicknames[self.clients.index(client)]} says {message}")
				self.broadcast(message)
			except:
				index = self.clients.index(client)
				self.nicknames.pop(index)
				self.clients.remove(client)
				break

	def receive(self) -> None:
		print("[STATUS] Server running ...\n")
		print("You can close by using Ctrl+C")
		while not self.shouldClose:
			client, address = self.server.accept()
			print(f"c->  [CLIENT] Connected with {str(address)}!")

			client.send("__RCV__".encode(self.FORMAT))
			nickname = client.recv(1024)
			self.nicknames.append(nickname)
			self.clients.append(client)

			print(f"Nickname of the client is {nickname}")
			self.broadcast(f"c->  [CLIENT] {nickname} joined the chat\n".encode(self.FORMAT))
			client.send("Connected to the server".encode(self.FORMAT))
			thread  = threading.Thread(target=self.handle, args=(client,))
			thread.start()

	# Deletes variables
	def dispose(self) -> None:
		self.shouldClose = True
		self.server.close()
		sys.exit(0)
