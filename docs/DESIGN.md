# No Hitter — Roguelike Campaign Design

## The joke and the promise

No Hitter begins with a toddler pitcher, a wiffle ball, a three-foot mound, and a literal one-foot-per-second throw. It ends with a plural, heavily modified pitching organism defending Earth from an eight-bat octopus god across the solar system. The simulation stays legible while the premise becomes unreasonable.

The design has five pillars:

1. Only a completed strikeout pays XP.
2. Every run asks the player to choose a build instead of buying every body and pitch upgrade.
3. Human baseball stays recognizable; prestige is what gives the game permission to become absurd.
4. Displayed speed, range, drag, and travel time describe the same immutable released projectile.
5. Future layers remain secret until the story reveals them.

## Campaign structure

The finite campaign contains exactly 100 numbered levels.

| Layer | Levels | Physical finale | Structural finale |
|---|---:|---|---|
| Human | 1–33 | 115 mph at regulation distance | Bambino Rex |
| Alien | 34–66 | about Mach 5,000 from Olympus Mound | Xylophax, Genetic Commissioner |
| Eldritch | 67–99 | approaching 5,000c from Earth toward Pluto | Ball-rog, the Unstrikeable |
| Final | 100 | Earth-to-Pluto causality trial | Octathulhu, God of the Eightfold Swing |

Each league has eleven three-level sub-eras. A sub-era changes the class, range, visual scale, threat curve, story context, guaranteed reward quality, and available one-time projects. Pitch drafts use a separate, predictable cadence: every five cleared numbered levels, plus each off-cadence league boss. Human sub-eras move through backyard play, tee ball, youth and school leagues, college, the minors, and professional baseball. Alien baseball expands from local planetary leagues to the Olympus championship. Eldritch baseball begins with Earth’s orbital defense platform and meets approaching gods across the solar system.

Xylophax and Octathulhu also have unnumbered first-contact exhibitions. These are witnessed story gates, not lottery fights. The opponent repeatedly hits guaranteed Grand Slams while a visible humiliation/doom meter fills. Offline play cannot fill either meter, and pitching does not begin before the introductory dialog closes.

After the first divine restoration, returning to the final boss unlocks procedural Extra Innings. Endless opponents borrow any previously revealed visual family, scale forever, and keep awarding run choices. God Prestige remains available.

## One plate appearance

Human play enforces one unresolved pitch:

```text
recover → select pitch → release immutable ball → physical flight → resolve
        → strike/ball/foul continues the count
        → hit/walk/strikeout replaces the batter → lineup wait → recover
```

A human batter needs three Strikes and four Balls. A two-strike Foul consumes time but does not add another Strike. A walk ends the plate appearance like a Single. Home Runs and Grand Slams teach no mastery, and Grand Slams can never be saved.

Post-human volleys resolve every real ball independently. All arms in a volley throw the same selected pitch, with mirrored or separated arcs, but each ball owns its outcome, defense roll, count contribution, and return path. More balls than bats compound a severe contact penalty; surplus bats apply the reciprocal advantage. Matching calls become Double Strike, Triple Single, and so on. Mixed calls display together, add hit bases and delays, and may complete Strike and Ball counts in the same impact.

When an overlapping eldritch volley loses its original batter, it does not silently retarget. Its projectiles lose targeting, veer in deterministic random directions, and fade quickly without resolving against the replacement.

## Progression and Mastery

Only a completed strikeout awards XP. Useful results still teach the exact matchup:

- Called Strike: full count-share of mastery.
- Strikeout: additional completion mastery.
- Triple, Double, Single, Foul, and Ball: small severity-aware mastery.
- Home Run and Grand Slam: none.

Mastery immediately adds logarithmic matchup Quality. Filling the requirement marks an opponent ready, but the next numbered level opens only when a strikeout occurs. If that strikeout crosses the threshold, it clears immediately. Finale opponents become sticky bosses when the next strikeout can finish the level; leaving and returning cannot replace them, and offline aggregation cannot bypass them.

Overmastery keeps a favorite opponent useful. Each logarithmic lap slightly improves XP, drop luck, and the matchup itself while loot level remains capped to that opponent. The bar repeatedly fills over itself with greener colors instead of freezing at 100%.

