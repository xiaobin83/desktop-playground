class_name LocalUser

const USER_ID := &'user_id'

static func get_local_user_id() -> String:
	var id: String
	if not PlayerPref.has_key(USER_ID):
		id = OS.get_unique_id()
		PlayerPref.set_value(USER_ID, id)
	else:
		id = PlayerPref.get_value(USER_ID)
	return id