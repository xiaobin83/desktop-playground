class_name Connection
extends Node

const RELIABLE_DATA_CHANNEL := &'reliable_date_channel'
const RELIABLE_DATA_CHANNEL_ID := 1
const RELIABLE_DATA_CHANNEL_DESC := {
	'negotiated': true,
	'id': RELIABLE_DATA_CHANNEL_ID
}

var _multi_peer := WebRTCMultiplayerPeer.new()
var _signaling: Signaling

var _printer: Printer = Printer.new('Connection')

var _is_established := false
var is_established: bool :
	get: return _is_established

func set_local_user(local_user: LocalUser) -> void:
	_printer = local_user.get_printer('Connection')
	_signaling = Signaling.new()
	_signaling.set_local_user(local_user)
	add_child(_signaling)

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
	if _signaling.connection_type == Signaling.ConnectionType.Mesh:
		if _signaling.room.contains_only_local_user():
			var peer = WebRTCPeerConnection.new()
			peer.create_data_channel(RELIABLE_DATA_CHANNEL, RELIABLE_DATA_CHANNEL_DESC)
			_multi_peer.add_peer(peer, _signaling.room.local_user.player_id)
			peer.session_description_created.connect(_on_session_created.bind(_signaling.room.local_user.player_id))
			peer.ice_candidate_created.connect(_on_ice_candidate_created)
			peer.initialize({
				"iceServers": [{"urls": ["stun:stun.l.google.com:19302"]}]
			})
			err = peer.create_offer()
			if err != OK:
				_printer.err('create_offer failed')
				return false

		for user in _signaling.room.users:
			if user != _signaling.room.local_user:
				# create peer of others
				var peer = WebRTCPeerConnection.new()
				peer.create_data_channel(RELIABLE_DATA_CHANNEL, RELIABLE_DATA_CHANNEL_DESC)
				peer.session_description_created.connect(_on_session_created.bind(user.player_id))
				peer.set_remote_description('offer', user.sdp)
				for ice_candidate in user.ice_candidates:
					peer.add_ice_candidate(ice_candidate.media, ice_candidate.index, ice_candidate.name)

	get_tree().get_multiplayer().set_multiplayer_peer(_multi_peer)

	_is_established = true

	return true

func _on_session_created(type: String, sdp: String, player_id: int) -> void:
	_printer.p('_on_session_created', type, sdp)
	var peer = _multi_peer.get_peer(player_id)
	var connection = peer.connection
	connection.set_local_description(type, sdp)
	if type == 'offer':
		_signaling.send_sdp(sdp)

func _on_ice_candidate_created(media: String, index: int, ice_name: String) -> void:
	_signaling.send_ice_candidate(media, index, ice_name)
