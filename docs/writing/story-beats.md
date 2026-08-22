# No Hitter story beat workbook

This is the per-beat authoring source for narrative work. Before changing story copy, future authors read this workbook and `story-voice-seed.md`. For an **IMPLEMENTED** beat, the player edits only **PLAYER PROSE SEED — EDIT THIS**; Codex updates the managed draft and runtime wiring while preserving supplied seed text verbatim. To request a **NEW** beat, copy the template and fill its ID, Trigger / order, Direction, and Player Prose Seed. `IMPLEMENTED` means the ID ships in `RunContent.STORY_BEATS`; `NEW` is intentionally pending and is accepted by the audit. `{{DNA_AWARD}}` is a documented runtime interpolation token and renders as the awarded DNA number.

## Machine-recognizable NEW BEAT template

<!-- NEW BEAT TEMPLATE: copy this entire section; Status: NEW permits no runtime draft -->
## BEAT: new_stable_id
Status: NEW
Trigger / order: Place exactly between `previous_id` and `next_id`; state the runtime condition.
Tier: human | genetic | eldritch | divine
Direction: What changes in the campaign arc and the intended joke/stakes.

### PLAYER PROSE SEED — EDIT THIS

Write user-owned prose here.

### CURRENT GAME DRAFT — CODEX-MANAGED

PENDING — no runtime implementation yet.

## BEAT: prologue_little_timmy
Status: IMPLEMENTED
Trigger / order: Fresh run initialization; first journal popup before level 1.
Tier: human
Direction: Mortal obsession begins as a sincere backyard duel.
### PLAYER PROSE SEED — EDIT THIS
> You stare at your mortal enemy. You feel the sun on your face as your hand clutches the rough contours of your weapon. Your entire body screams as you hurl it towards your foe.
>
> The wiffle ball sails two feet and rolls across the plate, stopping at Little Timmy’s feet. Clearly, you need a little more practice.
### CURRENT GAME DRAFT — CODEX-MANAGED
THREE FEET OF DESTINY — You stare at your mortal enemy. Sun warms your face; your hand closes around the rough plastic contours of your weapon; every tiny muscle screams as you hurl it toward your foe at one foot per second. The Wiffle ball sails two feet, rolls across the plate, and stops at Little Timmy's feet. Clearly, you need a little more practice.

## BEAT: story_tab_explained
Status: IMPLEMENTED
Trigger / order: Fresh run initialization, immediately after `prologue_little_timmy`.
Tier: human
Direction: Explain the durable scorebook.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE SCOREBOOK — The important moments of your campaign are recorded in LOG → STORY. It shows newest entries first; Reverse Order restores the chronology if you are feeling responsible.

## BEAT: arrive_tee_ball
Status: IMPLEMENTED
Trigger / order: Enter level 4, Tee-Ball sub-era.
Tier: human
Direction: The player takes the mound even in tee-ball.
### PLAYER PROSE SEED — EDIT THIS
> You stride forward, knock the pathetic tee to the ground, and take the mound. It is time to show them real baseball.
### CURRENT GAME DRAFT — CODEX-MANAGED
TEE-BALL DIPLOMACY — You stride forward, knock the pathetic tee to the ground, and take the mound. The crowd gasps around its orange slices. It is time to show them real baseball.

## BEAT: little_timmy_hat
Status: IMPLEMENTED
Trigger / order: First kept level-1 loot drop from Little Timmy; once per save, after the strikeout.
Tier: human
Direction: The first defeated batter leaves equipment evidence.
### PLAYER PROSE SEED — EDIT THIS
> Little Timmy trudges away after the strikeout, then stops. “Wait... leave the hat.” The cap remains like a surrendered crown; the Loadout has acquired its first piece of evidence.
### CURRENT GAME DRAFT — CODEX-MANAGED
WAIT... LEAVE THE HAT. — Little Timmy trudges away after the strikeout, then stops. "Wait... leave the hat." His oversized cap remains on the grass like a surrendered crown. EQUIPMENT is now unlocked: open LOADOUT to inspect and equip the things defeated batters abandon.

