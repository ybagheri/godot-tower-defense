# Vertical Slice Stage Plan & Structure Norms (ratified)

Resolves DESIGN_GAPS G-07 (and locks prerequisites answered by G-06).
Status: Approved 2026-08-27. Data source of truth: resources/stages/*.tres
chained in resources/campaigns/campaign_001.tres.

## Stage set: 5 (matches roadmap example)

| # | Stage (.tres) | Map archetype | Routes | Waves |
|---|---------------|--------------|--------|-------|
| 1 | Test Range (existing) | straight angled road | 1 | 5 (intro pace) |
| 2 | Twin Roads (existing) | twin parallel lanes | 2 | ~8 |
| 3 | Ironwood Pass (new) | long switchback gauntlet | 1 long | 8 |
| 4 | Broken Crossroads (new) | two converging attack lanes | 2 converging | 8 |
| 5 | Warlords Gate (new) | short brutal finale road | 1 dense | 9 finale |

## Wave-count norm (G-07 answer)

- Intro stages may run 4-5 waves; all later VS stages carry 8 waves;
  finale may reach 9-10. Hard cap 10 in VS.
- Prep windows shrink mildly per wave (>= 5s floor). Boss waves carry
  a longer prep window than preceding waves.
- Converging lanes share castle gate proximity but use DISTINCT path ids;
  difficulty comes from PARALLEL timing, never shared ids.

## Progression linkage (per G-06, prerequisite satisfied)

Unlock policy: sequential; entry N unlocks when entry N-1 recorded >= 1
star. Star thresholds live in balance_default.tres (data-driven since the
G-06 resolution; see PROJ-0005 test coverage additions).

## Authoring rules

- New stages reuse the existing visual language ONLY (ColorRect ground,
  Line2D routes width 52, SpawnMarker squares, castle instance at route end)
  until art bible lands (G-12).
- Line2D points MUST equal path waypoints exactly (manual sync per A7 until
  the G-13 tool exists).
- Enemy mix obeys ENEMIES.md ladder rules; towers obey TOWERS.md bar.
