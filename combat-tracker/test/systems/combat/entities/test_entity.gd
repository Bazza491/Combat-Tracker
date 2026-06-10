extends GutTest


func test_entity_damage_and_healing_respect_hp_bounds_and_vulnerabilities() -> void:
	var entity: Entity = Entity.new()
	entity.max_hp = 10
	entity.current_hp = 10
	entity.vulnerabilities = {Damage.Type.FIRE: Damage.Vulnerability.VULNERABLE}
	
	entity.damage(3, Damage.Type.FIRE)
	entity.heal(20)
	entity.damage(30, Damage.Type.NONE)
	
	assert_eq(entity.current_hp, -10, "Base entities should clamp HP between -max_hp and max_hp.")
	assert_eq(entity.get_damage_after_vulnerabilities(3, Damage.Type.FIRE), 6)

func test_enemy_damage_clamps_at_zero_hp() -> void:
	var enemy: Enemy = Enemy.new()
	enemy.max_hp = 10
	enemy.current_hp = 10
	
	enemy.damage(999, Damage.Type.NONE)
	
	assert_eq(enemy.current_hp, 0, "Enemy HP should not fall below zero.")
	assert_true(enemy.is_dead(), "Enemies at zero HP should be dead.")

func test_player_damage_distinguishes_unconscious_and_lethal_hits() -> void:
	var player: Player = Player.new()
	player.max_hp = 10
	player.current_hp = 7
	
	player.damage(8, Damage.Type.NONE)
	assert_eq(player.current_hp, 0, "Nonlethal player damage should stop at unconscious.")
	assert_true(player.is_unconscious(), "Zero HP players should be unconscious.")
	assert_false(player.is_dead(), "Unconscious players should not be dead.")
	
	player.current_hp = 7
	player.damage(17, Damage.Type.NONE)
	assert_eq(player.current_hp, -10, "Lethal player damage should fall to negative max HP.")
	assert_true(player.is_dead(), "Lethal damage should mark the player dead.")

func test_set_hp_emits_only_when_hp_changes() -> void:
	var entity: Entity = Entity.new()
	entity.max_hp = 10
	entity.current_hp = 10
	watch_signals(entity)
	
	entity.set_hp(10)
	entity.set_hp(6)
	
	assert_signal_emit_count(entity, "hp_changed", 1)
	assert_eq(entity.current_hp, 6, "set_hp should update current HP when the clamped value changes.")

func test_entity_notes_include_health_and_vulnerability_notes() -> void:
	var entity: Entity = Entity.new()
	entity.max_hp = 10
	entity.current_hp = 5
	entity.vulnerabilities = {
		Damage.Type.FIRE: Damage.Vulnerability.RESISTANT,
		Damage.Type.COLD: Damage.Vulnerability.VULNERABLE,
	}
	
	assert_has(entity.build_entity_notes(), "[Bloodied]")
	assert_has(entity.build_entity_notes(), "[res: fire]")
	assert_has(entity.build_entity_notes(), "[vuln: cold]")

func test_entity_labels_use_id_and_duplicate_number() -> void:
	var entity: Entity = Entity.new()
	entity.number = 4
	assert_eq(entity.get_label(), "4", "Entities without ids should use their number as the label.")
	
	entity.id = "goblin"
	entity.number = 0
	assert_eq(entity.get_label(), "goblin", "Single entities should use their id as the label.")
	
	entity.number = 3
	assert_eq(entity.get_label(), "goblin3", "Numbered entities should append their number to their id.")