Determination is the temporary bad-luck smoother. Bad results add severity points, rapid taps add a small amount, and a strikeout resets it. Its Quality bonus is uncapped but logarithmic, so a terrible run always improves without becoming an instant win.

## Run drafts

Age, physique, special training focus, and learned pitches are run-scoped choices.

- Every numbered level clear queues a deterministic saved perk offer.
- The perk level equals the defeated level and scales its magnitude.
- Normal rarity is random and can be improved by permanent upgrades.
- Every sub-era finale guarantees Rare-or-better perk quality. Every fifth numbered level and each authored boss separately queues a Pitch draft.
- A Pitch draft learns a new pitch or levels an existing one; bosses offer the strangest pitches.
- A cheap genetic license adds boss-perk rewards on future Bambino clears.
- Auto-advance may queue multiple offers, but never discards or rerolls them.

Offer generation uses the saved run seed and choice serial. Options are serialized when created, so reloading cannot reroll them and later balance patches cannot mutate an already offered card. The default offer has two cards; prestige can increase the board and improve its dice.

Corrupted perks require an eldritch unlock. Each eligible card independently has a 20% replacement chance. A corrupted card multiplies its positive effect by a saved random 2–3× and adds one meaningful negative stat.

Skipping age perks keeps the player a toddler and supports the secret human-league toddler challenge. The next sequential age remains an optional ordinary card, but gains quadratic selection weight after its authored normal level; the real two-card audit reaches full adulthood by the human finale reward in about 88% of runs that always choose an offered age. Age cards derive and display their exact Speed, Quality, Recovery, and Size step from gameplay data. Selected adjectives compose in the subtitle. Clones pluralize only the final body noun, preserving the complete ridiculous description.

## Spending and reset layers

The run economy has three distinct jobs:

- **Training** is the uncapped incremental sink. Every displayed run stat has one repeatable axis, and x1/x10/x100 buys the exact rounded full batch or nothing.
- **Balls** replace the current shell and provide clear payload/physical identity upgrades.
- **Facilities** are expensive, one-time multiplicative jumps and deliberate savings targets.

The Pitch tab is a read-only arsenal because pitch acquisition belongs to drafts. The BODY tab shows selected run perks plus only the prestige sections the player has revealed.

Genetic rebirth resets the run for DNA based on run XP. It unlocks biology, arms, count compression, draft manipulation, Training automation, human auto-advance capacity, and auto-tappers. Extra arms automatically add matching simultaneous-ball capacity.

Eldritch ascension destroys the current reality for Arcana based on DNA earned in that reality. It also resets genetics. Eldritch upgrades add mirror clones, portals, corrupted drafts, overlapping windups, Relic slots, alien auto-advance, catalog automation, additional auto-clickers, and the velocity layers needed for 5,000c.

God Prestige follows the level-100 victory. God suggests that the proper reward for saving the universe is doing it again. One permanent blessing is chosen; later wins collect the others and then Halos. Achievements, story knowledge, and lifetime records survive.

Automation never chooses a prestige or crosses an unwitnessed story gate. Basic-stat auto-buy is licensed one stat at a time. Human and alien auto-advance capacity is purchased one destination at a time. One-time catalog automation belongs to the eldritch layer.

## Active tapping

Manual and automatic field input feed the same 1.5-second rolling tap-rate signal. A smooth saturating curve converts that rate into faster recovery, lineup motion, and projectile progress. During flight, the ball visibly accelerates and loses effective drag; it never teleports.

Long waits receive more help than one-second waits. Repeated input on one timer and ultra-fast bursts each add separate diminishing returns, with no arbitrary “taps may only supply half” wall. Genetic ranks improve one auto-tapper’s logarithmic rate and fatigue tolerance; eldritch ranks add more clickers that inherit those values. The field renders a labeled pulse per clicker and a multi-lap circular tap meter.

## Physical scale and rendering

The opening wiffle ball travels three feet at one foot per second for three seconds. Human development approaches 115 mph. Alien development approaches Mach 5,000 at Olympus Mound. Eldritch development approaches 5,000 times light speed across Earth-to-Pluto range.

