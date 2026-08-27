---
Document ID: PERF-0002
Title: Performance Measurement
Version: 1.1.0
Status: Approved
Owner: Engineering
Created: 2026-08-27
Last Updated: 2026-08-27
Dependencies:
  - PERF-0001 Performance Baseline
---

# Performance Measurement

## Environment of record

| Item | Value |
|------|-------|
| Engine | Godot 4.7.2.stable headless (rendering excluded) |
| Harness | `tools/stress_battle.tscn` (uncapped frame rate by default, see below) |
| Host CPU | Intel Xeon E5-2690 v4 @ 2.60 GHz, 2 vCPU |
| Host RAM | ~1 GB available |
| Date | 2026-08-27 |

## Measured results (frame rate UNCAPPED)

Sampling window after warmup; all numbers wall-clock per headless frame:

| Configuration | avg frame | worst frame | FPS equivalent |
|---------------|-----------|-------------|----------------|
| Empty battle floor | 6.93 ms | 8.82 ms | ~144 fps |
| 150 enemies / 15 towers | 6.87 ms | 6.94 ms | ~145 fps |
| 500 enemies / 30 towers | 6.89 ms | 6.94 ms | ~145 fps |

Interpretation: the ~6.9 ms is the headless main-loop **floor** on this host;
gameplay-logic contribution stays **below measurement resolution (<0.1 ms)
up to 500 entities**, reproducing PERF-0001 after the harness change below.

## Harness accuracy fix (2026-08-27)

The project setting `run/max_fps=60` (added in 0.8.0) also caps the HEADLESS
loop: runs made between 0.8.0 and this fix reported `avg_frame=16.67 ms`
regardless of load — pure pacing, not cost. `stress_battle.gd` now defaults
to `Engine.max_fps = 0` (uncapped) since it measures logic only; pass
`max_fps=<n>` to restore pacing semantics. CI's stress smoke gate greps
`RESULT avg_frame` and is unaffected.

```bash
godot --headless --path . res://tools/stress_battle.tscn -- enemy_count=500 tower_count=30 frames=400
```

## Limitations & not-yet-measured

- Headless excludes rendering entirely: GPU fill-rate / draw-call cost of the
  GL Compatibility renderer under real maps and effects is unknown.
- **NOT VERIFIED ON PHYSICAL ANDROID DEVICE** — device profiling (fps,
  thermals, battery) remains part of REL-0001's verification checklist.
- Projectile counts are engine-pooled (prewarmed + grown); per-frame projectile
  populations were not separately instrumented at measurement time.
