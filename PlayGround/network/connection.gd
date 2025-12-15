class_name Connection
extends Node

const DATA_CHANNEL := &'date_channel'
const DATA_CHANNEL_ID := 1

const DATA_CHANNEL_DESC := {
	'negotiated': true,
	'id': DATA_CHANNEL_ID
}

var _peer: WebRTCPeerConnection
var _ch: WebRTCDataChannel
var _multi_peer: WebRTCMultiplayerPeer
var _signaling: Signaling
var _user_id: String = ""
var _room_id: String = ""

var _printer: Printer = Printer.new('Connection')

func set_local_user(local_user: LocalUser) -> void:
	_printer = local_user.get_printer('Connection')
	_signaling = Signaling.new()
	_signaling.set_local_user(local_user)

func start_connection_async(user_id: String, room_id: String) -> bool:
	_user_id = user_id
	_room_id = room_id

	var err = await _signaling.join_room_async(_user_id, _room_id)
	if err != OK:
		return false

	var local_peer = WebRTCPeerConnection.new()
	local_peer.session_description_created.connect(_on_session_created.bind(local_peer))
	local_peer.ice_candidate_created.connect(_on_ice_candidate_created)
	local_peer.initialize({
		"iceServers": [{"urls": ["stun:stun.l.google.com:19302"]}]
	})
	var local_ch = local_peer.create_data_channel(DATA_CHANNEL, DATA_CHANNEL_DESC)

	var room = _signaling.get_room()
	if room.has_only_one_user():
		err = local_peer.create_offer()
		if err != OK:
			_printer.err('create_offer failed')
			return false

	var local_user = _signaling.get_local_user()
	if not local_user:
		_printer.err('incorrect local peer id')
		local_peer = null
		return false

	var local_peer_id = local_user.player_id
	var multi_peer = WebRTCMultiplayerPeer.new()
	multi_peer.create_mesh(local_peer_id)
	multi_peer.add_peer(local_peer, local_peer_id)

	for info in _signaling.get_all_remote_peers():
		var p = WebRTCPeerConnection.new()
		multi_peer.add_peer(p, info.peer_id)

	_peer = local_peer
	_ch = local_ch
	_multi_peer = multi_peer

	return true

func _process(_delta: float) -> void:
	if _peer: _peer.poll()

func _on_session_created(peer: WebRTCPeerConnection, type: String, sdp: String) -> void:
	_printer.p('_on_session_created', type, sdp)
	if type == 'offer':
		peer.set_local_description(type, sdp)
	else:
		peer.set_remote_description(type, sdp)

func _on_ice_candidate_created(media: String, index: int, ice_name: String) -> void:
	var local_user = _signaling.get_local_user()
	if not local_user:
		_printer.err('no local user when _on_ice_candidate_created')
	_signaling.update_ice_candidate_async(local_user.user_id, media, index, ice_name)
