# One Foot Per Second — v0.10.6 Design

## Product shape

One Foot Per Second is a readable top-down idle simulation whose joke escalates honestly. The player begins three feet from a toddler, throws a large white wiffle ball at exactly 1 ft/s, and is visibly terrible. The same field eventually holds eight synchronized arms, alternate-reality pitchers, thousands of physical balls, a galaxy-width mound, and an eight-bat god.

The design has six constraints:

1. The opening joke must be physically legible: one foot per second over three feet takes three seconds.
2. An upgrade changes only what it claims to change. A released projectile is immutable.
3. Human baseball remains recognizable: one unresolved ball, three Strikes, four Balls, plausible equipment, and restrained pitch cadence.
4. Each prestige layer introduces a new way to solve baseball, not just a larger number.
5. Escalation is discovered in play. Mutations, magic, clones, divine rewards, future opponents, and their explanatory text do not appear before their story boundary.
6. Browser and native builds share every gameplay source and save migration. Platform profiles may aggregate presentation only; they may never alter progression math.

## Core plate-appearance state machine

There are eight pitch outcomes:

| Outcome | Direct XP | Count effect | Terminal delay at fresh settings |
|---|---:|---|---:|
| Grand Slam | 0 | Always ends batter; clears both counts | 12 s |
| Home Run | 0 | Ends batter unless protected | 8 s |
| Triple | 0 | Ends batter unless protected | 6 s |
| Double | 0 | Ends batter unless protected | 5 s |
| Single | 0 | Ends batter unless protected | 4 s |
| Foul | 0 | Adds one Strike, except at two Strikes | — |
| Ball | 0 | Adds one Ball; completed walk ends batter | 4 s on walk |
| Strike | 0 until count completes | Completed count strikes batter out | 3 s on K |

Only a Strike or simultaneous post-human volley that completes the required Strike count pays XP and mastery. Saved fair hits consume a pitch and preserve both counts. Grand Slams have zero save chance under every build. A walk is deliberately bad for the pitcher: it clears the plate appearance, pays nothing, and uses the Single-length lineup delay.

The base strikeout payout is:

```text
base XP = unmodified required Strikes × 5
```

Count compression changes the live requirement but not that bounty. A six-Strike alien compressed to three still pays 30 base XP.

Final XP is:

```text
base strikeout XP
× opponent reward
× DNA income multiplier
× strongest ball payload
× distance reward
× optional mastery and equipment bonuses
```

When the game is closed or a browser tab is suspended, the same state machine runs for up to seven days but its strikeout XP is multiplied by the body's offline efficiency. That value begins at `0.01`; Scorebook Study adds `0.01` per rank and ordinarily caps at `0.25`. Mastery, counts, batter replacement, story clocks, and loot still advance through the authoritative simulation. Returning with any deposited XP opens a summary that names the time away, XP gained, efficiency used, strikeouts, and loot.

## Outcome probabilities

Pitch quality is compared with opponent threat, including release distance and the generated batter's body/equipment counters. Five logistic thresholds first divide fair contact into Grand Slam, Home Run, Triple, Double, and Single buckets. Of that contact mass, 75% remains fair contact, 10% becomes Foul, and 15% becomes Ball; the remaining probability is Strike.

Each release chooses one learned pitch. Before Pitch Calling, every learned pitch is equally likely. Each Pitch Calling rank multiplies the strongest pitch's selection weight by `1.35` relative to the weakest, with intermediate pitches interpolated by quality. The selected pitch contributes its quality and its own speed range. Exact speed is sampled once, displayed at the field's upper-left, and used for that ball's probability and flight.

The fresh complete at-bat has a 6.472% strikeout chance. That figure is not `Strike³`: Fouls can help reach two Strikes, Balls can create a walk, and fair contact can end the batter. Live and offline simulation use an exact absorbing dynamic program over `(Strikes, Balls)`, including two-Strike Foul self-loops, protected-hit self-loops, simultaneous volleys, and terminal downtime.

