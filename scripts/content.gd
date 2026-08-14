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
	"tap": "Tapping the open field advances the active pitch, flight, or lineup timer. Taps may supply at most half of one timer; the rest must pass normally.",
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

# Replacement batters use these parts in sixteen different arrangements. The
# authored pool above remains one possible arrangement, while the composable
# forms provide thousands of era-appropriate identities per league without
# storing cosmetic strings in the save file.
const BATTER_NAME_COMPONENTS := [
	{
		"given": ["Timmy", "Nora", "Kevin", "Maddie", "Sam", "Sophie", "Ben", "Claire"],
		"middle": ["Snack", "Crayon", "Juice", "Nap", "Biscuit", "Pajama", "Wiggle", "Bubbles"],
		"family": ["McGee", "Crumb", "Juicebox", "Wobble", "Sprinkles", "Two-Socks", "Puddles", "Dinosaur"],
		"nickname": ["No-Nap", "Sticky Hands", "Tiny", "Big Kid", "Snacktime", "Uh-Oh", "Fast Shoes", "Again!"],
		"epithet": ["Breaker of Bedtime", "Keeper of the Juice Box", "Terror of the Sandbox", "Who Refuses Naps", "Champion of Sharing", "Bearer of the Blue Crayon", "Lord of the Playroom", "The Very Four-Year-Old"],
		"mononym": ["Binky", "Sprout", "Scooter", "Muffin", "Pickles", "Button", "Noodle", "Tater"],
		"title": ["Prince", "Princess", "Captain", "Doctor", "Big Kid", "Snack Boss", "Sir", "Lady"],
		"origin": ["the Sandbox", "Snack Table", "the Blue Slide", "Quiet Time", "Backyardia", "the Toy Chest"],
	},
	{
		"given": ["Brayden", "Kayleigh", "Jaxxon", "Trevor", "Riley", "Easton", "Harper", "Gabe"],
		"middle": ["Elite", "Travel", "Launch", "Tournament", "Composite", "All-Star", "Select", "Weekend"],
		"family": ["Batson", "Cleats", "Moonshot", "Dugout", "Rally", "Fencewell", "Gloveson", "Coachman"],
		"nickname": ["Two Xs", "Tournament", "Helmet Hair", "The Ringer", "Bat Flip", "Early Practice", "Matching Socks", "Pool Play"],
		"epithet": ["Crown of Little League", "Tyrant of Pool Play", "Destroyer of Orange Slices", "First of the Select Team", "Who Never Misses Practice", "Bearer of the Composite Bat", "Scourge of Saturday Mornings", "Champion of the Snack Stand"],
		"mononym": ["Sluggo", "Rally", "Dinger", "Rocket", "Webgem", "Shortstop", "Acekid", "Moonshot"],
		"title": ["Captain", "All-Star", "Coach's Favorite", "Tournament King", "Select", "Cleanup", "Leadoff", "District"],
		"origin": ["Field Three", "the Travel Team", "Pool B", "District Seven", "the Batting Cage", "Saturday Bracket"],
	},
	{
		"given": ["Seth", "Lola", "Gavin", "Vanessa", "Derek", "Casey", "Holly", "Stella"],
		"middle": ["Varsity", "Detention", "Honor-Roll", "Aluminum", "Cafeteria", "Pep-Rally", "Study-Hall", "Late-Bus"],
		"family": ["Lineup", "Lockermore", "Pepper", "Blacktop", "Bellringer", "Hallpass", "Scorebook", "Backstop"],
		"nickname": ["JV", "Pop Quiz", "The Senior", "Extra Credit", "Lunch Period", "No Homework", "Bus Ride", "Coach's Nephew"],
		"epithet": ["Sovereign of Varsity", "Dread of the Faculty Lot", "Keeper of the Hall Pass", "Who Bats After Detention", "Champion of Third Period", "Breaker of Aluminum", "First Name on the Lineup Card", "The Unbenched"],
		"mononym": ["Yearbook", "Hallpass", "Prom", "Pepper", "Crammer", "Letterman", "Backstop", "Homeroom"],
		"title": ["Captain", "Senior", "Prefect", "Valedictorian", "Cleanup", "Principal", "Coach", "Mascot"],
		"origin": ["Homeroom", "the Late Bus", "Second Lunch", "Varsity Hill", "the Blacktop", "Study Hall"],
	},
	{
		"given": ["Randy", "Tina", "Neil", "Stan", "Wanda", "Sheldon", "Cami", "Miranda"],
		"middle": ["Redshirt", "Portal", "Scholarship", "Statistics", "Midterm", "NIL", "Walk-On", "Fifth-Year"],
		"family": ["Slugworth", "Woodbat", "Campus", "Transfer", "Seminar", "Bursar", "Syllabus", "Alumni"],
		"nickname": ["The Undeclared", "Office Hours", "Meal Plan", "Extra Semester", "Transfer Portal", "Lab Partner", "Tenured", "The Walk-On"],
		"epithet": ["Eater of Aluminum", "Lord of the Transfer Portal", "Bearer of the NIL Deal", "Who Majors in Exit Velocity", "Champion of the College World", "The Permanently Eligible", "Destroyer of Office Hours", "First of the Redshirts"],
		"mononym": ["Syllabus", "Redshirt", "Bursar", "Seminar", "Woodbat", "Campus", "Tenure", "Portal"],
		"title": ["Professor", "Dean", "Captain", "Doctor", "Redshirt", "Chancellor", "Graduate", "Walk-On"],
		"origin": ["the Quad", "State", "the Transfer Portal", "West Campus", "the Wood-Bat Lab", "Conference Play"],
	},
	{
		"given": ["Bobby", "Penny", "Dave", "Pete", "Miguel", "Carla", "Oscar", "Olivia"],
		"middle": ["Per-Diem", "Call-Up", "Option-Year", "Rehab", "Roster", "Bus-League", "Prospect", "Clubhouse"],
		"family": ["Motel", "Callahan", "Transactions", "Coffee", "Waiver", "Doubleheader", "Farmhand", "Futures"],
		"nickname": ["Player To Be Named", "The Call-Up", "Forty-Man", "Cash Considerations", "Long Bus", "Rehab Start", "Options Left", "Organizational Depth"],
		"epithet": ["Awaiting Judgment", "Rider of the Fourteen-Hour Bus", "Keeper of the Meal Money", "Who Survived Double-A", "Last of the Options", "The Per-Diem Crowned", "Lord of Future Considerations", "Summoned to the Show"],
		"mononym": ["Callup", "Waivers", "Perdiem", "Prospect", "Rehab", "Options", "Clubhouse", "Futures"],
		"title": ["Prospect", "Veteran", "Call-Up", "Captain", "Organizational", "Taxi-Squad", "Rehab", "Roster"],
		"origin": ["the Farm", "Triple-A", "the Motel Bullpen", "Waiver Wire", "the Forty-Man", "Bus League"],
	},
	{
		"given": ["Connor", "Alice", "Walter", "Larry", "Evelyn", "Arnie", "Freddie", "Emma"],
		"middle": ["Contract-Year", "Arbitration", "Launch-Angle", "Exit-Velo", "October", "Franchise", "No-Trade", "Endorsement"],
		"family": ["Winslow", "Statcast", "Luxurytax", "Pennant", "Walkoff", "Dugout", "Clubhouse", "Cooperstown"],
		"nickname": ["WARlord", "Mr. October-ish", "The Franchise", "No-Trade", "Exit Velo", "Press Conference", "Walk-Off", "Club Option"],
		"epithet": ["Last of the Mortals", "Lord of Launch Angle", "Arbiter of Arbitration", "Bearer of the No-Trade Clause", "King Beneath the Luxury Tax", "Who Walks Off October", "The Five-Tool Crowned", "First Ballot of the Old Order"],
		"mononym": ["Walkoff", "Statcast", "October", "Franchise", "Cooperstown", "Pennant", "WARlord", "Slugger"],
		"title": ["MVP", "All-Star", "Captain", "Commissioner", "Franchise", "Derby King", "October", "Gold Glove"],
		"origin": ["Cooperstown", "the Show", "October", "the Luxury-Tax Realm", "Statcast", "the Home Run Derby"],
	},
	{
		"given": ["Henry", "Marla", "Chris", "Betty", "Florence", "Gary", "Derek", "C.A.S.E.Y."],
		"middle": ["CRISPR", "Firmware", "Bionic", "Four-Armed", "Gene-Doped", "Patch-Notes", "Clone", "Compliance"],
		"family": ["Prime", "Genome", "Chromosome", "Veincrown", "Patchwork", "Quadgrip", "Mechason", "Protocol"],
		"nickname": ["HGHenry", "Trenjamin", "Legal Gray Area", "Version Seven", "The Compliance Incident", "Hotfix", "Clone Number", "Unlicensed"],
		"epithet": ["The Vein-Crowned", "Reader of Seams", "Hands Unnumbered", "Who Passed No Drug Test", "Bearer of Forbidden Alleles", "First of the Hotfixes", "The Patched Beyond Recognition", "Commissioner of New Flesh"],
		"mononym": ["Trenbolus", "Mechandra", "Crisprax", "Genome-9", "Patchlord", "Quadra", "Bion", "Compliance"],
		"title": ["Doctor", "Clone", "Prototype", "Commissioner", "Version", "Gene-Lord", "Patch", "Specimen"],
		"origin": ["Vat Nine", "the Genome League", "Patch 7.4", "the Cloning Annex", "New Flesh", "the Compliance Hearing"],
	},
	{
		"given": ["Mookie", "Vera", "Marvin", "Eunice", "Sol", "Tina", "Carla", "Jones"],
		"middle": ["Moonbase", "Low-G", "Venusian", "Martian", "Europa", "Solar-Flare", "Comet-Tail", "Orbital"],
		"family": ["Quasar", "Moonshot", "Ringwalker", "Starfall", "Nebula", "Sunward", "Crater", "Aphelion"],
		"nickname": ["Low-G", "Red Planet", "Ring Runner", "Quick Mercury", "Vacuum Swing", "Solar Flare", "Three Legs", "Moonball"],
		"epithet": ["Champion Beneath All Suns", "Queen of the Warning Track", "Wielder of Plasma", "Who Bats Before Dawn", "Lord of Low Gravity", "Bearer of the Solar Crown", "The Tripodal Contact", "Scourge of Nine Moons"],
		"mononym": ["Lunara", "Tripodus", "Solus", "Jovus", "Andromedax", "Nebulon", "Xylax", "Glorbo"],
		"title": ["Solar", "Lunar", "Jovian", "Orbital", "Captain", "Admiral", "Tripodal", "Plasma"],
		"origin": ["Nine Moons", "the Jovian Diamond", "Low Orbit", "Andromeda", "the Solar League", "Europa"],
	},
	{
		"given": ["Zorp", "Xylax", "Glorbo", "Nebulon", "Vrrt", "Kragulus", "N'Kthra", "Dave"],
		"middle": ["Aeon", "Phase", "Void", "Ninefold", "Unfixed", "Moonless", "Causal", "Unscouted"],
		"family": ["Nightglass", "Worldend", "Gravemoon", "Starless", "Between-Seconds", "Blackdiamond", "Lastlight", "Outer-Inning"],
		"nickname": ["The Patient", "Ominous", "Unpronounceable", "The Unfixed", "Nine Bodies", "No Reflection", "Before Time", "The Final Rookie"],
		"epithet": ["Rookie of the Last Aeon", "The Unstrikeable", "God of the Eightfold Swing", "Who Bats Between Seconds", "Bearer of the Shared Eye", "Last Witness of Causality", "Champion Beyond Geometry", "Devourer of Called Strikes"],
		"mononym": ["Octathulhu", "Ball-rog", "N'Kthra", "Andromedax", "Q'Bert", "Vrrt", "Kragulus", "Nullslug"],
		"title": ["Elder", "Void", "Aeon", "Ninefold", "Last", "Unfixed", "Moonless", "Causal"],
		"origin": ["the Outer Dark", "the Last Aeon", "Between Seconds", "Nine Dead Moons", "the Unplayed Inning", "Beyond the Scorebook"],
	},
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

# Achievements are permanent, additive side bonuses rather than another
# purchase economy.  Future reward types can be added per definition; for now
# every entry uses the shared +1% XP default.  Tiers are revealed only after
# their corresponding story layer has been discovered, so this catalog does
# not advertise aliens, destroyed realities, or God to a new pitcher.
const DEFAULT_ACHIEVEMENT_XP_BONUS := 0.01
const ACHIEVEMENT_TIER_ORDER := ["human", "genetic", "eldritch", "divine"]
const ACHIEVEMENT_TIER_NAMES := {
	"human": "THE REGULAR OL’ CAREER",
	"genetic": "POST-HUMAN BASEBALL",
	"eldritch": "THE OUTER WORLD SERIES",
	"divine": "EXTRA INNINGS WITH GOD",
}

const ACHIEVEMENTS := [
	# Human baseball — 50 achievements.
	{"id": "first_pitch", "tier": "human", "name": "A Threat Has Been Issued", "metric": "lifetime_pitches", "threshold": 1.0, "description": "Resolve your first pitch."},
	{"id": "first_field_tap", "tier": "human", "name": "This Is Supposed to Be Idle", "metric": "field_taps", "threshold": 1.0, "description": "Hurry an active timer with a field tap."},
	{"id": "field_taps_100", "tier": "human", "name": "Wear Pattern on the Screen", "metric": "field_taps", "threshold": 100.0, "description": "Land 100 successful field taps."},
	{"id": "first_strike", "tier": "human", "name": "Technically a Strike", "metric": "outcome", "key": STRIKE_INDEX, "threshold": 1.0, "description": "Record your first Strike."},
	{"id": "first_strikeout", "tier": "human", "name": "Sit Down, Tiny Kevin", "metric": "lifetime_strikeouts", "threshold": 1.0, "description": "Complete your first strikeout."},
	{"id": "strikeouts_10", "tier": "human", "name": "Toddler Whisperer", "metric": "lifetime_strikeouts", "threshold": 10.0, "description": "Complete 10 career strikeouts."},
	{"id": "strikeouts_100", "tier": "human", "name": "Backyard Menace", "metric": "lifetime_strikeouts", "threshold": 100.0, "description": "Complete 100 career strikeouts."},
	{"id": "strikeouts_1000", "tier": "human", "name": "The Thousand-Yard Windup", "metric": "lifetime_strikeouts", "threshold": 1000.0, "description": "Complete 1,000 career strikeouts."},
	{"id": "strikeouts_10000", "tier": "human", "name": "Ten Thousand Tiny Ks", "metric": "lifetime_strikeouts", "threshold": 10000.0, "description": "Complete 10,000 career strikeouts."},
	{"id": "pitches_100", "tier": "human", "name": "Century of Apologies", "metric": "lifetime_pitches", "threshold": 100.0, "description": "Resolve 100 career pitches."},
	{"id": "pitches_1000", "tier": "human", "name": "Rubber Arm, Foam Ball", "metric": "lifetime_pitches", "threshold": 1000.0, "description": "Resolve 1,000 career pitches."},
	{"id": "pitches_10000", "tier": "human", "name": "Pitch-Clock Enthusiast", "metric": "lifetime_pitches", "threshold": 10000.0, "description": "Resolve 10,000 career pitches."},
	{"id": "pitches_100000", "tier": "human", "name": "This Is Probably Employment", "metric": "lifetime_pitches", "threshold": 100000.0, "description": "Resolve 100,000 career pitches."},
	{"id": "first_grand_slam", "tier": "human", "name": "There Goes the Neighborhood", "metric": "outcome", "key": GRAND_SLAM_INDEX, "threshold": 1.0, "description": "Allow your first Grand Slam."},
	{"id": "home_runs_25", "tier": "human", "name": "Souvenir Distributor", "metric": "outcome", "key": 1, "threshold": 25.0, "description": "Allow 25 Home Runs."},
	{"id": "fouls_100", "tier": "human", "name": "Living on the Edge", "metric": "outcome", "key": FOUL_INDEX, "threshold": 100.0, "description": "Produce 100 Fouls."},
	{"id": "balls_100", "tier": "human", "name": "The Zone Is More of a Suggestion", "metric": "outcome", "key": BALL_INDEX, "threshold": 100.0, "description": "Throw 100 Balls."},
	{"id": "strikes_1000", "tier": "human", "name": "Blue Likes It", "metric": "outcome", "key": STRIKE_INDEX, "threshold": 1000.0, "description": "Record 1,000 Strikes."},
	{"id": "reach_level_5", "tier": "human", "name": "Preschool Suspension", "metric": "level", "threshold": 4.0, "description": "Reach Level 5."},
	{"id": "reach_level_10", "tier": "human", "name": "Parent-Teacher Conference", "metric": "level", "threshold": 9.0, "description": "Reach Level 10."},
	{"id": "reach_level_15", "tier": "human", "name": "Varsity Adjacent", "metric": "level", "threshold": 14.0, "description": "Reach Level 15."},
	{"id": "reach_level_20", "tier": "human", "name": "College Material", "metric": "level", "threshold": 19.0, "description": "Reach Level 20."},
	{"id": "reach_level_25", "tier": "human", "name": "The Long Bus Ride", "metric": "level", "threshold": 24.0, "description": "Reach Level 25."},
	{"id": "reach_level_30", "tier": "human", "name": "A Regular Ol’ Big Leaguer", "metric": "level", "threshold": 29.0, "description": "Reach Level 30."},
	{"id": "complete_human_baseball", "tier": "human", "name": "The Human Limit", "metric": "level", "threshold": 30.0, "reveal_level": 29, "description": "Master the final human batter."},
	{"id": "distance_6ft", "tier": "human", "name": "Personal Space", "metric": "distance", "threshold": 1.0, "description": "Pitch from 6 feet."},
	{"id": "distance_30ft", "tier": "human", "name": "There Is Now a Mound", "metric": "distance", "threshold": 4.0, "description": "Pitch from 30 feet."},
	{"id": "distance_regulation", "tier": "human", "name": "Sixty Feet, Six Inches, Somehow", "metric": "distance", "threshold": 6.0, "description": "Pitch from a regulation mound."},
	{"id": "distance_outfield", "tier": "human", "name": "Pitching from Center Field", "metric": "distance", "threshold": 8.0, "description": "Pitch from 300 feet."},
	{"id": "speed_2fps", "tier": "human", "name": "Twice the Game’s Name", "metric": "speed", "threshold": 2.0, "description": "Throw a pitch at 2 ft/s."},
	{"id": "speed_10fps", "tier": "human", "name": "Breaking into Double Digits", "metric": "speed", "threshold": 10.0, "description": "Throw a pitch at 10 ft/s."},
	{"id": "speed_60fps", "tier": "human", "name": "A Brisk Sixty Feet per Second", "metric": "speed", "threshold": 60.0, "description": "Throw a pitch at 60 ft/s."},
	{"id": "speed_100mph", "tier": "human", "name": "Three Digits", "metric": "speed", "threshold": 146.66676444450962, "description": "Throw a pitch at 100 mph."},
	{"id": "speed_human_cap", "tier": "human", "name": "History, Doubled", "metric": "speed", "threshold": 310.3468735645824, "secret": true, "description": "Reach 211.6 mph, twice the recorded human benchmark."},
	{"id": "velocity_rank_1", "tier": "human", "name": "Arm Day", "metric": "training", "key": "velocity", "threshold": 1.0, "description": "Buy your first Speed Training rank."},
	{"id": "command_rank_1", "tier": "human", "name": "An Attempt Was Made", "metric": "training", "key": "command", "threshold": 1.0, "description": "Buy your first Command Drills rank."},
	{"id": "field_hustle_rank_1", "tier": "human", "name": "Idle Game, Active Finger", "metric": "training", "key": "field_hustle", "threshold": 1.0, "description": "Buy your first Field Hustle rank."},
	{"id": "recovery_rank_10", "tier": "human", "name": "Between-Pitch Breathing Optional", "metric": "training", "key": "recovery", "threshold": 10.0, "description": "Reach Recovery Drills rank 10."},
	{"id": "offline_rank_10", "tier": "human", "name": "The Scorebook Worked Overnight", "metric": "training", "key": "offline_efficiency", "threshold": 10.0, "description": "Reach Scorebook Study rank 10."},
	{"id": "arsenal_3", "tier": "human", "name": "Three Pitches Is an Arsenal", "metric": "pitches_owned", "threshold": 3.0, "description": "Learn three pitch types."},
	{"id": "arsenal_6", "tier": "human", "name": "Six Ways to Embarrass Yourself", "metric": "pitches_owned", "threshold": 6.0, "description": "Learn six pitch types."},
	{"id": "arsenal_9", "tier": "human", "name": "Every Legal-ish Pitch", "metric": "pitches_owned", "threshold": 9.0, "description": "Learn all nine human pitch types."},
	{"id": "ball_upgrades_5", "tier": "human", "name": "Ball of Theseus", "metric": "ball_upgrades_owned", "threshold": 5.0, "description": "Install five ball upgrades."},
	{"id": "ball_upgrades_10", "tier": "human", "name": "Core Curriculum", "metric": "ball_upgrades_owned", "threshold": 10.0, "description": "Install ten ball upgrades."},
	{"id": "ball_upgrades_16", "tier": "human", "name": "World-Series Materials Science", "metric": "ball_upgrades_owned", "threshold": 16.0, "description": "Install every human ball shell."},
	{"id": "facilities_5", "tier": "human", "name": "The Garage Is a Facility", "metric": "facilities_owned", "threshold": 5.0, "description": "Acquire five one-time facilities."},
	{"id": "facilities_15", "tier": "human", "name": "Zoning Violation", "metric": "facilities_owned", "threshold": 15.0, "description": "Acquire fifteen one-time facilities."},
	{"id": "first_loot", "tier": "human", "name": "Little Timmy’s Lost and Found", "metric": "loot_found", "threshold": 1.0, "description": "Find your first equipment item."},
	{"id": "legendary_loot", "tier": "human", "name": "Orange You Glad It Dropped", "metric": "loot_rarity", "threshold": 3.0, "secret": true, "description": "Find a Legendary equipment item."},
	{"id": "fully_equipped", "tier": "human", "name": "Dressed for the Job", "metric": "equipped_slots", "threshold": 6.0, "description": "Equip all six human clothing slots at once."},

	# Genetic and alien baseball — 25 achievements.
	{"id": "genetic_offer", "tier": "genetic", "name": "The Commissioner Has a Proposal", "metric": "genetic_offer", "threshold": 1.0, "description": "Hear Xylophax’s complete genetic proposal."},
	{"id": "genetic_rebirth_1", "tier": "genetic", "name": "Born Again, But Baseball", "metric": "genetic_rebirths", "threshold": 1.0, "description": "Complete your first genetic rebirth."},
	{"id": "genetic_rebirth_5", "tier": "genetic", "name": "Prenatal Free Agent", "metric": "genetic_rebirths", "threshold": 5.0, "description": "Complete five genetic rebirths."},
	{"id": "dna_10", "tier": "genetic", "name": "Double Helix, Double Play", "metric": "lifetime_dna", "threshold": 10.0, "description": "Earn 10 lifetime DNA."},
	{"id": "genetic_upgrades_5", "tier": "genetic", "name": "Genome Completionist, Junior", "metric": "genetic_upgrades_owned", "threshold": 5.0, "description": "Own five different genetic enhancements."},
	{"id": "arms_2", "tier": "genetic", "name": "The Other Other Hand", "metric": "arms", "threshold": 2.0, "description": "Grow a second pitching arm."},
	{"id": "arms_4", "tier": "genetic", "name": "Four-Seam, Four Arms", "metric": "arms", "threshold": 4.0, "description": "Pitch with four arms."},
	{"id": "arms_8", "tier": "genetic", "name": "Octo-Pitcher, Biologically", "metric": "arms", "threshold": 8.0, "description": "Pitch with eight arms."},
	{"id": "volley_2", "tier": "genetic", "name": "One Swing, Two Problems", "metric": "volley", "threshold": 2.0, "description": "Release two real balls in one volley."},
	{"id": "volley_4", "tier": "genetic", "name": "Arm-Based Load Balancing", "metric": "volley", "threshold": 4.0, "description": "Release four real balls in one volley."},
	{"id": "compressed_count", "tier": "genetic", "name": "Three Strikes, Eventually", "metric": "genetic_upgrade", "key": "compressed_strike_genome", "threshold": 1.0, "description": "Buy Compressed Strike Genome."},
	{"id": "saved_hits_100", "tier": "genetic", "name": "Catch, Return, Reuse", "metric": "saved_hits", "threshold": 100.0, "description": "Preserve the count through 100 ordinary hits."},
	{"id": "auto_advance", "tier": "genetic", "name": "The Legs Know the Schedule", "metric": "genetic_upgrade", "key": "migratory_instinct", "threshold": 1.0, "description": "Unlock Auto-advance."},
	{"id": "auto_coach", "tier": "genetic", "name": "Coach in the Medulla", "metric": "genetic_upgrade", "key": "autonomic_coach", "threshold": 1.0, "description": "Unlock Auto-coach."},
	{"id": "auto_scout", "tier": "genetic", "name": "Apex Sabermetrician", "metric": "genetic_upgrade", "key": "predator_scouting", "threshold": 1.0, "description": "Unlock Auto-scout."},
	{"id": "auto_wardrobe", "tier": "genetic", "name": "Dressed by Reflex", "metric": "genetic_upgrade", "key": "autonomic_wardrobe", "threshold": 1.0, "description": "Unlock automatic equipment selection."},
	{"id": "first_relic", "tier": "genetic", "name": "Post-Human Pocket", "metric": "relic_owned", "threshold": 1.0, "description": "Find your first Relic-slot item."},
	{"id": "reach_four_armed_hitter", "tier": "genetic", "name": "Four Arms, No Waiting", "metric": "level", "threshold": 33.0, "reveal_level": 33, "description": "Reach the Four-Armed Cleanup Hitter."},
	{"id": "reach_moonballer", "tier": "genetic", "name": "Moonball Is Now Literal", "metric": "level", "threshold": 35.0, "reveal_level": 35, "description": "Reach the Low-Gravity Moonballer."},
	{"id": "reach_plasma_slugger", "tier": "genetic", "name": "Plasma Burns Are Still Burns", "metric": "level", "threshold": 37.0, "reveal_level": 37, "description": "Reach the Plasma-Bat Slugger."},
	{"id": "reach_alien_champion", "tier": "genetic", "name": "Champion Beneath All Suns", "metric": "level", "threshold": 39.0, "reveal_level": 39, "description": "Reach the Interstellar Champion."},
	{"id": "complete_alien_baseball", "tier": "genetic", "name": "Solar-System Champions", "metric": "level", "threshold": 40.0, "reveal_level": 39, "description": "Master the final alien batter."},
	{"id": "speed_mach_1", "tier": "genetic", "name": "Sound Barrier: Optional", "metric": "speed", "threshold": 1125.33, "description": "Throw a pitch at Mach 1."},
	{"id": "speed_mach_3", "tier": "genetic", "name": "Licensed for Mach Three", "metric": "speed", "threshold": 3375.99, "reveal_level": 39, "description": "Throw a pitch at Mach 3."},
	{"id": "speed_mach_12", "tier": "genetic", "name": "Atmosphere Not Included", "metric": "speed", "threshold": 13503.96, "secret": true, "description": "Reach the Mach 12 genetic limit."},

	# Eldritch baseball — 19 achievements.
	{"id": "eldritch_offer", "tier": "eldritch", "name": "The Rookie Explains Reality", "metric": "eldritch_offer", "threshold": 1.0, "description": "Hear N’Kthra’s complete explanation of reality."},
	{"id": "eldritch_ascension_1", "tier": "eldritch", "name": "This Reality Had Bad Umpires", "metric": "eldritch_ascensions", "threshold": 1.0, "description": "Destroy your first reality."},
	{"id": "eldritch_ascension_3", "tier": "eldritch", "name": "Multiverse Journeyman", "metric": "eldritch_ascensions", "threshold": 3.0, "description": "Destroy three realities."},
	{"id": "arcana_10", "tier": "eldritch", "name": "Pocket Full of Arcana", "metric": "lifetime_arcana", "threshold": 10.0, "description": "Earn 10 lifetime Arcana."},
	{"id": "clones_2", "tier": "eldritch", "name": "Bullpen from Somewhere Else", "metric": "clones", "threshold": 2.0, "description": "Recruit your first mirror-reality pitcher."},
	{"id": "clones_8", "tier": "eldritch", "name": "Eight Me’s and a Scorekeeper", "metric": "clones", "threshold": 8.0, "description": "Pitch with eight versions of yourself."},
	{"id": "clones_32", "tier": "eldritch", "name": "Thirty-Two Pitchers, One Soul", "metric": "clones", "threshold": 32.0, "description": "Pitch with 32 versions of yourself."},
	{"id": "time_layers_8", "tier": "eldritch", "name": "Eight Innings at Once", "metric": "time_layers", "threshold": 8.0, "description": "Stack eight time-compressed innings."},
	{"id": "volley_16", "tier": "eldritch", "name": "Anime Bullpen Initiated", "metric": "volley", "threshold": 16.0, "description": "Release 16 real balls in one volley."},
	{"id": "volley_256", "tier": "eldritch", "name": "Missile Budget Exceeded", "metric": "volley", "threshold": 256.0, "description": "Release 256 real balls in one volley."},
	{"id": "volley_2048", "tier": "eldritch", "name": "Two Thousand Forty-Eight Problems", "metric": "volley", "threshold": 2048.0, "description": "Release the designed maximum 2,048-ball volley."},
	{"id": "first_portal", "tier": "eldritch", "name": "The Ball Was Never There", "metric": "eldritch_upgrade", "key": "portal_outfield", "threshold": 1.0, "description": "Open your first bullpen portal."},
	{"id": "reverse_terminator", "tier": "eldritch", "name": "Reverse Terminator", "metric": "eldritch_upgrade", "key": "reverse_terminator", "threshold": 1.0, "description": "Teach one outfit to time travel."},
	{"id": "reach_phase_hitter", "tier": "eldritch", "name": "Phase Me Once", "metric": "level", "threshold": 41.0, "reveal_level": 41, "description": "Reach the Phase-Shift Hitter."},
	{"id": "reach_nine_body_collective", "tier": "eldritch", "name": "The Nine Share One Strike Zone", "metric": "level", "threshold": 42.0, "reveal_level": 42, "description": "Reach the Nine-Body Batting Collective."},
	{"id": "reach_ball_rog", "tier": "eldritch", "name": "You Shall Not Ball", "metric": "level", "threshold": 43.0, "reveal_level": 43, "description": "Reach Ball-rog the Unstrikeable."},
	{"id": "reach_octathulhu", "tier": "eldritch", "name": "Eight Bats Enter", "metric": "level", "threshold": 44.0, "reveal_level": 44, "description": "Reach Octathulhu."},
	{"id": "speed_of_light", "tier": "eldritch", "name": "At the Speed of Plot", "metric": "speed", "threshold": 983571056.0, "reveal_level": 44, "description": "Throw a pitch at exactly light speed."},
	{"id": "cosmos_conquered", "tier": "eldritch", "name": "The Oldest Rule of Baseball", "metric": "cosmos", "threshold": 1.0, "reveal_level": 44, "description": "Defeat Octathulhu and save the universe."},

	# Divine extra innings — 6 achievements.
	{"id": "divine_ascension_1", "tier": "divine", "name": "God Is a Baseball Fan", "metric": "divine_ascensions", "threshold": 1.0, "description": "Let God restore your first universe."},
	{"id": "divine_blessings_2", "tier": "divine", "name": "Theological Loadout", "metric": "divine_blessings", "threshold": 2.0, "description": "Own two divine blessings."},
	{"id": "divine_ascension_3", "tier": "divine", "name": "Universal Three-Peat", "metric": "divine_ascensions", "threshold": 3.0, "description": "Save three universes."},
	{"id": "all_divine_blessings", "tier": "divine", "name": "Six Days, Six Blessings", "metric": "divine_blessings", "threshold": 6.0, "description": "Collect every named divine blessing."},
	{"id": "divine_halo_1", "tier": "divine", "name": "After the Afterlife", "metric": "divine_halos", "threshold": 1.0, "description": "Earn your first extra Halo."},
	{"id": "divine_halo_5", "tier": "divine", "name": "Halo Hall of Fame", "metric": "divine_halos", "threshold": 5.0, "description": "Earn five extra Halos."},
	{"id": "no_hitter", "tier": "divine", "name": "No Hitter", "metric": "no_hitter", "threshold": 1.0, "secret": true, "description": "Defeat the entire campaign through Octathulhu without allowing a single fair hit."},
]

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
		"id": "field_hustle",
		"name": "Field Hustle",
		"base_cost": 15.0,
		"growth": 2.10,
		"max_level": 6,
		"required_level": 2,
		"stats": ["tap"],
		"description": "Tap advance +0.17 percentage points.",
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
	{
		"id": "inherited_scorebook",
		"name": "Inherited Scorebook Cortex",
		"base_cost": 3.0,
		"growth": 4.0,
		"max_level": 3,
		"description": "Opponent mastery requirements ×0.85 per rank.",
	},
	{
		"id": "symbiotic_wardrobe",
		"name": "Symbiotic Wardrobe Dermis",
		"base_cost": 4.0,
		"growth": 4.0,
		"max_level": 4,
		"description": "Equipment effects ×1.20 per rank.",
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
	var legacy_pool: Array = BATTER_NAME_POOLS[era_index]
	var parts: Dictionary = BATTER_NAME_COMPONENTS[era_index]
	if legacy_pool.is_empty() or parts.is_empty():
		return "Unnamed Batter"
	var bounded_generation := maxi(generation, 0)
	var bounded_opponent := maxi(opponent_index, 0)
	var seed := bounded_generation * 104729 + bounded_opponent * 15485863 + era_index * 32452843
	var style := posmod(seed, 16)
	var first := _batter_name_component(parts, "given", seed, 1)
	var middle := _batter_name_component(parts, "middle", seed, 2)
	var family := _batter_name_component(parts, "family", seed, 3)
	var nickname := _batter_name_component(parts, "nickname", seed, 4)
	var epithet := _batter_name_component(parts, "epithet", seed, 5)
	var mononym := _batter_name_component(parts, "mononym", seed, 6)
	var title := _batter_name_component(parts, "title", seed, 7)
	var origin := _batter_name_component(parts, "origin", seed, 8)
	match style:
		0:
			return str(legacy_pool[posmod(int(seed / 11), legacy_pool.size())])
		1:
			return first
		2:
			return mononym
		3:
			return "%s %s" % [first, family]
		4:
			return "%s %s %s" % [first, middle, family]
		5:
			return "%s %s. %s" % [first, middle.left(1).to_upper(), family]
		6:
			return "%s \"%s\" %s" % [first, nickname, family]
		7:
			return "%s %s, %s" % [first, family, epithet]
		8:
			return "%s %s %s" % [title, first, family]
		9:
			return "The %s" % epithet
		10:
			return "%s %s" % [nickname, family]
		11:
			return "%s \"%s\"" % [first, nickname]
		12:
			return "%s %s." % [first, middle.left(1).to_upper()]
		13:
			return family
		14:
			return "%s of %s" % [first, origin]
		_:
			return "%s %s, %s" % [title, mononym, epithet]

static func _batter_name_component(parts: Dictionary, key: String, seed: int, salt: int) -> String:
	var pool: Array = parts.get(key, [])
	if pool.is_empty():
		return "Unknown"
	var divisor := salt * 13 + 7
	var index := posmod(int(seed / divisor) + salt * 17, pool.size())
	return str(pool[index])

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

static func achievement_by_id(id: String) -> Dictionary:
	for item in ACHIEVEMENTS:
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
