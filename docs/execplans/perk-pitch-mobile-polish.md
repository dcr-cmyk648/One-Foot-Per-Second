# No Hitter Perk, Pitch, Story, and Mobile Polish — Execution Plan

## Status

M1 gameplay systems, M2 story/name/text data, and M3 interface work are accepted. Determination now fills 20% more slowly and grants a 15% stronger quality step; perk upgrades use a genuine seeded 20% board roll, serialize exact accumulated effects/history, and preserve protected rewards; human pitches now form Speed/Quality/Drag sidegrades applied to immutable release snapshots. M2 adds the Tee Ball mound premise, the once-only Little Timmy hat/equipment beat, and substantially broader deterministic name grammar. M3 adds concise effective equipment comparisons, a bounded scrolling phone detail body, exact perk percentage/upgrade rendering, immediate current-stat refresh, and rendered Story/Ball glyph cleanup. Accepted source commit `90603e2` is stamped as v0.19.0/save schema 31. The one canonical all-platform pipeline and Sites parity/build tests pass; exact generated artifacts are ready to commit and publish to the approved channels. The project-root `AGENTS.md` remains an untracked user-owned instruction file that must not be staged or modified.

## Goal

Make run choices legible, balanced, and replayable: Determination should charge more deliberately but culminate in a stronger payoff; extreme perk numbers must be both believable and visibly reflected in authoritative stats; human pitches should be interesting sidegrades; and owned perks should occasionally receive deterministic rarity-scaled upgrades. At the same time, remove noisy equipment comparisons and broken glyphs, make mobile detail surfaces reliably scrollable, broaden name generation again, and add the requested Tee Ball and Little Timmy story beats.

## Requirements ledger

### Gameplay and run choices

- [x] **Determination curve:** Compared with v0.18.0, ordinary outcome gains are 20% slower while each logarithmic quality step is 15% stronger. Preserve smooth decay, UI truthfulness, offline rules, and tap-fatigue behavior.
- [x] **Perk magnitude sanity:** Data-side audit keeps human Offline/Loot effects below 8% at the strongest tested rarity. UI uses ordinary adaptive percentage formatting, so 0.01 displays `+1%`, fractional upgrades remain distinct, and tiny nonzero effects use scientific notation.
- [x] **Visible perk effects:** Selecting or upgrading an Offline/Loot perk immediately refreshes the existing current-stat summary to the exact authoritative result; no locked future row is exposed.
- [x] **Human pitch sidegrades:** Human-league pitches now trade Quality/Speed against a pitch-specific air-Drag multiplier captured in immutable release snapshots. The ordinary set passes a non-dominance audit; alien/eldritch/boss pitches may remain objectively superior.
- [x] **Owned-perk upgrades:** Once the player owns eligible ordinary run perks, a deterministic random chance may replace at most one ordinary perk offer with an upgrade to an owned perk. The card is visibly labeled `UPGRADE`, names the perk, and shows exact before → after changes.
- [x] **Upgrade rarity:** Higher rarity scales the primary improvement; sufficiently rare upgrades may add one compatible secondary stat. Selecting it mutates the owned instance rather than adding a duplicate.
- [x] **Upgrade offer rules:** A seeded pseudorandom 20% board roll begins after three eligible perks; boss rewards and age/body cards are protected, at most one upgrade appears, and the completed offer is serialized reroll-proof.
- [x] **Upgrade save semantics:** Exact accumulated effects, rank, secondary effects, and history persist. Schema 31 migrates old run data and preserves the earned value of an in-progress Determination meter.

### Equipment and mobile interaction

- [x] **Concise comparisons:** Equipment comparison lists only stats whose normalized effective item value differs between candidate and equipped item. Item name, Power, rarity, slot, and equipped/candidate distinction remain visible.
- [x] **Scrollable mobile comparison:** The equipment comparison/detail surface uses a genuine bounded scrolling body at 390×844 and has in-frame geometry at 360×700; close and equip/trash actions remain outside the body. Long-press/list-scroll behavior remains intact.
- [x] **Reusable mobile detail contract:** `_bounded_detail_scroll` marks and constructs bounded detail bodies while titles and essential actions remain sibling controls; mobile tests enforce the structure and real overflow.

