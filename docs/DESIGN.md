# No Hitter — v0.16.5 Design

## Product shape

No Hitter is a readable top-down idle simulation whose joke escalates honestly. The player begins as a slightly oversized toddler three feet from another toddler, throws a large white wiffle ball at exactly 1 ft/s, and is visibly terrible. The same field eventually holds eight synchronized arms, alternate-reality pitchers, thousands of physical balls, a galaxy-width mound, and an eight-bat god.

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

Only a Strike or simultaneous post-human volley that completes the required Strike count pays XP. Every called Strike immediately pays one count-share of opponent mastery, including a partial count; a normal completed count therefore retains the former total mastery value. Saved fair hits consume a pitch and preserve both counts but award no mastery. Grand Slams have zero save chance under every build. A walk is deliberately bad for the pitcher: it clears the plate appearance, pays nothing, and uses the Single-length lineup delay.

The early base strikeout payout is deliberately ramped so the first lucky out
does not purchase the whole opening shop:

```text
base XP = min(unmodified required Strikes × 5, 4 + opponent level)
```

The first toddler therefore pays 5 XP; levels 2–10 add one base XP apiece, and level 11 reaches the ordinary 15-XP human bounty. Count compression changes the live requirement but not the unmodified-count bounty. A six-Strike alien compressed to three still pays 30 base XP.

Final XP is:

```text
base strikeout XP
× opponent reward
× DNA income multiplier
× strongest ball payload
× optional mastery and equipment bonuses
× (1 + completed achievements × 0.005)
```

Opponent rewards are authored directly. Level-assigned distance changes physical flight and threat but never multiplies XP.

When the game is closed or a browser tab is suspended, the same state machine runs for up to seven days, but both strikeout XP and called-Strike mastery are multiplied by the body's offline efficiency. That value begins at `0.01`; each Scorebook Study rank removes 6% of the remaining gap to `0.75`. Counts, batter replacement, and loot still advance through the authoritative simulation. The first alien story clock is deliberately excluded because the player must witness it; later already-understood simulation remains idle-capable. Returning with either reward opens a summary that names the time away, XP and mastery gained, efficiency used, strikeouts, and loot. Browser visibility/page lifecycle events are recorded outside the frozen Godot loop so a giant iOS resume delta is still classified as away time exactly once.

## Outcome probabilities

Pitch quality is compared with opponent threat, including release distance and the generated batter's body/equipment counters. Five logistic thresholds first divide fair contact into Grand Slam, Home Run, Triple, Double, and Single buckets. Of that contact mass, 75% remains fair contact, 10% becomes Foul, and 15% becomes Ball; the remaining probability is Strike.

Each release chooses one learned pitch. Before Pitch Calling, every learned pitch is equally likely. Each Pitch Calling rank multiplies the strongest pitch's selection weight by `1.35` relative to the weakest, with intermediate pitches interpolated by quality. The selected pitch contributes its quality and its own speed range. Exact speed is sampled once, displayed at the field's upper-left, and used for that ball's probability and flight.

The fresh Dead-Fish Lob has a 39.75% Strike chance, and the complete opening at-bat has an 11.841% strikeout chance. That figure is not `Strike³`: Fouls can help reach two Strikes, Balls can create a walk, and fair contact can end the batter. Live and offline simulation use an exact absorbing dynamic program over `(Strikes, Balls)`, including two-Strike Foul self-loops, protected-hit self-loops, independently sampled simultaneous balls, and terminal downtime.

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
| 26–30 | Major Leagues | Obvious steroids, the 115 mph human-development cap, and Bambino Rex. |
| 31–35 | Alien Rookie Circuit | Xylophax, extra arms, simultaneous capacity, and longer counts. |
| 36–40 | Interstellar League | Planetary fields, Mach speeds, plasma, giants, and Solus. |
| 41–45 | Eldritch World Series | Reality mechanics, huge counts, Ball-rog, Octathulhu, and 1c. |

