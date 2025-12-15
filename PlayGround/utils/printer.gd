class_name Printer

var _tag: String

func _init(tag: String) -> void:
	_tag = tag

func p(...args) -> void:
	print(_tag, ' ', ' '.join(args))

func err(...args) -> void:
	printerr(_tag, ' ', ' '.join(args))
