# Design Assumptions Log

Decisions inferred without an approved GDD (per Manifest hierarchy, specs rule;
this file records gaps until design documents land). Each entry lists the
spec that permits inference and the milestone that must revisit it.

| # | Assumption | Basis | Revisit when |
|---|------------|-------|--------------|
| A1 | Damage formula: PHYSICAL flat armor (min 1 chip), elemental percentage resistance (min 1), TRUE unmitigated; crit multiplies post-mitigation | SPEC-0006 damage rules prose | Combat GDD |
| A2 | Enemy/Tower definitions carry an optional cosmetic `visual_scene` (plain Node2D); combat components are ALWAYS factory-assembled. Deviates from SPEC wording "Scene Reference" deliberately to keep component ownership single-sourced | ARCH-0001 factory rules; SPEC-0008 scene ref optional | Vertical Slice (M5) art pass |
| A3 | Flying targeting: towers have can_target_flying flag defaulting true until roster defines counter-play | SPEC-0007 priorities list only | Tower roster GDD |
| A4 | Balance numbers live in shipped `.tres` content (`resources/`); test fixtures duplicate small values locally | SPEC-0001 forbids hardcoded gameplay values in code paths | First balance pass |
| A5 | ENEMY_DIED / ENEMY_REACHED_GOAL are produced by EnemyEventRelay translating engine-level ENTITY_DIED / ENTITY_REACHED_DESTINATION for tagged enemies | Keeps HealthComponent engine-pure (ARCH-0001 layering) | If hero/projectile deaths need distinct relays |
| A6 | CastleSystem converts arrivals into castle damage; BattleController decides defeat on CASTLE_DESTROYED and calls waves.fail_stage() | SPEC-0009 destination handling, SPEC-0013 game over | Stage scene implementation |
| A7 | Map visuals (Line2D route) and stage route waypoints are synchronized MANUALLY in M4; a path-drawing editor tool is the future fix | No tooling milestone yet | Editor tooling / level design doc |
| A8 | HUD binds via controller.bind_controller() because children become ready before parents; avoids fragile cross-instance NodePath exports | Godot scene lifecycle ordering | UI refactor if composition changes |
