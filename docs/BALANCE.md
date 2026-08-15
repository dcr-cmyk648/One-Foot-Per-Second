# No Hitter — v0.15.2 Balance Audit

## Outcome

The complete campaign is long but finite, every prestige layer changes the strategy, and no tested stage requires loot or mathematically perfect gear. The deterministic no-loot runners currently reach:

| Milestone | Approximate active-production time |
|---|---:|
| Human baseball cleared | 11 h |
| Portal HELP becomes available | 11 h 5 m |
| Complete human development | 115 mph; 0.72 recoveries/s |
| First cosmic victory | 11 d 15 h |

These are deterministic open-game baselines with frequent optimal purchasing, every affordable body development, and strategically timed resets. A player who explores, attempts the toddler-only human clear, farms a favorite batter, or checks in less often will take longer. Automation reduces management after the first rebirth; offline progress simulates up to seven days but never makes an irreversible prestige choice or advances the first witnessed alien minute. Offline strikeout XP begins at 1% of the open-game payout and Scorebook Study approaches 75% with diminishing returns.

Automation is purchased as bounded capacity rather than an all-or-nothing skip. Each genetic Migratory Baseball Instinct rank licenses one of the 29 human destinations; each eldritch Interstellar Road-Trip Itinerary rank licenses one of the 10 alien destinations. Autonomic Coaching buys one independently chosen repeatable-stat license per rank, while the later Front Office purchases whole one-time catalogs only when their individual switches are enabled. No automation performs a prestige reset or bypasses an unwitnessed story gate.

The runner obeys the same human cadence as the field: one wind-up, one unresolved ball, full flight, impact, lineup change if needed, then the next wind-up. That is intentionally slower than a generic pitches-per-second spreadsheet and prevents hidden pitches from occurring while the visible ball or batter is unresolved.

## Why strikeout-only income works

The fresh Dead-Fish Lob has a **39.75%** Strike probability. Fouls can add strike one or two, Balls can produce a walk, and fair hits end the plate appearance. Solving the complete `(Strikes, Balls)` state machine gives an **11.841%** fresh strikeout probability per plate appearance. That is bad enough to sell the joke without making three Strikes feel like three independent one-in-four miracles.

The idle solver uses the same exact absorbing model at every level:

- a Foul advances the Strike count unless two Strikes are already present;
- a Ball advances the Ball count and a completed walk ends the batter like a Single;
- protected hits and two-strike Fouls are self-loops that consume pitches and time without erasing the count;
- an unprotected fair hit terminates the at-bat;
- a completed Strike count is the only XP-earning terminal state;
- post-human volleys can advance a count by more than one at impact.

XP remains strikeout-only, but every called Strike now banks one live-count share of that opponent's former strikeout mastery award. A normal three-Strike count still produces the same total mastery as before; receiving it incrementally means an unlucky early run always makes visible progress. Mastery also makes that exact matchup easier by `+0.12 quality × log₂(1 + mastery / requirement)`.

Frustration is based on bad results rather than elapsed time: Grand Slam `+12`, Home Run `+8`, Triple `+5`, Double `+3`, Single `+1`, Ball `+0.20`, Foul `+0.10`, and Strike `+0`. One authoritative volley contributes once even if it contains thousands of rendered balls. Its quality bonus is `+0.08 × log₂(1 + frustration / 4)`; a completed strikeout resets it. Closed-form offline play retains the expected bad-result tail after its final strikeout instead of multiplying severity by projectile count. Both adaptation curves are uncapped but logarithmic, so they smooth ugly runs without replacing upgrades or guaranteeing an immediate result.

The fully purchased audit profile reaches a 100% Strike result, and its 2,048-ball terminal volley exceeds Octathulhu's 61 live Strikes after compression. That final form is intentionally a victory lap. Earlier eldritch builds still have smaller volleys and imperfect odds, so they depend on count preservation: genetics guarantee saves on Singles, Doubles, and Triples; five clone ranks leave `0.60⁵ = 7.776%` ordinary-hit failure; portals apply a second independent save layer. Grand Slams remain unsavable at every stage.

## Counts, payout, and downtime

Human baseball keeps three Strikes and four Balls throughout. Alien counts climb from four to nine Strikes and eventually shrink to three Balls; eldritch counts climb through 12, 18, 28, 42, and 64 Strikes while the last two gods allow only two Balls. Genetic Strike compression affects only post-human opponents and can never reduce the requirement below three.

Only the final Strike pays. The opening bounty ramps by one base XP per opponent until it meets the normal five XP per unmodified required Strike:

| Opponent / base Strike count | Strikeout base XP |
|---|---:|
| Human level 1 | 5 |
| Human level 2 | 6 |
| Human level 5 | 9 |
| Human level 10 | 14 |
| Human level 11+ / 3 | 15 |
| Post-human / 4 | 20 |
| Post-human / 6 | 30 |
| Post-human / 9 | 45 |
| Post-human / 12 | 60 |
| Post-human / 18 | 90 |
| Post-human / 28 | 140 |
| Post-human / 42 | 210 |
| Post-human / 64 | 320 |

Compression retains the original payout. A six-Strike alien compressed to three still pays 30 base XP.

Every completed plate appearance includes a three-second lineup-change baseline. The outcome cards show only the additional delay:

| Terminal outcome | Added delay | Total fresh delay |
|---|---:|---:|
| Grand Slam | +9 s | 12 s |
| Home Run | +5 s | 8 s |
| Triple | +3 s | 6 s |
| Double | +2 s | 5 s |
| Single | +1 s | 4 s |
| Walk | +1 s | 4 s |
| Strikeout | +0 s | 3 s |

Fouls are not terminal. Lineup Hustle subtracts `0.15 s` per rank from the universal three-second baseline, down to 1.5 seconds. Shake It Off subtracts `0.05` per rank from the factor applied only to the added fair-hit delay, down to `×0.60`. Facility multipliers stack separately, and later Time Compression divides the completed downtime. Reliable pitching therefore earns the only payout and returns to an occupied plate sooner.

## Achievement income

The 109 achievements are deliberately modest individually and additive rather than multiplicative with one another:

```text
achievement XP multiplier = 1 + completed achievements × 0.01
```

Ten achievements therefore produce `×1.10`, fifty produce `×1.50`, and all 109 produce `×2.09`. The multiplier applies alongside ball, opponent, prestige, level-assigned range, mastery, and equipment factors and survives every prestige reset. The no-loot runner reaches the human boundary in roughly 11 hours and first cosmic victory in 11 days 15 hours. A hidden achievement provides no mechanical or narrative clue before its subject is encountered. **Past Your Bedtime** rewards completing human baseball without leaving the Toddler stage. **Puberty Has Entered the Bullpen** marks the Teenager body. **Wait… That’s Illegal** marks the first post-human pitch. The final No Hitter slot remains an extreme post-victory replay challenge rather than baseline progression: a God Prestige opens the attempt, any fair contact—including a saved hit—spoils it, and known prestige exhibitions pause before throwing so scripted story contact cannot make it impossible.

## Complete reset cadence

The current greedy no-loot audit uses 15 genetic and eldritch resets before its first cosmic victory. The exact sequence is not mandatory. Cube-root DNA rewards favor meaningful jumps rather than constant restarts, while Arcana's `0.60` exponent rewards accumulated DNA across several lifetimes before destroying a reality. Early DNA priorities are arms, simultaneous-ball capacity, count compression, fielding, speed/quality, then automation. Eldritch priorities are clones and portals for count survival, capacity and time layers for the visual salvo, velocity for the final gate, and quality/mastery for huge counts.

## Speed and rate calibration

- The first released pitch is exactly 1 ft/s and takes three real seconds to cross three feet.
- Pitch type then supplies a small speed range; the exact sampled speed is shown in the field and remains immutable in flight.
- Human development caps at 115 mph without equipment: a little beyond the fastest verified real pitch rather than twice it.
- Alien biology caps at Mach 12; the alien championship gate requires Mach 3.
- Eldritch bodies can reach exactly 1c; Octathulhu rejects anything slower.
- Fresh recovery is `0.25 pitches/s`: a four-second wind-up before flight.
- Human recovery approaches a combined `0.72/s` cap before equipment, or about 1.39 seconds of wind-up at the limit. Human play still permits only one unresolved pitch, so recovery starts after impact and travel time remains visible.

Human air drag is deterministic per released shell and range. Plate speed uses `v_plate=v_release×e^(−kd)` and physical travel integrates that deceleration exactly; the untouched opening Wiffle Ball uses zero drag to preserve the literal title joke. Purchased lightweight balls lose visibly more speed than regulation leather, while alien and eldritch vacuum fields use zero drag. Release speed, plate speed, drag coefficient, range, and duration are immutable once a ball leaves the hand.

Speed purchases stop at the current body's cap. The ordinary button says only `Base speed +0.75 ft/s`; the cap and its spoiler-light hint appear only after the player actually reaches it and tries to buy more.

## Cost and content cadence

The optional BODY catalog contains 12 sequential ages—Toddler, Preschooler, Grade-School Kid, Preteen, Young Teen, Teenager, Older Teen, Young Adult, Adult, Prime-Age Adult, Veteran Adult, and Regular Ol’ Guy. Costs run from 3 XP to 150B XP and arrive alongside the matching human leagues. Their individual speed multipliers stay between `×1.025` and `×1.04`; quality adds only `0.012–0.018`, recovery adds only `×1.006–1.015`, and visual size rises gradually from `×1.00` to `×1.32`.

