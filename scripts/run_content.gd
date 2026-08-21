class_name NoHitterRunContent
extends RefCounted

const Campaign = preload("res://scripts/campaign.gd")

const PERK_RARITIES := [
	{"id": "common", "name": "COMMON", "rank": 0, "factor": 1.00, "color": "a9b6c5", "weight": 72.0},
	{"id": "magic", "name": "MAGIC", "rank": 1, "factor": 1.35, "color": "66a6ff", "weight": 20.0},
	{"id": "rare", "name": "RARE", "rank": 2, "factor": 1.85, "color": "ffd45c", "weight": 6.0},
	{"id": "legendary", "name": "LEGENDARY", "rank": 3, "factor": 2.70, "color": "ff914d", "weight": 1.8},
	{"id": "boss", "name": "BOSS", "rank": 4, "factor": 4.25, "color": "d68cff", "weight": 0.2},
]

# Perks own one clear primary effect.  The magnitude is calculated from the
# defeated level and rolled rarity; cards store the resolved effect so changing
# balance later never mutates an already chosen run.  `operation` is one of:
# add, multiplier, or reduction (where a positive magnitude lowers a factor).
const RUN_PERKS := [
	# Velocity and physical delivery.
	{"id": "pool_noodle_ligament", "name": "Pool-Noodle Ligament", "league": "human", "stat": "speed", "operation": "multiplier", "base": 0.035, "level_growth": 0.065, "description": "Your arm is now medically classified as flexible."},
	{"id": "dad_said_throw_hard", "name": "Dad Said Throw Harder", "league": "human", "stat": "speed", "operation": "multiplier", "base": 0.045, "level_growth": 0.060, "description": "Elite instruction from a folding chair."},
	{"id": "radar_gun_stage_fright", "name": "Radar-Gun Stage Fright", "league": "human", "stat": "speed", "operation": "multiplier", "base": 0.055, "level_growth": 0.055, "description": "The number is watching. Perform."},
	{"id": "rotator_cuff_subscription", "name": "Rotator-Cuff Subscription", "league": "human", "stat": "speed", "operation": "multiplier", "base": 0.065, "level_growth": 0.050, "min_level": 12, "description": "Monthly tendons. Cancel anytime except during arbitration."},
	{"id": "fast_twitch_firmware", "name": "Fast-Twitch Firmware", "league": "alien", "stat": "speed", "operation": "multiplier", "base": 0.12, "level_growth": 0.045, "description": "Your muscle now has patch notes."},
	{"id": "solar_windup", "name": "Solar Windup", "league": "alien", "stat": "speed", "operation": "multiplier", "base": 0.16, "level_growth": 0.040, "description": "Release powered by a small, avoidable flare."},
	{"id": "velocity_without_cause", "name": "Velocity Without Cause", "league": "eldritch", "stat": "speed", "operation": "multiplier", "base": 0.28, "level_growth": 0.035, "description": "The ball moves first. Your arm apologizes later."},
	{"id": "redshifted_elbow", "name": "Redshifted Elbow", "league": "eldritch", "stat": "speed", "operation": "multiplier", "base": 0.36, "level_growth": 0.032, "description": "Orthopedists observe it only in the distant past."},

	# Command and matchup quality.
	{"id": "chalk_dust_clairvoyance", "name": "Chalk-Dust Clairvoyance", "league": "human", "stat": "quality", "operation": "add", "base": 0.055, "level_growth": 0.075, "description": "You can almost see the rectangle."},
	{"id": "catchers_glove_hypnosis", "name": "Catcher's-Glove Hypnosis", "league": "human", "stat": "quality", "operation": "add", "base": 0.070, "level_growth": 0.068, "description": "Stare at the target until it becomes true."},
	{"id": "scouting_report_osmosis", "name": "Scouting-Report Osmosis", "league": "human", "stat": "quality", "operation": "add", "base": 0.085, "level_growth": 0.060, "min_level": 9, "description": "Sleep directly on the spray chart."},
	{"id": "umpire_vibes", "name": "Immaculate Umpire Vibes", "league": "human", "stat": "quality", "operation": "add", "base": 0.105, "level_growth": 0.055, "min_level": 18, "description": "It looked like a strike from over here."},
	{"id": "compound_pitching_retina", "name": "Compound Pitching Retina", "league": "alien", "stat": "quality", "operation": "add", "base": 0.20, "level_growth": 0.045, "description": "Every seam gets its own pupil."},
	{"id": "predictive_strike_zone", "name": "Predictive Strike Zone", "league": "alien", "stat": "quality", "operation": "add", "base": 0.28, "level_growth": 0.040, "description": "The zone arrives one pitch early."},
	{"id": "omniscient_corner", "name": "The Omniscient Corner", "league": "eldritch", "stat": "quality", "operation": "add", "base": 0.55, "level_growth": 0.032, "description": "Every corner, including those geometry forgot."},
	{"id": "called_strike_prophecy", "name": "Called-Strike Prophecy", "league": "eldritch", "stat": "quality", "operation": "add", "base": 0.72, "level_growth": 0.030, "description": "The scorebook was filled before creation."},

	# Recovery and lineup tempo.
	{"id": "loose_elbow_policy", "name": "Loose-Elbow Policy", "league": "human", "stat": "recovery", "operation": "multiplier", "base": 0.025, "level_growth": 0.060, "description": "The waiver is laminated."},
	{"id": "bucket_bullpen_memory", "name": "Five-Gallon Bullpen Memory", "league": "human", "stat": "recovery", "operation": "multiplier", "base": 0.035, "level_growth": 0.055, "description": "Sit, throw, repeat, question nothing."},
	{"id": "espresso_artery", "name": "Bullpen Espresso Artery", "league": "human", "stat": "recovery", "operation": "multiplier", "base": 0.050, "level_growth": 0.048, "min_level": 15, "description": "Cardiovascularly inadvisable readiness."},
	{"id": "alternating_lobe_warmup", "name": "Alternating-Lobe Warmup", "league": "alien", "stat": "recovery", "operation": "multiplier", "base": 0.11, "level_growth": 0.040, "description": "One hemisphere rests while another signs the waiver."},
	{"id": "chronal_between_pitches", "name": "Chronal Time Between Pitches", "league": "alien", "stat": "recovery", "operation": "multiplier", "base": 0.15, "level_growth": 0.035, "description": "Recovery occurs in a cheaper second."},
	{"id": "seventh_inning_at_once", "name": "The Seventh Inning, All at Once", "league": "eldritch", "stat": "recovery", "operation": "multiplier", "base": 0.28, "level_growth": 0.030, "description": "Rest is a spatial direction now."},
	{"id": "organized_snack_line", "name": "Organized Snack Line", "league": "human", "stat": "lineup", "operation": "reduction", "base": 0.025, "level_growth": 0.060, "description": "The next batter already has orange slices."},
	{"id": "on_deck_bureaucracy", "name": "Reduced On-Deck Bureaucracy", "league": "human", "stat": "lineup", "operation": "reduction", "base": 0.040, "level_growth": 0.052, "min_level": 6, "description": "One fewer clipboard before every at-bat."},
	{"id": "teleporter_dugout", "name": "Teleporter Dugout", "league": "alien", "stat": "lineup", "operation": "reduction", "base": 0.11, "level_growth": 0.038, "description": "The on-deck circle is now a point."},
	{"id": "batter_already_here", "name": "The Batter Was Always Here", "league": "eldritch", "stat": "lineup", "operation": "reduction", "base": 0.22, "level_growth": 0.028, "description": "Please do not inspect the dugout."},
	{"id": "emotionally_supportive_backstop", "name": "Emotionally Supportive Backstop", "league": "human", "stat": "hit_delay", "operation": "reduction", "base": 0.035, "level_growth": 0.055, "description": "The fence says the Home Run was not your fault."},
	{"id": "souvenir_retrieval_intern", "name": "Souvenir-Retrieval Intern", "league": "human", "stat": "hit_delay", "operation": "reduction", "base": 0.050, "level_growth": 0.048, "min_level": 12, "description": "Unpaid and extremely fast over fences."},
	{"id": "wormhole_ball_return", "name": "Wormhole Ball Return", "league": "alien", "stat": "hit_delay", "operation": "reduction", "base": 0.13, "level_growth": 0.036, "description": "The souvenir exits before it lands."},
	{"id": "unhappened_home_run", "name": "The Home Run That Unhappened", "league": "eldritch", "stat": "hit_delay", "operation": "reduction", "base": 0.24, "level_growth": 0.028, "description": "The delay remembers. Reality does not."},

	# Arsenal, payload, mastery, loot, and active/away play.
	{"id": "catcher_calls_something_else", "name": "Catcher Calls Literally Anything Else", "league": "human", "stat": "calling", "operation": "multiplier", "base": 0.045, "level_growth": 0.050, "description": "Statistically less Dead-Fish Lob."},
	{"id": "telepathic_signs", "name": "Telepathic Signs", "league": "alien", "stat": "calling", "operation": "multiplier", "base": 0.14, "level_growth": 0.035, "description": "No mound visit. No privacy either."},
	{"id": "pitch_that_chooses_you", "name": "The Pitch That Chooses You", "league": "eldritch", "stat": "calling", "operation": "multiplier", "base": 0.30, "level_growth": 0.027, "description": "Your arsenal has opinions."},
	{"id": "cork_wound_tighter", "name": "Cork Wound Suspiciously Tighter", "league": "human", "stat": "payload", "operation": "multiplier", "base": 0.050, "level_growth": 0.055, "description": "Still a normal baseball according to counsel."},
	{"id": "commissioners_other_ball", "name": "The Commissioner's Other Ball", "league": "human", "stat": "payload", "operation": "multiplier", "base": 0.075, "level_growth": 0.045, "min_level": 21, "description": "No, not that one. The lively one."},
	{"id": "neutron_cork", "name": "Neutron Cork", "league": "alien", "stat": "payload", "operation": "multiplier", "base": 0.20, "level_growth": 0.034, "description": "A dense solution to an accounting problem."},
	{"id": "first_ball_last_ball", "name": "The First Ball and the Last Ball", "league": "eldritch", "stat": "payload", "operation": "multiplier", "base": 0.44, "level_growth": 0.026, "description": "Both are currently in your hand."},
	{"id": "remember_his_tell", "name": "Remember His Tell", "league": "human", "stat": "mastery", "operation": "multiplier", "base": 0.045, "level_growth": 0.052, "description": "He wiggles before ruining your afternoon."},
	{"id": "scorebook_with_tabs", "name": "Scorebook With Tabs", "league": "human", "stat": "mastery", "operation": "multiplier", "base": 0.060, "level_growth": 0.046, "min_level": 9, "description": "A terrifying organizational advantage."},
	{"id": "species_scouting_matrix", "name": "Species Scouting Matrix", "league": "alien", "stat": "mastery", "operation": "multiplier", "base": 0.17, "level_growth": 0.034, "description": "Now includes carbon-optional elbows."},
	{"id": "memory_before_meeting", "name": "Memory Before Meeting", "league": "eldritch", "stat": "mastery", "operation": "multiplier", "base": 0.36, "level_growth": 0.027, "description": "You have always known this batter's weakness."},
	{"id": "dryer_lint_luck", "name": "Dryer-Lint Luck", "league": "human", "stat": "loot", "operation": "add", "base": 0.004, "level_growth": 0.045, "description": "There might be a jersey in there."},
	{"id": "dugout_lost_and_found", "name": "Dugout Lost and Found", "league": "human", "stat": "loot", "operation": "add", "base": 0.006, "level_growth": 0.040, "min_level": 6, "description": "Ownership is a post-strikeout detail."},
	{"id": "quantum_lost_and_found", "name": "Quantum Lost and Found", "league": "alien", "stat": "loot", "operation": "add", "base": 0.018, "level_growth": 0.030, "description": "Every box contains an item until observed."},
	{"id": "inheritance_from_dead_timeline", "name": "Inheritance From a Dead Timeline", "league": "eldritch", "stat": "loot", "operation": "add", "base": 0.040, "level_growth": 0.024, "description": "The previous owner technically never existed."},
	{"id": "nap_time_training", "name": "Nap-Time Training", "league": "human", "stat": "offline", "operation": "add", "base": 0.006, "level_growth": 0.050, "description": "Progress happens while someone thinks you are asleep."},
	{"id": "scorebook_under_pillow", "name": "Scorebook Under the Pillow", "league": "human", "stat": "offline", "operation": "add", "base": 0.010, "level_growth": 0.042, "min_level": 9, "description": "Knowledge diffuses overnight."},
	{"id": "backup_consciousness", "name": "Backup Consciousness", "league": "alien", "stat": "offline", "operation": "add", "base": 0.030, "level_growth": 0.028, "description": "One of you was definitely playing."},
	{"id": "dreaming_bullpen", "name": "Dreaming Bullpen", "league": "eldritch", "stat": "offline", "operation": "add", "base": 0.065, "level_growth": 0.022, "description": "Closed applications remain open in dreams."},
	{"id": "screen_poking_form", "name": "Elite Screen-Poking Form", "league": "human", "stat": "tap", "operation": "multiplier", "base": 0.035, "level_growth": 0.050, "description": "Thumb mechanics reviewed by a professional."},
	{"id": "spare_clicking_finger", "name": "Spare Clicking Finger", "league": "alien", "stat": "tap", "operation": "multiplier", "base": 0.12, "level_growth": 0.030, "description": "Not useful for pitching. Extremely useful here."},
	{"id": "click_between_seconds", "name": "Click Between Seconds", "league": "eldritch", "stat": "tap", "operation": "multiplier", "base": 0.25, "level_growth": 0.024, "description": "Input sampled from the cracks in time."},
	{"id": "healthy_spite", "name": "Healthy Spite", "league": "human", "stat": "determination", "operation": "multiplier", "base": 0.050, "level_growth": 0.045, "description": "Every bad result becomes extremely personal."},
	{"id": "species_wide_grudge", "name": "Species-Wide Grudge", "league": "alien", "stat": "determination", "operation": "multiplier", "base": 0.16, "level_growth": 0.030, "description": "Humanity is counting on your inability to let this go."},
	{"id": "hatred_outlives_universe", "name": "Hatred Outlives the Universe", "league": "eldritch", "stat": "determination", "operation": "multiplier", "base": 0.34, "level_growth": 0.024, "description": "The universe reset. The grudge did not."},
	{"id": "seam_shaving", "name": "Recreational Seam Shaving", "league": "human", "stat": "drag", "operation": "reduction", "base": 0.025, "level_growth": 0.050, "description": "Aerodynamics with a kitchen knife."},
	{"id": "laminar_plasma_jacket", "name": "Laminar Plasma Jacket", "league": "alien", "stat": "drag", "operation": "reduction", "base": 0.12, "level_growth": 0.030, "description": "The atmosphere is politely moved aside."},
	{"id": "air_forgotten", "name": "Air, Forgotten", "league": "eldritch", "stat": "drag", "operation": "reduction", "base": 0.27, "level_growth": 0.022, "description": "Drag requires a universe that remembers gas."},
	{"id": "incentive_clause", "name": "Tiny Incentive Clause", "league": "human", "stat": "xp", "operation": "multiplier", "base": 0.035, "level_growth": 0.048, "description": "The contract pays almost enough to notice."},
	{"id": "galactic_tv_rights", "name": "Galactic TV Rights", "league": "alien", "stat": "xp", "operation": "multiplier", "base": 0.13, "level_growth": 0.030, "description": "Every strikeout airs in twelve systems."},
	{"id": "souls_as_performance_bonus", "name": "Souls as a Performance Bonus", "league": "eldritch", "stat": "xp", "operation": "multiplier", "base": 0.29, "level_growth": 0.023, "description": "Payroll has become metaphysical."},

	# Body age and adjectives. Ages replace the purchasable Grow Up ladder; build
	# perks stack their adjective while retaining the current age noun.
	{"id": "age_little_kid", "name": "Become a Little Kid", "league": "human", "stat": "body_age", "operation": "body", "age_order": 1, "normal_by_level": 4, "base": 1.0, "level_growth": 0.0, "description": "You are now old enough to know this is weird."},
	{"id": "age_big_kid", "name": "Become a Big Kid", "league": "human", "stat": "body_age", "operation": "body", "age_order": 2, "min_level": 3, "normal_by_level": 8, "base": 1.0, "level_growth": 0.0, "description": "A decisive victory over being smaller."},
	{"id": "age_preteen", "name": "Survive Preteenhood", "league": "human", "stat": "body_age", "operation": "body", "age_order": 3, "min_level": 9, "normal_by_level": 13, "base": 1.0, "level_growth": 0.0, "description": "The uniform no longer fits for unrelated reasons."},
	{"id": "age_teen", "name": "Puberty, Apparently", "league": "human", "stat": "body_age", "operation": "body", "age_order": 4, "min_level": 12, "normal_by_level": 18, "base": 1.0, "level_growth": 0.0, "description": "Voice −1 octave • Fastball +awkwardness."},
	{"id": "age_young_adult", "name": "Become a Young Adult", "league": "human", "stat": "body_age", "operation": "body", "age_order": 5, "min_level": 18, "normal_by_level": 24, "base": 1.0, "level_growth": 0.0, "description": "Old enough to sign your own tendon waivers."},
	{"id": "age_regular_guy", "name": "Become a Regular Ol' Guy", "league": "human", "stat": "body_age", "operation": "body", "age_order": 6, "min_level": 24, "normal_by_level": 30, "base": 1.0, "level_growth": 0.0, "description": "Entirely ordinary, except for the baseball destiny."},
	{"id": "build_athletic", "name": "Look Vaguely Athletic", "league": "human", "stat": "body_build", "operation": "body", "adjective": "athletic", "base": 1.0, "level_growth": 0.0, "description": "Speed and posture improve slightly."},
	{"id": "build_buff", "name": "Become a Buff Boi", "league": "human", "stat": "body_build", "operation": "body", "adjective": "buff", "min_level": 9, "base": 1.0, "level_growth": 0.0, "description": "The sleeves file a complaint."},
	{"id": "build_toned", "name": "Suspiciously Toned", "league": "human", "stat": "body_build", "operation": "body", "adjective": "toned", "min_level": 15, "base": 1.0, "level_growth": 0.0, "description": "Cardio exists and you resent it."},
	{"id": "build_creatine", "name": "Creatine Is Just Food, Coach", "league": "human", "stat": "body_build", "operation": "body", "adjective": "creatine-loaded", "min_level": 18, "base": 1.0, "level_growth": 0.0, "description": "Water weight with excellent branding."},
	{"id": "build_vitamins", "name": "Suspicious Vitamins", "league": "human", "stat": "body_build", "operation": "body", "adjective": "suspiciously vitaminized", "min_level": 21, "base": 1.0, "level_growth": 0.0, "description": "The label uses three alphabets."},
	{"id": "build_roided", "name": "Extremely Obvious Steroids", "league": "human", "stat": "body_build", "operation": "body", "adjective": "roided-out", "min_level": 27, "base": 1.0, "level_growth": 0.0, "description": "Subtlety −100% • Sleeves −all."},
]

