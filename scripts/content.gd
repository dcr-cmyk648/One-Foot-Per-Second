class_name GameContent
extends RefCounted

const OUTCOME_NAMES := [
	"GRAND SLAM",
	"HOME RUN",
	"TRIPLE",
	"DOUBLE",
	"SINGLE",
	"FOUL",
	"BALL",
	"STRIKE",
]
# Pitch outcomes never pay directly. The game banks no XP until the last
# required strike completes a strikeout; that payout is calculated from the
# opponent's unmodified count.
const OUTCOME_XP := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
const GRAND_SLAM_INDEX := 0
const HIT_OUTCOME_COUNT := 5
const FOUL_INDEX := 5
const BALL_INDEX := 6
const STRIKE_INDEX := 7
const OUTCOME_COLORS := [
	Color("ff2d55"),
	Color("ff5d73"),
	Color("ffad66"),
	Color("f9df74"),
	Color("73dfaa"),
	Color("d59cff"),
	Color("ffcf66"),
	Color("62d9ff"),
]

# Human baseball keeps the sacred three-strike count. Alien rules escalate
# cautiously enough to remain beatable with high strike odds; eldritch counts
# become absurd because clones, genetic fielders, and portals can preserve a
# partially completed count through ordinary hits. Grand Slams always reset it.
const BASE_STRIKES_REQUIRED := [
	3, 3, 3, 3, 3,
	3, 3, 3, 3, 3,
	3, 3, 3, 3, 3,
	3, 3, 3, 3, 3,
	3, 3, 3, 3, 3,
	3, 3, 3, 3, 3,
	4, 4, 5, 5, 6,
	6, 7, 7, 8, 9,
	12, 18, 28, 42, 64,
]

# Human baseball always uses the familiar four-ball walk. Stranger leagues
# gradually shrink the zone's mercy; this makes a Ball increasingly dangerous
# without adding another hidden prestige requirement.
const BASE_BALLS_REQUIRED := [
	4, 4, 4, 4, 4,
	4, 4, 4, 4, 4,
	4, 4, 4, 4, 4,
	4, 4, 4, 4, 4,
	4, 4, 4, 4, 4,
	4, 4, 4, 4, 4,
	4, 4, 4, 4, 4,
	3, 3, 3, 3, 3,
	3, 3, 3, 2, 2,
]

const HUMAN_FINAL_INDEX := 29
const ALIEN_EXHIBITION_INDEX := 30
const ALIEN_FINAL_INDEX := 39
const ELDRITCH_EXHIBITION_INDEX := 40
const FINAL_BOSS_INDEX := 44

const ERA_NAMES := [
	"BACKYARD",
	"YOUTH BASEBALL",
	"SCHOOL BALL",
	"AMATEUR & COLLEGE",
	"MINOR LEAGUES",
	"MAJOR LEAGUES",
	"ALIEN ROOKIE CIRCUIT",
	"INTERSTELLAR LEAGUE",
	"ELDRITCH WORLD SERIES",
]

# Strikeout loot is intentionally a modest sidegrade channel. Rarity controls
# how many independently rolled affixes an item receives, while item level
# controls their strength. The state layer applies hard aggregate caps so even
# seven perfect Uniques cannot become a hidden fourth prestige system. The
# seventh slot is not part of human baseball and cannot drop before that tier.
const LOOT_SLOTS := [
	{
		"id": "hat",
		"name": "HAT",
		"letter": "H",
		"required_level": 0,
		"primary_stat": "quality_bonus",
		"base_names": ["Crooked Cap", "Batting Helmet", "Varsity Cap", "Scouting Cap", "Bus-League Cap", "Big-League Crown", "Gene-Spliced Helm", "Solar Crown", "Hat of the Outer Dark"],
	},
	{
		"id": "jersey",
		"name": "JERSEY",
		"letter": "J",
		"required_level": 0,
		"primary_stat": "xp_bonus",
		"base_names": ["Juice-Stained Shirt", "Matching Jersey", "Letter Jersey", "Sponsored Jersey", "Call-Up Jersey", "Contract Jersey", "Four-Sleeved Jersey", "Vacuum Jersey", "Shroud of the Ninth Inning"],
	},
	{
		"id": "jockstrap",
		"name": "JOCK STRAP",
		"letter": "S",
		"required_level": 0,
		"primary_stat": "mastery_bonus",
		"base_names": ["Hand-Me-Down Jock Strap", "Team-Issue Jock Strap", "Varsity Jock Strap", "Conference Jock Strap", "Bus-League Jock Strap", "Championship Jock Strap", "Genome Support", "Zero-G Support", "Causality Cup"],
	},
	{
		"id": "glove",
		"name": "GLOVE",
		"letter": "G",
		"required_level": 0,
		"primary_stat": "rate_bonus",
		"base_names": ["Sticky Wiffle Glove", "Youth Glove", "Varsity Glove", "Scouted Glove", "Bus-Seat Glove", "Gold Glove", "Prehensile Glove", "Plasma Mitt", "Causality Catcher"],
	},
	{
		"id": "pants",
		"name": "PANTS",
		"letter": "P",
		"required_level": 0,
		"primary_stat": "speed_bonus",
		"base_names": ["Grass-Stained Pants", "Elastic Baseball Pants", "Varsity Pants", "Biomechanical Pants", "Meal-Money Pants", "Luxury Contract Pants", "Gene-Pocket Trousers", "Low-Gravity Pants", "Infinite Inseam"],
	},
	{
		"id": "cleats",
		"name": "CLEATS",
		"letter": "C",
		"required_level": 0,
		"primary_stat": "distance_bonus",
		"base_names": ["Velcro Cleats", "Plastic Cleats", "Varsity Spikes", "Long-Toss Cleats", "Fourteen-Hour-Bus Cleats", "Signature Cleats", "Tripodal Spikes", "Orbital Cleats", "Footwear Beyond Distance"],
	},
	{
		"id": "relic",
		"name": "RELIC",
		"letter": "R",
		"required_level": ALIEN_EXHIBITION_INDEX,
		"primary_stat": "quality_bonus",
		"base_names": ["Locked Relic", "Locked Relic", "Locked Relic", "Locked Relic", "Locked Relic", "Locked Relic", "Fossilized Pitch Clock", "Solar Pennant", "Shard of the First Inning"],
	},
]

const LOOT_RARITIES := [
	{"id": "common", "name": "COMMON", "color": Color("a9b6c5"), "probability": 0.7800, "affix_count": 0, "strength": 0.72},
	{"id": "magic", "name": "MAGIC", "color": Color("66a6ff"), "probability": 0.1800, "affix_count": 1, "strength": 0.88},
	{"id": "rare", "name": "RARE", "color": Color("ffd45c"), "probability": 0.0370, "affix_count": 2, "strength": 1.00},
	{"id": "legendary", "name": "LEGENDARY", "color": Color("ff914d"), "probability": 0.0027, "affix_count": 3, "strength": 1.14},
	{"id": "unique", "name": "UNIQUE", "color": Color("d68cff"), "probability": 0.0003, "affix_count": 4, "strength": 1.28},
]

const LOOT_STATS := [
	{"id": "speed_bonus", "name": "Speed", "format": "multiplier"},
	{"id": "rate_bonus", "name": "Recovery", "format": "multiplier"},
	{"id": "quality_bonus", "name": "Quality", "format": "additive"},
	{"id": "xp_bonus", "name": "Strikeout XP", "format": "multiplier"},
	{"id": "mastery_bonus", "name": "Opponent mastery", "format": "multiplier"},
	{"id": "distance_bonus", "name": "Distance XP", "format": "multiplier"},
]

