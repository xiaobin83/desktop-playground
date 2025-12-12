class_name Signaling
extends Node

@export var _signal_server : String = "http://localhost:9001"

func join_room(user_id: String, room_id: String) -> void:
	var join_room_req = HTTPRequest.new()
	join_room_req.request_completed.connect(_on_join_room_completed)
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"user_id": user_id,
		"room_id": room_id
	})
	join_room_req.request(_signal_server, headers, HTTPClient.METHOD_POST, body)

func update_ice_candidates(user_id: String, candidates: Array) -> void:
	var ice_req = HTTPRequest.new()
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"user_id": user_id,
		"candidates": candidates
	})
	ice_req.request(_signal_server + "/update_ice", headers, HTTPClient.METHOD_POST, body)

func _on_join_room_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	pass