const BOSS_PERKS := [
	{"id": "bambino_birthright", "name": "Bambino's Questionable Birthright", "league": "human", "stat": "speed", "operation": "multiplier", "base": 0.22, "level_growth": 0.02, "description": "The last mortal leaves you his least legal fastball."},
	{"id": "fourfold_commission", "name": "The Fourfold Commission", "league": "alien", "stat": "calling", "operation": "multiplier", "base": 0.55, "level_growth": 0.015, "description": "Xylophax signs every pitch call with four hands."},
	{"id": "unstrikeable_memory", "name": "Memory of the Unstrikeable", "league": "eldritch", "stat": "mastery", "operation": "multiplier", "base": 0.90, "level_growth": 0.010, "description": "Ball-rog's impossible scouting report has one margin note."},
	{"id": "eightfold_last_inning", "name": "The Eightfold Last Inning", "league": "eldritch", "stat": "payload", "operation": "multiplier", "base": 1.50, "level_growth": 0.008, "description": "Octathulhu's final bat becomes your first ball."},
]

const CORRUPTION_PENALTIES := [
	{"id": "slow_windup", "name": "Windup Seen From Space", "stat": "recovery", "operation": "reduction", "base": -0.18},
	{"id": "wild_release", "name": "The Zone Hates You", "stat": "quality", "operation": "add", "base": -0.42},
	{"id": "thick_atmosphere", "name": "Personal Atmosphere", "stat": "drag", "operation": "reduction", "base": -0.22},
	{"id": "late_dugout", "name": "Dugout Beyond Time", "stat": "lineup", "operation": "reduction", "base": -0.24},
	{"id": "fragile_spite", "name": "Spite With a Leak", "stat": "determination", "operation": "multiplier", "base": -0.30},
	{"id": "audited_contract", "name": "Cosmic Payroll Audit", "stat": "xp", "operation": "multiplier", "base": -0.20},
	{"id": "loud_equipment", "name": "Loot Can Hear You", "stat": "loot", "operation": "add", "base": -0.035},
	{"id": "pitch_amnesia", "name": "Pitch-Calling Amnesia", "stat": "calling", "operation": "multiplier", "base": -0.28},
]