## BEAT: arrive_coach_pitch
Status: IMPLEMENTED
Trigger / order: Enter level 7, Coach Pitch sub-era.
Tier: human
Direction: Adults organize; the player still defends the mound.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
COACH PITCH, YOUR MOUND — Adults organize the battlefield and call it Coach Pitch. You seize the mound anyway, defending it from aluminum bats and children with frighteningly confident stances. The distance expands; so does the enemy's belief in itself.

## BEAT: arrive_little_league
Status: IMPLEMENTED
Trigger / order: Enter level 10, Little League sub-era.
Tier: human
Direction: Childhood competition becomes an arms race.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE FIRST TRYHARDS — Matching socks appear. Private lessons appear. Somebody arrives with a composite bat and a warranty, as though this were an arms race. You understand that it is.

## BEAT: arrive_middle_school
Status: IMPLEMENTED
Trigger / order: Enter level 13, Middle School sub-era, every lifetime.
Tier: human
Direction: School bureaucracy and puberty raise the mundane stakes.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE AWKWARD LEAGUE — Middle school is a nation of limbs, cracked voices, and grudges conducted through sports. The strike zone is farther away, and one hitter has a laminated scouting report. You will survive this bureaucracy of puberty.

## BEAT: rebirth_middle_school
Status: IMPLEMENTED
Trigger / order: Also on entering level 13, but only after at least one genetic rebirth; records once before `arrive_middle_school`.
Tier: genetic
Direction: Returning to school proves the rebirth cost is real.
### PLAYER PROSE SEED — EDIT THIS
> Middle school… again. I knew it would be a wretched hive of axe body spray and acne, but I was willing to do anything to achieve my goal.
### CURRENT GAME DRAFT — CODEX-MANAGED
MIDDLE SCHOOL… AGAIN — Middle school… again. I knew it would be a wretched hive of axe body spray and acne, but I was willing to do anything to achieve my goal. The goal remains absurdly large. The lockers remain inexplicably sticky.

## BEAT: arrive_high_school
Status: IMPLEMENTED
Trigger / order: Enter level 16, High School sub-era.
Tier: human
Direction: The school joke becomes professionally documented stakes.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
FRIDAY-NIGHT LIGHTS — There are recruiters behind the backstop now. A bad pitch is no longer merely humiliating; it is professionally documented. You take the mound anyway, because destiny has acquired a clipboard.

## BEAT: arrive_small_college
Status: IMPLEMENTED
Trigger / order: Enter level 19, Small College sub-era.
Tier: human
Direction: Baseball adds tuition and emotional debt.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
TUITION AND TENDONS — College baseball offers classes, bus rides, and batters who study release points between assignments. You have entered higher learning, where the final exam has seams. Your student debt is emotional for now.

## BEAT: arrive_division_one
Status: IMPLEMENTED
Trigger / order: Enter level 22, Division I sub-era.
Tier: human
Direction: Analytics cannot stop the next harder pitch.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE BIG CAMPUS — Division I has video rooms, scouts, and an analytics department devoted to explaining why your last pitch was a mistake. You nod as if this is wisdom. Then you throw the next one harder.

## BEAT: arrive_lower_minors
Status: IMPLEMENTED
Trigger / order: Enter level 25, Lower Minors sub-era.
Tier: human
Direction: Professional baseball begins with buses and grudges.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE LONG BUS — Professional baseball begins with motel bullpens, meal money, and a bus that smells like an oath. The batters can read spin before the ball leaves your hand. You begin plotting revenge before it lands.

## BEAT: arrive_upper_minors
Status: IMPLEMENTED
Trigger / order: Enter level 28, Upper Minors sub-era.
Tier: human
Direction: Foreshadow the invasion bracket and a prior-cycle echo.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
ONE CALL AWAY — Every batter has packed for the majors. Each at-bat is a job interview conducted with a maple bat and no human resources department. Yet the same impossible signs keep appearing in every scouting report: four columns, a red diamond, a game nobody remembers scheduling. Your obsession feels less like ambition than a replay from a season reality forgot.

