## Damage type catalog used across combat, definitions and abilities
## (SPEC-0006). Values are stable; never reorder — resources store ints.
class_name DamageTypes
extends Object

enum Type {
	PHYSICAL = 0,
	MAGIC = 1,
	FIRE = 2,
	ICE = 3,
	POISON = 4,
	TRUE = 5,
}