### Writing, names, and text integrity

- [x] **More names and titles:** Expand human, alien, and eldritch component pools, title forms, nickname grammar, initials, mononyms, multi-part names, and ordering patterns again. Preserve authored boss signatures and deterministic saves. At minimum double the ordinary theoretical combination space from v0.18.0 and demonstrate no adjacent duplicate in a representative deterministic sample.
- [x] **Tee Ball premise:** The first Tee Ball arrival explicitly says the player strides forward, knocks the pathetic tee to the ground, and takes the mound to show them real baseball. No copy suggests the player hits from the tee.
- [x] **Little Timmy equipment beat:** On the first authoritative Little Timmy defeat/equipment unlock, add a once-only Story beat built around `Wait… leave the hat.` It explains that Equipment/Loadout is now available after the dejected opponent leaves. Tie it to the actual first equipment acquisition, not merely opening a menu, and preserve migrated saves.
- [x] **Broken-glyph audit:** M2 removed the unsupported bullet separator from catalog/story data; M3 replaced the hard-coded Story metadata separator and Ball heading dash with reliable ASCII and asserts the rendered text. Newly added upgrade-card labels also use ASCII separators.
- [x] **Text-integrity regression:** `tests/story_name_audit.gd` rejects controls, U+FFFD, private-use code points, and the identified U+2022 separator throughout player-facing content data. M3 owns the remaining hard-coded UI strings.

## Constraints and non-goals

- Preserve the 100-level campaign, strikeout-only XP, five-level pitch-draft cadence, immutable released-ball snapshots, first-lifetime pacing anchors, and spoiler gating.
- Do not make Determination a click-spam dominant strategy; stronger peak value must be earned by the slower curve and existing diminishing returns.
- Do not silently clamp a perk after advertising a larger number. Generation, stored effect, derived stat, card copy, and Status must agree.
- Do not retroactively reroll or mutate serialized pending choices. New perk-upgrade choice types must round-trip exactly.
- Do not make human pitch tradeoffs depend on hidden future-layer stats. A card must show every changed axis and explain direction succinctly.
- Do not displace age progression, mandatory rewards, boss pitches, or story gates with a perk-upgrade offer.
- Do not solve mobile scrolling by making the whole game page vertically scroll during play. Scroll only the bounded overlay/detail body.
- Do not stage or modify the user-owned untracked `AGENTS.md`.
- Local Godot processes remain sequential because concurrent instances collide in shared engine state.
- No packaging/publication until implementation is accepted as one source revision. Existing standing approval covers only the established Pages, GitHub release/update assets, supported native/browser artifacts, and owner-only Sites channels.

## Repository state and initial decisions

