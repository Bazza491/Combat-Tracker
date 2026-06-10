extends GutTest

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


func test_text_terminal_runs_deterministic_combat_flow() -> void:
	_submit("enemy goblin x2 12hp 13ac res fire vuln cold")
	_submit("enemy ogre 30hp 11ac")
	_submit("enemy skeleton 5hp")
	_submit("damage goblin 3 fire")
	_submit("damage goblin2 4")
	_submit("damage ogre 10")
	_submit("heal goblin2 2")
	_submit("damage goblin 8 cold")
	_submit("heal ogre 3")
	_submit("dmg skel 2")
	
	assert_eq(
		_snapshot(),
		[
			{
				"label": "goblin",
				"current_hp": 0,
				"max_hp": 12,
				"ac": 13,
				"vulnerabilities": {
					Damage.Type.FIRE: Damage.Vulnerability.RESISTANT,
					Damage.Type.COLD: Damage.Vulnerability.VULNERABLE,
				},
			},
			{
				"label": "goblin2",
				"current_hp": 10,
				"max_hp": 12,
				"ac": 13,
				"vulnerabilities": {
					Damage.Type.FIRE: Damage.Vulnerability.RESISTANT,
					Damage.Type.COLD: Damage.Vulnerability.VULNERABLE,
				},
			},
			{
				"label": "ogre",
				"current_hp": 23,
				"max_hp": 30,
				"ac": 11,
				"vulnerabilities": {},
			},
			{
				"label": "skeleton",
				"current_hp": 3,
				"max_hp": 5,
				"ac": 10,
				"vulnerabilities": {},
			},
		],
		"Terminal commands should leave the encounter in the exact expected state."
	)
	assert_eq(
		display.text_unformatted,
		"[bloodied]goblin[/bloodied] 0/12hp 13ac [Dead] [res: fire] [vuln: cold]\n" + \
		"goblin2 10/12hp 13ac [res: fire] [vuln: cold]\n" + \
		"ogre 23/30hp 11ac\n" + \
		"skeleton 3/5hp",
		"Terminal commands should render the expected encounter text."
	)
	assert_eq(terminal.text, "", "Terminal should be cleared after every submitted command.")
	assert_push_warning_count(0, "Normal combat flow should not emit warnings.")
	assert_push_error_count(0, "Normal combat flow should not emit push errors.")
	assert_engine_error_count(0, "Normal combat flow should not emit engine errors.")
	
	# TODO: Include player creation and player-targeting commands once the text terminal supports players.
	# TODO: Include initiative/turn commands once turn handling is implemented.
	# TODO: Include attack-roll command behavior against AC once attacks are implemented.
	# TODO: Include save/check commands once the terminal supports them.
	_submit("clear")
	assert_true(tracker.encounter.entities.is_empty(), "Clear should remove all combatants.")
	assert_eq(display.text_unformatted, TextTracker.EMPTY_ENCOUNTER_TEXT)


func _submit(input: String) -> void:
	terminal.text = input
	terminal.text_submitted.emit(input)

func _snapshot() -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for entity in tracker.encounter.entities:
		snapshot.append({
			"label": entity.get_label(),
			"current_hp": entity.current_hp,
			"max_hp": entity.max_hp,
			"ac": entity.ac,
			"vulnerabilities": entity.vulnerabilities,
		})
	return snapshot
