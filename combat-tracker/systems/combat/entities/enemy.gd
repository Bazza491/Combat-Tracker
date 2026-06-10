extends Entity
class_name Enemy


## Applies enemy damage without allowing hit points below zero.
func damage(amount: int, type: Damage.Type) -> void:
	set_hp(current_hp - get_damage_after_vulnerabilities(amount, type))

func get_min_hp() -> int:
	return 0
