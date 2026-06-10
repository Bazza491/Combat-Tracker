extends GutTest

var closest_match_cases: Array[Dictionary] = [
	{"options": ["goblin", "skeleton", "boar"], "query": "gobln", "expected": "goblin"},
	{"options": ["gurdy", "gurby", "gursky"], "query": "gursk", "expected": "gursky"},
	{"options": ["Fire", "Lightning", "Slashing"], "query": "lightnng", "expected": "Lightning"},
]


func test_closest_match_returns_empty_string_when_no_options_exist() -> void:
	assert_eq(Text.closest_match([], "anything"), "", "No options should return an empty match.")

func test_closest_match_prefers_exact_match() -> void:
	assert_eq(
		Text.closest_match(["bat", "bat2", "bat3"], "bat2"),
		"bat2",
		"Exact matches should win over similar labels."
	)

func test_closest_match_returns_most_similar_option(p = use_parameters(closest_match_cases)) -> void:
	var options: Array[String] = []
	options.assign(p.options)
	assert_eq(Text.closest_match(options, p.query), p.expected, "Closest match should pick the best label.")
