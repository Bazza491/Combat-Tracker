extends Object
class_name Dice

enum Type {
	FLAT_DAMAGE = 0,
	D4 = 4,
	D6 = 6,
	D8 = 8,
	D10 = 10,
	D12 = 12,
	D20 = 20
}

const TYPE_TEXT := {
	Type.FLAT_DAMAGE: "Flat Damage",
	Type.D4: "D4",
	Type.D6: "D6",
	Type.D8: "D8",
	Type.D10: "D10",
	Type.D12: "D12",
	Type.D20: "D20"
}

const TYPE_TEXTURE: Dictionary[Type, Texture]= {
	Type.D4: preload("res://systems/dice/icons/128x128/D4.png"),
	Type.D6: preload("res://systems/dice/icons/128x128/D6.png"),
	Type.D8: preload("res://systems/dice/icons/128x128/D8.png"),
	Type.D10: preload("res://systems/dice/icons/128x128/D10.png"),
	Type.D12: preload("res://systems/dice/icons/128x128/D12.png"),
	Type.D20: preload("res://systems/dice/icons/128x128/D20.png"),
}

static func roll(die_type: Dice.Type) -> int:
	if die_type == Dice.Type.FLAT_DAMAGE: return 0
	
	return randi_range(1, die_type)


static func roll_notation(notation: String) -> int:
	var regex := RegEx.new()
	if regex.compile("^(\\d+)[dD](\\d+)([+-]\\d+)?$") != OK:
		return -1
	
	var regex_match := regex.search(notation.strip_edges())
	if regex_match == null:
		return -1
	
	var num_dice := int(regex_match.get_string(1))
	var die_size := int(regex_match.get_string(2))
	var modifier := 0
	if regex_match.get_string(3) != "":
		modifier = int(regex_match.get_string(3))
	
	if num_dice <= 0 or die_size <= 0:
		return -1
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var total := modifier
	for _i in num_dice:
		total += rng.randi_range(1, die_size)
	
	return total
