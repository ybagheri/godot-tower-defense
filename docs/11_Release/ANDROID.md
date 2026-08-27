---
Document ID: REL-0001
Title: Android Build Guide
Version: 1.0.2
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
  4. Template APKs were installed under a hyphenated release-tag
     directory (`export_templates/4.7.2-stable`), but Godot resolves
     templates ONLY at `export_templates/<major>.<minor>.<patch>.<status>`
     dot-separated (`4.7.2.stable`), so every export aborted instantly
     with "No export template found". Proven by an A/B reproduction
     against the identical Godot 4.7.2 binary: hyphen layout ->
     "No export template found at .../4.7.2.stable/android_debug.apk";
     dotted layout -> that class of error disappears entirely. The
     workflow now derives the dotted name from `$GODOT_VERSION` and
     asserts both reassembled template APKs are non-empty before export.
- 🧪 Pipeline hardening (2026-08-27): every input was proven correct by a
  full local reproduction of the CI export (JDK 17 + SDK build-tools 34 +
  throwaway keystore + dotted template dir → signed debug APK), yet GitHub
  runners killed Godot mid-`first_scan_filesystem` (~83 %) on three
  consecutive runs with no engine error text (exit=1). Mitigations now in
  `.github/workflows/ci.yml`: a persistent `.godot` import cache (collapses
  the flaky cold-scan window on warm runs) and a 3-attempt export loop
  with `--verbose` retries, per-attempt summaries, and per-attempt logs.
- ✅ **Pipeline PROVEN green (2026-08-27, run #16):** the hardened
  pipeline signed and uploaded a debug APK on export attempt #1 (warm
  `.godot` cache) as artifact `godottd-debug-apk` (~28 MB), with every
  input matching the local reproduction exactly (Temurin JDK 17.0.20,
  SDK `/usr/local/lib/android/sdk`, build-tools 34.0.0 incl. apksigner,
  dotted template dir `4.7.2.stable`, editor settings
  `editor_settings-4.7.tres`). The silent mid-scan runner kills stopped
  once the import cache removed the cold-scan window. On-device
  touch/install testing remains the final human gate.

Release-signed builds additionally require keystore secrets via GitHub
*Settings → Secrets*, wired into a release job — intentionally not
configured yet; never commit keystores.

Local verification status in THIS sandbox: preset parsing verified;
templates/JDK/SDK absent so APK remains NOT VERIFIED here — that is now
covered server-side instead.

Logic-side performance headroom is proven separately (see
`docs/10_Testing/PERF_BASELINE.md`): gameplay logic stays under 0.1 ms per
frame at 500 entities; device GPU profiling is the remaining unknown.

## Release signing (manual prerequisite - DO NOT run without real secrets)

The release-signing CI job exists but stays DISABLED until the maintainer
configures GitHub *Settings -> Secrets and variables -> Actions*:

| Name | Kind | Value |
|------|------|-------|
| `RELEASE_KEYSTORE_BASE64` | Secret | base64 of your upload keystore (.jks/.keystore) |
| `RELEASE_KEYSTORE_PASSWORD` | Secret | keystore password |
| `RELEASE_KEY_ALIAS` | Secret | key alias inside the keystore |
| `RELEASE_KEY_PASSWORD` | Secret | key password |
| `RELEASE_SIGNING_ENABLED` | **Repository VARIABLE** | set to `true` only when all three secrets above exist |

Never commit keystores or passwords; never flip the variable before the
secrets exist. Generate a keystore ONCE on trusted hardware with keytool
(see playbook below), back it up offline, then lose access intentionally.

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
