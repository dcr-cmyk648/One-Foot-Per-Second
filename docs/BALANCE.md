# One Foot Per Second — v0.10.0 Balance Audit

## Outcome

The complete campaign is long but finite, every prestige layer changes the strategy, and no tested stage requires loot or mathematically perfect gear. The deterministic no-loot runners currently reach:

| Milestone | Approximate active-production time |
|---|---:|
| Human baseball cleared | 37 h 30 m |
| Xylophax's first exhibition completed | 38 h |
| First useful replay harvest | 3 d 3 h 30 m |
| Mid-alien harvest | 5 d 9 h 30 m |
| Four-digit DNA harvest | 11 d 3 h |
| Final pre-eldritch harvest | 18 d 6 h |
| First eldritch ascension | 33 d 18 h |
| First magic-assisted DNA rebirth | 37 d 15 h |
| Deeper eldritch ascension | 50 d 21 h |
| Octathulhu unlocked at 1c | 68 d 15 h |
| First cosmic victory | 68 d 21 h |

These are deterministic baselines with frequent purchasing and strategically timed resets. A player who explores, farms a favorite batter, or checks in less often will take longer. Automation reduces management after the first rebirth; offline progress simulates up to seven days but never makes an irreversible prestige choice.

The runner obeys the same human cadence as the field: one wind-up, one unresolved ball, full flight, impact, lineup change if needed, then the next wind-up. That is intentionally slower than a generic pitches-per-second spreadsheet and prevents hidden pitches from occurring while the visible ball or batter is unresolved.

## Why strikeout-only income works

The fresh Dead-Fish Lob has roughly a 30.5% Strike probability. Fouls can add strike one or two, Balls can produce a walk, and fair hits end the plate appearance. Solving the complete `(Strikes, Balls)` state machine gives a **6.472%** fresh strikeout probability per plate appearance. That is bad enough to sell the joke but frequent enough to fund the first upgrades.

The idle solver uses the same exact absorbing model at every level:

- a Foul advances the Strike count unless two Strikes are already present;
- a Ball advances the Ball count and a completed walk ends the batter like a Single;
- protected hits and two-strike Fouls are self-loops that consume pitches and time without erasing the count;
- an unprotected fair hit terminates the at-bat;
- a completed Strike count is the only XP-earning terminal state;
- post-human volleys can advance a count by more than one at impact.

The fully purchased audit profile reaches a 100% Strike result, and its 2,048-ball terminal volley exceeds Octathulhu's 61 live Strikes after compression. That final form is intentionally a victory lap. Earlier eldritch builds still have smaller volleys and imperfect odds, so they depend on count preservation: genetics guarantee saves on Singles, Doubles, and Triples; five clone ranks leave `0.60⁵ = 7.776%` ordinary-hit failure; portals apply a second independent save layer. Grand Slams remain unsavable at every stage.

## Counts, payout, and downtime

Human baseball keeps three Strikes and four Balls throughout. Alien counts climb from four to nine Strikes and eventually shrink to three Balls; eldritch counts climb through 12, 18, 28, 42, and 64 Strikes while the last two gods allow only two Balls. Genetic Strike compression affects only post-human opponents and can never reduce the requirement below three.

Only the final Strike pays. Base payout is five XP per unmodified required Strike:

| Base Strike count | Strikeout base XP |
|---:|---:|
| 3 | 15 |
| 4 | 20 |
| 6 | 30 |
| 9 | 45 |
| 12 | 60 |
| 18 | 90 |
| 28 | 140 |
| 42 | 210 |
| 64 | 320 |

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

## First-universe reset cadence

The current greedy audit uses eleven lower-layer resets, approximately:

1. `+20 DNA` after the initial Xylophax offer.
2. `+35 DNA` after the first human replay.
3. `+154 DNA` in the alien circuit.
4. `+1,426 DNA` on a deeper alien run.
5. `+3,476 DNA` for the final pre-eldritch build-out.
6. `+167 Arcana` after N'Kthra; most is immediately invested.
7. `+218 DNA` during the first magic-assisted replay.
8. `+111,559 DNA` after a deep new-reality harvest.
9. `+1,069 Arcana` on the deeper eldritch ascension.
10. `+722 DNA` in the next reality.
11. `+548,859 DNA` before the terminal body reaches exactly `1c` and defeats Octathulhu.

The exact sequence is not mandatory. Cube-root DNA rewards favor meaningful jumps rather than constant restarts, while Arcana's `0.60` exponent rewards accumulated DNA across several lifetimes before destroying a reality. Early DNA priorities are arms, simultaneous-ball capacity, count compression, fielding, speed/quality, then automation. Eldritch priorities are clones and portals for count survival, capacity and time layers for the visual salvo, velocity for the final gate, and quality/mastery for huge counts.

## Speed and rate calibration

- The first released pitch is exactly 1 ft/s and takes three real seconds to cross three feet.
- Pitch type then supplies a small speed range; the exact sampled speed is shown in the field and remains immutable in flight.
- Human biology caps at 211.6 mph, twice the 105.8 mph real-world reference used by the design.
- Alien biology caps at Mach 12; the alien championship gate requires Mach 3.
- Eldritch bodies can reach exactly 1c; Octathulhu rejects anything slower.
- Fresh recovery is `0.25 pitches/s`: a four-second wind-up before flight.
- The tested early curve remains about `0.26/s` at level 3, `0.68/s` at level 10, `1.42/s` at level 20, and `2.71/s` at the first human finale. Human play still permits only one unresolved pitch, so travel time remains visible even when recovery improves.

