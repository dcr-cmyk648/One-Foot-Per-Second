# No Hitter — v0.17.0 Balance Audit

## Acceptance policy

The release is balanced against deterministic, frequent-decision, no-loot runners. They choose the strongest saved draft offer for the current frontier, prefer impactful one-time purchases, spend a limited share on Training, farm backward when that produces more XP per second, and prestige when a physical or probability wall is more rational than another asymptotic rank.

This is an aggressive reference player, not a promised completion clock. Random equipment is disabled, active tapping is not required, no unbounded auto-clicker rank is used as hidden power, and no story encounter is skipped. A real player who checks in less often, explores builds, farms favorites, or attempts challenge achievements will take longer.

Current measured landmarks:

| Milestone | Deterministic no-loot time | Physical state |
|---|---:|---|
| Human league complete / first Xylophax contact | about 8 h 45 m–10 h 45 m | 115 mph |
| First playable alien championship complete / Octathulhu contact | about 2 d 17 h | about Mach 5,000 |
| First eldritch ascension | about 2 d 18 h | universe consumed |
| Final Octathulhu reached | about 69 d 15 h with coarse late-game decisions | 5,000c |
| Cosmic resolution | positive finite final-K odds plus focused final-boss contract | 5,000c |

The complete runner has a generous 120-day guardrail so tuning changes fail loudly rather than hanging forever. Exact prestige timing is intentionally seed- and choice-sensitive; the important invariants are meaningful frontier shocks, viable backward farming, multiple resets before each new league clear, and finite physical-license savings.

## Opening state

The fresh player has:

- 1.00 ft/s release speed;
- 3 ft range and a literal 3.00-second flight;
- 0.25 recoveries/s, so a four-second windup begins only after the prior pitch resolves;
- 0.45 internal Quality;
- approximately 51.37% called-Strike probability against the first toddler;
- approximately 21.51% completed-strikeout probability per plate appearance.

That is deliberately bad, but it is not the former `0.25³` dead zone. A strikeout pays 5 base XP rather than the old 15 XP windfall, and every called Strike banks visible matchup Mastery even when the plate appearance later fails.

Human baseball enforces one unresolved ball and a 0.72/s effective Recovery ceiling before equipment. Speed, flight time, batter handoff, and outcome odds therefore all matter; Recovery alone cannot turn youth baseball into an invisible projectile hose.

## Count-state math

The live and aggregate solvers use the same absorbing `(Strikes, Balls)` state machine:

- Strike advances the count and may complete the strikeout;
- Foul advances unless one Strike remains to completion;
- Ball advances and a completed walk terminates like a Single;
- saved contact and two-strike Fouls consume time without erasing the count;
- unsaved fair contact ends the batter;
- only strikeout is an XP-paying terminal state;
- simultaneous post-human balls may advance several counters at one impact.

Alien opponents progress from three toward eight required Strikes and up to four bats. Eldritch opponents reach 64 Strikes and eight bats. Genetic count compression applies only post-human and never reduces the requirement below three. The original larger count continues to determine payout.

## Mastery and Determination

Mastery weights per independently resolved ball are:

| Outcome | Relative ordinary Mastery |
|---|---:|
| Grand Slam | 0 |
| Home Run | 0 |
| Triple | 0.08 |
| Double | 0.12 |
| Single | 0.18 |
| Foul | 0.05 |
| Ball | 0.025 |
| Strike | 1.00 |

A strikeout also adds half a completed count’s base mastery as a completion bonus. Filling the requirement cannot unlock the next level without a strikeout. Excess mastery adds `0.12 internal Quality × log₂(1 + mastery / requirement)` and, after the requirement, small logarithmic XP and loot bonuses.

Determination severity is Grand Slam `+12`, Home Run `+8`, Triple `+5`, Double `+3`, Single `+1`, Ball `+0.20`, Foul `+0.10`, and Strike `+0`. Every resolved ball contributes independently. Four points grant the first `+0.08` internal Quality step; each later equal step needs twice the accumulated score. A strikeout resets the score.

Quality, Threat, and Determination are displayed as whole-number game ratings at ×1,000 presentation scale. Simulation remains in compact internal units; values too large or small for a useful fixed display use scientific notation.

## Difficulty shape

Every league has eleven three-level sub-eras. Within a sub-era, progress is visible but not a total reset. The next sub-era applies a larger threat/range/count/bat shock and creates a high-value draft decision. The no-loot runner regularly falls from comfortable odds into low-single-digit completed-strikeout odds, then recovers through a mixture of backward farming, choices, projects, and permanent upgrades.

The human called-Strike floor is 2.5%. It prevents a mathematically miserable early softlock while still permitting late-human strikeout odds below one tenth of one percent because three Strikes, Balls, Fouls, and fair contact all interact. The floor disappears after human baseball, where arms, bats, count compression, saved hits, and repeated prestige provide additional tactical axes.

Sticky Bambino, Xylophax, Ball-rog, and Octathulhu gates cannot be replaced or completed offline. First-contact exhibitions force their story outcomes rather than offering a misleading `0.0001%` lottery.

## XP and spending

Range has no XP multiplier. Each opponent owns a calibrated strikeout bounty; farther range is already represented by physical flight, drag, threat, and the opponent’s direct reward.

The economy has three lanes:

1. Training costs grow exponentially and provides small repeatable deltas. Every visible base stat has one axis. x10/x100 price the exact sum of sequential rounded ranks and buy the full batch or nothing.
2. Ball shells replace one another. They are meaningful payload upgrades without pretending to render payload as extra fake projectiles.
3. Facilities use 256× their authored baseline price, with premium human capital projects another 4× above that. Their multiplicative effects remain exciting, but the first-lifetime policy buys roughly one or two catalog items per numbered frontier rather than every revealed project immediately.

Training is deliberately the fallback sink, not the best answer to every wall. Speed has high early value and modest built-in Quality. Command remains useful but its repeatable delta is smaller than a strong pitch draft or Facility. At the physical ceiling, Speed Training bends continuously into an asymptote and reports its real next-rank delta; the finite prestige velocity tracks are the practical way through Mach/c licenses.

## Physical anchors

| Boundary | Range concept | Body ceiling / license |
|---|---|---:|
| Fresh | 3 ft | 1 ft/s |
| Human finale | regulation baseball | 115 mph |
| Alien finale | Olympus Mound / planetary arc | Mach 5,000 |
| Final defense | Earth orbit to Pluto | 5,000c |

The championship gate accepts 80% of the post-human era ceiling so an asymptotic stat never requires mathematical infinity. The display and representative pitches still approach the named anchor. Eight genetic Fast-Twitch tiers and six eldritch Velocity Without Distance tiers make those trials reachable across multiple meaningful resets without perfect loot or an impossible repeatable-rank bill.

Human air drag uses the released shell and distance. Plate speed is `release × e^(−kd)` and travel integrates the same deceleration. Alien/eldritch atmosphere is authored by environment. A released projectile never changes because an upgrade was bought after release.

## Run choices

Every finite level grants a perk draft. Its level equals the defeated level, so identical names remain valuable later. Every sub-era finale guarantees Rare-or-better quality and grants a separate Pitch draft. Prestige can add choices and rarity weight, but the baseline board always has a viable stat-category spread and deterministic fallback.

The choice-aware audit saves every offer and scores the actual resulting state rather than assuming every perk exists. A poor draft can be slower, but no tested draft needs perfect gear or a specific single card to satisfy a physical gate. Corrupted cards remain optional high-variance build tools because their negative stat is serialized alongside their 2–3× positive effect.

## Multi-ball and defense

Each ball is authoritative. A volley shares pitch identity and speed family, not outcome.

- Every ball beyond visible bat coverage multiplies remaining contact by 0.18 again.
- Every surplus bat attacks the remaining no-contact chance with the reciprocal 0.42 factor.
- Arms add real simultaneous capacity.
- Clone count determines immutable spatial coverage.
- Catch practice determines the independent catch roll.
- Fielding clearance determines which hit severity is eligible.
- Grand Slams are never eligible.

A human catch retires the batter without XP. A post-human catch preserves the count. Mixed simultaneous results stack Strikes, Balls, bases, and delays before terminal-state resolution.

## Tapping and automation

Manual and automatic input share a rolling 1.5-second tap rate. The effective timer-speed bonus uses a saturating curve with separate rapid-burst fatigue. Long phases receive up to substantially more help than a one-second phase, but input always acts on a shrinking remaining duration rather than deleting a fixed fraction.

Auto-tapper rate grows logarithmically and has no authored rank cap. Eldritch clicker count is separately repeatable. Neither unbounded axis is included as required power in the no-active-input pacing audit.

Automation is capacity-based and never prestiges automatically:

- one genetic license per repeatable Training stat;
- one genetic human destination per auto-advance rank;
- one eldritch alien destination per auto-advance rank;
- later eldritch switches for one-time catalogs;
- no bypass of pending choices or unwitnessed story gates.

## Loot and achievements

Loot is disabled in pacing runners. Normal equipment remains a moderate sidegrade with one to three affixes and aggregate stat caps. Relics are intentionally much larger one-stat effects but have limited slots. Opponent-visible rarity controls the drop pool; overmastery can favor better worn pieces but cannot invent a future tier.

There are 130 achievements. Each adds an additive 0.5% XP, so the complete current catalog supplies ×1.65. The large catalog is permanent flavor and a modest long-run bonus, not a prerequisite for the first clear. Unknown secret achievements reveal no future nouns or mechanics.

## Offline and renderer limits

Offline simulation covers up to seven days. XP and Mastery begin at 1% efficiency and approach 75% through Scorebook Study. Offline play may fill ordinary Mastery but cannot perform a prestige, choose a draft, fill a witnessed exhibition, or bypass a sticky boss.

The finite design tops out at a 2,048-ball volley. Native rendering reserves the entire volley. Browser rendering shows 512 weighted representatives after the exact scene becomes unreadable, while the solver still resolves every ball. A hard 20,000 physical-balls/s guard keeps pathological imported saves finite.

## Release gates

The automated release is rejected if any of these fail:

- campaign is not exactly 33/33/33+1;
- a fresh opening ball is not 1 ft/s for three physical seconds;
- the no-loot human run cannot reach first contact at 115 mph;
- the no-loot multiverse cannot pass Mach-5,000 and 5,000c licenses and reach level 100 inside the guardrail;
- the focused witnessed-final-K contract cannot turn a ready level-100 Octathulhu into cosmic victory;
- mastery-only contact unlocks a level;
- offline play crosses a witnessed boss or exhibition;
- a saved choice rerolls after load;
- an old public save loses permanent progress;
- balls in one volley share outcomes;
- an abandoned volley resolves against a replacement batter;
- desktop or 390×844 phone content clips outside its bounded viewport;
- Web source hashes, artifact hashes, update metadata, and packaged archives disagree.