- Base is clean v0.18.0 completion commit `ccbab50`, except for the user-owned untracked root `AGENTS.md`.
- Existing authoritative systems are concentrated in `scripts/game_state.gd`, `scripts/run_content.gd`, and `scripts/content.gd`; interface surfaces and mobile dialogs are in `scripts/main.gd`; story/name generation is split across campaign/run content and GameState.
- Perk upgrades are a new choice subtype, not a second upgrade catalog. The serialized option contains its target perk identity, exact delta(s), rarity, and resulting effect preview.
- Upgrade rarity may add a secondary stat only from a compatibility table owned by content data. It must never reveal or operate on a locked prestige stat.
- Human pitch sidegrades should prefer already-authoritative physical properties. Any schema extension uses neutral defaults so old learned pitches and saves remain valid.
- The equipment comparison filter operates on effective deltas after all affix/default normalization, not raw dictionary-key presence.
- Story copy follows `docs/writing/story-voice-seed.md` and shipped strings remain authored in code.
- M1 discovery: `main.gd::_run_effect_text` multiplies additive Offline/Loot values by 100 for percent and then calls `format_rating`, which multiplies by the global `DISPLAY_RATING_SCALE` again. M3 must format these as ordinary percentages; generation, storage, simulation getters, and stat totals are already correct.
- M2 records the Little Timmy beat only when the first kept career drop is earned against authoritative opponent 0; established equipment saves receive the durable story ID without a retroactive popup. First-career inventory is empty, so the forced hat is retained in normal play.
- M2 name generation adds three deterministic style families plus expanded components for every era. Representative human/alien/eldritch 512-name samples are deterministic, contain at least 200 unique names, and have no adjacent duplicate; the calculated ordinary space is at least twice the v0.18 baseline.
- M2 discovery: the data-side U+2022 separator was removed, but `scripts/main.gd` still contains rendered Story/Ball typography outside M2 ownership. M3 must replace and assert those exact UI strings rather than assuming a content-only scan covers the screen.
- M3 discovery: the apparent four-digit Offline/Loot bonuses were purely a display double-scaling bug. Stored effects and simulation math were already correct. Adaptive rendering now distinguishes `+1%` from `+1.25%` and preserves scientific notation for tiny nonzero values.
- M3 equipment detail uses normalized candidate/equipped affixes multiplied by current item-effectiveness for comparison rows; total-loadout caps remain explicitly disclosed because they apply after the swap rather than belonging to either item alone.

## Milestones

### M1 — Determination, perk upgrades, and pitch balance

- Discover and document the current Determination, perk magnitude/application, pitch schema, choice serialization, and stat-summary paths.
- Implement and migrate deterministic owned-perk upgrade choices with exact rarity-scaled effects and focused round-trip tests.
- Retune Determination and perk magnitude contracts; ensure Status/Loadout reflect selected effects.
- Extend/rebalance human pitch sidegrades with exact pros/cons and neutral compatibility defaults.
- Add focused gameplay/data/save tests and run only the relevant existing contract runner(s).

### M2 — Story, names, and glyph integrity

- Expand deterministic names/titles/grammar and quantify the expanded space/repetition behavior.
- Author the Tee Ball and Little Timmy equipment-unlock beats in the stored voice, with once-only/save migration semantics.
- Locate and replace unsupported characters in Story/Ball/player-facing content.
- Add story trigger, name, migration, and text-integrity regressions.

### M3 — Equipment comparison and mobile detail contract

- Filter equipment comparisons to effective differences.
- Rebuild the phone detail surface around a bounded scroll body with persistent close/action controls.
- Apply the reusable detail pattern/contract to the new perk-upgrade inspection if needed and audit sibling tall overlays for the same structural issue.
- Validate desktop hover and phone long-press parity at exact 390×844 plus one narrower supported width.

### M4 — Sol integration and synchronized release

- Review each accepted worker diff/evidence once; run only invalidated integration checks plus the required final release gate.
- Sanity-check first-human Determination, pitch choice diversity, perk magnitude ceilings, and upgrade-offer determinism.
- Stamp one new version before export, lock one accepted source revision, and run the canonical deterministic all-platform pipeline once.
- Reuse exact artifacts for GitHub Pages, GitHub release/update assets, native/browser downloads, and owner-only Sites; retry failed destinations only.

## Acceptance criteria

