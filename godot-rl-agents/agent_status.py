import socket
import json
import os
import argparse
import viz

class AgentStatus:

	DEFAULT_PORT = 10034
	DEFAULT_TIMEOUT = 60

	def __init__(self, path: str, port = DEFAULT_PORT):
		self._port = port
		self._path = path

	def _start_server(self):

		self._viz = viz.Viz(self._path)

		sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

		addr = '0.0.0.0'
		if os.name == 'nt':
			addr = '127.0.0.1'

		server_address = (addr, self._port)
		sock.bind(server_address)

		sock.listen(1)
		sock.settimeout(AgentStatus.DEFAULT_TIMEOUT)

		print(f'AgentStatus listening on port {port}')

		self.connection, _ = sock.accept()

	def _step_recv(self):
		self._recv()

	def _recv(self):
		string_size_bytes: bytearray = bytearray()
		length: int = 4
		received_length: int = 0
		while received_length < length:
			data = self.connection.recv(length - received_length)
			received_length += len(data)
			string_size_bytes.extend(data)

		length = int.from_bytes(string_size_bytes, 'little')

		string_bytes: bytearray = bytearray()
		received_length = 0

		while received_length < length:
			data = self.connection.recv(length - received_length)
			received_length += len(data)
			string_bytes.extend(data)

		string = string_bytes.decode()
		d = json.loads(string)
		type = d['type']
		name = d['name']
		data = d['data']
		step = d['step']
		if type == 'scalars':
			self._viz.record(name, data, step)
		elif type == 'scalar':
			self._viz.record_value(name, data, step)

	def serve(self):
		self._start_server()
		while True:
			self._step_recv()

	def close(self):
		self.connection.close()
		self._viz.close()

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('--path', help = 'tensor board log path', type = str)
	parser.add_argument('--port', help = 'port', type = int)
	args = parser.parse_args()

	path = args.path
	if not path:
		path = ''

	port = args.port
	if not port:
		port = AgentStatus.DEFAULT_PORT

	agent_status = AgentStatus(args.path, port)
	try:
		agent_status.serve()
	except KeyboardInterrupt:
		agent_status.close()