const PITCH_DRAFT_POOLS := {
	"human": ["four_seam", "changeup", "two_seam", "curveball", "slider", "sweeper", "circle_change", "splitter", "knuckleball", "forkball", "screwball", "buzzsaw_cutter", "fireball", "gyroball", "eephus", "max_effort_four_seam"],
	"alien": ["gazorpian_strudelball", "gravity_ball", "andromedan_knucklebomb", "nebular_spitball", "plasma_sinker", "bubonic_swerve", "quasar_riser", "quantum_fork", "false_vacuum_change"],
	"eldritch": ["wormhole_changeup", "pitch_first_death", "eschaton_screwball", "event_horizon", "causal_paradox_eephus"],
}

const BOSS_PITCHES := {
	Campaign.HUMAN_FINAL_INDEX: "max_effort_four_seam",
	Campaign.ALIEN_FINAL_INDEX: "false_vacuum_change",
	Campaign.FINAL_BOSS_INDEX: "causal_paradox_eephus",
}

const STORY_BEATS := [
	{"id": "prologue_little_timmy", "tier": "human", "title": "THREE FEET OF DESTINY", "body": "You stare at your mortal enemy. Sun warms your face; your hand closes around the rough plastic contours of your weapon; every tiny muscle screams as you hurl it toward your foe at one foot per second. The Wiffle ball sails two feet, rolls across the plate, and stops at Little Timmy's feet. Clearly, you need a little more practice."},
	{"id": "story_tab_explained", "tier": "human", "title": "THE SCOREBOOK", "body": "The important moments of your campaign are recorded in LOG → STORY. It shows newest entries first; Reverse Order restores the chronology if you are feeling responsible."},
	{"id": "arrive_tee_ball", "tier": "human", "title": "TEE-BALL DIPLOMACY", "body": "You have crossed into tee-ball, where the battlefield has a rubber tee and the crowd carries orange slices. Every swing is applauded with the intensity of a coronation. You still intend to conquer it."},
	{"id": "arrive_coach_pitch", "tier": "human", "title": "COACH PITCH, YOUR MOUND", "body": "Adults organize the battlefield and call it Coach Pitch. You seize the mound anyway, defending it from aluminum bats and children with frighteningly confident stances. The distance expands; so does the enemy's belief in itself."},
	{"id": "arrive_little_league", "tier": "human", "title": "THE FIRST TRYHARDS", "body": "Matching socks appear. Private lessons appear. Somebody arrives with a composite bat and a warranty, as though this were an arms race. You understand that it is."},
	{"id": "arrive_middle_school", "tier": "human", "title": "THE AWKWARD LEAGUE", "body": "Middle school is a nation of limbs, cracked voices, and grudges conducted through sports. The strike zone is farther away, and one hitter has a laminated scouting report. You will survive this bureaucracy of puberty."},
	{"id": "arrive_high_school", "tier": "human", "title": "FRIDAY-NIGHT LIGHTS", "body": "There are recruiters behind the backstop now. A bad pitch is no longer merely humiliating; it is professionally documented. You take the mound anyway, because destiny has apparently acquired a clipboard."},
	{"id": "arrive_small_college", "tier": "human", "title": "TUITION AND TENDONS", "body": "College baseball offers classes, bus rides, and batters who study release points between assignments. You have entered higher learning, where the final exam has seams. Your student debt is emotional for now."},
	{"id": "arrive_division_one", "tier": "human", "title": "THE BIG CAMPUS", "body": "Division I has video rooms, scouts, and an analytics department devoted to explaining why your last pitch was a mistake. You nod as if this is wisdom. Then you throw the next one harder."},
	{"id": "arrive_lower_minors", "tier": "human", "title": "THE LONG BUS", "body": "Professional baseball begins with motel bullpens, meal money, and a bus that smells like an oath. The batters can read spin before the ball leaves your hand. You begin plotting revenge before it lands."},
	{"id": "arrive_upper_minors", "tier": "human", "title": "ONE CALL AWAY", "body": "Every batter has packed for the majors. Each at-bat is a job interview conducted with a maple bat and no human resources department. You are the interviewer, and the answer is Strike Three."},
	{"id": "arrive_major_leagues", "tier": "human", "title": "THE SHOW", "body": "The last mortal league is waiting. Nobody here is impressed by your Wiffle-ball origin story, which is rude because it was clearly prophetic. They have the bats to prove it; you have the mound."},
	{"id": "human_school_ball", "tier": "human", "title": "THE SCHOOL HAS A TEAM", "body": "The school has a team now, and somebody keeps statistics like a witness to your crimes. The mound is farther away; the batters are taller. You prepare to make attendance mandatory."},
	{"id": "human_college", "tier": "human", "title": "A SCHOLARSHIP OF QUESTIONABLE VALUE", "body": "Baseball now has tuition, scouts, and an alarming amount of video analysis. You enroll in the ancient elective called Throwing It Past Them. The syllabus is mostly pain."},
	{"id": "human_minors", "tier": "human", "title": "THE LONG BUS", "body": "Professional baseball begins with motel bullpens, meal money, and fourteen consecutive hours on a bus. You emerge with a stiff back and a sharper grudge. The hitters have made a mistake by existing nearby."},
	{"id": "human_majors", "tier": "human", "title": "THE SHOW", "body": "The last mortal league is waiting. Nobody here is impressed by your Wiffle-ball origin story. You take this personally, which is the only proper response."},
	{"id": "bambino_arrival", "tier": "human", "title": "BAMBINO REX", "body": "Bambino Rex enters as the last human champion, wearing the expression of someone who believes progress bars are beneath him. The whole mortal age holds its breath. Only a strikeout ends this ridiculous era of baseball."},
	{"id": "xylophax_portal", "tier": "genetic", "title": "YOU THINK YOU'RE HOT STUFF", "body": "A portal opens over the diamond. An alien crowd is already booing in several frequencies. Xylophax carries four bats and asks whether humanity sent its best toddler."},
	{"id": "genetic_help", "tier": "genetic", "title": "COME WITH ME", "body": "A stranger steps through a smaller portal. “Come with me if you want to… be really good at baseball.” The pause was legally necessary."},
	{"id": "first_rebirth", "tier": "genetic", "title": "BORN AGAIN, WITH NOTES", "body": "You wake up as a toddler again. Was it all a dream? Then you notice your modifications. You pick up a Wiffle ball with determination and look at the confused toddler at the plate. “Your time has come, Little Timmy. You shall be the first to fall in my conquest of the stars.” Little Timmy blinks and wipes sticky sno-cone residue on his jersey. No matter: all prestige upgrades are retained, and your ambitions range far beyond this preschool."},
	{"id": "genetic_replay", "tier": "genetic", "title": "LITTLE TIMMY HAS CONCERNS", "body": "The backyard is unchanged. You are not. Little Timmy is trying not to stare at the additional anatomy."},
	{"id": "rebirth_middle_school", "tier": "genetic", "title": "MIDDLE SCHOOL… AGAIN", "body": "Middle school… again. I knew it would be a wretched hive of axe body spray and acne, but I was willing to do anything to achieve my goal. The goal remains absurdly large. The lockers remain inexplicably sticky."},
	{"id": "alien_olympus", "tier": "genetic", "title": "OLYMPUS MOUND", "body": "Xylophax waits across Mars with four bats and the authority to call this regulation distance."},
	{"id": "octathulhu_contact", "tier": "eldritch", "title": "SOMETHING WANTS TO PLAY", "body": "Eight bats unfold beyond the scoreboard, each held by an arm that should not have an elbow. Octathulhu will eat the universe unless you beat him at baseball. This is somehow a real game now. Take the mound."},
	{"id": "universe_eaten", "tier": "eldritch", "title": "FINAL SCORE: UNIVERSE 0", "body": "Octathulhu hits another Grand Slam and eats the stadium, the league, and causality in that order. You had one job. It was baseball."},
	{"id": "first_eldritch_rebirth", "tier": "eldritch", "title": "A LESS DOOMED REALITY", "body": "Your consciousness lands in another backyard. Copies of you from nearby realities have also received the memo. Apparently the universe has a bullpen now."},
	{"id": "earth_defense", "tier": "eldritch", "title": "EARTH'S BULLPEN", "body": "You return to Earth with alien-league fame and an extremely bad warning. Governments build a mound in orbit because pitching from the ground would destroy the ground. The opposing lineup is approaching from every planet."},
	{"id": "ball_rog", "tier": "eldritch", "title": "BALL-ROG, THE UNSTRIKEABLE", "body": "Beyond Pluto, gravity itself carries a bat. Ball-rog considers called Strikes a personal insult."},
	{"id": "octathulhu_final", "tier": "eldritch", "title": "THE FINAL INNING", "body": "Octathulhu returns with eight arms, eight bats, and the confidence of a god who has already eaten one box score."},
	{"id": "cosmic_victory", "tier": "divine", "title": "NO HITTER", "body": "The universe survives because one increasingly irregular pitcher became very good at baseball."},
	{"id": "god_offer", "tier": "divine", "title": "WOULDN'T THE BEST REWARD BE DOING IT AGAIN?", "body": "God thanks you for saving creation and offers to reset absolutely everything. There are, apparently, still bonuses."},
	{"id": "endless_unlocked", "tier": "divine", "title": "EXTRA INNINGS", "body": "Octathulhu has been reached again. The finite scorebook ends here; the opposing lineup does not."},
]

