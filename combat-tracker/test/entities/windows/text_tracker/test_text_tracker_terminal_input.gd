extends GutTest

const FUZZ_ITERATIONS: int = 40
const FUZZ_SEED: int = 421337
const COMMAND_TOKENS: Array[String] = [
	"",
	" ",
	"enemy",
	"add",
	"create",
	"dmg",
	"damage",
	"heal",
	"clear",
	"clr",
	"turn",
	"trn",
	"goblin",
	"skeleton",
	"boar",
	"lightnng",
	"slash",
	"fire",
	"res",
	"vuln",
	"x0",
	"x1",
	"x3",
	"x-2",
	"0hp",
	"1hp",
	"12hp",
	"-5hp",
	"10ac",
	"-1ac",
	"0",
	"1",
	"-3",
	"2d6",
	"0d6",
	"999999",
	"???",
	"[]",
	"[bloodied]",
]

var tracker: TextTracker
var display: EnemyDisplay
var terminal: LineEdit


func before_each() -> void:
	display = autofree(EnemyDisplay.new())
	terminal = autofree(LineEdit.new())
	tracker = TextTracker.new()
	tracker.display_text = display
	tracker.terminal = terminal
	add_child_autofree(tracker)


func test_fuzzed_terminal_input_does_not_create_invalid_encounter_state() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = FUZZ_SEED
	
	for input in _build_fuzz_inputs(rng):
		_submit_terminal_input(input)
		_assert_encounter_is_valid_after(input)
		assert_eq(terminal.text, "", "Terminal should be cleared after input '%s'." % input)
	
	assert_push_error_count(0, "Fuzzed terminal input should not produce push errors.")
	assert_engine_error_count(0, "Fuzzed terminal input should not produce engine errors.")


func _build_fuzz_inputs(rng: RandomNumberGenerator) -> Array[String]:
	var inputs: Array[String] = [
		"enemy goblin 0hp",
		"enemy goblin -5hp",
		"enemy goblin x0",
		"enemy goblin x-2",
		"enemy goblin x2 5hp res fire vuln cold",
		"dmg goblin 2d6 fire",
		"heal goblin -3",
		"turn 10",
		"clear",
	]
	
	for _index in FUZZ_ITERATIONS:
		var parts: Array[String] = []
		for _part_index in rng.randi_range(0, 6):
			parts.append(COMMAND_TOKENS[rng.randi_range(0, COMMAND_TOKENS.size() - 1)])
		inputs.append(" ".join(parts))
	
	return inputs

func _submit_terminal_input(input: String) -> void:
	terminal.text = input
	terminal.text_submitted.emit(input)

func _assert_encounter_is_valid_after(input: String) -> void:
	for entity in tracker.encounter.entities:
		assert_false(entity.get_label().is_empty(), "Input '%s' should not create an empty label." % input)
		assert_gt(entity.max_hp, 0, "Input '%s' should not create nonpositive max HP." % input)
		assert_between(
			entity.current_hp,
			entity.get_min_hp(),
			entity.max_hp,
			"Input '%s' should keep current HP inside entity bounds." % input
		)