const STAT_HELP := {
	"speed": "Speed sets travel time and contributes modestly to Quality. Each released ball keeps its sampled speed forever.",
	"quality": "Quality shifts probability away from dangerous contact and toward Strikes.",
	"recovery": "Recovery is completed wind-ups per second. More Recovery means less time between resolved balls.",
	"lineup": "Lineup time is the universal delay before any replacement batter reaches the plate.",
	"hit_delay": "Hit delay scales only the extra lineup penalty caused by a fair hit; it does not shorten the universal lineup time.",
	"calling": "Calling biases the random arsenal toward stronger learned pitch types without removing weaker ones.",
	"distance": "Distance control reduces the added batter threat from moving the mound farther away.",
	"offline": "Offline efficiency is the share of normal strikeout XP deposited while the game is closed or suspended.",
	"payload": "Payload multiplies the XP awarded by a completed strikeout without creating invisible balls.",
	"mastery": "Mastery fills opponent unlock bars and continues logarithmically after a batter is mastered.",
}

const LOOT_PREFIXES := [
	[""],
	["Unexpected", "Coach-Approved", "Suspiciously Clean", "Remarkable"],
	["Improbable", "All-Star", "Statistically Dubious", "Glorious"],
	["Legendary", "League-Breaking", "Commissioner-Banned", "Unreasonably Serious"],
	["Only Existing", "Reality-Original", "Prophecied", "One True"],
]

const LOOT_SUFFIXES := {
	"speed_bonus": ["Emergency Velocity", "Unscheduled Windups", "The Fast Part"],
	"rate_bonus": ["Loose Arms", "No Rest Days", "Immediate Recovery"],
	"quality_bonus": ["Called Strikes", "Unfair Command", "The Tiny Zone"],
	"xp_bonus": ["Heavy Payouts", "Contract Incentives", "XP Arbitration"],
	"mastery_bonus": ["Scouting Reports", "Dominion", "Unreasonable Reputation"],
	"distance_bonus": ["Long Toss", "The Far Mound", "Geometric Ambition"],
}

# Hand-tuned around the quality a reasonably purchasing first-season pitcher
# reaches at each era boundary. This keeps new classes competitive instead of
# letting uncapped idle-game income turn the whole ladder into automatic
# strikes. The final anchor is Octathulhu rather than a tenth era.
const OPPONENT_DIFFICULTY_ANCHORS := [2.60, 6.0, 11.0, 17.0, 24.0, 28.0, 36.0, 52.0, 72.0, 100.0]

const DISTANCE_TIERS := [
	{"name": "PRESCHOOL POINT-BLANK", "label": "3 ft", "feet": 3.0, "required_level": 0, "xp_multiplier": 1.0, "difficulty": 0.0},
	{"name": "ONE BIG STEP BACK", "label": "6 ft", "feet": 6.0, "required_level": 2, "xp_multiplier": 1.25, "difficulty": 0.20},
	{"name": "BACKYARD CHALLENGE", "label": "12 ft", "feet": 12.0, "required_level": 5, "xp_multiplier": 1.6, "difficulty": 0.45},
	{"name": "LITTLE-LEAGUE CLOSE", "label": "20 ft", "feet": 20.0, "required_level": 8, "xp_multiplier": 2.1, "difficulty": 0.75},
	{"name": "HALF MOUND", "label": "30 ft", "feet": 30.0, "required_level": 11, "xp_multiplier": 2.8, "difficulty": 1.0},
	{"name": "YOUTH MOUND", "label": "44 ft", "feet": 44.0, "required_level": 14, "xp_multiplier": 4.0, "difficulty": 1.3},
	{"name": "REGULATION MOUND", "label": "60 ft 6 in", "feet": 60.5, "required_level": 19, "xp_multiplier": 6.0, "difficulty": 1.6},
	{"name": "BASEPATH BOMBARDMENT", "label": "90 ft", "feet": 90.0, "required_level": 24, "xp_multiplier": 9.0, "difficulty": 2.0},
	{"name": "OUTFIELD ARTILLERY", "label": "300 ft", "feet": 300.0, "required_level": 29, "xp_multiplier": 15.0, "difficulty": 2.5},
	{"name": "ONE-MILE MOUND", "label": "1 mile", "feet": 5280.0, "required_level": 31, "xp_multiplier": 30.0, "difficulty": 3.1},
	{"name": "LOW-ORBIT BULLPEN", "label": "250 miles", "feet": 1320000.0, "required_level": 34, "xp_multiplier": 100.0, "difficulty": 4.0},
	{"name": "LUNAR SERIES", "label": "Earth to Moon", "feet": 1.261e9, "required_level": 36, "xp_multiplier": 500.0, "difficulty": 5.0},
	{"name": "SOLAR MOUND", "label": "1 AU", "feet": 4.908e11, "required_level": 38, "xp_multiplier": 2500.0, "difficulty": 6.0},
	{"name": "INTERSTELLAR CLASSIC", "label": "1 light-year", "feet": 3.104e16, "required_level": 40, "xp_multiplier": 200000.0, "difficulty": 7.5},
	{"name": "GALAXY-WIDTH WORLD SERIES", "label": "100,000 light-years", "feet": 3.104e21, "required_level": 43, "xp_multiplier": 100000000.0, "difficulty": 10.0},
]

const OPPONENT_NAMES := [
	"Wiffle-Bat Toddler",
	"Foam-Bat Kindergartener",
	"Sugar-Rush Preschooler",
	"Tee-Ball Cleanup Kid",
	"Backyard Fencebreaker",
	"Coach-Pitch Rookie",
	"Rec-League Regular",
	"Travel-Ball Tryhard",
	"District All-Star",
	"Little-League Champion",
	"Seventh-Grade Bench Bat",
	"Middle-School Contact Kid",
	"JV Cleanup Hitter",
	"Varsity Captain",
	"Varsity Phenom",
	"Sandlot Ringer",
	"Community-College Crusher",
	"Division III Technician",
	"Division I Star",
	"College World-Series Champion",
	"Rookie-Ball Prospect",
	"High-A Hotshot",
	"Double-A Masher",
	"Triple-A Call-Up",
	"Top Organizational Prospect",
	"Everyday Big Leaguer",
	"All-Star",
	"MVP",
	"Home Run Derby Champion",
	"MLB Champion",
	"Alien Exhibition Commissioner",
	"Gene-Doped Slugger",
	"Adaptive Batting Android",
	"Four-Armed Cleanup Hitter",
	"Chronal Leadoff Hitter",
	"Low-Gravity Moonballer",
	"Tripodal Contact Hitter",
	"Plasma-Bat Slugger",
	"Jovian Giant",
	"Interstellar Champion",
	"Aeon-League Rookie",
	"Phase-Shift Hitter",
	"Nine-Body Batting Collective",
	"Unstrikeable Void Titan",
	"Eight-Armed God of Baseball",
]

const BAT_NAMES := [
	"Bent Wiffle Bat",
	"Foam Thunderstick",
	"Juice-Box Slugger",
	"Regulation Tee-Ball Bat",
	"Fencebreaker Junior",
	"Coach-Pitch Aluminum",
	"Rec-League Ringer",
	"Composite Travel Bat",
	"District Alloy",
	"Little-League Crown",
	"Hand-Me-Down Aluminum",
	"Contact-Weighted Alloy",
	"JV Maple",
	"Varsity Maple",
	"Sovereign Ash",
	"Sandlot Blackwood",
	"Community-College Composite",
	"D-III Precision Maple",
	"D-I Scouted Ash",
	"Collegiate World-Eater",
	"Rookie-Ball Maple",
	"High-A Hickory",
	"Double-A White Ash",
	"Triple-A Pro Maple",
	"Judgment Bat",
	"Big-League Maple",
	"All-Star Ash",
	"MVP Black Maple",
	"Derby-Loaded Slugger",
	"Bambino Relic",
	"Courtesy-Exhibition Antimatter Bat",
	"Vein-Fed Composite",
	"Firmware Smartbat",
	"Fourfold Quartet",
	"Chronal Pre-Swing Bat",
	"Lunar Low-G Bat",
	"Red-Diamond Tripod Bat",
	"Contained Plasma Bat",
	"Jovian Monument Bat",
	"Solar-Crown Flare",
	"Aeon Rookie Standard",
	"Phase-Shift Bat",
	"Ninefold Shared Bat",
	"Unstrikeable Gravity Club",
	"Eightfold Causality Array",
]

