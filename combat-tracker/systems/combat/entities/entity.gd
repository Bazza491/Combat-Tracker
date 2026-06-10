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

## Applies damage after vulnerability modifiers, using this entity's hit point bounds.
func damage(amount: int, type: Damage.Type) -> void:
	set_hp(current_hp - get_damage_after_vulnerabilities(amount, type))

func heal(amount: int) -> void:
	set_hp(current_hp + amount)

func set_hp(value: int) -> void:
	var new_hp: int = clampi(value, get_min_hp(), max_hp)
	if new_hp == current_hp:
		# Don't emit the hp changed signal
		return
	
	current_hp = new_hp
	hp_changed.emit(current_hp, max_hp)

func get_min_hp() -> int:
	return -max_hp

func get_damage_after_vulnerabilities(amount: int, type: Damage.Type) -> int:
	return int(
		amount * Damage.vuln_multiplier(
			vulnerabilities.get(type, Damage.Vulnerability.NONE)
		)
	)


func get_hp_ratio(clamp_zero: bool = true) -> float:
	if max_hp <= 0 and clamp_zero:
		return 0.0
	return float(current_hp) / float(max_hp)

func is_bloodied() -> bool:
	return get_hp_ratio() <= 0.5

func is_dead() -> bool:
	return get_hp_ratio(false) <= 0.0


## Builds status and vulnerability notes for text displays.
func build_entity_notes() -> Array[String]:
	var built_notes: Array[String] = []
	var health_note: String = get_health_note()
	if not health_note.is_empty():
		built_notes.append(health_note)

	built_notes.append_array(build_vulnerability_notes())
	return built_notes

func get_health_note() -> String:
	if is_dead():
		return "[Dead]"
	if is_bloodied():
		return "[Bloodied]"
	return ""

func build_vulnerability_notes() -> Array[String]:
	var resistant_types: Array[String] = []
	var vulnerable_types: Array[String] = []

	for type in vulnerabilities:
		match vulnerabilities[type]:
			Damage.Vulnerability.RESISTANT:
				resistant_types.append(Damage.type_text(type).to_lower())
			Damage.Vulnerability.VULNERABLE:
				vulnerable_types.append(Damage.type_text(type).to_lower())

	var built_notes: Array[String] = []
	if not resistant_types.is_empty():
		built_notes.append("[res: %s]" % ", ".join(resistant_types))
	if not vulnerable_types.is_empty():
		built_notes.append("[vuln: %s]" % ", ".join(vulnerable_types))

	return built_notes


func get_label() -> String:
	if id.is_empty(): return str(number)
	if number == 0: return id
	
	return "%s%d" % [id, number]
