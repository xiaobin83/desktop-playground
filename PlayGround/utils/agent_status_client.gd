class_name AgentStatusClient
extends Node

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 10034

const TYPE_SCALAR = &'scalar'
const TYPE_SCALARS = &'scalars'
const TYPE_EP_TRAJECTORY = &'ep_trajectory'

var _stream: StreamPeerTCP 

static var _instance

func _enter_tree() -> void:
	_instance = self

func _exit_tree() -> void:
	_instance = null

func _ready() -> void:
	_stream = await _connect()

func _connect() -> StreamPeerTCP:
	var stream = StreamPeerTCP.new()
	stream.connect_to_host(SERVER_IP, SERVER_PORT)
	stream.set_no_delay(true)
	stream.poll()
	while stream.get_status() < StreamPeerTCP.STATUS_CONNECTED:
		await get_tree().process_frame
		stream.poll()
	if stream.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		return stream
	return null

static func report_trajectory(key: StringName, trajectory: Dictionary, step: int) -> void:
	pass

static func report_scalar(key: StringName, value: float, step: int) -> void:
	if not _instance or not _instance._stream: return

	var data = {
		"type": TYPE_SCALAR,
		"name": key,
		"data": value,
		"step": step
	}
	_instance._put_string(data)


static func report_scalars(key: StringName, scalars: Dictionary, step: int) -> void:
	if not _instance or not _instance._stream: return

	var data = {
		"type": TYPE_SCALARS,
		"name": key,
		"data": scalars,
		"step": step,
	}
	_instance._put_string(data)

func _put_string(data):
	assert(_stream)
	var s = JSON.stringify(data, "", false)
	#print(s)
	_stream.put_string(s)