const OPPONENT_QUIRKS := [
	"The strike zone is three feet away. This does not help as much as it should.",
	"Owns a slightly less forgiving foam bat.",
	"Powered by juice boxes and limitless confidence.",
	"Has mastered the strategic advantage of using a tee.",
	"The neighbor is already asking who keeps breaking the fence.",
	"Can now recognize a fastball after the seventh identical fastball.",
	"A patient hitter with an alarmingly real aluminum bat.",
	"Has private coaching, matching socks, and no mercy.",
	"Punishes predictable pitch sequences.",
	"The first batter who has heard of a breaking ball.",
	"Frequently distracted, but only between pitches.",
	"A compact swing makes raw speed less reliable.",
	"Scouting reports begin to matter.",
	"Adjusts to whichever pitch you throw most often.",
	"There are recruiters behind the backstop.",
	"Old, patient, and incapable of being embarrassed.",
	"Studies release points between classes.",
	"Turns small command mistakes into enormous problems.",
	"Has a frighteningly complete spray chart.",
	"The crowd now reacts to every terrible decision.",
	"Professional eyesight meets an unprofessional salary.",
	"No longer swings at anything merely because it is moving.",
	"Can identify spin before the ball leaves your hand.",
	"Has already packed for the majors.",
	"Your first regulation-distance major-league problem.",
	"Makes routine contact look deeply personal.",
	"Knows every conventional pitch in the game.",
	"Has an endorsement deal for hitting your mistakes.",
	"Measures success in damaged scoreboards.",
	"The last opponent still constrained by ordinary biology.",
	"The first alien exhibition is contractually required to be humiliating.",
	"Whatever is in that bloodstream is not on the approved list.",
	"Records each pitch and patches its batting firmware live.",
	"Four bats cover four independent sections of the zone.",
	"Begins swinging several seconds before you throw.",
	"Low gravity turns weak contact into orbital debris.",
	"Three legs, two eyes, one very long bat.",
	"The bat is technically a contained stellar flare.",
	"The strike zone is visible from several moons.",
	"Champion of every inhabited planet with a regulation diamond.",
	"An elder deity, classified as a rookie because an aeon is one season here.",
	"Briefly exits normal space when fooled.",
	"Nine bodies share one perfect scouting report.",
	"Bad pitches cannot escape. Neither can good ones. Ball-rog considers this fair.",
	"The Octopus God of the Universe: eight bats, eight arms, and jurisdiction over causality.",
]

# Each opponent entry is a batter class; the field rotates named individuals
# from the matching era through that class. The stepped index in
# batter_display_name() makes the order varied but deterministic, which keeps
# screenshots and headless tests reproducible without putting cosmetic names
# into the save format.
const BATTER_NAME_POOLS := [
	[
		"Little Timmy",
		"No-Nap Nora",
		"Biscuit McGee",
		"Maddie Two-Socks",
		"Sippy-Cup Sam",
		"Tiny Kevin",
		"Crayon-Eater Claire",
		"Pajama Max",
		"Snacktime Sophie",
		"Booger King Ben",
		"Princess Fastball",
		"Doug (Age Four)",
	],
	[
		"Brayden Elite",
		"Kayleigh Launch-Angle",
		"Jaxxon with Two Xs",
		"Travel-Team Trevor",
		"Carter Cleats",
		"Riley Recball",
		"Easton Batson",
		"Mackenzie Moonshot",
		"Cooper Junior Junior",
		"Dugout Declan",
		"Helmet-Hair Harper",
		"Tournament Gabe",
	],
	[
		"Seventh-Inning Seth",
		"Locker-Room Lola",
		"JV Gavin",
		"Varsity Vanessa",
		"Detention Derek",
		"Cafeteria Casey",
		"Honor-Roll Holly",
		"Aluminum-Bat Alan",
		"Bus-Ride Brenda",
		"Pep-Rally Pete",
		"Study-Hall Stella",
		"Coach's Nephew",
	],
	[
		"Redshirt Randy",
		"Transfer-Portal Tina",
		"NIL Deal Neil",
		"Statistics Major Stan",
		"Walk-On Wanda",
		"Scholarship Sheldon",
		"Professor Slugworth",
		"Campus Legend Cami",
		"Aluminum-to-Wood Wyatt",
		"Fifth-Year Frank",
		"Midterm Miranda",
		"The Undeclared Hitter",
	],
	[
		"Bus-League Bobby",
		"Per-Diem Penny",
		"Double-A Dave",
		"Prospect Pete",
		"Bullpen-Motel Miguel",
		"Call-Up Carla",
		"Organizational Oscar",
		"Roster-Filler Rita",
		"Rehab-Start Reggie",
		"Option-Year Olivia",
		"Clubhouse-Coffee Carl",
		"Future Considerations",
	],
	[
		"Contract-Year Connor",
		"Arbitration Alice",
		"WARlord Walter",
		"Launch-Angle Larry",
		"Exit-Velo Evelyn",
		"All-Star Arnie",
		"Franchise Freddie",
		"October Opal",
		"No-Trade Nate",
		"Dugout-Interview Dan",
		"Endorsement Emma",
		"Player to Be Named Later",
	],
	[
		"HGHenry",
		"Cyber-Slugger 7",
		"CRISPR Chris",
		"Mecha-Marla",
		"Trenjamin",
		"Firmware Frank",
		"Clone Number Derek",
		"Bionic Betty",
		"Patch-Notes Pete",
		"Four-Armed Florence",
		"Legal Gray Area Gary",
		"The Compliance Incident",
	],
	[
		"Moonbase Mookie",
		"Low-G Larry",
		"Venusian Vera",
		"Martian Marvin",
		"Europa Eunice",
		"Io Jones",
		"Saturn-Ring Sally",
		"Solar-Flare Sol",
		"Comet-Tail Carla",
		"Mercury Quick",
		"Titan Tina",
		"Asteroid Previously Named Dave",
	],
	[
		"Zorp the Patient",
		"Xylax of Nine Moons",
		"Glorbo Prime",
		"The Smallest Andromedan",
		"Q'Bert the Unscouted",
		"Nebulon Jones",
		"Vrrt, Son of Vrrt",
		"The Batter Between Seconds",
		"Ominous Dave",
		"Kragulus Minor",
		"Unpronounceable Steve",
		"The Last Little Timmy",
	],
]

# The first member of important classes gets a deliberately authored title;
# replacements still rotate through the era pools above. This keeps reusable
# ladder classes separate from the increasingly Elden-Ring-ish individuals.
const SIGNATURE_BATTER_NAMES := {
	0: "Little Timmy",
	4: "Milo, Breaker of Backyard Fences",
	9: "Cooper, Crown of Little League",
	14: "Valeria, Sovereign of Varsity",
	19: "Collegius, Eater of Aluminum",
	24: "The Call-Up, Awaiting Judgment",
	29: "Bambino Rex, Last of the Mortals",
	30: "Xylophax, Genetic Commissioner",
	31: "Trenbolus, the Vein-Crowned",
	32: "C.A.S.E.Y. Prime, Reader of Seams",
	33: "The Fourfold Batter, Hands Unnumbered",
	34: "Chronoswing, Who Bats Before",
	35: "Lunara, Queen of the Warning Track",
	36: "Tripodus of the Red Diamond",
	37: "Venus Pyre, Wielder of Plasma",
	38: "Jovus, Giant Beyond the Zone",
	39: "Solus, Champion Beneath All Suns",
	40: "N'Kthra, Rookie of the Last Aeon",
	41: "Andromedax, the Unfixed",
	42: "The Nine Who Share One Eye",
	43: "Ball-rog, the Unstrikeable",
	44: "Octathulhu, God of the Eightfold Swing",
}

