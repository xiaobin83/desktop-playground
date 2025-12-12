extends Node

var _peer: WebRTCPeerConnection
var _signaling: Signaling
var _user_id: String = ""
var _room_id: String = ""

func start_connection(user_id: String, room_id: String) -> void:
	_user_id = user_id
	_room_id = room_id

	_signaling = Signaling.new()

	_peer = WebRTCPeerConnection.new()
	_peer.ice_candidate_created.connect(_on_ice_candidate_created)
	_peer.initialize({
		"iceServers": [{"urls": ["stun:stun.l.google.com:19302"]}]
	})
	_signaling.join_room(_user_id, _room_id)

func _on_ice_candidate_created(media: String, index: int, ice_name: String) -> void:
	print(media, index, ice_name)
	# _signaling.update_ice_candidates(_user_id, [candidate])
