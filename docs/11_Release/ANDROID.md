---
Document ID: REL-0001
Title: Android Build Guide
Version: 1.0.1
Status: Approved
Owner: Release Engineering
Created: 2026-08-26
Last Updated: 2026-08-27
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

### Current CI state (2026-08-27)

- ✅ `test` job green on GitHub runners (import, compile check, 156
  tests / 24 suites, stress smoke).
- ✅ Template delivery via the `ci-assets` branch verified end-to-end:
  chunks reassemble into valid template APKs (127 MB debug assembly
  passes archive integrity checks).
- 🔧 FIXED in `.github/workflows/ci.yml` — three defects that made CI red
  while every individual step looked healthy:
  1. Editor settings were written to a filename Godot never loads
     (`editor_settings-4.7.2-stable.tres`). Godot only reads
     `editor_settings-<major>.<minor>.tres` (engine binary format string
     `"editor_settings-%d.%d.tres"`; verified empirically), so
     `export/android/java_sdk_path` / `android_sdk_path` never reached
     the exporter. The workflow now derives major.minor from
     `godot --version`.
  2. The export step discarded Godot's exit code and never checked the
     APK, so a failed export surfaced confusingly at the artifact-upload
     step. The step now fails immediately on non-zero exit or missing
     APK, with the full log in the job summary and the
     `android-export-diagnostics` artifact (`export_log.txt`).
  3. A duplicated second `Upload APK artifact` step was removed, and the
     cleanup after template extraction now deletes only `assets/android`
     (a blanket `rm -rf assets` would have stripped audio/fonts/icons
     from the packaged PCK).
- ⏳ Remaining unknown: Gradle dependency fetch inside the runner-side
  export build. If anything further fails, the new gate prints the exact
  Godot/Gradle error at the export step instead of masking it.

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
