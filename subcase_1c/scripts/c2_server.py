#!/usr/bin/env python3
import os
import socket
import threading

bind_ip = os.getenv("C2_BIND_IP", "0.0.0.0")
port = int(os.getenv("C2_PORT", "9001"))

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((bind_ip, port))
server.listen(5)

def handle(client):
    client.send(b"Connected to C2\n")
    client.close()

while True:
    client, addr = server.accept()
    threading.Thread(target=handle, args=(client,), daemon=True).start()