Each level is a reusable batter class. Authored signatures and era-specific pools generate individual names such as Little Timmy or Milo, Breaker of Fences without turning those titles into class labels. Every batter deterministically rolls a small body modifier, bat, and level-scaled equipment loadout. Even the opening toddler visibly wears a hat, professional opponents fill all six mundane slots, and post-human opponents add a Relic. These rolls modify threat modestly and are visible in the batter-side vertical loadout.

Every terminal result has a distinct exit treatment. The old batter moves toward the upper-right and the replacement enters from the lower-left. A circular on-deck meter uses the authoritative remaining delay.

## Progressive interface contract

Startup opens a dedicated title screen with Resume Game, Start New Game, and Import Save. Resume Game opens the autosave and three device-local manual slots without entering the field first. Start New Game requires the same typed `RESET` hard stop whenever real progress exists, while leaving manual slots and exported backups intact. Its animated abstract matchup is keyed to historical farthest progress: it begins as ordinary backyard baseball, reveals alien imagery only after alien contact, reveals the void only after reaching it, and reserves the complete cosmic treatment for victory.

The fresh in-game interface exposes ordinary XP, the human opponent ladder, Training, Pitch, Ball, Facility, **BODY**, Gear, Status, Help, six equipment squares, Saves, and the permanent-progress reset. Status shows all 15 effective trained stats and itemizes only upgrades already owned or revealed. BODY begins with separate Grow and Build subtabs; DNA, Arcana, and Divine subtabs do not exist visibly until their story boundaries, then open once when first discovered. The seven-slot Relic remains anonymous until post-human play. DNA, mutations, automation, extra bodies, and alien catalogs appear only after the portal stranger's offer. Arcana, magic, clones, reality statistics, and eldritch catalogs appear only after N'Kthra's offer. Divine controls and completion statistics appear only after the first cosmic victory.

Within a revealed story tier, its full catalog is visible and every tab is ordered by unlock level, then cost. A locked entry shows only its unmet requirements; it does not reveal the effect. Most gates are campaign levels, while selected Facility gates ask for a measured speed, a level-assigned range, or a Strikeout achievement. Descriptions state concrete arithmetic such as `Quality ×1.08` or `Lineup time ×0.90`; repeatable cards show the effective change from the exact next rank. Unlocked but unaffordable cards keep the same readable color as affordable cards; only the XP-price action dims. Speed remains linear through 85% of the current body's limit and then approaches that limit asymptotically, so it never becomes a rejected `BODY LIMIT REACHED` purchase.

Pitch, Ball, Facility, and BODY each expose an independent saved Hide Purchased toggle. It removes only completed one-time entries from that tab; available and locked options remain visible. In BODY it applies to completed ages and physical modifiers without concealing unrevealed prestige systems. Training and prestige ranks are repeatable or strategically stateful, so they do not use this filter.

The Achievements tab always exposes a 130-slot total. Each completion permanently adds one additive half-percentage point to XP income, so the catalog ranges from `×1.00` to `×1.65`; achievements survive genetic, eldritch, and God Prestige resets. Cards use passive text as their drag/wheel surface and delimit Details as their only inspection action. A saved Hide Achieved filter removes only completed cards. Future subjects appear only as `HIDDEN ACHIEVEMENT`. Multiple simultaneous completions enter a queued toast with both name and completed condition. Durable event counters recognize post-rebirth toddler bullying, bat overload, multi-Strike counts, simultaneous fair contact and Strikes, mixed hit types, impossible base totals, and full eight-outcome chaos. `Wait… That’s Illegal` records the first learned post-human pitch. The fully secret No Hitter challenge begins with each post-victory God Prestige and is spoiled by any fair-hit outcome even when late-game defenses preserve the count.

Ordinary growth is a 12-stage sequential XP channel: Toddler, Preschooler, Grade-School Kid, Preteen, Young Teen, Teenager, Older Teen, Young Adult, Adult, Prime-Age Adult, Veteran Adult, and Regular Ol’ Guy. The immediate 3-XP Preschooler purchase is useful without abruptly skipping the early cadence. Twelve optional BODY modifiers branch between strength, conditioning, command, nutrition, and progressively more questionable chemistry. Each age and physical modifier supplies a modest authored visual-size change; ordinary Training does not enlarge a mortal marker. Every time-travel reset begins at Toddler again. A secret achievement records clearing all human opponents without buying any age.

