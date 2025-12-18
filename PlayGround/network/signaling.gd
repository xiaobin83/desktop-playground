class_name Signaling
extends Node

enum ConnectionType { None, Mesh, Server, Client }
enum Actor { Offerer, Answerer }

signal on_peer_joined(user: User)

@export var _signal_server : String = "http://localhost:9001"

const ACTION_HEARTBEAT := "heartbeat"
const ACTION_JOIN := "join"
const ACTION_SEND_ICE := "send_ice"
const ACTION_SEND_OFFER := "send_offer"

var _regex_user_id_with_nm := Utils.create_regex(r'^(\w+):(\w+)$')

class User:
	var user_nm :String # name space
	var user_id :String
	var player_id :int
	var actor :Actor
class Room:
	var room_id :String
	var users :Array[User] = []
	var local_user: User

	func has_only_one_user() -> bool:
		return users.size() == 1

class Response:
	var status: int
	var response_code: int
	var headers: PackedStringArray
	var body: String
	var dict : Dictionary

	func _init(result: Array) -> void:
		status = result[0]
		response_code = result[1]
		headers = result[2]
		body = result[3].get_string_from_utf8()
		dict = JSON.parse_string(body) as Dictionary

var _room: Room
var room: Room :
	get: return _room

class Request:
	var _body: String
	var _printer: Printer

	signal completed(response: Response)

	func _init(body_string: String, printer: Printer) -> void:
		_body = body_string
		_printer = printer

	func send_async(signal_server: String):
		var req = ObjectPool.allocate_class(HTTPRequest)
		var headers = ["Content-Type: application/json"]
		_printer.p("request: ", _body)
		req.request(signal_server, headers, HTTPClient.METHOD_POST, _body)
		var result = await req.request_completed
		ObjectPool.recycle(req)
		var response = Response.new(result)
		_printer.p("response: ", response.response_code, response.body)
		completed.emit(response)

var _request_queue: Array[Request] = []

var _printer: Printer = Printer.new('Signaling')
var _cooldown = Cooldown.new(10.0)

var _connection_type: ConnectionType = ConnectionType.None
var connection_type: ConnectionType :
	get: return _connection_type

func _ready() -> void:
	_serve_async()

func _serve_async() -> void:
	while true:
		if _request_queue.size() > 0:
			var request = _request_queue.pop_front()
			await request.send_async(_signal_server)
		else:
			await get_tree().process_frame

func set_local_user(local_user: LocalUser) -> void:
	_printer = local_user.get_printer('Signaling')

func join_room_async(user_id: String, room_id: String) -> int:
	var body = JSON.stringify({
		'action': ACTION_JOIN,
		'user_id': user_id,
		'room_id': room_id
	})
	var request = _queue_request(body)
	var response = await request.completed
	return _complete_join_room(user_id, response)

func send_ice_candidate(media: String, index :int, ice_name: String) -> int:
	if _room == null:
		_printer.err('no room when send_ice_candidate')
		return FAILED
	var local_user = _room.local_user
	var body = JSON.stringify({
		'action': ACTION_SEND_ICE,
		'user_id': local_user.user_id,
		'ice_candidate': {
			'media': media,
			'index': index,
			'ice_name': ice_name
		}
	})
	_queue_request(body)
	return OK

func send_offer(sdp: String) -> int:
	if _room == null:
		_printer.err('no room when send_offer')
		return FAILED
	var local_user = _room.local_user
	var body = JSON.stringify({
		'action': ACTION_SEND_OFFER,
		'user_id': local_user.user_id,
		'sdp': sdp
	})
	_queue_request(body)
	return OK

func _complete_join_room(user_id: String, resp: Response) -> int:
	if resp.status != HTTPRequest.RESULT_SUCCESS:
		return FAILED
	if resp.response_code != 200:
		return false

	var dict = resp.dict
	if dict == null: return FAILED

	var err = dict.get('error')
	if err != null:
		_printer.err(err)
		return FAILED

	var type_str = dict.get('connection_type')
	match type_str:
		"mesh":
			_connection_type = ConnectionType.Mesh
		"server":
			_connection_type = ConnectionType.Server
		"client":
			_connection_type = ConnectionType.Client
		_:
			_connection_type = ConnectionType.None

	var users_in_room = dict.get('users_in_room')
	if not users_in_room:
		_printer.err('no users in room')
		return FAILED

	var room_id = dict.get('room_id')
	if not room_id:
		_printer.err('no room_id in response')
		return FAILED

	_room = Room.new()
	_room.room_id = room_id
	for user in users_in_room:
		var user_id_with_nm = user.get('user_id') as String
		var player_id = user.get('player_id')
		var user_in_room = User.new()
		user_in_room.user_id = user_id_with_nm
		user_in_room.player_id = player_id
		user_in_room.actor = Utils.get_enum_value(Actor, user.get('actor'))
		_room.users.append(user_in_room)

		var match = _regex_user_id_with_nm.search(user_id_with_nm)
		if match:
			user_in_room.user_nm = match.get_string(1)
			user_in_room.user_id = match.get_string(2)
			if user_in_room.user_id == user_id:
				_room.local_user = user_in_room

	return OK

func get_all_remote_peers() -> Array[User]:
	return []

func _send_heartbeat_async() -> void:
	var body = JSON.stringify({
		'action': ACTION_HEARTBEAT,
		'user_id': _room.local_user.user_id,
	})
	_queue_request(body)

func _queue_request(body: String) -> Request:
	var request = Request.new(body, _printer)
	_request_queue.append(request)
	return request
