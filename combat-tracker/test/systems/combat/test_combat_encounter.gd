extends GutTest

var encounter: CombatEncounter


func before_each() -> void:
	encounter = CombatEncounter.new()


func test_add_enemy_creates_numbered_duplicates_and_sorts_by_label() -> void:
	encounter.add_enemy("zombie", 8, 9)
	encounter.add_enemy("bat", 3, 12, {}, 3)
	
	assert_eq(_labels(), ["bat", "bat2", "bat3", "zombie"], "Enemies should be sorted by label.")
	assert_eq(encounter.entities[0].current_hp, 3, "Added enemies should start at max HP.")
	assert_eq(encounter.entities[0].ac, 12, "Added enemies should receive the configured AC.")

func test_add_enemy_duplicates_vulnerabilities_per_entity() -> void:
	encounter.add_enemy("imp", 10, 10, {Damage.Type.FIRE: Damage.Vulnerability.VULNERABLE}, 2)
	
	encounter.entities[0].vulnerabilities[Damage.Type.FIRE] = Damage.Vulnerability.RESISTANT
	
	assert_eq(
		encounter.entities[1].vulnerabilities[Damage.Type.FIRE],
		Damage.Vulnerability.VULNERABLE,
		"Duplicate enemies should not share the same vulnerabilities dictionary."
	)

func test_damage_and_heal_closest_label_mutate_matching_entity() -> void:
	encounter.add_enemy("goblin", 10)
	encounter.add_enemy("skeleton", 10)
	
	assert_true(encounter.damage_closest_label("gobln", 4), "Closest label damage should find a target.")
	assert_eq(encounter.find_label_or_null("goblin").current_hp, 6, "Damage should apply to the closest match.")
	assert_true(encounter.heal_closest_label("goblin", 3), "Closest label healing should find a target.")
	assert_eq(encounter.find_label_or_null("goblin").current_hp, 9, "Healing should restore target HP.")
	assert_eq(encounter.find_label_or_null("skeleton").current_hp, 10, "Other entities should not be changed.")

func test_damage_and_heal_return_false_when_encounter_is_empty() -> void:
	assert_false(encounter.damage_closest_label("nobody", 3), "Damage should report when no target exists.")
	assert_false(encounter.heal_closest_label("nobody", 3), "Healing should report when no target exists.")

func test_clear_entities_preserves_display_preferences() -> void:
	encounter.flags = CombatEncounter.Flags.HP_HIDDEN
	encounter.health_display = CombatEncounter.HealthDisplayMode.BLOODIED_ONLY
	encounter.add_enemy("goblin")
	
	encounter.clear_entities()
	
	assert_true(encounter.entities.is_empty(), "Clear should remove all entities.")
	assert_eq(encounter.flags, CombatEncounter.Flags.HP_HIDDEN, "Clear should preserve flags.")
	assert_eq(
		encounter.health_display,
		CombatEncounter.HealthDisplayMode.BLOODIED_ONLY,
		"Clear should preserve health display mode."
	)

func test_sort_by_initiative_orders_low_to_high() -> void:
	encounter.add_enemy("slow")
	encounter.add_enemy("fast")
	encounter.find_label_or_null("slow").initiative = 2
	encounter.find_label_or_null("fast").initiative = 8
	
	encounter.sort_by_initiative()
	
	assert_eq(_labels(), ["slow", "fast"], "Initiative sorting should use ascending initiative values.")

func test_find_label_returns_exact_match_before_closest_match() -> void:
	encounter.add_enemy("bat", 5, 10, {}, 3)
	
	assert_same(encounter.find_closest_label("bat2"), encounter.find_label_or_null("bat2"))


func _labels() -> Array[String]:
	var labels: Array[String] = []
	for entity in encounter.entities:
		labels.append(entity.get_label())
	return labels