const TRAINING := [
	{
		"id": "velocity",
		"name": "Speed Training",
		"base_cost": 1.0,
		"growth": 1.30,
		"required_level": 0,
		"stats": ["speed"],
		"description": "Base speed +0.15 ft/s.",
	},
	{
		"id": "command",
		"name": "Command Drills",
		"base_cost": 2.0,
		"growth": 1.105,
		"required_level": 1,
		"stats": ["quality"],
		"description": "Base quality +0.08.",
	},
	{
		"id": "recovery",
		"name": "Recovery Drills",
		"base_cost": 25.0,
		"growth": 1.45,
		"max_level": 26,
		"required_level": 3,
		"stats": ["recovery"],
		"description": "Base recovery +0.035/s.",
	},
	{
		"id": "offline_efficiency",
		"name": "Scorebook Study",
		"base_cost": 100.0,
		"growth": 1.65,
		"max_level": 24,
		"required_level": 4,
		"stats": ["offline"],
		"description": "Offline XP +1 percentage point.",
	},
	{
		"id": "distance_control",
		"name": "Long-Toss Mechanics",
		"base_cost": 120.0,
		"growth": 1.72,
		"max_level": 20,
		"required_level": 5,
		"stats": ["distance"],
		"description": "Distance-threat factor −0.025.",
	},
	{
		"id": "turnover",
		"name": "Lineup Hustle",
		"base_cost": 600.0,
		"growth": 2.40,
		"max_level": 10,
		"required_level": 7,
		"stats": ["lineup"],
		"description": "Base lineup time −0.15s.",
	},
	{
		"id": "hit_recovery",
		"name": "Shake It Off",
		"base_cost": 2400.0,
		"growth": 2.25,
		"max_level": 8,
		"required_level": 9,
		"stats": ["hit_delay"],
		"description": "Hit-delay factor −0.05.",
	},
	{
		"id": "pitch_calling",
		"name": "Pitch Calling",
		"base_cost": 9000.0,
		"growth": 2.10,
		"max_level": 12,
		"required_level": 11,
		"stats": ["calling"],
		"description": "Best-option bias +0.50.",
	},
]

const PITCHES := [
	{
		"id": "dead_fish",
		"name": "Dead-Fish Lob",
		"cost": 0.0,
		"required_level": 0,
		"bonus": -0.25,
		"speed_min": 1.00,
		"speed_max": 1.00,
		"color": Color("f4f7ff"),
		"description": "Quality −0.25 • Speed ×1.00.",
	},
	{
		"id": "four_seam",
		"name": "Four-Seam Fastball",
		"cost": 8.0,
		"required_level": 0,
		"bonus": 0.15,
		"speed_min": 0.97,
		"speed_max": 1.03,
		"color": Color("d8f3ff"),
		"description": "Quality +0.15 • Speed ×0.97–1.03.",
	},
	{
		"id": "changeup",
		"name": "Changeup",
		"cost": 28.0,
		"required_level": 2,
		"bonus": 0.30,
		"speed_min": 0.78,
		"speed_max": 0.90,
		"color": Color("83e6c2"),
		"description": "Quality +0.30 • Speed ×0.78–0.90.",
	},
	{
		"id": "curveball",
		"name": "Curveball",
		"cost": 95.0,
		"required_level": 5,
		"bonus": 0.48,
		"speed_min": 0.76,
		"speed_max": 0.91,
		"color": Color("8ca7ff"),
		"description": "Quality +0.48 • Speed ×0.76–0.91.",
	},
	{
		"id": "slider",
		"name": "Slider",
		"cost": 360.0,
		"required_level": 9,
		"bonus": 0.68,
		"speed_min": 0.84,
		"speed_max": 0.98,
		"color": Color("bc91ff"),
		"description": "Quality +0.68 • Speed ×0.84–0.98.",
	},
	{
		"id": "splitter",
		"name": "Splitter",
		"cost": 1600.0,
		"required_level": 13,
		"bonus": 0.92,
		"speed_min": 0.80,
		"speed_max": 0.96,
		"color": Color("f49dff"),
		"description": "Quality +0.92 • Speed ×0.80–0.96.",
	},
	{
		"id": "knuckleball",
		"name": "Knuckleball",
		"cost": 8200.0,
		"required_level": 17,
		"bonus": 1.20,
		"speed_min": 0.58,
		"speed_max": 0.82,
		"color": Color("ffd07d"),
		"description": "Quality +1.20 • Speed ×0.58–0.82.",
	},
	{
		"id": "buzzsaw_cutter",
		"name": "Buzzsaw Cutter",
		"cost": 2500000.0,
		"required_level": 21,
		"bonus": 1.45,
		"speed_min": 0.90,
		"speed_max": 1.00,
		"color": Color("d6ff7f"),
		"description": "Quality +1.45 • Speed ×0.90–1.00.",
	},
	{
		"id": "fireball",
		"name": "Rising Four-Seam",
		"cost": 25000000.0,
		"required_level": 25,
		"bonus": 1.75,
		"speed_min": 0.98,
		"speed_max": 1.04,
		"color": Color("ff6a4f"),
		"description": "Quality +1.75 • Speed ×0.98–1.04.",
	},
	{
		"id": "gravity_ball",
		"name": "Gravity Ball",
		"cost": 900000000.0,
		"required_level": 32,
		"bonus": 2.50,
		"speed_min": 0.82,
		"speed_max": 1.06,
		"color": Color("65f0ff"),
		"description": "Quality +2.50 • Speed ×0.82–1.06.",
	},
	{
		"id": "plasma_sinker",
		"name": "Plasma Sinker",
		"cost": 300000000000.0,
		"required_level": 35,
		"bonus": 3.05,
		"speed_min": 0.94,
		"speed_max": 1.08,
		"color": Color("ff8b55"),
		"description": "Quality +3.05 • Speed ×0.94–1.08.",
	},
	{
		"id": "quantum_fork",
		"name": "Quantum Forkball",
		"cost": 6000000000000.0,
		"required_level": 38,
		"bonus": 3.60,
		"speed_min": 0.88,
		"speed_max": 1.10,
		"color": Color("ff6fca"),
		"description": "Quality +3.60 • Speed ×0.88–1.10.",
	},
	{
		"id": "wormhole_changeup",
		"name": "Wormhole Changeup",
		"cost": 800000000000000.0,
		"required_level": 40,
		"bonus": 4.35,
		"speed_min": 0.72,
		"speed_max": 1.18,
		"color": Color("9d7bff"),
		"description": "Quality +4.35 • Speed ×0.72–1.18.",
	},
	{
		"id": "event_horizon",
		"name": "Event-Horizon Ball",
		"cost": 8000000000000000000.0,
		"required_level": 43,
		"bonus": 5.20,
		"speed_min": 0.96,
		"speed_max": 1.25,
		"color": Color("fff6a6"),
		"description": "Quality +5.20 • Speed ×0.96–1.25.",
	},
]

