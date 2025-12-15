class_name Signaling
extends RefCounted

@export var _signal_server : String = "http://localhost:9001"

class User:
	var user_id :String
	var player_id :int

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
	var body: PackedByteArray

	func _init(result: Array) -> void:
		status = result[0]
		response_code = result[1]
		headers = result[2]
		body = result[3]

var _room: Room

var _printer: Printer = Printer.new('Signaling')

func set_local_user(local_user: LocalUser) -> void:
	_printer = local_user.get_printer('Signaling')

func join_room_async(user_id: String, room_id: String) -> int:
	var body = JSON.stringify({
		'action': 'join',
		'user_id': user_id,
		'room_id': room_id
	})
	var response = await _request_async(body)
	_complete_join_room(user_id, room_id, response)
	return OK

func update_ice_candidate_async(user_id: String, media: String, index :int, ice_name: String) -> void:
	var body = JSON.stringify({
		'action': 'update_ice',
		'user_id': user_id,
		'ice_candidate': {
			'media': media,
			'index': index,
			'ice_name': ice_name
		}
	})
	await _request_async(body)

func _request_async(body) -> Response:
	var req = ObjectPool.allocate_class(HTTPRequest)
	var headers = ["Content-Type: application/json"]
	_printer.p('request %s' % body)
	req.request(_signal_server, headers, HTTPClient.METHOD_POST, body)
	var result = await req.request_completed
	ObjectPool.recycle(req)
	return Response.new(result)

func _complete_join_room(user_id: String, room_id: String, resp: Response) -> bool:
	if resp.status != HTTPRequest.RESULT_SUCCESS:
		return false
	if resp.response_code != 200:
		return false
	var body_str = resp.body.get_string_from_utf8()
	_printer.p(body_str)
	var dict = JSON.parse_string(body_str) as Dictionary
	if dict == null:
		return false
	var err = dict.get('error')
	if err != null:
		_printer.err(err)
		return false

	var users_in_room = dict.get('users_in_room')
	if not users_in_room:
		_printer.err('no users in room')
		return false

	_room = Room.new()
	_room.room_id = room_id
	for user in users_in_room:
		var ret_user_id = user.get('user_id') as String
		var player_id = user.get('player_id')
		var user_in_room = User.new()
		user_in_room.user_id = ret_user_id
		user_in_room.player_id = player_id
		_room.users.append(user_in_room)

		if ret_user_id == user_id:
			_room.local_user = user_in_room

	return true

func get_local_user() -> Variant:
	if not _room or not _room.local_user: return null
	return _room.local_user

func get_all_remote_peers() -> Array[User]:
	return []

func get_room() -> Room:
	return _room