Each release snapshots pitch, source, target generation, randomized release speed, drag, plate speed, duration, path, curve, color, and trail. Later purchases affect later balls only. Human fields model air drag; alien and eldritch environments use their authored atmosphere. The Live Throw Profile shows the last released pitch after impact so its telemetry remains inspectable.

Missed Strikes and Balls continue at their existing visual speed through the plate and fade. Only contacted balls create return trajectories. The arm is a short rectangle that moves through release; enemy bats are separate, independently animated rectangles arranged around the body.

The camera compresses distance logarithmically, but character scale shrinks aggressively before applying a small legibility floor. Mortal bodies never imply hundreds of feet of width. Environment transitions carry the scale joke from grass to alien ground to star-dense space.

Native rendering reserves every designed outbound projectile through the 2,048-ball finite volley. Browser rendering draws 512 weighted outbound representatives once the exact scene would become unreadable. That visual ceiling never changes combat, counts, XP, mastery, or loot.

## Equipment and Relics

A strikeout may copy an item from the defeated batter’s visible loadout. The slot and rarity come from something the opponent is actually wearing, so a Legendary hat advertises a real Legendary-hat chance. The callout appears over the batter and nothing auto-equips by default.

Ordinary equipment has one to three affixes regardless of rarity. Rarity raises magnitude rather than merely adding more lines. Every run stat is eligible, including genuine positive/negative tradeoffs. Integer Power is a convenient sort, not a promise that an item is best for every build.

Each slot stores ten items. Equipped and starred items are protected; overflow scraps the lowest-Power eligible item and records material. Relics unlock after human baseball, start with one slot, and each grant one enormous stat effect. Eldritch upgrades add slots. Clone equipment requires its own upgrade.

## Story, names, achievements, and disclosure

The Story tab stores every revealed beat and popup, newest first by default, with a saved Reverse Order switch. A fresh slot immediately presents the one-foot-per-second prologue; each authored first-lifetime human sub-era records its distinct arrival only when the player actually enters it after resolving rewards. Genetic-replay and eldritch-replay variants remain separate one-time entries. The title illustration and subtitle also advance only through known history.

For future narrative work, read [the story voice seed](writing/story-voice-seed.md) first. It is the primary source for authorial voice and canonical story facts; shipped runtime copy remains authored in `scripts/run_content.gd`, never parsed from Markdown.

Ordinary names use a broad grammar of single names, initials, multiple given names, surnames, nicknames, and era-appropriate titles. Authored bosses keep exclusive signatures. Later eras progressively relax the rules into alien and Elden-Ring-style absurdity.

Achievements are permanent and additive at +0.5% XP each. Hidden achievements occupy visible anonymous slots but reveal no name, condition, progress, or future subject. New mechanics should normally ship with a few funny event achievements. The extreme secret No Hitter requires a complete post-victory campaign without any fair contact.

## Responsive interface and spoiler contract

Desktop uses a three-column composition when space permits and collapses side content before clipping. Portrait Web rotates the field so the pitcher is below the batter and moves menus into bounded overlays. Passive text scrolls; only explicit buttons buy, equip, compare, or open details. Desktop hover and stationary phone hold expose the same information, while movement cancels hold inspection so lists remain scrollable.

Future terms—DNA, aliens, Arcana, clones, divinity, endless play—do not appear in tabs, help, save summaries, achievements, or title art before their reveal. Once revealed, save rows include the applicable prestige balances so a fresh reset is distinguishable from an old run.

## Save and release contract

Save schema 28 migrates every public generation. Old 30/10/5 campaign positions map by authored position inside their league, not raw global multiplication. Old body stages and purchased pitches become deterministic equivalent legacy run perks and pitch levels for the loaded body. Prestige currencies, upgrades, equipment, achievements, story knowledge, lifetime counters, pending choices, active volleys, and update checkpoints are preserved.

Writes use validated pending, primary, and backup generations. Browser builds additionally keep rotating Web mirrors and a pre-update checkpoint, flush persistent storage before activation, and choose the most advanced valid generation after reload. Portable Export/Import remains the cross-device fallback, not the normal update path.

Browser, installed PWA, macOS, Windows, Linux, GitHub Pages, and Sites all ship the same Godot source and save schema. Platform-specific differences are presentation ceilings and packaging only.