# Ball evolution is intentionally a potency channel, not another source of
# invisible projectiles. Each shell replaces the previous one, so the highest
# owned potency applies instead of multiplying the whole list together.
const BALL_UPGRADES := [
	{
		"id": "fresh_wiffle",
		"name": "Fresh Wiffle Ball",
		"cost": 4.0,
		"required_level": 1,
		"potency": 1.10,
		"description": "Payload ×1.10.",
	},
	{
		"id": "taped_seams",
		"name": "Tape-Repaired Wiffle Ball",
		"cost": 18.0,
		"required_level": 2,
		"potency": 1.25,
		"description": "Payload ×1.25.",
	},
	{
		"id": "backyard_rubber",
		"name": "Backyard Rubber Ball",
		"cost": 70.0,
		"required_level": 4,
		"potency": 1.45,
		"description": "Payload ×1.45.",
	},
	{
		"id": "real_leather",
		"name": "Actual Leather Baseball",
		"cost": 240.0,
		"required_level": 6,
		"potency": 1.75,
		"description": "Payload ×1.75.",
	},
	{
		"id": "youth_cork",
		"name": "Little-League Cork Ball",
		"cost": 900.0,
		"required_level": 8,
		"potency": 2.05,
		"description": "Payload ×2.05.",
	},
	{
		"id": "cork_core",
		"name": "Questionably Springy Cork Core",
		"cost": 3000.0,
		"required_level": 10,
		"potency": 2.5,
		"description": "Payload ×2.50.",
	},
	{
		"id": "raised_seams",
		"name": "Raised-Seam Varsity Ball",
		"cost": 10000.0,
		"required_level": 12,
		"potency": 3.1,
		"description": "Payload ×3.10.",
	},
	{
		"id": "superball_core",
		"name": "Double-Cushioned Cork Center",
		"cost": 36000.0,
		"required_level": 14,
		"potency": 4.0,
		"description": "Payload ×4.",
	},
	{
		"id": "college_hide",
		"name": "College-Tournament Cowhide",
		"cost": 120000.0,
		"required_level": 16,
		"potency": 5.5,
		"description": "Payload ×5.50.",
	},
	{
		"id": "tungsten_winding",
		"name": "Suspiciously Tight Wool Winding",
		"cost": 450000.0,
		"required_level": 18,
		"potency": 8.0,
		"description": "Payload ×8.",
	},
	{
		"id": "mud_rubbed",
		"name": "Minor-League Mud-Rubbed Ball",
		"cost": 1800000.0,
		"required_level": 20,
		"potency": 12.0,
		"description": "Payload ×12.",
	},
	{
		"id": "triple_a_winding",
		"name": "Triple-A Tight-Wound Ball",
		"cost": 6000000.0,
		"required_level": 22,
		"potency": 20.0,
		"description": "Payload ×20.",
	},
	{
		"id": "juiced_ball",
		"name": "Allegedly Unjuiced Big-League Ball",
		"cost": 25000000.0,
		"required_level": 24,
		"potency": 35.0,
		"description": "Payload ×35.",
	},
	{
		"id": "derby_overrun",
		"name": "Home-Run-Derby Factory Overrun",
		"cost": 80000000.0,
		"required_level": 26,
		"potency": 60.0,
		"description": "Payload ×60.",
	},
	{
		"id": "commissioner_denied",
		"name": "Commissioner-Denied Live Ball",
		"cost": 300000000.0,
		"required_level": 28,
		"potency": 100.0,
		"description": "Payload ×100.",
	},
	{
		"id": "world_series_ball",
		"name": "World-Series Game Ball",
		"cost": 700000000.0,
		"required_level": 29,
		"potency": 140.0,
		"description": "Payload ×140.",
	},
	{
		"id": "dragonhide_cover",
		"name": "Meteor-Hide Cover",
		"cost": 1200000000.0,
		"required_level": 31,
		"potency": 200.0,
		"description": "Payload ×200.",
	},
	{
		"id": "railgun_jacket",
		"name": "Railgun Jacket",
		"cost": 8000000000.0,
		"required_level": 33,
		"potency": 400.0,
		"description": "Payload ×400.",
	},
	{
		"id": "plasma_filament",
		"name": "Plasma-Filament Seams",
		"cost": 30000000000.0,
		"required_level": 35,
		"potency": 1000.0,
		"description": "Payload ×1,000.",
	},
	{
		"id": "neutron_pearls",
		"name": "Neutron-Pearl Core",
		"cost": 200000000000.0,
		"required_level": 37,
		"potency": 3000.0,
		"description": "Payload ×3,000.",
	},
	{
		"id": "quantum_lacing",
		"name": "Quantum Lacing",
		"cost": 1500000000000.0,
		"required_level": 39,
		"potency": 10000.0,
		"description": "Payload ×10,000.",
	},
	{
		"id": "causality_seams",
		"name": "Causality-Seamed Ball",
		"cost": 50000000000000.0,
		"required_level": 40,
		"potency": 100000.0,
		"description": "Payload ×100,000.",
	},
	{
		"id": "pocket_singularity",
		"name": "Pocket-Singularity Center",
		"cost": 2000000000000000.0,
		"required_level": 41,
		"potency": 1000000.0,
		"description": "Payload ×1,000,000.",
	},
	{
		"id": "void_leather",
		"name": "Leather From the Space Between Innings",
		"cost": 100000000000000000.0,
		"required_level": 42,
		"potency": 20000000.0,
		"description": "Payload ×20,000,000.",
	},
	{
		"id": "event_horizon_core",
		"name": "Event-Horizon Core",
		"cost": 2000000000000000000.0,
		"required_level": 43,
		"potency": 200000000.0,
		"description": "Payload ×200,000,000.",
	},
	{
		"id": "eightfold_causality",
		"name": "Eightfold Causality Ball",
		"cost": 20000000000000000000.0,
		"required_level": 44,
		"potency": 1000000000.0,
		"description": "Payload ×1,000,000,000.",
	},
]

