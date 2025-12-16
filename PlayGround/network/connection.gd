class_name Connection
extends Node

const DATA_CHANNEL := &'date_channel'
const DATA_CHANNEL_ID := 1

const DATA_CHANNEL_DESC := {
	'negotiated': true,
	'id': DATA_CHANNEL_ID
}

var _multi_peer := WebRTCMultiplayerPeer.new()
var _signaling: Signaling

var _printer: Printer = Printer.new('Connection')

func set_local_user(local_user: LocalUser) -> void:
	_printer = local_user.get_printer('Connection')
	_signaling = Signaling.new()
	_signaling.set_local_user(local_user)

func start_connection_async(user_id: String, room_id: String) -> bool:
	var err = await _signaling.join_room_async(user_id, room_id)
	if err != OK:
		return false

	if _signaling.connection_type == Signaling.ConnectionType.Mesh:
		_multi_peer.create_mesh(_signaling.room.local_user.player_id)
	elif _signaling.connection_type == Signaling.ConnectionType.Server:
		_multi_peer.create_server()
	elif _signaling.connection_type == Signaling.ConnectionType.Client:
		_multi_peer.create_client(_signaling.room.local_user.player_id)

	# connected
	var local_peer = WebRTCPeerConnection.new()
	local_peer.session_description_created.connect(_on_session_created)
	local_peer.ice_candidate_created.connect(_on_ice_candidate_created)
	local_peer.initialize({
		"iceServers": [{"urls": ["stun:stun.l.google.com:19302"]}]
	})
	var local_user = _signaling.room.local_user
	var local_peer_id = local_user.player_id
	_multi_peer.add_peer(local_peer, local_peer_id)

	local_peer.create_data_channel(DATA_CHANNEL, DATA_CHANNEL_DESC)

	if _signaling.connection_type == Signaling.ConnectionType.Mesh:
		if _signaling.room.local_user.actor == Signaling.Actor.Offerer:
			err = local_peer.create_offer()
			if err != OK:
				_printer.err('create_offer failed')
				return false




	get_tree().get_multiplayer().set_multiplayer_peer(_multi_peer)

	return true

func _process(delta: float) -> void:
	_signaling.poll(delta)

func _on_session_created(type: String, sdp: String) -> void:
	_printer.p('_on_session_created', type, sdp)
	var peer = _multi_peer.get_peer(_signaling.room.local_user.player_id)
	var connection = peer.connection
	if type == 'offer':
		connection.set_local_description(type, sdp)
	else:
		connection.set_remote_description(type, sdp)
	_signaling.send_offer_async(sdp)

func _on_ice_candidate_created(media: String, index: int, ice_name: String) -> void:
	_signaling.send_ice_candidate_async(media, index, ice_name)
