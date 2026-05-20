extends Resource
class_name Entity

signal hp_changed(current_hp: int, max_hp: int)

@export var id: String = ""
@export var number: int = 0
@export var full_name: String = ""
@export var initiative: int = -1

@export var max_hp: int = 1
@export var current_hp: int = 1
@export var ac: int = 10
@export var vulnerabilities: \
	Dictionary[Damage.Type, Damage.Vulnerability] = {}

@export_multiline("write notes here...") var notes: String

func damage(amount: int) -> void:
	set_hp(current_hp - amount)

func heal(amount: int) -> void:
	set_hp(current_hp + amount)

func set_hp(value: int) -> void:
	var new_hp := clampi(value, -max_hp, max_hp)
	if new_hp == current_hp:
		# Don't emit the hp changed signal
		return
	
	current_hp = new_hp
	hp_changed.emit(current_hp, max_hp)


func get_hp_ratio(clamp_zero: bool = true) -> float:
	if max_hp <= 0 and clamp_zero:
		return 0.0
	return float(current_hp) / float(max_hp)

func is_bloodied() -> bool:
	return get_hp_ratio() <= 0.5


func get_label() -> String:
	if id.is_empty(): return str(number)
	if number == 0: return id
	
	return "%s%d" % [id, number]