## Count arc

| Campaign segment | Levels | Base Strikes | Base Balls |
|---|---:|---:|---:|
| Human baseball | 1–30 | 3 throughout | 4 throughout |
| Alien rookie circuit | 31–35 | 4, 4, 5, 5, 6 | 4 throughout |
| Interstellar league | 36–40 | 6, 7, 7, 8, 9 | 3 throughout |
| Eldritch World Series | 41–45 | 12, 18, 28, 42, 64 | 3, 3, 3, 2, 2 |

Compressed Strike Genome has three ranks, affects only post-human opponents, and never reduces a requirement below three. Huge eldritch counts become feasible because genetic fielders guarantee saves on Singles, Doubles, and Triples; mirror clones and portals probabilistically save remaining ordinary hits; and simultaneous volleys can add multiple Strikes at one impact.

The field shows three familiar Strike diamonds throughout human baseball and a separate row of four gold Ball circles. Larger counts use compact icon limits plus numeric labels rather than covering the batter.

## Campaign structure

| Levels | Era | Mechanical purpose |
|---:|---|---|
| 1–5 | Backyard | Establish the slow physical joke, counts, and first reliable Ks. |
| 6–10 | Youth Baseball | Introduce arsenal breadth, long toss, and generated counters. |
| 11–15 | School Ball | Build command, recovery, and human ball construction. |
| 16–20 | Amateur & College | Reach regulation-style distance and sustained farming. |
| 21–25 | Minor Leagues | Add late-human facilities without abandoning plausible baseball. |
| 26–30 | Major Leagues | Obvious steroids, the 211.6 mph body cap, and Bambino Rex. |
| 31–35 | Alien Rookie Circuit | Xylophax, extra arms, simultaneous capacity, and longer counts. |
| 36–40 | Interstellar League | Planetary fields, Mach speeds, plasma, giants, and Solus. |
| 41–45 | Eldritch World Series | Reality mechanics, huge counts, Ball-rog, Octathulhu, and 1c. |

Each level is a reusable batter class. Authored signatures and era-specific pools generate individual names such as Little Timmy or Milo, Breaker of Fences without turning those titles into class labels. Every batter deterministically rolls a small body modifier, bat, and level-scaled equipment loadout. A toddler exposes body and bat; an MLB batter can use all six mundane slots; post-human opponents add a Relic. These rolls modify threat modestly and are visible in the batter-side vertical loadout.

Every terminal result has a distinct exit treatment. The old batter moves toward the upper-right and the replacement enters from the lower-left. A circular on-deck meter uses the authoritative remaining delay.

## Progressive interface contract

The fresh game exposes ordinary XP, the human opponent ladder, Training, Pitch, Ball, Facility, Gear, Stats, Help, six equipment squares, and the permanent-progress reset. The seven-slot Relic remains anonymous until post-human play. DNA, mutations, automation, extra bodies, and alien catalogs appear only after Xylophax's offer. Arcana, magic, clones, reality statistics, and eldritch catalogs appear only after N'Kthra's offer. Divine controls and completion statistics appear only after the first cosmic victory.

Within a revealed story tier, its full catalog is visible and every tab is ordered by unlock level, then cost. A locked entry shows only its unmet requirements; it does not reveal the effect. Most gates are campaign levels, while selected Facility gates ask for a measured speed, a farther mound, or a Strikeout achievement. Descriptions state concrete arithmetic such as `Base speed +0.15 ft/s`, `Quality ×1.08`, or `Lineup time ×0.90`. Maximum-rank and body-cap language appears only when reached. Attempting to train beyond a body limit opens a contextual hint rather than spoiling genetics.

