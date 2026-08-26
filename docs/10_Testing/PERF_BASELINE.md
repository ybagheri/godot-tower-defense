---
Document ID: PERF-0001
Title: Performance Baseline
Version: 1.0.0
Status: Approved
Owner: Engineering
Created: 2026-08-26
Last Updated: 2026-08-26
---

# Performance Baseline (logic)

Measured with `tools/stress_battle.tscn`, Godot 4.7.2 headless (rendering
excluded), sampling window after 30-frame warmup:

| Load | avg frame | worst frame |
|------|-----------|-------------|
| empty scene floor | 6.90 ms | 8.70 ms |
| 150 enemies / 15 towers | 6.92 ms | 7.39 ms |
| 300 enemies / 25 towers | 6.88 ms | 6.94 ms |
| 500 enemies / 30 towers | 6.90 ms | 9.25 ms |

## Findings

- The ~6.9 ms is the headless main-loop floor; gameplay logic contributes
  **below measurement resolution (<0.1 ms) up to 500 entities**.
- Targets of 100+ enemies/projectiles (README) have large logic headroom;
  the real mobile constraint will be GPU fill/draw cost, which must be
  profiled on hardware (REL-0001).
- Micro-optimizations deferred until a device profile shows need
  (e.g., FIRST-priority distance caching) - measure first (§23).

## Reproduce

```bash
godot --headless --path . res://tools/stress_battle.tscn -- enemy_count=300 tower_count=25 frames=400
```
