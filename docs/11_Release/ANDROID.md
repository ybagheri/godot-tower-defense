---
Document ID: REL-0001
Title: Android Build Guide
Version: 1.0.0
Status: Approved
Owner: Release Engineering
Created: 2026-08-26
Last Updated: 2026-08-26
Dependencies:
  - PROJ-0002 Project Roadmap
Related ADR: None
Related RFC: None
---

# ANDROID Build Guide

## Current Status

`export_presets.cfg` ships two validated presets (**Android Debug**, **Android
Release**, arm64-v8a, sensor landscape, immersive mode). Preset parsing is
verified via headless Godot.

**APK builds are NOT VERIFIED in the development sandbox.** Missing, in order:

1. Export templates for the exact editor version.
2. Java JDK 17.
3. Android SDK (platform + build-tools; Godot uses `apksigner`/`zipalign`
   even for non-gradle exports).
4. A release keystore (never committed).

## One-time setup (maintainer machine)

```bash
# 1. Templates must match the editor version exactly:
#    download Godot_v<VERSION>-stable_export_templates.tpz from
#    https://github.com/godotengine/godot/releases and install:
mkdir -p ~/.local/share/godot/export_templates/<VERSION>.stable
unzip -j Godot_v<VERSION>-stable_export_templates.tpz \
    'templates/*' -d ~/.local/share/godot/export_templates/<VERSION>.stable/

# 2. JDK 17 + Android SDK (cmdline-tools -> platform-tools, platforms;android-34,
#    build-tools;34.0.0), then point Godot at them:
#    Editor > Editor Settings > Export > Android
```

## Building

```bash
godot --headless --path . --export-debug "Android Debug" exports/godottd-debug.apk
godot --headless --path . --export-release "Android Release" exports/godottd-release.apk
```

Release requires keystore credentials configured in the preset or environment;
`export_credentials.cfg` stays git-ignored.

## Verification checklist per §31

- [ ] project imports cleanly (verified headless)
- [ ] scenes load / gameplay starts (verified desktop-headless)
- [ ] touch input works (device)
- [ ] save/load round-trips on device storage (`user://save/save_001.json`)
- [ ] audio plays through device buses
- [ ] performance acceptable on mid-range hardware (profiler)
- [ ] release export signs & installs

## Known mobile considerations already handled

- GL Compatibility renderer (widest low-end support)
- ETC2/ASTC VRAM compression enabled in project settings
- Touch emulation both directions enabled
- Landscape sensor orientation, immersive mode
- Voice caps + throttled SFX; pooled effects/text; no per-frame allocations
  in hot paths
