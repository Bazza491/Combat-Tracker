"""
A Text based, command-line like combat tracker. 

DM-Facing, built for mouse-free, keyboard-only control so that
simple, quick commands like:
	dmg 1 20 psych
deals 20 psychic damage (accounting for resistances and 
vulnerabilities) to enemy "1". 

other command examples to set up:
	dmg 3 4d12+6 psych
		Will also roll damage
	mstr s2 255hp 20ac res psych thunder fire vuln light rad bludg
		Creates (and adds to list) monster name "s2", with 
		255 hp, 	20 armour class, resistance to psychic, thunder 
		and fire damage, and vulnerability to lightning radiant,
		and bludgeoning damage
		
		hp, ac, etc. are order agnostic, but command is always 
		first, then enemy name, then args
	clr
		clears all info
	turn george pete frauline rupert
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
"""
extends Control

@export var display_text: RichTextLabel
@export var line_edit: LineEdit

func _ready() -> void:
	pass
	# _clear_display()
	# _display_tutorial_text()
	# _connect_signals() 
		# including line_edit.text_submitted
