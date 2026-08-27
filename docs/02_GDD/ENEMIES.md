# Vertical Slice Enemy Roster & Difficulty Ladder (ratified)

Resolves DESIGN_GAPS G-04. Status: Approved 2026-08-27. Data source of
truth: resources/enemies/*.tres.

The VS ships EXACTLY four enemies. Ogre Warlord is the ONLY boss.

| Enemy (.tres) | Tier | Identity | First appearance |
|---------------|------|----------|------------------|
| Goblin (basic) | filler | baseline melee swarm | stage 1 wave 1 |
| Wisp (fast) | flyer | unarmored speed pressure | stage 1 wave 3 |
| Fallen Knight (elite) | wall | armored damage sponge | stage 1 wave 3 |
| Ogre Warlord | BOSS | castle-breaking climax unit | final wave of every stage (boss wave, escorted) |

Ladder rules frozen for VS:
1. Every stage contains ALL tiers before its finale; escorts around the
   ogre keep PRESSURE constant while he walks.
2. FLYING MIX NORM: by stage 3 onward wisps contribute >= 20% of non-boss
   spawns across the stage (counted per wave definition).
3. Difficulty escalates through COUNT and TIMING only (denser intervals,
   shorter initial delays, more parallel groups) - no stat inflation inside
   stages; between stages it may scale via .tres edits ONLY if a stage\'s
   baseline proves trivial, and such edits update resources/enemies/*.tres
   globally (never per-stage overrides).
4. Exactly ONE boss wave per stage (is_boss_wave=true).
