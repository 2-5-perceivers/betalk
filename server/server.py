import socket
import sys
import threading
from utils.bcolors import bcolors

class Server:
	server: socket = None

	shouldClose: bool = False
	server: socket.socket = None

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
		print(bcolors.OKGREEN + f"[STATUS] Server started on {self.HOST}" + bcolors.ENDC)
		self.receive()

	def broadcast(self, message) -> None:
		for client in self.clients:
			client.send(message);

	def handle(self, client: socket.socket) -> None:
		# TODO: fix bug: when client dies it just keeps broadcasting same message
		while not self.shouldClose:
			try:
				message = client.recv(1024)
				print(f"[CLIENT] {self.nicknames[self.clients.index(client)]} says {message}")
				self.broadcast(message)
			except:
				index = self.clients.index(client)
				client.close()
				self.nicknames.pop(index)
				self.clients.remove(client)
				break

	def receive(self) -> None:
		print("[STATUS] Server running ...\n")
		print("[INFO] You can close by using Ctrl+C\n")
		while not self.shouldClose:
			client, address = self.server.accept()

			nickname = client.recv(1024).decode(self.FORMAT)
			self.nicknames.append(nickname)
			self.clients.append(client)

			print(f"[CLIENT] Connected with {str(address)}!")
			print(f"[INFO] Nickname of the client is {nickname}")
			print(f"[INFO] Total clients: {str(self.clients.__len__())}")

			self.broadcast(f"{nickname} joined the chat\n".encode(self.FORMAT))
			client.send("Connected to the server".encode(self.FORMAT))
			thread  = threading.Thread(target=self.handle, args=(client,))
			thread.start()

	# Deletes variables
	def dispose(self) -> None:
		self.shouldClose = True
		self.server.close()
		sys.exit(0)
