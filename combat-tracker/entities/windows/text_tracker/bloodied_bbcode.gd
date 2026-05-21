extends RichTextEffect
class_name RichTextBloodied

var bbcode = "bloodied"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Get parameters, or use the provided default value if missing.
	var hp_percent = char_fx.env.get("hp%", 0.5)
	
	var color: Color = Color(0.64, 0.064, 0.064, 1.0)
	
	#color = color.darkened(1 - hp_percent)
	
	char_fx.color = color
	
	return true
