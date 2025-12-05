class_name GanWorld
extends Node

enum Blocker {
	None = 0,
	Wall,
	Count
}

enum InnerItem {
	None = 0,
	Start,
	Exit,
	Treasure,
	Count
}

static func decode_blocker_action(action: int) -> Blocker:
	if action < 0 or action >= Blocker.Count:
		return Blocker.None
	return action as Blocker

static func decode_inner_item_action(action: int) -> InnerItem:
	if action < 0 or action >= InnerItem.Count:
		return InnerItem.None
	return action as InnerItem

static func encode_blocker(blocker: int) -> float:
	return float(blocker) / float(Blocker.Count - 1)

static func encode_inner_item(inner_item: int) -> float:
	return float(inner_item) / float(InnerItem.Count - 1)