Ordinary Training offers one additive purchase per base stat, unlocked gradually in this order: Speed, Quality, Recovery, Offline XP, Distance Control, base Lineup time, fair-hit Delay, and Pitch Calling. The field's compact profile shows all eight values with hover explanations. One-time Facilities provide the separate multiplicative layer, so a new building or questionable intervention is a larger event than pumping another Training rank. There are no same-operation quality buttons with cosmetic names.

Eight outcome cards contain only name, probability, and compact added delay. Hover text explains count/terminal behavior. Strikeout payout sits on its own small line. Player equipment is six compact rarity-colored squares at the field's lower-right; clicking a square opens its sorted slot inventory. Opponent equipment mirrors that language in a vertical strip on the batter's side.

The interface targets a 1600×1000 logical canvas, opens maximized, and supports a 1280×800 minimum. Every tab has an independent scroll viewport inside a fixed panel footprint, preventing the field from resizing when tabs change. A typed uppercase `RESET` confirmation is required before permanent progress can be erased.

## Prestige I: genetic rebirth

Bambino Rex requires the first body's 211.6 mph limit. Clearing human baseball reveals Xylophax, Genetic Commissioner, whose first one-minute exhibition is guaranteed Grand Slams. Xylophax then offers prenatal genetic engineering and a Time Machine, because naturally the only responsible way to add arms is to modify the pitcher as a baby.

```text
DNA = floor((body XP / 10,000,000,000) ^ (1 / 3)) × DNA multipliers
```

A genetic rebirth resets XP, Training, pitches, balls, facilities, opponent access/mastery, distance, live counts, and the Locker. It preserves DNA, genetic upgrades, Arcana, magic, divine rewards, and lifetime statistics. Reverse Terminator Wardrobe is the explicit equipment exception.

| Genetic upgrade | Effect per rank | Cap |
|---|---|---:|
| Remember the Strike Zone | all XP ×1.50 | 5 |
| Fast-Twitch Everything | speed ×1.80 | 6 |
| Compound Pitching Eye | quality +1.25 | 6 |
| Prehensile Pitching Arms | arms and potential sources ×2 | 3 |
| Parallel Pitching Lobes | simultaneous-ball cap ×2 | 3 |
| Elastic UCL Colony | pitch cooldown ×0.847 | 5 |
| Regulation Ball Gland | payload ×2.50 | 5 |
| Compressed Strike Genome | post-human requirement −1 | 3 |
| Prehensile Outfield Reflex | protect Single, then Double, then Triple | 3 |
| Migratory Baseball Instinct | Auto-advance | 1 |
| Autonomic Coaching Lobe | Auto-coach | 1 |
| Predator Scouting Reflex | Auto-scout | 1 |
| Autonomic Wardrobe Lobe | equip the highest-Power item in every unlocked slot | 1 |

After rebirth, Xylophax becomes a normal four-Strike opponent. Alien biology raises the body ceiling to Mach 12; Solus requires Mach 3 for the championship gate.

## Prestige II: eldritch ascension

After the alien leagues, N'Kthra, Rookie of the Last Aeon repeats the one-minute guaranteed-Grand-Slam lesson. Ascension destroys the current reality and transfers the pitcher's consciousness elsewhere.

```text
Arcana = floor((reality DNA) ^ 0.60) × Arcana multipliers
```

Eldritch ascension resets the body and additionally erases unspent DNA, genetic upgrades, current-reality rebirths, and all loot. It preserves Arcana, magic, divine rewards, and lifetime statistics.

| Eldritch upgrade | Effect per rank | Cap |
|---|---|---:|
| Mirror-Reality Bullpen | bodies ×2; ordinary-hit failure ×0.60 | 5 |
| Time Compression Ritual | time layers ×2; batter downtime ÷2 | 3 |
| Non-Euclidean Bullpen Geometry | simultaneous-ball cap ×4 | 4 |
| Velocity Without Distance | speed ×12 | 4 |
| Eyes Behind the Moon | quality +2 | 5 |
| Causal Seams | payload ×10 | 5 |
| Bullpen Portals | save chance +20 percentage points | 4 |
| Memory of Flesh | DNA gained ×1.50 | 4 |
| Mercy Is Euclidean | mastery ×1.75 | 3 |
| Reverse Terminator Wardrobe | one random equipped slot survives genetic rebirth | 7 |
| One-Size-Fits-All-Realities Uniform | every clone receives full gear bonuses | 1 |

