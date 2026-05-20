extends Resource
class_name CombatEncounter

@export var entities: Dictionary[String, Entity] = {}

@export var 

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
