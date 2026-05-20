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
	var matching_entity: Entity = null
	for entity in entities:
		if entity.get_label() == search_label:
			matching_entity = entity
	
	return matching_entity

func find_closest_label(search_label: String) -> Entity:
	if entities.is_empty(): return null
	var closest_entity: Entity = null
	var dummy: Entity = Entity.new()
	dummy.id = search_label + "!"
	
	entities.append(dummy)
	sort_by_label()
	
	if entities.find(dummy) != 0:
		closest_entity = entities[entities.find(dummy) - 1]
	else:
		closest_entity = entities[1]
	
	entities.remove_at(entities.find(dummy))
	
	return closest_entity