The eldritch body can reach exactly the speed of light. Octathulhu's causality armor rejects anything slower.

## Loot and equipment

Only completed strikeouts can drop clothing. The ordinary chance is 12%; the first career K guarantees Little Timmy's Oversized Cap and ten dry eligible rolls trigger pity. Hits, walks, Fouls, saved hits, and partial Strikes never roll loot.

Human slots are Hat, Jersey, Jock Strap, Glove, Pants, and Cleats. A seventh post-human slot is Relic. Each item has opponent-capped level, rarity, randomized affixes, and an integer Power calculated from its actual bonuses. Slot inventories sort highest-Power first and hold ten items. Overflow removes the lowest-Power eligible item, with rarity and level as tie-breakers; equipped and starred items are protected.

Rarities are Common, Magic, Rare, Legendary, and Unique. Before overmastery adjustments, parcel rarity is 78% Common, 18% Magic, 3.7% Rare, 0.27% Legendary, and 0.03% Unique. The equipped square uses a bright rarity-colored border and checkmark, and the Locker explicitly labels the equipped row. A complete outfit is capped at +15% speed, +18% recovery, +0.50 quality, +25% strikeout XP, +20% mastery, and +15% distance XP. Speed gear applies after the biological cap, so clothing may exceed a body's nominal maximum without being required to pass a progression gate. All campaign audits disable loot.

Mastery continues past an opponent's unlock target. Each logarithmic excess-mastery doubling adds a small XP multiplier and improves rarity/affix quality, while item level remains capped to that opponent. An overmastered toddler can drop an excellent level-one cap, not cosmic pants.

Ordinary time travel erases the Locker. Each Reverse Terminator Wardrobe rank carries one randomly selected equipped item through a genetic rebirth. Autonomic Wardrobe Lobe automatically equips the highest-Power surviving or newly dropped item in every unlocked slot. Mirror clones initially dilute aggregate gear bonuses until One-Size-Fits-All-Realities Uniform equips the entire bullpen conceptually.

## Prestige III: divine restoration

Defeating Octathulhu marks the cosmos conquered. God thanks the pitcher for saving the universe with baseball, restores everything, and offers one unowned permanent blessing. Divine restoration erases XP, lower currencies, genetics, magic, lower reset counts, and loot; divine rewards and lifetime statistics remain.

The six blessings cover starting speed, mastery, universal ordinary-hit protection, payload, DNA gain, and Arcana gain. All can be collected across six victories. Later victories award stackable Halos, each multiplying XP and mastery by `1.50`. Grand Slams remain terminal even with Angels in the Outfield.

## Distance, camera, and controls

Fifteen ranges run from 3 feet through 6, 12, 20, 30, 44, 60.5, 90, and 300 feet, then one mile, low orbit, Earth-to-Moon, one AU, one light-year, and 100,000 light-years. Farther ranges raise XP and threat. Long-Toss Mechanics multiplicatively reduces only the threat penalty.

True flight time is `release distance / exact release speed`. Visual flight preserves the literal three-second opening and logarithmically compresses extreme durations to a readable ceiling; Stats retains the true physical value. Small field arrows move the mound immediately even during flight, without modifying the released ball. Previous/next batter controls are also always available within unlocked bounds; selecting a new target during flight makes that same unresolved pitch meet the newly selected batter.

