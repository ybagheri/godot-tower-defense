---
Document ID: SPEC-0016
Title: Stage Path Catalog Specification
Version: 1.0.0
Status: Approved
Owner: Game Architecture
Created: 2026-08-28
Last Updated: 2026-08-28
Dependencies:
  - PROJ-0001 Project Manifest
  - ARCH-0001 Architecture Overview
  - SPEC-0001 Resource System
  - SPEC-0005 Wave System
  - SPEC-0009 Path System
Related ADR:
  - ADR-0001 Repository Structure
Related RFC:
  - None
---

# SPEC-0016: Stage Path Catalog

# Purpose

This document defines where enemy route data lives and how a stage's visual
map is bound to it, for the **godot-tower-defense** framework.

Before this specification, every stage `.tres` embedded its
`PathDefinition` routes as inline sub-resources and each map scene's
`Line2D` nodes were synchronized to those waypoints by hand. Route data was
duplicated between stage resource and map scene with nothing detecting drift.

This specification externalizes routes into a shared file catalog and turns
the map binding into a validated contract.

---

# Route Catalog

- All shipped `PathDefinition` resources live as external `.tres` files under
  `res://resources/paths/`, one file per route.
- The file name equals the route id (`stage003.main.tres` holds route
  `stage003.main`).
- A `StageDefinition.paths` catalog maps route key -> external
  `PathDefinition` resource via `ExtResource`. Routes are never embedded as
  sub-resources anymore.
- Spawn groups reference routes by catalog key through `path_id`
  (unchanged from SPEC-0009).

---

# Map Binding Contract

Each map scene visualizes the routes of exactly one stage:

1. Every `Line2D` node in a shipped map carries a `route_id` metadata entry
   (`metadata/route_id`) holding its catalog key.
2. The set of `route_id` metas in a map covers the stage's path catalog
   exactly once per key - no missing, no duplicate, no unknown keys.
3. A `Line2D`'s `points` must equal the waypoints of the route its meta
   names.

Pairing is proven by exact waypoint equality; a mismatch is a build error,
not a warning.

---

# Enforcement

Invariants are enforced by `tests/unit/content_validation_test.gd`:

- `test_route_catalogs_are_external_resources` - every stage route resolves
  an external resource under `res://resources/paths/` whose id equals its
  catalog key.
- `test_map_line2ds_match_route_catalog_via_route_id_meta` - meta coverage,
  uniqueness, and waypoint equality across all five shipped stages.

The one-shot migration that produced this layout is kept as a record in
`tools/migrate_stage_paths_to_files.gd` (executed 2026-08-27, exit
`MIGRATION DONE failures=0`). It is not part of any pipeline; authoring new
stages follows the contract directly.

---

# Workflow for New Stages

1. Author the route as `resources/paths/<route_id>.tres` with
   `id == <route_id>`.
2. Reference it from the stage `.tres` via `ExtResource` in `paths`.
3. Draw the route in the map scene with a `Line2D` whose `points` equal the
   waypoints, and stamp `metadata/route_id = "<route_id>"`.
4. The content validation suite rejects any drift at CI time.

This retires the manual-sync assumption recorded as A7: the editor tool is
no longer the fix for drift, the validation suite is.
