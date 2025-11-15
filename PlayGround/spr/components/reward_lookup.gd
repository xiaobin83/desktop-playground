class_name RewardLookup
extends Node


const CONSUME = &'consume'
const PARTIAL_CONSUME = &'partial_consume'
const DISTANCE = &'distance'
const FUEL = &'fuel'
const LACKING_FUEL = &'lacking_fuel'
const HAS_FUEL = &'has_fuel'
const POSE = &'pose'

const GET_CLOSER = &'get_closer'
const GET_CLOSER_THRESHOLD = 0.10 # 10% improvement

const FORCE_ALIGNMENT = &'force_alignment'
const FORCE_ALIGNMENT_DECAY_RATE = 0.999

static var _rewards := {
	CONSUME: 3.0,
	PARTIAL_CONSUME: 1.0,
	DISTANCE: -0.001,
	LACKING_FUEL: -0.01,
	HAS_FUEL: 0.01,
	POSE: 1,
	GET_CLOSER: 0.1,
	FORCE_ALIGNMENT: 0.1,
}

static func get_force_alignment_decay_rate(level: int) -> float:
	return pow(FORCE_ALIGNMENT_DECAY_RATE, level)

static func get_reward(what: StringName) -> float:
	if what in _rewards:
		return _rewards[what]
	return 0.0

static func get_distance_reward(distance: float) -> float:
	return _rewards[DISTANCE] * distance

static func get_fuel_reward(critical_fuel: float, fuel: float) -> float:
	if fuel < critical_fuel:
		return _rewards[LACKING_FUEL] * (critical_fuel - fuel)
	else:
		return _rewards[HAS_FUEL]

static func get_pose_reward(rotation: float) -> float:
	var d = abs(rad_to_deg(rotation))
	if d < 90:
		return _rewards[POSE]
	return 0