- Determination reaches the same landmarks more slowly under an identical tap sequence but has a measurably higher full-meter effect, with UI and authoritative math agreeing.
- Human Offline/Loot perk cards cannot advertise absurd four-digit percentage bonuses; selecting each tested perk changes its displayed and simulated stat by exactly the advertised amount.
- In a deterministic corpus, eligible boards produce serialized upgrade offers at the configured rate, never more than one, never displacing protected choices, and load to identical options/effects.
- At least the ordinary human pitch set forms real sidegrades: dominance tests find no normal human pitch that is greater-or-equal on every axis and strictly greater on one, after accounting for whether higher/lower is beneficial.
- Equipment comparisons omit unchanged stats and remain fully scrollable/closable on mobile.
- Name-space tests show at least 2× v0.18.0 ordinary combinations with no adjacent duplicates in the sampled sequence.
- Tee Ball and Little Timmy beats appear once at the authoritative moments and survive save/load without replay.
- Player-facing content passes the unsupported-character audit; Story and Ball surfaces contain no replacement/tofu glyph sources.
- One synchronized released revision reaches every previously approved channel without rebuilding successful artifacts per destination.

## Validation ladder

### Focused milestone evidence

- New deterministic perk-upgrade/pitch/Determination runner
- Existing choice/save and progression runner(s) only where affected
- New story/name/text-integrity runner or extension of the focused content audit
- `tests/ui_runner.gd -- --fresh` and `tests/mobile_ui_runner.gd -- --fresh` only for M3
- `git diff --check`

### Final accepted revision

- One justified integration smoke for cross-milestone choice rendering/save behavior
- Canonical all-platform release gate once after metadata stamping
- Exact Web/native/source artifact parity and approved destination verification

## Progress

- [x] Convert every Aug. 21 10:06 PM Bullet Journal note into a requirement.
- [x] Preserve the completed v0.18.0 release and identify the new phase boundary.
- [x] Complete and accept M1 through one Terra implementation worker.
- [x] Complete and accept M2 through one Terra implementation worker.
- [x] Complete and accept M3 through one Terra implementation worker plus one bounded precision correction.
- [ ] Complete M4 integration and synchronized release.

## Accepted milestone evidence

- M1: `tests/overhaul_runner.gd` PASS; deterministic upgrade-offer, Determination, immutable pitch, migration, and non-dominance contracts pass; `git diff --check` PASS.
- M2: `tests/story_name_audit.gd` PASS; `tests/overhaul_runner.gd` PASS; Little Timmy/save migration, authored Tee Ball copy, name-space, and text-integrity contracts pass.
- M3: desktop `tests/ui_runner.gd -- --fresh` PASS; mobile `tests/mobile_ui_runner.gd -- --fresh` PASS; Sol precision correction desktop UI rerun PASS; `git diff --check` PASS.
- Release metadata: project/native/distribution metadata and changelog are stamped to v0.19.0/save schema 31 before the first export. `stamp_sites_release.mjs` is intentionally deferred until the exact new Web PCK exists.

## M4 release record (in progress)

- Accepted gameplay source: `90603e2` (`Release No Hitter v0.19.0 source`)
- Version / save schema: `0.19.0` / `31`
- Canonical `scripts/package_all_platforms.sh` invocation: PASS; run exactly once
- Release gate: PASS (`test_runner`, desktop UI, 390×844 mobile UI, macOS Universal, Windows x86_64/ARM64, Linux x86_64/ARM64, Browser, binary/archive/DMG validation)
- Web parity and Sites adapter: PASS; all four rendered-response tests pass from the exact Web payload
- Web PCK / Sites fingerprint: `ed8a2f498dda45d1af9149de30ebe4ecfdf874ccc126c0f71e4d0eff4d22939b`
- Browser ZIP SHA-256: `5629749be9cd24d09c84688ebedaa55b0972ff9df1bf2cd5e62f3c36a7a977d7`
- All Platforms ZIP SHA-256: `da3f01b6ac95e59b005e550cd32f91326da4bddcec930e8e6e603a8f617e34f2`
- Generated artifact commit, Pages workflow, GitHub Release, and owner-only Sites deployment: pending

## Exact next action

Commit the generated v0.19.0 Web/Sites/checksum tree plus this release record (excluding user-owned `AGENTS.md`), push the resulting revision to `main` for Pages, publish the already-built GitHub Release assets, and save/deploy the already-tested `sites-host` payload privately. Record the aggregate results without rebuilding successful outputs.
