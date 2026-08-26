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

**CI builds the debug APK automatically.** Every push to `main` runs
`.github/workflows/ci.yml` on GitHub's runners (which have the disk, JDK 17
and Android SDK this sandbox lacks):

1. `test` job: headless import + full script compile check + 150+ unit/
   integration tests + a logic stress smoke gate.
2. `android-debug-apk` job: installs Godot, extracts **only** the two
   Android template APKs from the official pack (~90 MB of the 1.28 GB
   tpz), generates a throwaway debug keystore, and exports
   `godottd-debug.apk`.

**Fetch your APK:** repository on GitHub → *Actions* → latest
successful run → artifact **godottd-debug-apk**.

### Current CI state (2026-08-26)

- ✅ `test` job green on GitHub runners (import, compile check, 150+
  tests, stress smoke).
- ✅ Android job installs Godot, templates (from the `ci-assets` branch —
  the official 1.28 GB tpz is unreachable/throttled from runners),
  JDK 17, Android SDK, build-tools 34, and a throwaway debug keystore.
- ❌ The final `--export-debug` invocation fails; cause not yet read —
  **open the failed run → artifact `android-export-diagnostics`**
  (~1 KB text: env, editor settings, template listing, full Godot log)
  and check the job summary pane. Two likely culprits, in order:
  1. Editor-settings keys need adjusting to what the log says verbatim
     (`export/android/*` in
     `~/.config/godot/editor_settings-<version>.tres`, written by the
     workflow).
  2. `apksigner` resolution inside `$ANDROID_HOME/build-tools/<ver>`.

Release-signed builds additionally require keystore secrets via GitHub
*Settings → Secrets*, wired into a release job — intentionally not
configured yet; never commit keystores.

Local verification status in THIS sandbox: preset parsing verified;
templates/JDK/SDK absent so APK remains NOT VERIFIED here — that is now
covered server-side instead.

Logic-side performance headroom is proven separately (see
`docs/10_Testing/PERF_BASELINE.md`): gameplay logic stays under 0.1 ms per
frame at 500 entities; device GPU profiling is the remaining unknown.

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
