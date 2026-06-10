@tool
extends RichTextLabel
class_name EnemyDisplay

@export_multiline var text_unformatted: String = "Testing":
	set(value):
		text_unformatted = value


const KEYWORD_BBCODE: Dictionary[String, String] = {
	"Bloodied": "[bloodied]Bloodied[/bloodied]",
}


func refresh() -> void:
	text = _format_keyword_notes(text_unformatted)


func _format_keyword_notes(value: String) -> String:
	var formatted_text: String = value
	for keyword in KEYWORD_BBCODE:
		formatted_text = formatted_text.replace("[%s]" % keyword, KEYWORD_BBCODE[keyword])
	return formatted_text
