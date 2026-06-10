extends GutTest

var die_types: Array[Dice.Type] = [
	Dice.Type.D4,
	Dice.Type.D6,
	Dice.Type.D8,
	Dice.Type.D10,
	Dice.Type.D12,
	Dice.Type.D20,
]

var notation_range_cases: Array[Dictionary] = [
	{"notation": "1d1", "low": 1, "high": 1},
	{"notation": "2d1+3", "low": 5, "high": 5},
	{"notation": "3D1-2", "low": 1, "high": 1},
	{"notation": "1d6+2", "low": 3, "high": 8},
	{"notation": " 2d4 ", "low": 2, "high": 8},
]

var invalid_notation_cases: Array[String] = [
	"",
	"d6",
	"1d",
	"0d6",
	"1d0",
	"1d-6",
	"2d6x",
	"2 d6",
]


func test_flat_damage_roll_returns_zero() -> void:
	assert_eq(Dice.roll(Dice.Type.FLAT_DAMAGE), 0, "Flat damage should not roll random values.")

func test_die_rolls_stay_inside_die_bounds(p = use_parameters(die_types)) -> void:
	for _index in 20:
		assert_between(Dice.roll(p), 1, p, "Die rolls should stay inside the die range.")

func test_roll_notation_stays_inside_expected_bounds(p = use_parameters(notation_range_cases)) -> void:
	for _index in 20:
		assert_between(
			Dice.roll_notation(p.notation),
			p.low,
			p.high,
			"Dice notation should roll inside its possible total range."
		)

func test_invalid_roll_notation_returns_negative_one(p = use_parameters(invalid_notation_cases)) -> void:
	assert_eq(Dice.roll_notation(p), -1, "Invalid dice notation should fail with -1.")