Ordinary Training offers one repeatable purchase for every base stat: Speed, Quality, Field Tap, Recovery, Offline XP, Distance Control, Lineup time, fair-hit Delay, Pitch Calling, Payload, Mastery, Drag, Strikeout XP, Loot chance, and Frustration response. Speed adds a raw `0.75 ft/s` before multipliers while below the velocity knee, then asymptotically closes the remaining body-limit gap; Command adds only 18 displayed Quality, and velocity supplies a separate logarithmic Quality contribution. Human Recovery likewise bends smoothly above `0.60/s` toward its `0.72/s` body ceiling instead of flattening into a zero-value purchase. Each visible card calculates the exact next-rank delta against the current effective stat, while hover or a stationary phone hold adds the full formula. Quality, Threat, Frustration, and related matchup ratings use a presentation-only `×1000` scale, so internal `0.039` reads `39` and internal `6` reads `6000`; unwieldy or sub-unit values use `1eN`. Status and the phone Upgrades header show all 15 values. The compact Live Throw Profile retains only the last immutable throw: pitch name, release speed, plate speed, drag loss, travel time, Quality, and range. Thirty-one pitches, 26 ball shells, 84 one-time Facilities/projects, 12 age stages, and 12 BODY modifiers provide the larger multiplicative layer. Effective Facility prices are four times the authored baseline and premium human projects are eight times baseline, preserving one-time purchases as savings goals. The post-human pitch catalog deliberately includes extreme tradeoffs such as a very slow, high-Quality Gazorpian Strudelball and a very fast, inaccurate Andromedan Knucklebomb.

Clicking or tapping unobstructed field space advances whichever visible foreground timer is active: wind-up recovery, immutable ball flight, or the complete next-batter handoff. A one-second phase uses the 1.7% base; a fresh ten-second phase advances by 5%, exactly half a second. The duration component approaches a bounded four-point bonus, while Field Hustle raises the base toward 4% with diminishing returns. Input also feeds a quarter-second exponential moving tap rate. Up to four taps per second are fatigue-free; above that grace rate, effectiveness is `1 / sqrt(1 + ((burst rate − 4) / tolerance)^2)`, so ordinary play remains unchanged while macro-speed bursts approach finite sustained throughput. Base tolerance is eight taps per second, and Autonomic Clicking Finger raises it by `1 + 0.50 × log2(rank + 1)`. Independently, every tap on the same timer advances a fraction of the portion that input has not already supplied, producing a smooth asymptote with no fixed floor. Flight taps advance the existing projectile clock without changing sampled speed, path, source, or outcome; lineup taps advance the authoritative cooldown and visible on-deck meter together.

Eight outcome cards contain only name, probability, and compact added delay. Hover or phone tap details explain count/terminal behavior. Strikeout payout sits on its own small line. Player equipment is six compact rarity-colored squares at the field's lower-right; clicking a square opens its sorted slot inventory. Every phone item row reserves a high-contrast two-line identity block—complete name, then Power/rarity/item level—before its explicit Equip, Compare, and protection controls. Passive item text leaves phone scrolling free while a stationary hold opens the full comparison. Opponent equipment mirrors the square language in a vertical strip on the batter's side.

A narrow vertical matchup gauge sits immediately beside that opponent strip. Its YOU marker is the current called-Strike probability and THEM is the complementary batter resistance, so 4% Strike produces 4/96 rather than parity. Marker height and color both carry meaning: red is a bad matchup, orange/yellow is near-even, and green is pitcher control. Desktop hover or phone tap adds the completed-strikeout probability and the older synthetic build ratings for diagnostic context; those ratings no longer drive the visible markers.

The interface targets a 1600×1000 logical canvas, opens maximized, and supports a 1280×800 minimum. Every tab has an independent scroll viewport inside a fixed panel footprint, preventing the field from resizing when tabs change. Portrait Web builds rotate the field and replace desktop sidebars with Upgrades, Status, Log, and Saves overlays. Saves includes a touch-sized Return to Title action. A typed uppercase `RESET` confirmation is required before permanent progress can be erased.

