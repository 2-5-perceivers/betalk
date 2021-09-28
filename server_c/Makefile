CC := clang
ARGS := -Wall

build/bin/server: build/obj/main.o build/obj/server.o
	$(CC) build/obj/main.o build/obj/server.o -o build/bin/server

build/obj/main.o: main.c
	$(CC) -c main.c -o build/obj/main.o

build/obj/server.o: lib/server.c
	$(CC) -c lib/server.c -o build/obj/server.o

run:
	./build/bin/server run 192.168.1.25 9090

clean:
	rm build/obj/*
	rm build/bin/*