static func rarity_by_id(id: String) -> Dictionary:
	for rarity in PERK_RARITIES:
		if str(rarity.id) == id:
			return rarity
	return PERK_RARITIES[0]

static func perk_by_id(id: String) -> Dictionary:
	for definition in RUN_PERKS:
		if str(definition.id) == id:
			return definition
	for definition in BOSS_PERKS:
		if str(definition.id) == id:
			return definition
	return {}

static func story_by_id(id: String) -> Dictionary:
	for definition in STORY_BEATS:
		if str(definition.id) == id:
			return definition
	return {}

static func eligible_perks(level_index: int, include_boss: bool = false) -> Array[Dictionary]:
	var league := Campaign.league_for_index(level_index)
	var result: Array[Dictionary] = []
	var source: Array = BOSS_PERKS if include_boss else RUN_PERKS
	var league_rank := 0 if league == "human" else (1 if league == "alien" else 2)
	for definition_value in source:
		var definition: Dictionary = definition_value
		var definition_rank := 0 if str(definition.league) == "human" else (1 if str(definition.league) == "alien" else 2)
		if definition_rank > league_rank:
			continue
		if level_index < int(definition.get("min_level", 0)):
			continue
		result.append(definition)
	return result

static func resolved_effect(definition: Dictionary, level_number: int, rarity_factor: float, extra_factor: float = 1.0) -> Dictionary:
	if definition.is_empty():
		return {}
	var operation := str(definition.get("operation", "add"))
	if operation == "body":
		return {
			"stat": str(definition.stat),
			"operation": operation,
			"age_order": int(definition.get("age_order", 0)),
			"adjective": str(definition.get("adjective", "")),
		}
	var level_scale := 1.0 + log(float(maxi(level_number, 1))) / log(2.0) * float(definition.get("level_growth", 0.0))
	var magnitude := float(definition.get("base", 0.0)) * level_scale * rarity_factor * extra_factor
	var value := magnitude
	if operation == "multiplier":
		value = maxf(0.01, 1.0 + magnitude)
	elif operation == "reduction":
		value = maxf(0.02, 1.0 - magnitude)
	return {
		"stat": str(definition.stat),
		"operation": operation,
		"magnitude": magnitude,
		"value": value,
	}