const MILESTONES := [
	{
		"id": "regulation_ball",
		"name": "A Regulation Baseball",
		"cost": 6.0,
		"required_level": 0,
		"stats": ["speed"],
		"effects": {"speed": 1.25},
		"description": "Speed ×1.25.",
	},
	{
		"id": "bucket_bullpen",
		"name": "Five-Gallon-Bucket Bullpen",
		"cost": 15.0,
		"required_level": 1,
		"stats": ["recovery"],
		"effects": {"recovery": 1.05},
		"description": "Recovery ×1.05.",
	},
	{
		"id": "chalk_strike_zone",
		"name": "Chalk Strike-Zone Rectangle",
		"cost": 30.0,
		"required_level": 2,
		"stats": ["quality"],
		"effects": {"quality": 1.04},
		"description": "Quality ×1.04.",
	},
	{
		"id": "coach_stopwatch",
		"name": "Coach's Suspicious Stopwatch",
		"cost": 70.0,
		"required_level": 3,
		"stats": ["recovery"],
		"effects": {"recovery": 1.08},
		"description": "Recovery ×1.08.",
	},
	{
		"id": "backyard_radar_target",
		"name": "Cardboard Radar Target",
		"cost": 150.0,
		"required_level": 4,
		"required_speed_fps": 2.5,
		"stats": ["speed"],
		"effects": {"speed": 1.12},
		"description": "Speed ×1.12.",
	},
	{
		"id": "rosin_bag",
		"name": "Rosin Bag",
		"cost": 350.0,
		"required_level": 5,
		"stats": ["quality"],
		"effects": {"quality": 1.08},
		"description": "Quality ×1.08.",
	},
	{
		"id": "on_deck_bat_rack",
		"name": "Organized On-Deck Bat Rack",
		"cost": 1000.0,
		"required_level": 6,
		"stats": ["lineup"],
		"effects": {"lineup": 0.90},
		"description": "Lineup time ×0.90.",
	},
	{
		"id": "suspicious_vitamins",
		"name": "Suspicious Vitamins",
		"cost": 3000.0,
		"required_level": 7,
		"stats": ["speed"],
		"effects": {"speed": 1.25},
		"description": "Speed ×1.25.",
	},
	{
		"id": "padded_backstop",
		"name": "Emotionally Supportive Backstop",
		"cost": 8000.0,
		"required_level": 8,
		"stats": ["hit_delay"],
		"effects": {"hit_delay": 0.90},
		"description": "Hit delay ×0.90.",
	},
	{
		"id": "mail_order_coach",
		"name": "Mail-Order Pitching Coach",
		"cost": 20000.0,
		"required_level": 9,
		"stats": ["quality"],
		"effects": {"quality": 1.08},
		"description": "Quality ×1.08.",
	},
	{
		"id": "fence_radar",
		"name": "Fence-Mounted Radar Gun",
		"cost": 60000.0,
		"required_level": 10,
		"required_speed_fps": 10.0,
		"stats": ["speed"],
		"effects": {"speed": 1.15},
		"description": "Speed ×1.15.",
	},
	{
		"id": "weighted_balls",
		"name": "Weighted-Ball Program",
		"cost": 200000.0,
		"required_level": 12,
		"stats": ["speed", "quality"],
		"effects": {"speed": 2.20, "quality": 1.06},
		"description": "Speed ×2.20; Quality ×1.06.",
	},
	{
		"id": "borrowed_high_speed_camera",
		"name": "Borrowed High-Speed Camera",
		"cost": 700000.0,
		"required_level": 14,
		"required_distance_index": 4,
		"stats": ["quality"],
		"effects": {"quality": 1.08},
		"description": "Quality ×1.08.",
	},
	{
		"id": "ice_bucket",
		"name": "Reusable Elbow Ice Bucket",
		"cost": 2000000.0,
		"required_level": 15,
		"stats": ["recovery"],
		"effects": {"recovery": 1.08},
		"description": "Recovery ×1.08.",
	},
	{
		"id": "clubhouse_ice_bath",
		"name": "Clubhouse Ice Bath",
		"cost": 6000000.0,
		"required_level": 17,
		"required_strikeouts": 100.0,
		"stats": ["hit_delay"],
		"effects": {"hit_delay": 0.85},
		"description": "Hit delay ×0.85.",
	},
	{
		"id": "minor_league_ball_cart",
		"name": "Minor-League Ball Cart",
		"cost": 20000000.0,
		"required_level": 18,
		"stats": ["lineup"],
		"effects": {"lineup": 0.85},
		"description": "Lineup time ×0.85.",
	},
	{
		"id": "biomechanics_lab",
		"name": "Biomechanics Lab",
		"cost": 80000000.0,
		"required_level": 20,
		"stats": ["recovery"],
		"effects": {"recovery": 1.25},
		"description": "Recovery ×1.25.",
	},
	{
		"id": "secondhand_radar",
		"name": "Secondhand Radar Gun",
		"cost": 250000000.0,
		"required_level": 21,
		"required_speed_fps": 44.0,
		"stats": ["speed", "quality"],
		"effects": {"speed": 1.40, "quality": 1.05},
		"description": "Speed ×1.40; Quality ×1.05.",
	},
	{
		"id": "bullpen_espresso",
		"name": "Bullpen Espresso Machine",
		"cost": 800000000.0,
		"required_level": 22,
		"stats": ["recovery"],
		"effects": {"recovery": 1.06},
		"description": "Recovery ×1.06.",
	},
	{
		"id": "kinesiology_cocoon",
		"name": "Kinesiology-Tape Cocoon",
		"cost": 2500000000.0,
		"required_level": 23,
		"stats": ["recovery"],
		"effects": {"recovery": 1.08},
		"description": "Recovery ×1.08.",
	},
	{
		"id": "pitch_clock_loophole",
		"name": "Pitch-Clock Loophole",
		"cost": 8000000000.0,
		"required_level": 24,
		"stats": ["recovery"],
		"effects": {"recovery": 1.10},
		"description": "Recovery ×1.10.",
	},
	{
		"id": "chartered_bullpen_cart",
		"name": "Chartered Bullpen Cart",
		"cost": 25000000000.0,
		"required_level": 25,
		"stats": ["lineup"],
		"effects": {"lineup": 0.80},
		"description": "Lineup time ×0.80.",
	},
	{
		"id": "steroids",
		"name": "Extremely Obvious Steroids",
		"cost": 80000000000.0,
		"required_level": 26,
		"required_speed_fps": 88.0,
		"stats": ["speed", "recovery"],
		"effects": {"speed": 3.40, "recovery": 1.08},
		"description": "Speed ×3.40; Recovery ×1.08.",
	},
	{
		"id": "rapsodo_cathedral",
		"name": "Rapsodo Cathedral",
		"cost": 250000000000.0,
		"required_level": 27,
		"required_speed_fps": 146.667,
		"stats": ["quality"],
		"effects": {"quality": 1.12},
		"description": "Quality ×1.12.",
	},
	{
		"id": "carbon_tendon_wrap",
		"name": "Carbon-Fiber Tendon Wrap",
		"cost": 700000000000.0,
		"required_level": 28,
		"stats": ["recovery"],
		"effects": {"recovery": 1.12},
		"description": "Recovery ×1.12.",
	},
	{
		"id": "world_series_tunnel",
		"name": "World-Series On-Deck Tunnel",
		"cost": 2000000000000.0,
		"required_level": 29,
		"stats": ["hit_delay"],
		"effects": {"hit_delay": 0.75},
		"description": "Hit delay ×0.75.",
	},
	{
		"id": "titanium_elbow",
		"name": "Titanium Elbow",
		"cost": 6000000000000.0,
		"required_level": 30,
		"stats": ["recovery"],
		"effects": {"recovery": 1.30},
		"description": "Recovery ×1.30.",
	},
	{
		"id": "xenobiology_motion_lab",
		"name": "Xenobiology Motion Lab",
		"cost": 20000000000000.0,
		"required_level": 31,
		"stats": ["quality"],
		"effects": {"quality": 1.12},
		"description": "Quality ×1.12.",
	},
	{
		"id": "hypersonic_radar_array",
		"name": "Hypersonic Radar Array",
		"cost": 80000000000000.0,
		"required_level": 32,
		"required_speed_fps": 1125.33,
		"stats": ["speed"],
		"effects": {"speed": 1.25},
		"description": "Speed ×1.25.",
	},
	{
		"id": "gravitic_recovery_chamber",
		"name": "Gravitic Recovery Chamber",
		"cost": 300000000000000.0,
		"required_level": 33,
		"stats": ["recovery"],
		"effects": {"recovery": 1.25},
		"description": "Recovery ×1.25.",
	},
	{
		"id": "teleporting_bat_rack",
		"name": "Teleporting On-Deck Bat Rack",
		"cost": 1000000000000000.0,
		"required_level": 34,
		"stats": ["lineup"],
		"effects": {"lineup": 0.50},
		"description": "Lineup time ×0.50.",
	},
	{
		"id": "hive_mind",
		"name": "Pitcher Hive Mind",
		"cost": 4000000000000000.0,
		"required_level": 35,
		"stats": ["quality"],
		"effects": {"quality": 1.20},
		"description": "Quality ×1.20.",
	},
	{
		"id": "plasma_bruise_eraser",
		"name": "Plasma Bruise Eraser",
		"cost": 15000000000000000.0,
		"required_level": 36,
		"stats": ["hit_delay"],
		"effects": {"hit_delay": 0.50},
		"description": "Hit delay ×0.50.",
	},
	{
		"id": "mach_cone_harness",
		"name": "Mach-Cone Shoulder Harness",
		"cost": 60000000000000000.0,
		"required_level": 37,
		"required_speed_fps": 3375.99,
		"stats": ["speed"],
		"effects": {"speed": 1.50},
		"description": "Speed ×1.50.",
	},
	{
		"id": "chronal_pitch_clock",
		"name": "Chronal Pitch Clock",
		"cost": 200000000000000000.0,
		"required_level": 38,
		"stats": ["recovery"],
		"effects": {"recovery": 1.50},
		"description": "Recovery ×1.50.",
	},
	{
		"id": "solar_championship_tunnel",
		"name": "Solar Championship Tunnel",
		"cost": 800000000000000000.0,
		"required_level": 39,
		"required_distance_index": 12,
		"stats": ["lineup"],
		"effects": {"lineup": 0.35},
		"description": "Lineup time ×0.35.",
	},
	{
		"id": "wormhole_mound",
		"name": "Wormhole Mound",
		"cost": 3000000000000000000.0,
		"required_level": 40,
		"stats": ["payload"],
		"effects": {"payload": 10.0},
		"description": "Payload ×10.",
	},
	{
		"id": "fourth_dimensional_film_room",
		"name": "Fourth-Dimensional Film Room",
		"cost": 12000000000000000000.0,
		"required_level": 41,
		"required_speed_fps": 9835710.56,
		"stats": ["quality"],
		"effects": {"quality": 1.25},
		"description": "Quality ×1.25.",
	},
	{
		"id": "causality_catcher",
		"name": "Causality Catcher's Mitt",
		"cost": 50000000000000000000.0,
		"required_level": 42,
		"stats": ["quality"],
		"effects": {"quality": 1.20},
		"description": "Quality ×1.20.",
	},
	{
		"id": "instantaneous_on_deck_door",
		"name": "Instantaneous On-Deck Door",
		"cost": 180000000000000000000.0,
		"required_level": 43,
		"stats": ["lineup"],
		"effects": {"lineup": 0.20},
		"description": "Lineup time ×0.20.",
	},
	{
		"id": "reality_stitching",
		"name": "Reality Stitching",
		"cost": 7.0e20,
		"required_level": 44,
		"stats": ["quality", "payload"],
		"effects": {"quality": 1.35, "payload": 100.0},
		"description": "Quality ×1.35; Payload ×100.",
	},
	{
		"id": "outer_dark_umpire",
		"name": "Umpire of the Outer Dark",
		"cost": 2.0e22,
		"required_level": 44,
		"stats": ["mastery"],
		"effects": {"mastery": 2.50},
		"description": "Opponent mastery ×2.50.",
	},
]