## BEAT: arrive_major_leagues
Status: IMPLEMENTED
Trigger / order: Enter level 31, Major Leagues sub-era.
Tier: human
Direction: The final human league confirms the suspicious observer.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE SHOW — The last mortal league is waiting. Nobody here is impressed by your Wiffle-ball origin story, which is rude because it was clearly prophetic. The cameras linger on a fourth empty seat behind home plate. They have the bats to prove it; you have the mound.

## BEAT: bambino_arrival
Status: IMPLEMENTED
Trigger / order: Human league boss becomes sticky at level 33 (also recorded on clear as a once-safe fallback).
Tier: human
Direction: End the mortal age before first contact.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
BAMBINO REX — Bambino Rex enters as the last human champion, wearing the expression of someone who believes progress bars are beneath him. The whole mortal age holds its breath. Only a strikeout ends this ridiculous era of baseball.

## BEAT: xylophax_portal
Status: IMPLEMENTED
Trigger / order: Clear human level 33 before genetic rebirth; queues alien transmission.
Tier: genetic
Direction: Reveal Earth as an alien baseball invasion-bracket game.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
YOU THINK YOU'RE HOT STUFF — A portal opens over the diamond. An alien crowd is already booing in several frequencies. Their invasion bracket has reached Earth, and its human-esque champion carries four bats. Xylophax asks whether humanity sent its best toddler.

## BEAT: alien_arrival_popup
Status: IMPLEMENTED
Trigger / order: Special `AlienArrivalDialog`, after accepting the pending alien transmission and before the Xylophax exhibition.
Tier: genetic
Direction: Xylophax declares Earth lost under baseball law and proves impossible superiority.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
SO YOU THINK YOU'RE HOT STUFF — The stadium folds inside out. You, the mound, and several confused alien hot-dog vendors are teleported beneath a sky full of cheering aliens. Their human-esque champion has finished Earth's invasion-bracket game, and Commissioner Xylophax now steps to the plate with four bats. By baseball law, he declares Earth lost; then he demonstrates why the Power display has begun laughing at you.

## BEAT: genetic_help
Status: IMPLEMENTED
Trigger / order: Journal beat when the alien exhibition humiliation meter reaches 100%; before portal acceptance.
Tier: genetic
Direction: Offer the reckless time-travel solution.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
COME WITH ME — A stranger steps through a smaller portal. “Come with me if you want to… be really good at baseball.” The pause was legally necessary.

## BEAT: alien_help_popup
Status: IMPLEMENTED
Trigger / order: Special `AlienHelpDialog`, after accepting the 100% alien-help offer and before genetic rebirth.
Tier: genetic
Direction: Make the prenatal genetics waiver concrete.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
A MAN STEPS OUT OF A PORTAL — He watches Xylophax turn another perfect pitch into an unavoidable Grand Slam. Then he lowers his sunglasses. “Come with me if you want to… be really good at baseball.” He has a Time Machine and an alarming prenatal genetics waiver. Getting into the portal will restart this life immediately.

## BEAT: first_rebirth
Status: IMPLEMENTED
Trigger / order: First successful genetic rebirth; once per save.
Tier: genetic
Direction: Toddlerhood returns with retained modifications and interstellar ambition.
### PLAYER PROSE SEED — EDIT THIS
> You wake up as a toddler again. Was it all a dream? Then you notice your… modifications. You pick up a wiffle ball with a sense of determination and look at the confused toddler squaring off at the plate. “Your time has come, Little Timmy. You shall be the first to fall in my conquest of the stars.” Little Timmy blinks and wipes sticky sno-cone residue on his jersey. No matter, your ambitions range far beyond this preschool.
### CURRENT GAME DRAFT — CODEX-MANAGED
BORN AGAIN, WITH NOTES — You wake up as a toddler again. Was it all a dream? Then you notice your modifications. You pick up a Wiffle ball with determination and look at the confused toddler at the plate. “Your time has come, Little Timmy. You shall be the first to fall in my conquest of the stars.” Little Timmy blinks and wipes sticky sno-cone residue on his jersey. No matter: all prestige upgrades are retained, and your ambitions range far beyond this preschool.