Twelve optional BODY modifiers share that tab in paired build choices. Playground Conditioning and Cardio Basics begin the split; later pairs cover strength versus conditioning, Creatine versus mobility, Suspicious Vitamins versus professional nutrition, advanced strength versus altitude cardio, and Extremely Obvious Steroids versus professional rehab. They are one-time multiplicative purchases, not duplicate additive Training buttons. The opening 1 ft/s, 0.45-Quality, 0.25/s body remains a deliberately weak toddler. Body purchases do not raise the human cap, and skipping them remains a valid challenge route rather than a progression softlock.

Ordinary Training has one clear purchase per displayed base stat:

| Training | Unlock level | Effect per rank | Cost growth | Limit |
|---|---:|---|---:|---:|
| Speed Training | 1 | base speed +0.75 ft/s | ×1.18 | current body |
| Command Drills | 2 | base quality +0.018 | ×1.18 | none |
| Field Hustle | 3 | remaining gap to 4% ×0.92 | ×1.62 | none |
| Recovery Drills | 4 | remaining gap to 0.48/s ×0.90 | ×1.42 | none |
| Scorebook Study | 5 | remaining gap to 75% ×0.94 | ×1.55 | none |
| Long-Toss Mechanics | 6 | remaining distance threat ×0.94 | ×1.58 | none |
| Lineup Hustle | 8 | remaining gap to 1.25s ×0.90 | ×1.82 | none |
| Shake It Off | 10 | remaining hit-delay gap to ×0.35 ×0.90 | ×1.82 | none |
| Pitch Calling | 12 | best-option bias +0.85 × ln(rank + 1) | ×1.72 | none |
| Core Transfer | 13 | base payload +0.01× | ×1.76 | none |
| Scouting Notebook | 14 | base mastery gain +0.015× | ×1.78 | none |
| Seam Conditioning | 15 | air drag ×0.985 | ×1.80 | none |
| Contract Incentives | 17 | base strikeout XP +0.01× | ×1.84 | none |
| Locker-Room Networking | 19 | remaining gap to 100% loot chance ×0.995 | ×1.88 | none |
| Competitive Memory | 21 | Frustration quality per doubling +1% | ×1.92 | none |

Only Speed begins unlocked; the other 14 axes appear gradually. Every displayed base stat has one repeatable Training purchase. Distinct operations intentionally stack across systems: Training raises the additive base or approaches a transparent asymptote, while one-time Facilities and BODY choices multiply the completed stat.

Active field taps begin at 1.7% of the current foreground timer's starting duration and approach 4% through repeatable Field Hustle. The tap budget is capped at 50% per recovery, flight, or lineup phase. The next-batter handoff is accelerated in the same way as wind-up and flight, with its authoritative cooldown and visual on-deck meter kept synchronized. No amount of clicking can replace the other half of the timer, and untouched idle/offline pacing remains unchanged.

Thirty-one pitch types, 26 replacement ball shells, and 84 one-time facilities/projects run from level 1 through level 45. Facilities are costly, high-impact multipliers; a parallel human project lane ranges from 500 XP to 3.2 trillion XP so large balances retain aspirational targets instead of collapsing into repeatable Command. Several purchases are gated by actual measured speed, a campaign level that supplies the required range, or lifetime Strikeouts. Human chemistry now lives in BODY, where Suspicious Vitamins arrive long before Extremely Obvious Steroids. Every tab is sorted by unlock level and cost; Pitch, Ball, and Facility each have an independent saved Hide Purchased filter. Every learned pitch joins the automatic mix; Pitch Calling gradually favors stronger options instead of deleting weaker pitches. The 14 post-human pitches use much larger bonuses and meaningful speed/quality detriments, including Gazorpian Strudelball, Bubonic Swerve, and The Pitch of the First Death. Ball shells replace rather than multiply one another, so the strongest owned payload is easy to understand. Railgun Jackets, plasma, and causal construction begin only after the human story boundary.

Opponent mastery is authored as completed-count equivalents rather than one global exponential. Human targets begin at 5.6 ordinary strikeouts and rise to roughly 55 at the MLB Champion; the former curve ended above 1,200. Alien targets begin at 50 uncompressed counts and rise with their four-to-nine-Strike rules; eldritch targets rise more sharply because one clone volley can contribute many called Strikes. Every called Strike still awards one count-share immediately. Late-human threat anchors rise more aggressively, so the ladder's resistance comes from earning rare strikeouts against better batters rather than repeating an already-solved matchup. Opponent rewards grow by `×1.80` per level so each rarer completed count carries the savings value formerly spread across many routine outs. Inherited Scorebook Cortex multiplies the live requirement by `0.85^rank`; the same reduced threshold controls unlocks, full bars, cosmic completion, matchup adaptation, and the start of logarithmic farming bonuses. Auto-scout evaluates the expected XP-per-second model across unlocked opponents at their assigned ranges.