## Prestige I: genetic rebirth

Bambino Rex requires the first body to enter the 115 mph trial band, modestly beyond the fastest verified real pitch while leaving obvious room for the next league. The display rounds the asymptotic approach naturally; the gate accepts 99.9% of the authored limit. Clearing human baseball teleports the field into an alien stadium and reveals Xylophax, Genetic Commissioner. His opening exhibition is guaranteed Grand Slams regardless of mastery, Frustration, gear, or stats. He remains at the plate, taunts after every impact, and fills a twelve-Grand-Slam humiliation meter occupying the future HELP location; offline time cannot advance it. When full, the meter becomes a small red HELP button without interrupting play. Clicking it reveals a portal stranger who says, “Come with me if you want to… be really good at baseball,” immediately performs the first prenatal genetic rebirth, and explains DNA after the player wakes up as a toddler.

```text
DNA = floor((body XP / 10,000,000,000) ^ (1 / 3)) × DNA multipliers
```

A genetic rebirth resets XP, Training, pitches, balls, facilities, opponent access/mastery, distance, live counts, and the Locker. It preserves DNA, genetic upgrades, Arcana, magic, divine rewards, and lifetime statistics. Reverse Terminator Wardrobe is the explicit equipment exception.

| Genetic upgrade | Effect per rank | Cap |
|---|---|---:|
| Remember the Strike Zone | all XP ×1.50 | 5 |
| Fast-Twitch Everything | speed ×1.80 | 6 |
| Compound Pitching Eye | quality +1.25 | 6 |
| Prehensile Pitching Arms | arms, potential sources, and balls per throw ×2 | 3 |
| Alternating Pitching Lobes | Recovery ×2 | 3 |
| Elastic UCL Colony | Recovery ×1.50 | 5 |
| Regulation Ball Gland | payload ×2.50 | 5 |
| Compressed Strike Genome | post-human requirement −1 | 3 |
| Prehensile Outfield Reflex | protect Single, then Double, then Triple | 3 |
| Migratory Baseball Instinct | license one additional human Auto-advance destination | 29 |
| Autonomic Coaching Lobe | license one independently chosen Training auto-buy stat | 9 |
| Predator Scouting Reflex | Auto-scout | 1 |
| Autonomic Wardrobe Lobe | equip the highest-Power item in every unlocked slot | 1 |
| Inherited Scorebook Cortex | opponent mastery requirement ×0.85 | 3 |
| Symbiotic Wardrobe Dermis | equipment effects ×1.20 before aggregate caps | 4 |

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
| Time Compression Ritual | time layers ×2; Recovery ×2; batter downtime ÷2 | 3 |
| Non-Euclidean Bullpen Geometry | simultaneous-ball cap ×4 | 4 |
| Velocity Without Distance | speed ×12 | 4 |
| Eyes Behind the Moon | quality +2 | 5 |
| Causal Seams | payload ×10 | 5 |
| Bullpen Portals | save chance +20 percentage points | 4 |
| Memory of Flesh | DNA gained ×1.50 | 4 |
| Mercy Is Euclidean | mastery ×1.75 | 3 |
| Reverse Terminator Wardrobe | one random equipped slot survives genetic rebirth | 7 |
| One-Size-Fits-All-Realities Uniform | every clone receives full gear bonuses | 1 |
| Front Office Outside Time | unlock independent one-time catalog auto-buy switches | 1 |
| Interstellar Road-Trip Itinerary | license one additional alien Auto-advance destination | 10 |

The eldritch body can reach exactly the speed of light. Octathulhu's causality armor rejects anything slower.

## Loot and equipment

Only completed strikeouts can drop clothing. The ordinary chance is 12%; the first career K guarantees Little Timmy's Oversized Cap and ten dry eligible rolls trigger pity. Hits, walks, Fouls, saved hits, and partial Strikes never roll loot. A drop first selects one player-wearable item visible in the defeated batter's loadout, then creates an item in that exact slot and rarity. Mastery can gently favor the better pieces being worn, but it cannot invent a rarity the batter does not have. The rarity-colored drop callout follows the defeated batter rather than appearing over the pitcher.

