extends Object
class_name Damage

enum Type {
	NONE,
	ACID,
	BLUDGEONING,
	COLD,
	FIRE,
	FORCE,
	LIGHTNING,
	NECROTIC,
	PIERCING,
	POISON,
	PSYCHIC,
	RADIANT,
	SLASHING,
	THUNDER
}

enum Vulnerability {
	NONE = 2,
	VULNERABLE = 4,
	RESISTANT = 1
}

const TYPE_TEXT := {
	Type.NONE: "None",
	Type.ACID: "Acid",
	Type.BLUDGEONING: "Bludgeoning",
	Type.COLD: "Cold",
	Type.FIRE: "Fire",
	Type.FORCE: "Force",
	Type.LIGHTNING: "Lightning",
	Type.NECROTIC: "Necrotic",
	Type.PIERCING: "Piercing",
	Type.POISON: "Poison",
	Type.PSYCHIC: "Psychic",
	Type.RADIANT: "Radiant",
	Type.SLASHING: "Slashing",
	Type.THUNDER: "Thunder",
}

const TEXT_TYPE := {
	"None": Type.NONE,
	"Acid": Type.ACID,
	"Bludgeoning": Type.BLUDGEONING,
	"Cold": Type.COLD,
	"Fire": Type.FIRE,
	"Force": Type.FORCE,
	"Lightning": Type.LIGHTNING,
	"Necrotic": Type.NECROTIC,
	"Piercing": Type.PIERCING,
	"Poison": Type.POISON,
	"Psychic": Type.PSYCHIC,
	"Radiant": Type.RADIANT,
	"Slashing": Type.SLASHING,
	"Thunder": Type.THUNDER,
}

const DAMAGE_TYPE_COLOR := {
	Type.ACID: Color("#7FFF00"),         # bright toxic green
	Type.BLUDGEONING: Color("#8B6F47"), # earthy brown
	Type.COLD: Color("#7FDBFF"),         # icy blue
	Type.FIRE: Color("#FF5A36"),         # orange-red
	Type.FORCE: Color("#C080FF"),        # arcane purple
	Type.LIGHTNING: Color("#FFE14A"),    # electric yellow
	Type.NECROTIC: Color("#4B4453"),     # dark desaturated purple
	Type.PIERCING: Color("db0b0bff"),     # steel grey
	Type.POISON: Color("#6BDB3F"),       # venom green
	Type.PSYCHIC: Color("#FF4FD8"),      # vivid magenta
	Type.RADIANT: Color("#FFF4A3"),      # holy pale gold
	Type.SLASHING: Color("#D64545"),     # blood red
	Type.THUNDER: Color("#5DA9FF"),      # storm blue
}

static func vuln_multiplier(vulnerability: Vulnerability) -> float:
	return vulnerability/2.0

static func type_text(type: Type) -> String:
	return TYPE_TEXT.get(type, "None")

static func type_from_text(text: String) -> Type:
	var type_names: Array[String] = []
	type_names.assign(TEXT_TYPE.keys())
	return TEXT_TYPE.get(Text.closest_match(type_names, text), Type.NONE)