## Renderer and simulation budget

Human baseball is fixed at one unresolved ball. Post-human sources come from arms, clones, and time layers; separate capacity upgrades raise the usable volley to 2,048 balls. The native MultiMesh reserves 4,000 outbound balls, so every designed projectile renders one-for-one. The browser profile draws 512 outbound representatives before applying a visible weight, without changing the simulated volley or its rewards. Stars and visually dense return volleys are drawn in batches, with smaller browser-only cosmetic ceilings. On the development Mac's Radeon Pro 560X, the fresh native scene holds 60 FPS; a ten-second complete stress run spans 44–60 FPS across launch, impact, and return phases, with most samples at 58–60. A 20,000 balls/s physical-throughput ceiling keeps all economy values finite.

At readable rates, projectile creation is driven only by authoritative release events. A release snapshots pitch type, exact speed, distance, duration, color, path, and source hand. Movement and upgrades cannot mutate it. No release occurs while the plate is empty or while the previous human pitch is unresolved, and returning a batter never creates a catch-up burst.

Dense and offline production use the exact count-state renewal model rather than iterating every pitch. It retains terminal-outcome mix, saved-hit volume, walks, strikeouts, downtime, mastery, and statistically equivalent loot rolls while allowing seven days of offline play to resolve quickly. The raw strikeout XP from that same solution is multiplied by the saved body's 1%–75% asymptotic offline efficiency before it reaches spendable, run, or lifetime XP; foreground pacing audits explicitly use the full-rate path.

## Verified failure modes

The automated suite explicitly checks that:

- hits, walks, Fouls, and partial Strikes cannot award XP; only called Strikes award mastery;
- Fouls stop adding Strikes at two and four human Balls cause a walk;
- unprotected hits and walks clear both counts and start the correct full downtime;
- protected hits hold the count, while Grand Slams bypass every protection layer;
- human counts stay at three Strikes/four Balls and post-human Strike compression never drops below three;
- every release has exactly one authoritative simulation event and no pitch appears on an empty plate;
- a released ball keeps its type, release speed, plate speed, drag, release distance, and travel time through upgrades or opponent changes;
- choosing another unlocked batter during flight resolves that same pitch against the chosen target;
- missed Strikes and Balls continue through the plate without an unexplained speed change;
- the pitch and on-deck meters reflect their authoritative cooldowns;
- each purchased body age affects speed, quality, recovery, subtitle, loadout, and rendered size while every reset begins as a toddler;
- the toddler human-league clear unlocks only when no age has been purchased;
- Xylophax remains 100% Grand Slam under arbitrary stats and reveals HELP only after a witnessed minute, never from offline time;
- all eight outcome cards remain compact and expose detail through tooltips;
- every exact and bulk loot drop copies a player-wearable slot and rarity visible on the defeated batter; mastery may favor better worn gear but cannot invent an unworn rarity;
- human opponents progress through Human Common–Unique and end fully Unique; alien and eldritch opponents expand the possible wardrobe with five new family tiers each while retaining older-family possibilities;
- loot obeys Power sorting, no-auto-equip default, prestige-only auto-equip, item amplification, caps, starred protection, Scrap conversion, resets, inheritance, and save rules;
- every level-gated catalog is displayed in unlock order, and alternate speed/range/Strikeout gates conceal effects until met;
- the achievement catalog contains 109 unique entries, stacks exactly +1% XP apiece, persists through prestige and save/load, keeps every unencountered entry anonymous, and offers a saved Hide Achieved filter without making card text consume scroll gestures;
- each one-time catalog filter is independent, saved, touch-sized on phone, and never hides locked or available purchases;
- human and alien Auto-advance stop at their separately purchased destination capacities, while auto-buy purchases only explicitly licensed stats and catalogs;
- progressive interface layers remain hidden until their story boundary;
- a giant iOS-style resumed frame is split into a small live tick and one offline catch-up interval;
- all 45 levels, costs, deterministic era-name combinations, signature names, traits, prestige boundaries, and migrations remain valid;
- Octathulhu cannot be completed below 1c and cosmic victory fires only once.

The remaining balance risk is deliberate: a player can select an aspirational opponent whose long count and authored range produce worse income than farming backward. Every unlocked opponent remains selectable, but its distance is fixed by level, so farming is a matchup decision rather than a repetitive "move closer" tax.
