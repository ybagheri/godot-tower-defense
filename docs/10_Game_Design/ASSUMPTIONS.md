# Design Assumptions Log

Decisions inferred without an approved GDD (per Manifest hierarchy, specs rule;
this file records gaps until design documents land). Each entry lists the
spec that permits inference and the milestone that must revisit it.

| # | Assumption | Basis | Revisit when |
|---|------------|-------|--------------|
| A1 | Damage formula: PHYSICAL flat armor (min 1 chip), elemental percentage resistance (min 1), TRUE unmitigated; crit multiplies post-mitigation | SPEC-0006 damage rules prose | Combat GDD |
| A2 | EnemyDefinition carries no scene reference yet; factories build generic entities. Custom visual scenes attach during Vertical Slice (M5) | SPEC-0008 scene ref is optional wiring | Art pipeline |
| A3 | Flying targeting: towers have can_target_flying flag defaulting true until roster defines counter-play | SPEC-0007 priorities list only | Tower roster GDD |
| A4 | Balance numbers (goblin 10hp/100spd/5g etc.) exist ONLY inside tests as fixtures, not shipped content | SPEC-0001 forbids hardcoded gameplay values in code paths | First balance pass |
| A5 | ENEMY_DIED / ENEMY_REACHED_GOAL are produced by EnemyEventRelay translating engine-level ENTITY_DIED / ENTITY_REACHED_DESTINATION for tagged enemies | Keeps HealthComponent engine-pure (ARCH-0001 layering) | If hero/projectile deaths need distinct relays |
| A6 | Castle damage application is wired by the scene orchestrator (Milestone 4); LootComponent already carries per-enemy damage_to_castle | SPEC-0009 destination handling | Stage scene implementation |