Human slots are Hat, Jersey, Jock Strap, Glove, Pants, and Cleats. A seventh post-human slot is Relic. Each item has opponent-capped level, rarity, randomized affixes, and an integer Power calculated from its actual bonuses. Fresh drops show a short rarity-colored field callout but never equip themselves. Slot inventories sort highest-Power first and hold ten items. Overflow removes the lowest-Power eligible item, with rarity and level as tie-breakers; equipped and starred items are protected. Every cleared item yields persistent Scrap equal to `item level × rarity-family value`; the human family uses `1/3/8/20/50`, while alien and eldritch families pay larger values. Scrap is saved for a later system and currently has no cost sink.

The five human rarities are Common, Magic, Rare, Legendary, and Unique. Alien baseball adds Alien Common through Alien Unique to the same pool; the outer league adds Eldritch Common through Eldritch Unique. Later opponents may still wear older families, creating a deliberately broad 15-rarity wardrobe rather than replacing every baseball cap at a story boundary. Human rarity rises across the league until Bambino Rex wears top-tier gear in every ordinary slot. Solus and Octathulhu likewise close their eras in their family's top tier. The equipped square uses a bright rarity-colored border without a redundant icon. The Locker labels `EQUIPPED ITEM`, `TOTAL LOADOUT BONUSES`, `THIS ITEM`, and Scrap separately. Passive row text preserves wheel and touch scrolling; bounded Equip, Compare, and protection controls perform actions. Pointer-oriented browser layouts expose the complete six-stat candidate-versus-equipped comparison on hover. Phone/S-Pen layouts use a stationary hold for the same comparison. A complete outfit is capped at +15% speed, +18% recovery, +500 displayed Quality, +25% strikeout XP, +20% mastery, and +15% range-threat reduction. Symbiotic Wardrobe Dermis amplifies each item by `1.20` per rank before those caps. Speed gear applies after the biological cap, so clothing may exceed a body's nominal maximum without being required to pass a progression gate. All campaign audits disable loot.

Replacement batters use a deterministic, era-aware name generator rather than a short loop. Eight component pools per era feed sixteen formats: single names, first/last, first/middle/last, middle initials, quoted nicknames, origins, titles, and epithets. The same opponent index and batter generation always produce the same identity across save/load, while authored signature opponents such as Little Timmy, Ball-rog, and Octathulhu remain fixed for their first appearance.

Mastery continues past an opponent's unlock target. Every mastery point also adapts the pitcher to that exact opponent: `+120 displayed Quality × log₂(1 + mastery / live target)`, uncapped with diminishing returns. Inherited Scorebook Cortex multiplies every actual target by `0.85` per rank; bars, unlock checks, cosmic completion, matchup adaptation, and the start of overmastery all use that adjusted threshold. Each logarithmic excess-mastery doubling adds a small XP multiplier and improves rarity/affix quality, while item level remains capped to that opponent. An overmastered toddler can drop an excellent level-one cap, not cosmic pants.

Frustration measures bad results rather than elapsed time. On the displayed scale each independently resolved ball adds: Grand Slam `+12000`, Home Run `+8000`, Triple `+5000`, Double `+3000`, Single `+1000`, Ball `+200`, Foul `+100`, and Strike `+0`. It supplies `+80 displayed Quality × log₂(1 + internal points / 4)`, resets on every completed strikeout, and has no hard cap. Its field bar displays the logarithmic progression asymptotically so a nearly full meter communicates diminishing returns rather than a false maximum.

Ordinary time travel erases the Locker. Each Reverse Terminator Wardrobe rank carries one randomly selected equipped item through a genetic rebirth. Autonomic Wardrobe Lobe is the only normal mechanism that automatically equips the highest-Power surviving or newly dropped item in every unlocked slot. Mirror clones initially dilute aggregate gear bonuses until One-Size-Fits-All-Realities Uniform equips the entire bullpen conceptually.

## Prestige III: God Prestige

