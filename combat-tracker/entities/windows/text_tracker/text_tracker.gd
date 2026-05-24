"""
A Text based, command-line like combat tracker. 

DM-Facing, built for mouse-free, keyboard-only control so that
simple, quick commands like:
	dmg 1 20 psych
deals 20 psychic damage (accounting for resistances and 
vulnerabilities) to enemy "1". (damage type optional in command)

other command examples to set up:
	dmg 3 4d12+6 psych
		Will also roll damage
	enemy s2 255hp 20ac res psych thunder fire vuln light rad bludg
		Creates (and adds to list) enemy with label "s2", with 
		255 hp, 20 armour class, resistance to psychic, thunder 
		and fire damage, and vulnerability to lightning radiant,
		and bludgeoning damage
		
		hp, ac, etc. are order agnostic, but command is always 
		first, then enemy name, then args
	enemy bat x6 40hp
		creates 6 bats (labels bat, bat2, bat3, etc.) with 40hp but all 
		unspecified stats are defaulted
	clr
		clears all info and resets the combat encounter to empty (without 
		changing preferences/flags)
	turns george pete frauline rupert
		sets the turn order widget to the above list of names 
		(no/default initiative count)
	turn george 20
		adds george to the turn order widget at initiative 20
	turn 15
		skips to the next person at or after initiative 15 in the
		turn order widget

Add aliases for all commands and arguments
	eg. clr/clear/c, turn/turns/trn, dmg/damage, psych/psychic, etc.
As well as fuzzy searching for monster/player names, defaulting to lowest 
option in alphabetical order
	use/make some generic:
	var string := TextProcessing.fuzzy_search(
		query: String, 
		options: Array[String]
		)
	instead of this, for now, use the current solution of adding the query to 
	the options array, sorting the options array alphabetically, then choosing
	the appropriate option before or after the search query in alphabetical 
	order
"""
extends Control
class_name TextTracker

@export var display_text: RichTextLabel
@export var terminal: LineEdit

var encounter: CombatEncounter = CombatEncounter.new()

@onready var command_handler = CommandHandler.new(encounter)

enum Command {
	NONE,
	DAMAGE,
	HEAL,
	ADD_ENEMY,
	CLEAR,
	SET_TURNS_LIST,
	ADD_PLAYER_AT_INITIATIVE,
	SKIP_TO_INITIATIVE
}


func _process_command(input: String) -> void:
	var args: Array[String] = input.strip_edges().split(" ", false)
	var command: Command = _pick_command(args)
	
	args.pop_front()
	command_handler.handle_command(command, args)
	
	terminal.clear()


func _ready() -> void:
	_clear_display()
	_display_tutorial_text()
	#_initialise_combat_encounter()
	_connect_signals() 
		# including terminal.text_submitted
	Text.test()


func _clear_display() -> void:
	display_text.text = ""
	_process_command("clear")


func _display_tutorial_text() -> void:
	display_text.text = \
	"""
	use command "enemy {name} x{amount} {hit points}hp" to get started
	damage enemies with "dmg {name} {amount}"
	"""


func _connect_signals() -> void:
	terminal.text_submitted.connect(_process_command)


func _pick_command(input: Array[String]) -> Command:
	return Command.NONE


func refresh() -> void:
	display_text.text = \
	"""
	bat 35hp [Grappled] [Prone]
	bat2 15hp [Bloodied] [Sapped]
	"""
