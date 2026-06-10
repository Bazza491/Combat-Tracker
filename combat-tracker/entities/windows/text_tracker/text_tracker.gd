extends Control
class_name TextTracker

enum Command {
	NONE,
	DAMAGE,
	HEAL,
	ADD_ENEMY,
	CLEAR,
	SET_TURNS_LIST,
	ADD_PLAYER_AT_INITIATIVE,
	SKIP_TO_INITIATIVE,
}

const TUTORIAL_TEXT: String = \
	"use command \"enemy {name} x{amount} {hit points}hp\" to get started\n" + \
	"damage enemies with \"dmg {name} {amount}\""
const EMPTY_ENCOUNTER_TEXT: String = "No entities in combat encounter."
const COMMAND_ALIASES: Dictionary = {
	"dmg": Command.DAMAGE,
	"damage": Command.DAMAGE,
	"heal": Command.HEAL,
	"enemy": Command.ADD_ENEMY,
	"add": Command.ADD_ENEMY,
	"create": Command.ADD_ENEMY,
	"clr": Command.CLEAR,
	"clear": Command.CLEAR,
	"c": Command.CLEAR,
	"turns": Command.SET_TURNS_LIST,
}

@export var display_text: RichTextLabel
@export var terminal: LineEdit

var encounter: CombatEncounter = CombatEncounter.new()

@onready var command_handler: CommandHandler = CommandHandler.new(encounter)


func _ready() -> void:
	_connect_signals()
	display_text.text = TUTORIAL_TEXT


func _connect_signals() -> void:
	terminal.text_submitted.connect(_process_command)


func _process_command(input: String) -> void:
	var args: Array[String] = _split_command_input(input)
	if args.is_empty():
		return
	
	command_handler.handle_command(_pick_command(args), args.slice(1))
	terminal.clear()
	refresh()

## Rebuilds the text display from the current combat encounter state.
func refresh() -> void:
	var lines: Array[String] = []
	for entity in encounter.entities:
		lines.append(_build_entity_line(entity))
	
	display_text.text = "\n".join(lines) if not lines.is_empty() else EMPTY_ENCOUNTER_TEXT


func _split_command_input(input: String) -> Array[String]:
	var args: Array[String] = []
	args.assign(input.strip_edges().split(" ", false))
	return args

func _pick_command(args: Array[String]) -> Command:
	if args[0].to_lower() == "turn" or args[0].to_lower() == "trn":
		return Command.SKIP_TO_INITIATIVE \
			if args.size() > 1 and args[1].is_valid_int() \
			else Command.ADD_PLAYER_AT_INITIATIVE
	
	return COMMAND_ALIASES.get(args[0].to_lower(), Command.NONE)


func _build_entity_line(entity: Entity) -> String:
	var notes: Array[String] = _build_entity_notes(entity)
	var line: String = "%s %d/%dhp" % [
		_build_entity_label_text(entity),
		entity.current_hp,
		entity.max_hp,
	]
	
	if entity.ac != 10:
		line += " %dac" % entity.ac
	if not notes.is_empty():
		line += " " + " ".join(notes)
	
	return line

func _build_entity_label_text(entity: Entity) -> String:
	return "[bloodied]%s[/bloodied]" % entity.get_label() \
		if entity.is_bloodied() \
		else entity.get_label()

func _build_entity_notes(entity: Entity) -> Array[String]:
	var notes: Array[String] = []
	if entity.is_dead():
		notes.append("[Dead]")
	elif entity.is_bloodied():
		notes.append("[Bloodied]")
	
	notes.append_array(_build_vulnerability_notes(entity))
	return notes

func _build_vulnerability_notes(entity: Entity) -> Array[String]:
	var resistant_types: Array[String] = []
	var vulnerable_types: Array[String] = []
	
	for type in entity.vulnerabilities:
		match entity.vulnerabilities[type]:
			Damage.Vulnerability.RESISTANT:
				resistant_types.append(_get_damage_type_display_name(type))
			Damage.Vulnerability.VULNERABLE:
				vulnerable_types.append(_get_damage_type_display_name(type))
	
	var notes: Array[String] = []
	if not resistant_types.is_empty():
		notes.append("[res: %s]" % ", ".join(resistant_types))
	if not vulnerable_types.is_empty():
		notes.append("[vuln: %s]" % ", ".join(vulnerable_types))
	
	return notes

func _get_damage_type_display_name(type: Damage.Type) -> String:
	return Damage.TYPE_TEXT.get(type, "None").to_lower()