Defeating Octathulhu marks the cosmos conquered. God says, “Thanks for saving the universe. Wouldn’t the best reward be doing it all again?”, restores everything, and offers one unowned permanent blessing. God Prestige erases XP, lower currencies, genetics, magic, lower reset counts, and loot; blessings, Halos, achievements, and lifetime statistics remain.

The six blessings cover starting speed, mastery, universal ordinary-hit protection, payload, DNA gain, and Arcana gain. All can be collected across six victories. Later victories award stackable Halos, each multiplying XP and mastery by `1.50`. Grand Slams remain terminal even with Angels in the Outfield.

## Distance, camera, and controls

Thirteen authored ranges run from 3 feet through 10, 25, 46, 50, 54, and 60 feet 6 inches, then one mile, low orbit, Earth-to-Moon, one AU, one light-year, and 100,000 light-years. Each range is assigned by opponent level at the same authored unlock threshold; it is not a separate player-selected optimization. The human ladder reaches tee-ball, youth, intermediate, high-school/college, and regulation distances alongside the corresponding classes. Farther stages raise threat and physical flight time but never XP; opponent strikeout bounties are calibrated directly. Long-Toss Mechanics multiplicatively reduces only the threat penalty.

Human-league air uses `v(x)=v₀e⁻ᵏˣ`, so physical flight is `(e^(kd)-1)/(kv₀)` and plate speed is `v₀e⁻ᵏᵈ`; the untouched opening Wiffle Ball intentionally has `k=0` and still takes exactly three seconds. Alien and eldritch fields are vacuum. Visual flight preserves the literal opening and logarithmically compresses extreme durations to a readable ceiling. Previous/next batter controls are always available within unlocked bounds. Selecting a new target sets that opponent's range for the next release and makes the same unresolved pitch meet the new batter, while the released ball preserves its original distance, drag, plate speed, and remaining flight time.

Camera scale maps logarithmically from a close three-foot view toward galaxy width. Human character rings use authored body size rather than raw stat totals, so neither side swells across home plate merely because Command or Speed was trained. The fresh toddler pitcher is roughly 50% larger than the opposing toddler for legibility; purchased ages and BODY modifiers add only modest, authored growth. Post-human arms, clones, and time layers may resume the saturating escalation. Batter intrinsic size ranges from toddlers through huge aliens and field-dominating gods, then shares the same distance perspective. Pitcher and batter use the same point, dark center, and colored-ring language. The pitching arm is a short rectangular limb that drives toward the plate and releases from its tip; the batter's rectangular bat swings toward the incoming ball.

Human fields use muted grass. Alien terrain appears only after the human tier; deep space becomes black with increasingly dense stars, galaxies, and universe-scale rings as the camera retreats.

## Projectile architecture

Simulation and presentation have separate responsibilities but share one authoritative event stream:

- `BaseballGameState` owns economy, exact count state, probabilities, pitch selection, immutable release snapshots, downtime, loot, progression, resets, saving, and offline math.
- `PitchField` owns the top-down visual, GPU instances, pitch/plate meters, batter lifecycle, count icons, return balls, environments, and camera.
- `GameContent` owns authored opponents, name pools, ranges, pitches, ball shells, facilities, loot definitions, prestige upgrades, blessings, and text.
- `Main` owns the responsive spoiler-gated interface and binds state to presentation.

Every human pitch follows `wind-up → release → immutable flight → impact → cooldown`. A release publishes pitch identity and speed but no outcome; only impact reveals the result, so pitcher behavior cannot telegraph a hit. Every projectile snapshots type, exact release and plate speed, air drag, release distance, original and remaining duration, source hand, curve, trail, scale, and color. Upgrades and level changes affect future releases only.

PitchField draws only authoritative releases. Frame time cannot manufacture an extra ball. The plate and simulation clocks suppress releases while no batter is present; returning from a long frame cannot generate a catch-up volley. Missed Strikes and Balls continue beyond the plate at their incoming screen speed and fade. Fouls visibly deflect out of bounds. Fair hits return into the field, and protected hits return toward the bullpen.