const SCALE_UPGRADES := []

const GENETIC_UPGRADES := [
	{
		"id": "ancestral_memory",
		"name": "Remember the Strike Zone",
		"base_cost": 1.0,
		"growth": 2.0,
		"max_level": 5,
		"description": "All XP ×1.50.",
	},
	{
		"id": "fast_twitch_everything",
		"name": "Fast-Twitch Everything",
		"base_cost": 2.0,
		"growth": 3.0,
		"max_level": 6,
		"description": "Speed ×1.80.",
	},
	{
		"id": "compound_pitching_eye",
		"name": "Compound Pitching Eye",
		"base_cost": 2.0,
		"growth": 3.0,
		"max_level": 6,
		"description": "Quality +1.25.",
	},
	{
		"id": "extra_arms",
		"name": "Prehensile Pitching Arms",
		"base_cost": 3.0,
		"growth": 5.0,
		"max_level": 3,
		"description": "Arms ×2; potential throwing sources ×2.",
	},
	{
		"id": "parallel_pitching_lobes",
		"name": "Parallel Pitching Lobes",
		"base_cost": 3.0,
		"growth": 4.0,
		"max_level": 3,
		"description": "Maximum simultaneous balls ×2 (up to throwing sources).",
	},
	{
		"id": "elastic_ucl_colony",
		"name": "Elastic UCL Colony",
		"base_cost": 3.0,
		"growth": 4.0,
		"max_level": 5,
		"description": "Recovery ×1.18.",
	},
	{
		"id": "ball_gland",
		"name": "Regulation Ball Gland",
		"base_cost": 4.0,
		"growth": 4.0,
		"max_level": 5,
		"description": "Ball payload ×2.50.",
	},
	{
		"id": "compressed_strike_genome",
		"name": "Compressed Strike Genome",
		"base_cost": 6.0,
		"growth": 6.0,
		"max_level": 3,
		"description": "Post-human strike requirement −1 (minimum 3).",
	},
	{
		"id": "prehensile_outfield",
		"name": "Prehensile Outfield Reflex",
		"base_cost": 8.0,
		"growth": 5.0,
		"max_level": 3,
		"description": "Protect SINGLE, then DOUBLE, then TRIPLE; protected hits keep the count.",
	},
	{
		"id": "migratory_instinct",
		"name": "Migratory Baseball Instinct",
		"base_cost": 1.0,
		"growth": 1.0,
		"max_level": 1,
		"description": "Unlock Auto-advance.",
	},
	{
		"id": "autonomic_coach",
		"name": "Autonomic Coaching Lobe",
		"base_cost": 4.0,
		"growth": 1.0,
		"max_level": 1,
		"description": "Unlock Auto-coach.",
	},
	{
		"id": "predator_scouting",
		"name": "Predator Scouting Reflex",
		"base_cost": 8.0,
		"growth": 1.0,
		"max_level": 1,
		"description": "Unlock Auto-scout for opponent and range.",
	},
	{
		"id": "autonomic_wardrobe",
		"name": "Autonomic Wardrobe Lobe",
		"base_cost": 5.0,
		"growth": 1.0,
		"max_level": 1,
		"description": "Automatically equip the highest-Power item in every unlocked slot.",
	},
]

const ELDRITCH_UPGRADES := [
	{
		"id": "mirror_clones",
		"name": "Mirror-Reality Bullpen",
		"base_cost": 1.0,
		"growth": 4.0,
		"max_level": 5,
		"description": "Bodies ×2; potential throwing sources ×2; remaining ordinary-hit failure ×0.60.",
	},
	{
		"id": "time_compression",
		"name": "Time Compression Ritual",
		"base_cost": 2.0,
		"growth": 5.0,
		"max_level": 3,
		"description": "Time layers ×2; potential throwing sources ×2; batter downtime ÷2.",
	},
	{
		"id": "non_euclidean_bullpen",
		"name": "Non-Euclidean Bullpen Geometry",
		"base_cost": 2.0,
		"growth": 5.0,
		"max_level": 4,
		"description": "Maximum simultaneous balls ×4 (up to throwing sources).",
	},
	{
		"id": "velocity_without_distance",
		"name": "Velocity Without Distance",
		"base_cost": 1.0,
		"growth": 4.0,
		"max_level": 4,
		"description": "Speed ×12.",
	},
	{
		"id": "eyes_behind_moon",
		"name": "Eyes Behind the Moon",
		"base_cost": 2.0,
		"growth": 3.0,
		"max_level": 5,
		"description": "Quality +2.",
	},
	{
		"id": "causal_seams",
		"name": "Causal Seams",
		"base_cost": 2.0,
		"growth": 4.0,
		"max_level": 5,
		"description": "Ball payload ×10.",
	},
	{
		"id": "portal_outfield",
		"name": "Bullpen Portals",
		"base_cost": 3.0,
		"growth": 5.0,
		"max_level": 4,
		"description": "Portal save chance +20 percentage points; saved hits keep the count.",
	},
	{
		"id": "memory_of_flesh",
		"name": "Memory of Flesh",
		"base_cost": 3.0,
		"growth": 4.0,
		"max_level": 4,
		"description": "DNA gained ×1.50.",
	},
	{
		"id": "mercy_is_euclidean",
		"name": "Mercy Is Euclidean",
		"base_cost": 5.0,
		"growth": 5.0,
		"max_level": 3,
		"description": "Opponent mastery ×1.75.",
	},
	{
		"id": "reverse_terminator",
		"name": "Reverse Terminator Wardrobe",
		"base_cost": 2.0,
		"growth": 3.0,
		"max_level": 7,
		"description": "Genetic time travel keeps 1 random equipped item per rank; all other loot resets.",
	},
	{
		"id": "clone_dress_code",
		"name": "One-Size-Fits-All-Realities Uniform",
		"base_cost": 6.0,
		"growth": 1.0,
		"max_level": 1,
		"description": "Every mirror clone receives full equipped-item bonuses.",
	},
]

