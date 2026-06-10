extends Entity
class_name Player


## Applies player damage, falling unconscious at zero unless a single hit is lethal.
func damage(amount: int, type: Damage.Type) -> void:
	var remaining_hp: int = current_hp - get_damage_after_vulnerabilities(amount, type)
	set_hp(-max_hp if remaining_hp <= -max_hp else maxi(remaining_hp, 0))

func is_dead() -> bool:
	return current_hp <= -max_hp

func is_unconscious() -> bool:
	return current_hp == 0

func get_health_note() -> String:
	if is_dead():
		return "[Dead]"
	if is_unconscious():
		return "[Unconscious]"
	return super()
