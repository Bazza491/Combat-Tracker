extends Resource
class_name CombatEncounter

@export var entities: Array[Entity] = []

#@export var 

@export_group("Visuals")

@export_flags(
	"HP Hidden:%s" % Flags.HP_HIDDEN,
	"a"
	) var flags: int = 0

enum Flags {
	HP_HIDDEN = 1,
	
}

@export var health_display: HealthDisplayMode = \
	HealthDisplayMode.PERCENT_FLOAT

enum HealthDisplayMode {
	BLOODIED_ONLY,
	PERCENT_INT,
	PERCENT_FLOAT,
}

## Adds multiple enemies that share base stats, numbering duplicates after the first.
func add_enemy(
	id: String,
	max_hp: int = 10,
	ac: int = 10,
	vulnerabilities: Dictionary[Damage.Type, Damage.Vulnerability] = {},
	quantity: int = 1
	) -> void:
	assert(not id.is_empty(), "Enemy id cannot be empty.")
	assert(max_hp > 0, "Enemy max_hp must be positive.")
	assert(quantity > 0, "Enemy quantity must be positive.")
	
	for index in quantity:
		var entity: Entity = Entity.new()
		entity.id = id
		entity.number = 0 if quantity == 1 or index == 0 else index + 1
		entity.max_hp = max_hp
		entity.current_hp = max_hp
		entity.ac = ac
		entity.vulnerabilities = vulnerabilities.duplicate()
		entities.append(entity)
	
	sort_by_label()

## Removes every combatant from this encounter without changing display preferences.
func clear_entities() -> void:
	entities.clear()

## Damages the combatant with the closest label and returns whether one was found.
func damage_closest_label(
	search_label: String,
	amount: int,
	type: Damage.Type = Damage.Type.NONE
	) -> bool:
	var target: Entity = find_closest_label(search_label)
	if target == null:
		return false
	
	target.damage(amount, type)
	return true

## Heals the combatant with the closest label and returns whether one was found.
func heal_closest_label(search_label: String, amount: int) -> bool:
	var target: Entity = find_closest_label(search_label)
	if target == null:
		return false
	
	target.heal(amount)
	return true


func sort_by_initiative() -> void:
	entities.sort_custom(
		func(a: Entity, b: Entity):
			return a.initiative < b.initiative
	)

func sort_by_label() -> void:
	entities.sort_custom(
		func(a: Entity, b: Entity):
			return a.get_label() < b.get_label()
	)

#func get_enemies() -> Array[Enemy]:
	#return entities.filter(
		#func(entity: Entity): 
			#return entity is Enemy
			#)

#func get_players() -> Array[Player]:
	#return entities.filter(
		#func(entity: Entity): 
			#return entity is Player
			#)

func find_label_or_null(search_label: String) -> Entity:
	for entity in entities:
		if entity.get_label() == search_label:
			return entity
	
	return null

## Returns the closest matching combatant by label, or null when the encounter is empty.
func find_closest_label(search_label: String) -> Entity:
	if entities.is_empty():
		return null
	
	var exact_match: Entity = find_label_or_null(search_label)
	if exact_match != null:
		return exact_match
	
	var labels: Array[String] = []
	for entity in entities:
		labels.append(entity.get_label())
	
	return find_label_or_null(Text.closest_match(labels, search_label))
