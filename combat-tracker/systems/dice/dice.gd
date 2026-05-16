extends Object
class_name Dice

enum Type {
	FLAT_DAMAGE,
	D4,
	D6,
	D8,
	D10,
	D12,
	D20
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
