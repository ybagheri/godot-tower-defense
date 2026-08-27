---
Document ID: ADR-0003
Title: Documentation Numbering Canonicalization
Version: 1.0.0
Status: Approved
Owner: Project Architecture
Created: 2026-08-27
Last Updated: 2026-08-27
Dependencies:
  - DOC-0000 Documentation Index
---

# ADR-0003: Documentation Numbering Canonicalization

## Status
Approved (2026-08-27)

## Context

docs/ carried duplicate number prefixes from unplanned growth:
- `10_Game_Design` vs `10_Testing`
- `11_AI` vs `11_Release`

Cross-references (CHANGELOG, REL-0001, INDEX, README) point at existing
paths, which previously deferred any fix.

## Decision

Canonical numbers after renumbering:

| Dir | Final # | Rationale |
|-----|---------|-----------|
| 00_Project .. 09_Level_Design | unchanged | tracked + cross-referenced |
| **10_Testing** | stays 10 | PERF docs referenced by REL-0001 |
| **11_Release** | stays 11 | REL paths referenced by CI comments |
| **12_Game_Design** | renamed FROM 10_Game_Design | breaks the 10 collision with the least-referenced dir |
| ~~11_AI~~ | REMOVED | empty placeholder, not git-tracked, never populated |

Number 03 intentionally remains RESERVED (future GameBible category per
original taxonomy); uniqueness is achieved without churning Specification
paths (04_Specifications stays put - most cross-referenced directory).

## Consequences

- Only live references were migrated; historical CHANGELOG entries keep
  their original paths as log records.
- Future categories must claim unused numbers via RFC or ADR first.