## BEAT: genetic_rebirth_explanation_popup
Status: IMPLEMENTED
Trigger / order: Special `GeneticRebirthExplanationDialog`, immediately after the first successful genetic rebirth.
Tier: genetic
Direction: Explain retained DNA without spoiling later prestige layers.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
WELCOME BACK, TINY — You wake up as a toddler again. Baseball chronology is optional. You gained {{DNA_AWARD}} DNA. Spend it in BODY → DNA on permanent genetic upgrades before growing through the human leagues again. All prestige upgrades are retained on later genetic rebirths.

## BEAT: genetic_replay
Status: IMPLEMENTED
Trigger / order: Each successful genetic rebirth after the first; once journal ID per save.
Tier: genetic
Direction: Repeated rebirth makes Little Timmy uneasy.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
LITTLE TIMMY HAS CONCERNS — The backyard is unchanged. You are not. Little Timmy is trying not to stare at the additional anatomy.

## BEAT: alien_olympus
Status: IMPLEMENTED
Trigger / order: Alien league boss becomes sticky at level 66 (also recorded on clear as a once-safe fallback).
Tier: genetic
Direction: Return to Xylophax after Earth’s premature legal defeat.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
OLYMPUS MOUND — Xylophax waits across Mars with four bats and the authority to call this regulation distance. By alien baseball law, Earth was declared lost when its champion fell; your rebirth has made that paperwork embarrassingly premature.

## BEAT: octathulhu_contact
Status: IMPLEMENTED
Trigger / order: Clear alien level 66 before eldritch ascension; queues eldritch transmission.
Tier: eldritch
Direction: The player’s prowess tears reality and attracts elder baseball gods.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
SOMETHING WANTS TO PLAY — Your impossible pitching has torn a seam through the standings and into older realities. Eight bats unfold beyond the scoreboard, each held by an arm that should not have an elbow. Octathulhu will eat the universe unless you beat him at baseball. Take the mound before the elder gods file a roster correction.

## BEAT: eldritch_arrival_popup
Status: IMPLEMENTED
Trigger / order: Special `EldritchArrivalDialog`, after accepting the pending eldritch transmission and before the Octathulhu exhibition.
Tier: eldritch
Direction: Show the reality tear as the direct cause of the elder encounter.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
SOMETHING WANTS TO PLAY — The alien crowd stops making noise. Your pitching has opened a seam past their bracket and into something older; eight bats unfold beyond the scoreboard, each held by something too large for the current reality. Octathulhu has mistaken the universe for a baseball. It would like to bat.

## BEAT: universe_eaten
Status: IMPLEMENTED
Trigger / order: Eldritch exhibition doom meter reaches 100%; once per save.
Tier: eldritch
Direction: Failure costs the universe in scorebook order.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
FINAL SCORE: UNIVERSE 0 — Octathulhu hits another Grand Slam and eats the stadium, the league, and causality in that order. You had one job. It was baseball.

## BEAT: first_eldritch_rebirth
Status: IMPLEMENTED
Trigger / order: First successful eldritch ascension; once per save.
Tier: eldritch
Direction: A destroyed cycle becomes a multiversal bullpen.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
A LESS DOOMED REALITY — Your consciousness lands in another backyard. Copies of you from nearby realities have also received the memo. The universe has a bullpen now, and its eldritch clipboard is somehow in triplicate.

## BEAT: earth_defense
Status: IMPLEMENTED
Trigger / order: Immediately after `first_eldritch_rebirth`; once per save.
Tier: eldritch
Direction: Alien-league fame returns to defend Earth.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
EARTH'S BULLPEN — You return to Earth with alien-league fame and an extremely bad warning. Governments build a mound in orbit because pitching from the ground would destroy the ground. The opposing lineup is approaching from every planet.

