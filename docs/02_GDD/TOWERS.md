# Vertical Slice Tower Roster (ratified)

Resolves DESIGN_GAPS G-03. Status: Approved 2026-08-27. Data source of truth:
resources/towers/*.tres (this file fixes SCOPE, .tres fixes NUMBERS).

The Vertical Slice ships EXACTLY three towers; no additions during VS.
Phase 4 candidates (frost-control tower pairing with the future
StatusEffect system) are noted, not promised.

| Tower (.tres) | Role | Damage identity | Upgrade fantasy |
|---------------|------|-----------------|-----------------|
| Archer Tower | cheap generalist opener | fast PHYSICAL, single target | rate-of-fire scaling |
| Arcane Spire | anti-heavy magic | MAGIC %, longer range | damage/pierce-through-resist emphasis |
| Bombard | area denial / armor cracker | heavy PHYSICAL slow reload, splash | radius + armor-cracking bursts |

Rules frozen for VS:
- Offering bar order fixed as above (HUD build buttons follow catalog order).
- can_target_flying defaults true until Phase 4 counter-play redesign (A3) -
  Bombard MAY be excluded from flying later ONLY via its own data toggle.
- Balance tuning happens exclusively inside .tres values (A4); this document
  forbids rebalancing base roles.