Speed purchases stop at the current body's cap. The ordinary button says only `Base speed +0.15 ft/s`; the cap and its spoiler-light hint appear only after the player actually reaches it and tries to buy more.

## Cost and content cadence

Ordinary Training has one clear purchase per displayed base stat:

| Training | Unlock level | Effect per rank | Cost growth | Limit |
|---|---:|---|---:|---:|
| Speed Training | 1 | base speed +0.15 ft/s | ×1.30 | current body |
| Command Drills | 2 | base quality +0.08 | ×1.105 | none |
| Recovery Drills | 4 | base recovery +0.035/s | ×1.45 | 26 |
| Long-Toss Mechanics | 6 | distance-threat factor −0.025 | ×1.72 | 20 |
| Lineup Hustle | 8 | base lineup time −0.15 s | ×2.40 | 10 |
| Shake It Off | 10 | fair-hit delay factor −0.05 | ×2.25 | 8 |
| Pitch Calling | 12 | best-option bias +0.50 | ×2.10 | 12 |

Only Speed begins unlocked; the other axes appear as level-gated entries in this order. The former Command, Spin, and Deception buttons were all additive quality purchases and are folded into Command. Distinct operations intentionally stack across systems: Training raises the additive base, while one-time Facilities multiply the completed stat.

Fourteen pitch types, twenty-six replacement ball shells, and forty-two one-time facilities/interventions run from level 1 through level 45. Facilities are costly, high-impact multipliers; several are gated by actual measured speed, mound distance, or lifetime Strikeouts in addition to campaign level. Suspicious Vitamins arrive long before Extremely Obvious Steroids, and the human ladder stays recognizably human. Every tab is sorted by unlock level and cost. Every learned pitch joins the automatic mix; Pitch Calling gradually favors stronger options instead of deleting weaker pitches. Ball shells replace rather than multiply one another, so the strongest owned payload is easy to understand. Railgun Jackets, plasma, and causal construction begin only after the human story boundary.

Opponent mastery rises as `25 × 1.34^index`, while reward rises faster at `1.55^index`. A frontier opponent is attractive only when its longer count and higher failure downtime do not outweigh the reward. Auto-scout evaluates the same expected XP-per-second model across unlocked opponents and ranges.

## Renderer and simulation budget

Human baseball is fixed at one unresolved ball. Post-human sources come from arms, clones, and time layers; separate capacity upgrades raise the usable volley to 2,048 balls. The native MultiMesh reserves 4,000 outbound balls, so every designed projectile renders one-for-one. The browser profile draws 512 outbound representatives before applying a visible weight, without changing the simulated volley or its rewards. Stars and visually dense return volleys are drawn in batches, with smaller browser-only cosmetic ceilings. On the development Mac's Radeon Pro 560X, the fresh native scene holds 60 FPS; a ten-second complete stress run spans 44–60 FPS across launch, impact, and return phases, with most samples at 58–60. A 20,000 balls/s physical-throughput ceiling keeps all economy values finite.

At readable rates, projectile creation is driven only by authoritative release events. A release snapshots pitch type, exact speed, distance, duration, color, path, and source hand. Movement and upgrades cannot mutate it. No release occurs while the plate is empty or while the previous human pitch is unresolved, and returning a batter never creates a catch-up burst.

Dense and offline production use the exact count-state renewal model rather than iterating every pitch. It retains terminal-outcome mix, saved-hit volume, walks, strikeouts, downtime, XP, mastery, and statistically equivalent loot rolls while allowing seven days of offline play to resolve quickly.

## Verified failure modes

The automated suite explicitly checks that:

- hits, walks, Fouls, and partial Strikes cannot award XP or mastery;
- Fouls stop adding Strikes at two and four human Balls cause a walk;
- unprotected hits and walks clear both counts and start the correct full downtime;
- protected hits hold the count, while Grand Slams bypass every protection layer;
- human counts stay at three Strikes/four Balls and post-human Strike compression never drops below three;
- every release has exactly one authoritative simulation event and no pitch appears on an empty plate;
- a released ball keeps its type, exact speed, release distance, and travel time through upgrades or mound movement;
- choosing another unlocked batter during flight resolves that same pitch against the chosen target;
- missed Strikes and Balls continue through the plate without an unexplained speed change;
- the pitch and on-deck meters reflect their authoritative cooldowns;
- all eight outcome cards remain compact and expose detail through tooltips;
- loot obeys its restrained rarity curve, Power sorting, caps, starred protection, automatic best-item equipment, resets, inheritance, and save rules;
- every level-gated catalog is displayed in unlock order, and alternate speed/distance/Strikeout gates conceal effects until met;
- progressive interface layers remain hidden until their story boundary;
- all 45 levels, costs, names, traits, prestige boundaries, and migrations remain valid;
- Octathulhu cannot be completed below 1c and cosmic victory fires only once.

The remaining balance risk is deliberate: a player can select an aspirational opponent whose long count produces worse income than farming backward. Since all unlocked opponents and distances remain selectable, that is a tactical choice rather than a softlock.
