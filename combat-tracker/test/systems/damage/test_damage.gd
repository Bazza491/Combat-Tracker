extends GutTest

var vulnerability_cases: Array[Dictionary] = [
	{"vulnerability": Damage.Vulnerability.NONE, "expected": 1.0},
	{"vulnerability": Damage.Vulnerability.VULNERABLE, "expected": 2.0},
	{"vulnerability": Damage.Vulnerability.RESISTANT, "expected": 0.5},
]

var damage_type_cases: Array[Dictionary] = [
	{"text": "Fire", "expected": Damage.Type.FIRE},
	{"text": "lightnng", "expected": Damage.Type.LIGHTNING},
	{"text": "slash", "expected": Damage.Type.SLASHING},
]


func test_vulnerability_multiplier_matches_combat_math(p = use_parameters(vulnerability_cases)) -> void:
	assert_eq(
		Damage.vuln_multiplier(p.vulnerability),
		p.expected,
		"Damage vulnerability enum values should map to combat multipliers."
	)

func test_type_from_text_accepts_exact_and_close_damage_names(p = use_parameters(damage_type_cases)) -> void:
	assert_eq(
		Damage.type_from_text(p.text),
		p.expected,
		"Damage text lookup should return the closest supported damage type."
	)