Camera scale maps logarithmically from a 3.6× three-foot close-up toward galaxy width. Pitcher and batter use the same point, dark center, and colored-ring language. The fresh pitcher is roughly 50% larger than the toddler and grows on a saturation curve toward twice the original intrinsic size. Batter intrinsic size ranges from toddlers through huge aliens and field-dominating gods, then shares the same distance perspective. The pitching arm is a short rectangular limb that drives toward the plate and releases from its tip; the batter's rectangular bat swings toward the incoming ball.

Human fields use muted grass. Alien terrain appears only after the human tier; deep space becomes black with increasingly dense stars, galaxies, and universe-scale rings as the camera retreats.

## Projectile architecture

Simulation and presentation have separate responsibilities but share one authoritative event stream:

- `BaseballGameState` owns economy, exact count state, probabilities, pitch selection, immutable release snapshots, downtime, loot, progression, resets, saving, and offline math.
- `PitchField` owns the top-down visual, GPU instances, pitch/plate meters, batter lifecycle, count icons, return balls, environments, and camera.
- `GameContent` owns authored opponents, name pools, ranges, pitches, ball shells, facilities, loot definitions, prestige upgrades, blessings, and text.
- `Main` owns the responsive spoiler-gated interface and binds state to presentation.

Every human pitch follows `wind-up → release → immutable flight → impact → cooldown`. A release publishes pitch identity and speed but no outcome; only impact reveals the result, so pitcher behavior cannot telegraph a hit. Every projectile snapshots type, exact speed, release distance, original and remaining duration, source hand, curve, trail, scale, and color. Upgrades and mound movement affect future releases only.

PitchField draws only authoritative releases. Frame time cannot manufacture an extra ball. The plate and simulation clocks suppress releases while no batter is present; returning from a long frame cannot generate a catch-up volley. Missed Strikes and Balls continue beyond the plate at their incoming screen speed and fade. Fouls visibly deflect out of bounds. Fair hits return into the field, and protected hits return toward the bullpen.

Human simultaneous capacity is exactly one. Post-human throwing sources are `arms × bodies × time layers`, while Parallel Pitching Lobes and Non-Euclidean Bullpen Geometry separately raise how many sources may release in one volley. The designed maximum is 2,048 balls. The desktop profile's 4,000-instance outbound pool renders every designed projectile one-for-one. The browser profile uses 512 outbound representatives, 96 return balls, 96 stars, and 16 clone bodies before aggregating presentation; the authoritative volley, outcome, XP, mastery, and loot remain identical. CPU-side environment stars and incoherently dense return volleys are batched. Desktop clone limb detail alone is bounded once dozens overlap; the primary pitcher always shows every purchased arm. The development Mac holds 60 FPS fresh and measures 44–60 FPS across a ten-second complete native stress run, with most samples at 58–60. Physical throughput is capped at 20,000 balls/s.

## Save and completion contract

Save version 13 persists the explicit pitch phase, hidden pending outcome, selected pitch ID, exact sampled speed, release distance, original and remaining duration, generated batter identity/loadout, live Strike and Ball counts, eight additive Training axes, forty-two Facilities, cooldown, eight result totals, strikeouts, currencies, upgrades, mastery, automation, loot, favorites, equipment, pity, and lifetime statistics. Saves created before v0.10.6 default the new Scorebook Study rank to zero without a schema conversion.

Version-12 multiplicative Training ranks migrate to equivalent additive ranks; its single lineup modifier becomes the new base-lineup investment while fair-hit recovery starts cleanly. Legacy Command, Spin, and Deception ranks migrate into one additive Command investment. Older saves retain the Belt-to-Jock-Strap migration, ten-item pruning, added outcome slots, count-compression mapping, portal mapping, and conversion of retired prestige systems.

Octathulhu mastery at 1c sets `cosmos_conquered`, unlocks exactly one divine choice, and cannot trigger twice in the same universe. The permanent-progress reset requires the player to type uppercase `RESET`, then erases the save and reinitializes both simulation and field state.