Human simultaneous capacity is exactly one. Post-human throwing sources are `arms × bodies × time layers`; purchased arms immediately set the initial usable capacity, and Non-Euclidean Bullpen Geometry expands it by `×4` per rank. The designed maximum is 2,048 balls. One volley samples one pitch and gives every ball that type/color, but each ball independently samples outcome, save defense, count effect, Frustration, and return path. Every ball beyond the opponent's simultaneous bat count multiplies remaining contact chance by `0.18` again. Matching outcomes are called Double, Triple, and so on; mixed calls appear together, fair-hit bases and delays stack, and Strike/ball counts can race to finish the plate appearance. The opening pair uses mirrored opposite curves and larger salvos alternate through progressively wider lanes. The desktop profile's 4,000-instance outbound pool renders every designed projectile one-for-one. The browser profile uses 512 outbound representatives, 96 return balls, 96 stars, and 16 clone bodies before aggregating presentation; the authoritative independent outcomes, XP, mastery, and loot remain identical. CPU-side environment stars and incoherently dense return volleys are batched. Desktop clone limb detail alone is bounded once dozens overlap; the primary pitcher always shows every purchased arm. The development Mac holds 60 FPS fresh and measures 44–60 FPS across a ten-second complete native stress run, with most samples at 58–60. Physical throughput is capped at 20,000 balls/s.

## Save and completion contract

Save version 25 persists body age, BODY modifiers, the toddler-clear proof, and witnessed alien-humiliation progress in addition to the explicit pitch phase, every pending-ball outcome and save flag, selected pitch ID, exact sampled release/plate speed and drag, release distance, original and remaining duration, generated batter identity/loadout, live Strike and Ball counts, 15 additive Training axes, 84 Facilities, cooldown, eight result totals, strikeouts, currencies, upgrades, mastery, outcome-weighted Frustration, manual and automatic tap accounting, unbounded clicker ranks, per-stat/per-catalog automation choices, human and alien Auto-advance capacity, loot with its defeated-batter source, favorites, equipment, Scrap, pity, 130 achievement IDs and durable event history, filters, No Hitter eligibility, peak records, and lifetime statistics. Version 25 accepts every earlier genetic upgrade ID—including the renamed Alternating Pitching Lobes key—and expands old shared-volley pending state into one compatible outcome per saved ball, while older distance, age, exhibition, Frustration, automation, loot, and Training migrations remain intact.

Every automatic save is first written and validated as a pending generation; the preceding valid primary becomes a backup before replacement. Loading selects the newest valid generation, preserves an unreadable primary separately, and refuses to let an older cached executable overwrite a newer schema. If nothing valid remains, automatic writes lock instead of silently replacing the evidence; IMPORT or an explicit typed RESET is required. The product rename retains the original custom application-data directory and save filename for continuity. All platforms expose an autosave plus three device-local manual slots from both the title Resume picker and in-game SAVES overlay. Web builds additionally mirror those slots and rotating primary/rollback generations in localStorage, request persistent browser storage, and write/read back a distinct pre-update checkpoint. Startup chooses the best verified generation using monotonic lifetime progress and timestamps; the checkpoint remains until a successful later save proves it is no longer ahead. Background lifecycle events flush storage, and update activation retains its bounded Later/Update review and reload watchdog. Portable Export/Import remains an optional fallback and the cross-device transfer path; mobile Files providers such as Google Drive can participate through the operating-system picker without granting the game account access.

Version-12 multiplicative Training ranks migrate to equivalent additive ranks; its single lineup modifier becomes the new base-lineup investment while fair-hit recovery starts cleanly. Legacy Command, Spin, and Deception ranks migrate into one additive Command investment. Older saves retain the Belt-to-Jock-Strap migration, ten-item pruning, added outcome slots, count-compression mapping, portal mapping, and conversion of retired prestige systems.

Octathulhu mastery at 1c sets `cosmos_conquered`, unlocks exactly one God Prestige choice, and cannot trigger twice in the same universe. The permanent-progress reset requires the player to type uppercase `RESET`, then erases the save and reinitializes both simulation and field state.