const DIVINE_BLESSINGS := [
	{
		"id": "let_there_be_fastballs",
		"name": "Let There Be Fastballs",
		"description": "Starting speed ×10.",
	},
	{
		"id": "eternal_seventh",
		"name": "The Seventh Inning Is Eternal",
		"description": "Opponent mastery ×2.",
	},
	{
		"id": "angels_outfield",
		"name": "Angels in the Outfield",
		"description": "Ordinary hits always preserve the count; Grand Slams still end the at-bat.",
	},
	{
		"id": "loaves_and_baseballs",
		"name": "Loaves, Fishes & Baseballs",
		"description": "Ball payload ×25.",
	},
	{
		"id": "book_of_genealogy",
		"name": "The Book of Baseball Genealogy",
		"description": "DNA gained ×2.",
	},
	{
		"id": "bottom_ninth_revelation",
		"name": "Revelation, Bottom of the Ninth",
		"description": "Arcana gained ×2.",
	},
]

static func opponents() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index in OPPONENT_NAMES.size():
		var era_index := int(index / 5)
		var distance := 3.0
		if era_index == 1:
			distance = 20.0
		elif era_index == 2:
			distance = 44.0
		elif era_index >= 3 and era_index <= 5:
			distance = 60.5
		elif era_index == 6:
			distance = 72.0
		elif era_index == 7:
			distance = 120.0
		elif era_index == 8:
			distance = 300.0
		var mastery_required := 25.0 * pow(1.34, index)
		result.append({
			"id": "opponent_%02d" % (index + 1),
			"name": OPPONENT_NAMES[index],
			"era": ERA_NAMES[era_index],
			"era_index": era_index,
			"difficulty": _opponent_difficulty_for_index(index),
			"reward": pow(1.55, index),
			"mastery_required": mastery_required,
			"distance": distance,
			"quirk": OPPONENT_QUIRKS[index],
			"trait": _trait_for_index(index),
		})
	return result

static func _opponent_difficulty_for_index(index: int) -> float:
	var bounded_index := clampi(index, 0, OPPONENT_NAMES.size() - 1)
	var era_index := int(bounded_index / 5)
	var within_era := bounded_index % 5
	if era_index >= ERA_NAMES.size() - 1:
		return lerpf(
			float(OPPONENT_DIFFICULTY_ANCHORS[era_index]),
			float(OPPONENT_DIFFICULTY_ANCHORS[era_index + 1]),
			float(within_era) / 4.0
		)
	return lerpf(
		float(OPPONENT_DIFFICULTY_ANCHORS[era_index]),
		float(OPPONENT_DIFFICULTY_ANCHORS[era_index + 1]),
		float(within_era) / 5.0
	)

static func batter_display_name(opponent_index: int, generation: int) -> String:
	if generation <= 0 and SIGNATURE_BATTER_NAMES.has(opponent_index):
		return str(SIGNATURE_BATTER_NAMES[opponent_index])
	var era_index := clampi(int(opponent_index / 5), 0, BATTER_NAME_POOLS.size() - 1)
	var pool: Array = BATTER_NAME_POOLS[era_index]
	if pool.is_empty():
		return "Unnamed Batter"
	# Seven is coprime with the twelve-name pools, so a class visits every name
	# before repeating. The opponent offset prevents adjacent classes from
	# opening with the same person while preserving Little Timmy at level one.
	var name_index := (maxi(generation, 0) * 7 + maxi(opponent_index, 0) * 3) % pool.size()
	return str(pool[name_index])

static func _trait_for_index(index: int) -> String:
	match index:
		8, 9:
			return "sequence_reader"
		14:
			return "scouted"
		19:
			return "college_champion"
		24:
			return "major_distance"
		29:
			return "adaptive_legend"
		30:
			return "switch_experiment"
		32:
			return "cybernetic_learning"
		33:
			return "four_bats"
		34:
			return "chrono"
		35:
			return "low_gravity"
		37:
			return "plasma_bat"
		38:
			return "giant_zone"
		39:
			return "solar_champion"
		40:
			return "aeon_rookie"
		41:
			return "phase_hitter"
		42:
			return "hive_mind"
		43:
			return "black_hole"
		44:
			return "octopus_god"
		_:
			return "standard"

static func trait_description(trait_id: String) -> String:
	match trait_id:
		"sequence_reader":
			return "COUNTER • +0.70 threat per missing pitch below 2."
		"scouted", "college_champion", "adaptive_legend":
			return "COUNTER • +0.48 threat per missing pitch below 4."
		"major_distance":
			return "COUNTER • Below 60 ft 6 in: +0.40 threat per 10× closer."
		"switch_experiment":
			return "COUNTER • One throwing arm adds +0.75 threat; 2+ removes it."
		"cybernetic_learning":
			return "COUNTER • +0.55 threat per missing pitch below 6."
		"four_bats":
			return "COUNTER • +0.75 threat per 10× below 100 pitches/sec."
		"chrono":
			return "COUNTER • +0.80 threat per 10× below 500 pitches/sec."
		"low_gravity", "plasma_bat", "giant_zone", "solar_champion":
			return "FIELD EFFECT • +0.65 threat."
		"aeon_rookie":
			return "COUNTER • One time layer adds +0.80 threat; 2+ removes it."
		"phase_hitter":
			return "COUNTER • +0.50 threat per missing pitch below 8."
		"hive_mind":
			return "COUNTER • +0.60 threat per 3× short of 9 pitcher bodies."
		"black_hole":
			return "COUNTER • +0.42 threat per 10× below 1M ft/s."
		"octopus_god":
			return "COUNTER • +0.90 threat per 10× below 1,000/s; +0.50 per arm-doubling below 8."
		_:
			return ""

static func training_by_id(id: String) -> Dictionary:
	for item in TRAINING:
		if item.id == id:
			return item
	return {}

static func pitch_by_id(id: String) -> Dictionary:
	for item in PITCHES:
		if item.id == id:
			return item
	return {}

static func ball_upgrade_by_id(id: String) -> Dictionary:
	for item in BALL_UPGRADES:
		if item.id == id:
			return item
	return {}

static func milestone_by_id(id: String) -> Dictionary:
	for item in MILESTONES:
		if item.id == id:
			return item
	return {}

static func scale_by_id(id: String) -> Dictionary:
	for item in SCALE_UPGRADES:
		if item.id == id:
			return item
	return {}

static func genetic_by_id(id: String) -> Dictionary:
	for item in GENETIC_UPGRADES:
		if item.id == id:
			return item
	return {}

static func eldritch_by_id(id: String) -> Dictionary:
	for item in ELDRITCH_UPGRADES:
		if item.id == id:
			return item
	return {}

static func divine_by_id(id: String) -> Dictionary:
	for item in DIVINE_BLESSINGS:
		if item.id == id:
			return item
	return {}

static func loot_slot_by_id(id: String) -> Dictionary:
	for item in LOOT_SLOTS:
		if item.id == id:
			return item
	return {}

static func loot_rarity(index: int) -> Dictionary:
	if index < 0 or index >= LOOT_RARITIES.size():
		return {}
	return LOOT_RARITIES[index]

static func loot_stat_by_id(id: String) -> Dictionary:
	for item in LOOT_STATS:
		if item.id == id:
			return item
	return {}
