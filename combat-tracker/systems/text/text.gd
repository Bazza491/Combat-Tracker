class_name Text

const TEST: Array[String] = ["test", "gurdy", "test2", "gurby", "gursky", "test3"]

static func closest_match(options: Array[String], query: String) -> String:
	return options.reduce(reduce_closest_match.bind(query), "")

static func reduce_closest_match(accum: String, element: String, query: String) -> String:
	return element if element.similarity(query) > accum.similarity(query) else accum


static func test() -> void:
	const query = "gur"
	print("closest match = ", closest_match(TEST, query), " for query ", query)