## BEAT: ball_rog
Status: IMPLEMENTED
Trigger / order: Clear level 99 (`ELDRITCH_FINAL_INDEX` = 98, zero-based); records before level 100 unlocks.
Tier: eldritch
Direction: Escalate toward the final god through an unstrikeable cosmic batter.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
BALL-ROG, THE UNSTRIKEABLE — Beyond Pluto, gravity itself carries a bat. Ball-rog considers called Strikes a personal insult.

## BEAT: octathulhu_final
Status: IMPLEMENTED
Trigger / order: Enter final level 100; boss becomes sticky (also recorded on clear as a once-safe fallback).
Tier: eldritch
Direction: Finalize the eightfold baseball stakes.
### PLAYER PROSE SEED — EDIT THIS
> Octathulhu will eat the universe unless you can beat him at baseball.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE FINAL INNING — Octathulhu returns with eight arms, eight bats, and the confidence of a god who has already eaten one box score.

## BEAT: cosmic_victory
Status: IMPLEMENTED
Trigger / order: Clear level 100; before divine-offer bookkeeping.
Tier: divine
Direction: Reward an irregular pitcher for literal cosmic survival.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
NO HITTER — The universe survives because one increasingly irregular pitcher became very good at baseball.

## BEAT: god_offer
Status: IMPLEMENTED
Trigger / order: Clear level 100; once per save after `cosmic_victory`.
Tier: divine
Direction: Divine reward lands as benefits bureaucracy.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
WOULDN'T THE BEST REWARD BE DOING IT AGAIN? — God thanks you for saving creation and offers to reset absolutely everything. The benefits office has, somehow, prepared a bonus package.

## BEAT: endless_unlocked
Status: IMPLEMENTED
Trigger / order: A subsequent level-100 clear after a divine ascension, when Extra Innings first unlocks.
Tier: divine
Direction: The scorebook ends; the on-deck circle does not.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
EXTRA INNINGS — Octathulhu is out again. God quietly admits that the official scorebook ends here, then points toward an infinite on-deck circle full of increasingly unreasonable opponents. You may enter Extra Innings—or reset the universe again whenever you prefer.

## Legacy migration-only journal entries

`human_school_ball`, `human_college`, `human_minors`, and `human_majors` are implemented only as save-migration journal IDs for pre-v26 saves; they do not have current runtime triggers. Their managed drafts remain in `RunContent.STORY_BEATS`, and the audit requires workbook coverage below.

## BEAT: human_school_ball
Status: IMPLEMENTED
Trigger / order: Legacy migration for saves at level 13+; no current trigger.
Tier: human
Direction: Legacy school bridge.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE SCHOOL HAS A TEAM — The school has a team now, and somebody keeps statistics like a witness to your crimes. The mound is farther away; the batters are taller. You prepare to make attendance mandatory.

## BEAT: human_college
Status: IMPLEMENTED
Trigger / order: Legacy migration for saves at level 19+; no current trigger.
Tier: human
Direction: Legacy college bridge.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
A SCHOLARSHIP OF QUESTIONABLE VALUE — Baseball now has tuition, scouts, and an alarming amount of video analysis. You enroll in the ancient elective called Throwing It Past Them. The syllabus is mostly pain.

## BEAT: human_minors
Status: IMPLEMENTED
Trigger / order: Legacy migration for saves at level 25+; no current trigger.
Tier: human
Direction: Legacy professional bridge.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE LONG BUS — Professional baseball begins with motel bullpens, meal money, and fourteen consecutive hours on a bus. You emerge with a stiff back and a sharper grudge. The hitters have made a mistake by existing nearby.

## BEAT: human_majors
Status: IMPLEMENTED
Trigger / order: Legacy migration for saves at level 31+; no current trigger.
Tier: human
Direction: Legacy final-human bridge.
### PLAYER PROSE SEED — EDIT THIS
No supplied seed.
### CURRENT GAME DRAFT — CODEX-MANAGED
THE SHOW — The last mortal league is waiting. Nobody here is impressed by your Wiffle-ball origin story. You take this personally, which is the only proper response.
