@tool
extends RichTextLabel
class_name EnemyDisplay

@export_multiline var text_unformatted: String = "Testing":
	set(value):
		text_unformatted = value
		refresh()

func refresh() -> void:
	text = "" # also clears tags?
	text_unformatted = text_unformatted.replace(
		"[bloodied]", "[bloodied]Bloodied[/bloodied]"
		)
	text = text_unformatted
