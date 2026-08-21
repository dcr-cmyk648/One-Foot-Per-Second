class_name NoHitterCampaign
extends RefCounted

# The finite campaign is deliberately regular: eleven authored three-level
# sub-eras in each league, followed by Octathulhu at level 100.  First-contact
# exhibitions are story phases that sit between leagues; they do not consume a
# level number.
const HUMAN_START_INDEX := 0
const HUMAN_FINAL_INDEX := 32
const ALIEN_START_INDEX := 33
const ALIEN_FINAL_INDEX := 65
const ELDRITCH_START_INDEX := 66
const ELDRITCH_FINAL_INDEX := 98
const FINAL_BOSS_INDEX := 99
const FINITE_LEVEL_COUNT := 100
const LEVELS_PER_SUBERA := 3
# Narrative remains in authored three-opponent sub-eras. Pitch drafts use a
# separate, predictable reward cadence.
const PITCH_DRAFT_INTERVAL := 5

const LEAGUE_HUMAN := "human"
const LEAGUE_ALIEN := "alien"
const LEAGUE_ELDRITCH := "eldritch"

# Distances are simulation data, not payout multipliers.  Repeated entries are
# intentional: regulation baseball stays at regulation distance while opponent
# skill rises; post-human play changes the physical joke instead.
const DISTANCE_TIERS := [
	{"id": "preschool_point_blank", "name": "PRESCHOOL POINT-BLANK", "label": "3 ft", "feet": 3.0, "required_level": 0, "difficulty": 0.0, "environment": "grass"},
	{"id": "tee_ball_line", "name": "TEE-BALL COACH LINE", "label": "10 ft", "feet": 10.0, "required_level": 3, "difficulty": 0.12, "environment": "grass"},
	{"id": "coach_pitch", "name": "COACH-PITCH FRONT LINE", "label": "25 ft", "feet": 25.0, "required_level": 6, "difficulty": 0.26, "environment": "grass"},
	{"id": "little_league", "name": "LITTLE-LEAGUE MOUND", "label": "46 ft", "feet": 46.0, "required_level": 9, "difficulty": 0.44, "environment": "grass"},
	{"id": "junior_league", "name": "JUNIOR-LEAGUE MOUND", "label": "54 ft", "feet": 54.0, "required_level": 12, "difficulty": 0.58, "environment": "grass"},
	{"id": "regulation", "name": "REGULATION MOUND", "label": "60 ft 6 in", "feet": 60.5, "required_level": 15, "difficulty": 0.72, "environment": "grass"},
	{"id": "alien_long_toss", "name": "GENOME-LEAGUE LONG TOSS", "label": "90 ft", "feet": 90.0, "required_level": ALIEN_START_INDEX, "difficulty": 1.0, "environment": "alien_grass"},
	{"id": "lunar_crater", "name": "LUNAR CRATER DIAMOND", "label": "300 ft", "feet": 300.0, "required_level": 36, "difficulty": 1.25, "environment": "moon"},
	{"id": "martian_mile", "name": "MARTIAN MILE MOUND", "label": "1 mile", "feet": 5280.0, "required_level": 39, "difficulty": 1.6, "environment": "mars"},
	{"id": "asteroid_hop", "name": "ASTEROID-TO-ASTEROID SERIES", "label": "25 miles", "feet": 132000.0, "required_level": 42, "difficulty": 2.0, "environment": "space"},
	{"id": "jovian_orbit", "name": "JOVIAN ORBITAL DIAMOND", "label": "250 miles", "feet": 1320000.0, "required_level": 45, "difficulty": 2.5, "environment": "space"},
	{"id": "moonlet_series", "name": "MOONLET ROAD SERIES", "label": "1,000 miles", "feet": 5280000.0, "required_level": 48, "difficulty": 3.0, "environment": "space"},
	{"id": "planetary_diameter", "name": "PLANETARY-DIAMETER PARK", "label": "2,500 miles", "feet": 13200000.0, "required_level": 51, "difficulty": 3.6, "environment": "space"},
	{"id": "solar_proving_ground", "name": "SOLAR PROVING GROUND", "label": "3,500 miles", "feet": 18480000.0, "required_level": 54, "difficulty": 4.2, "environment": "space"},
	{"id": "interstellar_embassy", "name": "INTERSTELLAR EMBASSY FIELD", "label": "4,000 miles", "feet": 21120000.0, "required_level": 57, "difficulty": 4.9, "environment": "space"},
	{"id": "galactic_series", "name": "GALACTIC ROAD-SERIES PARK", "label": "4,500 miles", "feet": 23760000.0, "required_level": 60, "difficulty": 5.7, "environment": "space"},
	{"id": "olympus_mound", "name": "OLYMPUS MOUND", "label": "Across Mars • 4,212 miles", "feet": 22239360.0, "required_level": 63, "difficulty": 6.6, "environment": "mars"},
	{"id": "earth_to_moon", "name": "EARTH DEFENSE • LUNAR LINE", "label": "Earth to Moon", "feet": 1.261e9, "required_level": ELDRITCH_START_INDEX, "difficulty": 8.0, "environment": "space"},
	{"id": "earth_to_mercury", "name": "EARTH DEFENSE • MERCURY LINE", "label": "48 million miles", "feet": 2.5344e11, "required_level": 69, "difficulty": 9.5, "environment": "deep_space"},
	{"id": "earth_to_venus", "name": "EARTH DEFENSE • VENUS LINE", "label": "100 million miles", "feet": 5.28e11, "required_level": 72, "difficulty": 11.0, "environment": "deep_space"},
	{"id": "earth_to_mars", "name": "EARTH DEFENSE • MARS LINE", "label": "200 million miles", "feet": 1.056e12, "required_level": 75, "difficulty": 13.0, "environment": "deep_space"},
	{"id": "earth_to_belt", "name": "EARTH DEFENSE • ASTEROID LINE", "label": "300 million miles", "feet": 1.584e12, "required_level": 78, "difficulty": 15.5, "environment": "deep_space"},
	{"id": "earth_to_jupiter", "name": "EARTH DEFENSE • JOVIAN LINE", "label": "500 million miles", "feet": 2.64e12, "required_level": 81, "difficulty": 18.5, "environment": "deep_space"},
	{"id": "earth_to_saturn", "name": "EARTH DEFENSE • SATURN LINE", "label": "900 million miles", "feet": 4.752e12, "required_level": 84, "difficulty": 22.0, "environment": "deep_space"},
	{"id": "earth_to_uranus", "name": "EARTH DEFENSE • URANUS LINE", "label": "1.8 billion miles", "feet": 9.504e12, "required_level": 87, "difficulty": 27.0, "environment": "deep_space"},
	{"id": "earth_to_neptune", "name": "EARTH DEFENSE • NEPTUNE LINE", "label": "2.7 billion miles", "feet": 1.4256e13, "required_level": 90, "difficulty": 33.0, "environment": "deep_space"},
	{"id": "earth_to_pluto_approach", "name": "EARTH DEFENSE • PLUTO APPROACH", "label": "3.2 billion miles", "feet": 1.6896e13, "required_level": 93, "difficulty": 40.0, "environment": "outer_dark"},
	{"id": "earth_to_pluto", "name": "EARTH–PLUTO WORLD SERIES", "label": "3.67 billion miles", "feet": 1.93776e13, "required_level": 96, "difficulty": 50.0, "environment": "outer_dark"},
]

# Three fully authored opponents live in every row.  Difficulty, reward and
# mastery interpolate mechanically inside the row so balance can be tuned at
# the meaningful sub-era boundary rather than across one hundred unrelated
# constants.
const SUBERAS := [
	{
		"id": "preschool_backyard", "league": LEAGUE_HUMAN, "era": "BACKYARD", "name": "PRESCHOOL BACKYARD", "name_pool": 0, "distance_tier": 0,
		"classes": ["Wiffle-Bat Toddler", "Foam-Bat Preschooler", "Juice-Box Cleanup Toddler"],
		"bats": ["Bent Wiffle Bat", "Foam Thunderstick", "Juice-Box Slugger"],
		"quirks": ["The strike zone is three feet away. This does not help as much as it should.", "Owns a slightly less forgiving foam bat.", "Powered by juice boxes and limitless confidence."],
		"difficulty": [2.20, 2.80], "mastery_counts": [4.0, 5.0], "bat_count": 1,
	},
	{
		"id": "tee_ball", "league": LEAGUE_HUMAN, "era": "BACKYARD", "name": "TEE-BALL", "name_pool": 0, "distance_tier": 1,
		"classes": ["Tee-Ball Beginner", "Orange-Slice All-Star", "Tee-Ball Fence Threat"],
		"bats": ["Regulation Tee-Ball Bat", "Snack-Stand Slugger", "Fencebreaker Junior"],
		"quirks": ["Has mastered the strategic advantage of using a tee.", "Runs entirely on orange slices and applause.", "The neighbor is already asking who keeps breaking the fence."],
		"difficulty": [3.20, 4.20], "mastery_counts": [4.5, 5.5], "bat_count": 1,
	},
	{
		"id": "coach_pitch", "league": LEAGUE_HUMAN, "era": "YOUTH BASEBALL", "name": "COACH PITCH", "name_pool": 1, "distance_tier": 2,
		"classes": ["Coach-Pitch Rookie", "Machine-Pitch Regular", "Rec-League Cleanup Kid"],
		"bats": ["Coach-Pitch Aluminum", "Machine-Timed Alloy", "Rec-League Ringer"],
		"quirks": ["Can now recognize a fastball after the seventh identical fastball.", "Has calibrated one swing to exactly one machine.", "A patient hitter with an alarmingly real aluminum bat."],
		"difficulty": [4.80, 6.00], "mastery_counts": [5.0, 6.0], "bat_count": 1,
	},
	{
		"id": "little_league", "league": LEAGUE_HUMAN, "era": "YOUTH BASEBALL", "name": "LITTLE LEAGUE", "name_pool": 1, "distance_tier": 3,
		"classes": ["Travel-Ball Tryhard", "District All-Star", "Little-League Champion"],
		"bats": ["Composite Travel Bat", "District Alloy", "Little-League Crown"],
		"quirks": ["Has private coaching, matching socks, and no mercy.", "Punishes predictable pitch sequences.", "The first batter who has heard of a breaking ball."],
		"difficulty": [6.80, 8.50], "mastery_counts": [5.5, 6.5], "bat_count": 1,
	},
	{
		"id": "middle_school", "league": LEAGUE_HUMAN, "era": "SCHOOL BALL", "name": "MIDDLE SCHOOL", "name_pool": 2, "distance_tier": 4,
		"classes": ["Seventh-Grade Bench Bat", "Middle-School Contact Hitter", "Eighth-Grade Cleanup Captain"],
		"bats": ["Hand-Me-Down Aluminum", "Contact-Weighted Alloy", "Eighth-Grade Maple"],
		"quirks": ["Frequently distracted, but only between pitches.", "A compact swing makes raw speed less reliable.", "Has a laminated scouting report and a hall pass."],
		"difficulty": [9.50, 11.50], "mastery_counts": [6.0, 7.0], "bat_count": 1,
	},
	{
		"id": "high_school", "league": LEAGUE_HUMAN, "era": "SCHOOL BALL", "name": "HIGH SCHOOL", "name_pool": 2, "distance_tier": 5,
		"classes": ["Junior-Varsity Starter", "Varsity Cleanup Hitter", "State-Championship Phenom"],
		"bats": ["JV Maple", "Varsity Maple", "Sovereign Ash"],
		"quirks": ["Scouting reports begin to matter.", "Adjusts to whichever pitch you throw most often.", "There are recruiters behind the backstop."],
		"difficulty": [12.5, 14.8], "mastery_counts": [6.5, 7.5], "bat_count": 1,
	},
	{
		"id": "small_college", "league": LEAGUE_HUMAN, "era": "AMATEUR & COLLEGE", "name": "COMMUNITY COLLEGE & D-III", "name_pool": 3, "distance_tier": 5,
		"classes": ["Community-College Crusher", "Division III Technician", "Small-College Conference MVP"],
		"bats": ["Community-College Composite", "D-III Precision Maple", "Conference-Crown Ash"],
		"quirks": ["Studies release points between classes.", "Turns small command mistakes into enormous problems.", "The meal plan includes advanced pitch recognition."],
		"difficulty": [15.8, 18.0], "mastery_counts": [7.0, 8.0], "bat_count": 1,
	},
	{
		"id": "division_one", "league": LEAGUE_HUMAN, "era": "AMATEUR & COLLEGE", "name": "DIVISION I", "name_pool": 3, "distance_tier": 5,
		"classes": ["Division I Starter", "College World-Series Star", "Golden-Spikes Finalist"],
		"bats": ["D-I Scouted Ash", "Collegiate World-Eater", "Golden-Spikes Maple"],
		"quirks": ["Has a frighteningly complete spray chart.", "The crowd now reacts to every terrible decision.", "There is an analytics department for this exact at-bat."],
		"difficulty": [18.4, 19.5], "mastery_counts": [7.5, 8.5], "bat_count": 1,
	},
	{
		"id": "lower_minors", "league": LEAGUE_HUMAN, "era": "MINOR LEAGUES", "name": "LOWER MINORS", "name_pool": 4, "distance_tier": 5,
		"classes": ["Complex-League Prospect", "Low-A Batting Champion", "High-A Hotshot"],
		"bats": ["Complex-League Maple", "Low-A Hickory", "High-A White Ash"],
		"quirks": ["Professional eyesight meets an unprofessional salary.", "No longer swings at anything merely because it is moving.", "Can identify spin before the ball leaves your hand."],
		"difficulty": [20.2, 22.0], "mastery_counts": [8.0, 9.0], "bat_count": 1,
	},
	{
		"id": "upper_minors", "league": LEAGUE_HUMAN, "era": "MINOR LEAGUES", "name": "UPPER MINORS", "name_pool": 4, "distance_tier": 5,
		"classes": ["Double-A Masher", "Triple-A Call-Up", "Top Organizational Prospect"],
		"bats": ["Double-A White Ash", "Triple-A Pro Maple", "Judgment Bat"],
		"quirks": ["Has already packed for the majors.", "Makes routine contact look deeply personal.", "The front office has stopped pretending this is developmental."],
		"difficulty": [27.0, 29.0], "mastery_counts": [8.5, 9.5], "bat_count": 1,
	},
	{
		"id": "major_leagues", "league": LEAGUE_HUMAN, "era": "MAJOR LEAGUES", "name": "MAJOR LEAGUES", "name_pool": 5, "distance_tier": 5,
		"classes": ["Everyday Big Leaguer", "Major-League All-Star", "MLB Home-Run King"],
		"bats": ["Big-League Maple", "All-Star Ash", "Bambino Relic"],
		"quirks": ["Knows every conventional pitch in the game.", "Has an endorsement deal for hitting your mistakes.", "The last opponent still constrained by ordinary biology."],
		"difficulty": [29.5, 31.5], "mastery_counts": [9.0, 10.0], "bat_count": 1,
	},

	{
		"id": "genome_rookies", "league": LEAGUE_ALIEN, "era": "ALIEN ROOKIE CIRCUIT", "name": "GENOME ROOKIE CIRCUIT", "name_pool": 6, "distance_tier": 6,
		"classes": ["Gene-Doped Slugger", "Adaptive Batting Android", "Licensed Two-Arm Mutant"],
		"bats": ["Vein-Fed Composite", "Firmware Smartbat", "Genome-League Alloy"],
		"quirks": ["Whatever is in that bloodstream is legal on three planets.", "Records each pitch and patches its batting firmware live.", "The second arm is mostly there for paperwork."],
		"difficulty": [78.0, 105.0], "mastery_counts": [10.0, 12.0], "bat_count": 1, "strikes": 4,
	},
	{
		"id": "lunar_minors", "league": LEAGUE_ALIEN, "era": "ALIEN ROOKIE CIRCUIT", "name": "LUNAR MINORS", "name_pool": 7, "distance_tier": 7,
		"classes": ["Low-Gravity Moonballer", "Crater-League Contact Hitter", "Europa Ice-Bat Champion"],
		"bats": ["Lunar Low-G Bat", "Crater-Carved Composite", "Europa Icewood"],
		"quirks": ["Low gravity turns weak contact into orbital debris.", "The warning track is a neighboring crater.", "The bat is colder than several baseball rules allow."],
		"difficulty": [122.0, 165.0], "mastery_counts": [11.0, 13.0], "bat_count": 1, "strikes": 4,
	},
	{
		"id": "martian_league", "league": LEAGUE_ALIEN, "era": "PLANETARY LEAGUES", "name": "MARTIAN LEAGUE", "name_pool": 7, "distance_tier": 8,
		"classes": ["Tripodal Contact Hitter", "Red-Dust Switch Hitter", "Olympus Foothills Slugger"],
		"bats": ["Red-Diamond Tripod Bat", "Twin-Planet Switchbat", "Basalt-Heart Slugger"],
		"quirks": ["Three legs, two eyes, one extremely level swing.", "Changes handedness by rotating the torso.", "Treats a mile-long warning track as shallow left."],
		"difficulty": [192.0, 258.0], "mastery_counts": [12.0, 14.0], "bat_count": 2, "strikes": 4,
	},
	{
		"id": "asteroid_circuit", "league": LEAGUE_ALIEN, "era": "PLANETARY LEAGUES", "name": "ASTEROID CIRCUIT", "name_pool": 7, "distance_tier": 9,
		"classes": ["Vacuum-Belt Utility Hitter", "Ceres Cleanup Miner", "Asteroid-Hopping Champion"],
		"bats": ["Vacuum-Sealed Bat", "Ceres Core-Sample Club", "Transfer-Orbit Slugger"],
		"quirks": ["The dugout and home plate are on different rocks.", "Has mined enough iron to ignore inside pitches.", "Times swings by orbital rendezvous."],
		"difficulty": [300.0, 410.0], "mastery_counts": [13.0, 15.0], "bat_count": 2, "strikes": 5,
	},
	{
		"id": "jovian_league", "league": LEAGUE_ALIEN, "era": "GAS-GIANT BASEBALL", "name": "JOVIAN LEAGUE", "name_pool": 7, "distance_tier": 10,
		"classes": ["Jovian Giant", "Great-Red-Spot Pull Hitter", "Four-Moon Cleanup Titan"],
		"bats": ["Jovian Monument Bat", "Storm-Eye Slugger", "Galilean Quartet"],
		"quirks": ["The strike zone is visible from several moons.", "Pulls everything toward the Great Red Spot.", "Four moons provide one deeply unfair scouting report."],
		"difficulty": [475.0, 650.0], "mastery_counts": [14.0, 16.0], "bat_count": 2, "strikes": 5,
	},
	{
		"id": "saturn_series", "league": LEAGUE_ALIEN, "era": "GAS-GIANT BASEBALL", "name": "SATURN RING SERIES", "name_pool": 7, "distance_tier": 11,
		"classes": ["Ring-Skipping Leadoff Hitter", "Titan Methane Slugger", "Saturn-Series Champion"],
		"bats": ["Ring-Ice Contact Bat", "Titan Hydrocarbon Maple", "Crown-of-Rings Flare Bat"],
		"quirks": ["Bunts can complete an orbit.", "The pine tar is a hydrocarbon weather system.", "Won a championship that lasted twenty-nine Earth years."],
		"difficulty": [760.0, 1030.0], "mastery_counts": [15.0, 17.0], "bat_count": 3, "strikes": 5,
	},
	{
		"id": "solar_circuit", "league": LEAGUE_ALIEN, "era": "STELLAR LEAGUE", "name": "SOLAR CIRCUIT", "name_pool": 7, "distance_tier": 12,
		"classes": ["Plasma-Bat Slugger", "Solar-Flare Cleanup Hitter", "Heliosphere Batting Prince"],
		"bats": ["Contained Plasma Bat", "Solar-Crown Flare", "Heliosphere Scepter"],
		"quirks": ["The bat is technically a contained stellar flare.", "Every bat flip causes a minor coronal event.", "Has never played a night game."],
		"difficulty": [1210.0, 1650.0], "mastery_counts": [16.0, 18.0], "bat_count": 3, "strikes": 6,
	},
	{
		"id": "interstellar_league", "league": LEAGUE_ALIEN, "era": "STELLAR LEAGUE", "name": "INTERSTELLAR LEAGUE", "name_pool": 8, "distance_tier": 13,
		"classes": ["Chronal Leadoff Hitter", "Phase-Shift Contact Hitter", "Interstellar Champion"],
		"bats": ["Chronal Pre-Swing Bat", "Phase-Shift Bat", "Star-League Solar Ash"],
		"quirks": ["Begins swinging several seconds before you throw.", "Briefly exits normal space when fooled.", "Champion of every inhabited planet with a regulation diamond."],
		"difficulty": [1930.0, 2650.0], "mastery_counts": [17.0, 20.0], "bat_count": 3, "strikes": 6,
	},
	{
		"id": "galactic_league", "league": LEAGUE_ALIEN, "era": "GALACTIC LEAGUE", "name": "GALACTIC LEAGUE", "name_pool": 8, "distance_tier": 14,
		"classes": ["Andromedan Switch Hitter", "Nebular Cleanup Collective", "Galactic Pennant Holder"],
		"bats": ["Andromeda Twinbat", "Nebular Shared Bat", "Galaxy-Crown Array"],
		"quirks": ["Switches sides of the plate by changing galaxies.", "Three nervous systems vote on every swing.", "The pennant is larger than the human Moon."],
		"difficulty": [3120.0, 4300.0], "mastery_counts": [19.0, 22.0], "bat_count": 4, "strikes": 7,
	},
	{
		"id": "aeon_league", "league": LEAGUE_ALIEN, "era": "GALACTIC LEAGUE", "name": "AEON LEAGUE", "name_pool": 8, "distance_tier": 15,
		"classes": ["Aeon-League Rookie", "Probability-Weighted Slugger", "Causality-Series MVP"],
		"bats": ["Aeon Rookie Standard", "Probability Bat", "Causality-Series Club"],
		"quirks": ["Classified as a rookie because an aeon is one season here.", "Only swings in timelines where contact occurred.", "Has already seen the box score."],
		"difficulty": [5050.0, 7000.0], "mastery_counts": [21.0, 24.0], "bat_count": 4, "strikes": 7,
	},
	{
		"id": "olympus_championship", "league": LEAGUE_ALIEN, "era": "OLYMPUS CHAMPIONSHIP", "name": "OLYMPUS CHAMPIONSHIP", "name_pool": 8, "distance_tier": 16,
		"classes": ["Olympus-Mound Cleanup Giant", "Four-Bat Planetary Champion", "Alien Baseball Commissioner"],
		"bats": ["Olympus Basalt Bat", "Fourfold Planetary Array", "Commissioner's Fourfold Judgment"],
		"quirks": ["Home plate is on the far side of Mars.", "Four bats cover four independent sections of the zone.", "Xylophax rewrote the rules and still brought four bats."],
		"difficulty": [8300.0, 12000.0], "mastery_counts": [23.0, 27.0], "bat_count": 4, "strikes": 8,
	},

	{
		"id": "orbital_omens", "league": LEAGUE_ELDRITCH, "era": "EARTH DEFENSE", "name": "ORBITAL OMENS", "name_pool": 8, "distance_tier": 17,
		"classes": ["Orbital Omen Batter", "Moon-Eater Leadoff Horror", "Lunar-Shadow Cleanup God"],
		"bats": ["Omen-Wood Bat", "Moon-Eater Club", "Lunar-Shadow Array"],
		"quirks": ["The crowd cannot agree whether it has arrived yet.", "Takes warmup swings through the Moon.", "Its shadow reaches home plate first."],
		"difficulty": [26000.0, 40000.0], "mastery_counts": [25.0, 30.0], "bat_count": 2, "strikes": 12, "balls": 3,
	},
	{
		"id": "mercury_line", "league": LEAGUE_ELDRITCH, "era": "EARTH DEFENSE", "name": "MERCURY LINE", "name_pool": 8, "distance_tier": 18,
		"classes": ["Sun-Side Scorched Idol", "Mercurial Many-Angled Hitter", "Terminator-Line Batting Saint"],
		"bats": ["Sun-Side Cinder Bat", "Mercurial Angle", "Terminator-Line Relic"],
		"quirks": ["The bat is bright enough to erase the foul line.", "Every angle is inside the strike zone to it.", "Exists precisely between day and night."],
		"difficulty": [52000.0, 80000.0], "mastery_counts": [28.0, 34.0], "bat_count": 2, "strikes": 14, "balls": 3,
	},
	{
		"id": "venus_line", "league": LEAGUE_ELDRITCH, "era": "EARTH DEFENSE", "name": "VENUS LINE", "name_pool": 8, "distance_tier": 19,
		"classes": ["Acid-Cloud Contact Deity", "Venusian Pressure Titan", "Morning-Star Cleanup Oracle"],
		"bats": ["Acid-Cloud Bat", "Pressure-Forged Club", "Morning-Star Oracle Bat"],
		"quirks": ["The scouting report dissolved before first pitch.", "Compresses bad pitches into better contact.", "Announces the result before swinging."],
		"difficulty": [105000.0, 165000.0], "mastery_counts": [31.0, 37.0], "bat_count": 3, "strikes": 16, "balls": 3,
	},
	{
		"id": "mars_line", "league": LEAGUE_ELDRITCH, "era": "EARTH DEFENSE", "name": "MARS LINE", "name_pool": 8, "distance_tier": 20,
		"classes": ["Red God of the Warning Track", "War-Mound Batting Tyrant", "Olympus Shadow Colossus"],
		"bats": ["Red-God Scepter", "War-Mound Cleaver", "Olympus Shadow Bat"],
		"quirks": ["Every swing declares a small war.", "Regards the alien championship as batting practice.", "Covers Mars even when standing behind it."],
		"difficulty": [220000.0, 350000.0], "mastery_counts": [34.0, 40.0], "bat_count": 3, "strikes": 18, "balls": 3,
	},
	{
		"id": "asteroid_line", "league": LEAGUE_ELDRITCH, "era": "EARTH DEFENSE", "name": "ASTEROID LINE", "name_pool": 8, "distance_tier": 21,
		"classes": ["Ceres-Bound Grave Hitter", "Belt of One Thousand Swings", "The Asteroid Umpire's Regret"],
		"bats": ["Ceres Gravewood", "Thousand-Swing Belt", "Umpire's Regret"],
		"quirks": ["Dead planets still send scouting reports.", "One body occupies the entire asteroid belt.", "Even the umpire has stopped calling the corners."],
		"difficulty": [470000.0, 760000.0], "mastery_counts": [37.0, 44.0], "bat_count": 4, "strikes": 21, "balls": 3,
	},
	{
		"id": "jupiter_line", "league": LEAGUE_ELDRITCH, "era": "EARTH DEFENSE", "name": "JUPITER LINE", "name_pool": 8, "distance_tier": 22,
		"classes": ["Storm-Eyed Batting Sovereign", "Galilean Moon Collector", "Jupiter, Who Swings the Red Spot"],
		"bats": ["Storm-Eye Array", "Galilean Collector", "Great-Red Causality Bat"],
		"quirks": ["Sees the seam through a hurricane older than baseball.", "Keeps moons as batting weights.", "The storm itself takes a second swing."],
		"difficulty": [1000000.0, 1650000.0], "mastery_counts": [40.0, 48.0], "bat_count": 4, "strikes": 24, "balls": 3,
	},
	{
		"id": "saturn_line", "league": LEAGUE_ELDRITCH, "era": "EARTH DEFENSE", "name": "SATURN LINE", "name_pool": 8, "distance_tier": 23,
		"classes": ["Ring-Crowned Outer Batter", "Titan of the Seventh Inning", "Saturnine God Beneath the Scoreboard"],
		"bats": ["Ring-Crowned Array", "Seventh-Inning Titan Bat", "Saturnine Scorebreaker"],
		"quirks": ["The rings are all technically on deck.", "Its seventh inning lasts a human lifetime.", "The scoreboard refuses to display the name."],
		"difficulty": [2200000.0, 3700000.0], "mastery_counts": [44.0, 52.0], "bat_count": 4, "strikes": 28, "balls": 3,
	},
	{
		"id": "uranus_line", "league": LEAGUE_ELDRITCH, "era": "EARTH DEFENSE", "name": "URANUS LINE", "name_pool": 8, "distance_tier": 24,
		"classes": ["Sideways World-Series Horror", "Ice-Giant Switch Deity", "The Laughing Seventh Planet"],
		"bats": ["Sideways Series Bat", "Ice-Giant Switch Array", "Seventh-Planet Punchline"],
		"quirks": ["Plays the entire game sideways and resents questions.", "Switch-hits across an axial tilt.", "The obvious joke has already eaten three broadcasters."],
		"difficulty": [5000000.0, 8500000.0], "mastery_counts": [48.0, 57.0], "bat_count": 5, "strikes": 32, "balls": 3,
	},
	{
		"id": "neptune_line", "league": LEAGUE_ELDRITCH, "era": "EARTH DEFENSE", "name": "NEPTUNE LINE", "name_pool": 8, "distance_tier": 25,
		"classes": ["Blue-Wind Batting Wraith", "Triton Retrograde Slugger", "Neptune's Unremembered Champion"],
		"bats": ["Blue-Wind Wraith Bat", "Retrograde Triton Club", "Unremembered Champion's Array"],
		"quirks": ["The wind is supersonic and batting cleanup.", "Runs the bases in the wrong orbital direction.", "Won a league deleted from every calendar."],
		"difficulty": [12000000.0, 21000000.0], "mastery_counts": [52.0, 62.0], "bat_count": 5, "strikes": 36, "balls": 2,
	},
	{
		"id": "pluto_approach", "league": LEAGUE_ELDRITCH, "era": "OUTER DARK", "name": "PLUTO APPROACH", "name_pool": 8, "distance_tier": 26,
		"classes": ["Kuiper-Belt Batting Choir", "Dwarf-Planet Crowned Horror", "Charon, Keeper of the Last Dugout"],
		"bats": ["Kuiper Choir Array", "Dwarf-Planet Crown Bat", "Last-Dugout Oar"],
		"quirks": ["Every frozen body sings the same scouting report.", "Still insists it is a full-sized batting god.", "Ferries eliminated batters beyond the foul pole."],
		"difficulty": [30000000.0, 54000000.0], "mastery_counts": [57.0, 68.0], "bat_count": 6, "strikes": 42, "balls": 2,
	},
	{
		"id": "pluto_world_series", "league": LEAGUE_ELDRITCH, "era": "OUTER DARK", "name": "EARTH–PLUTO WORLD SERIES", "name_pool": 8, "distance_tier": 27,
		"classes": ["Void-Titan Pennant Holder", "Seven-Bat Causality Champion", "Unstrikeable Outer-Dark God"],
		"bats": ["Void-Pennant Club", "Sevenfold Causality Array", "Gravity Club of the Unstrikeable"],
		"quirks": ["The pennant was sewn from abandoned timelines.", "Seven bats cover seven mutually exclusive strike zones.", "Bad pitches cannot escape. Neither can good ones. Ball-rog considers this fair."],
		"difficulty": [80000000.0, 150000000.0], "mastery_counts": [64.0, 78.0], "bat_count": 7, "strikes": 54, "balls": 2,
	},
]

const FINAL_LEVEL := {
	"id": "octathulhu_final",
	"league": LEAGUE_ELDRITCH,
	"era": "OUTER DARK",
	"subera": "THE FINAL INNING",
	"name_pool": 8,
	"distance_tier": 27,
	"class_name": "Eight-Armed God of Baseball",
	"bat_name": "Eightfold Causality Array",
	"quirk": "Octathulhu: eight bats, eight arms, and jurisdiction over the final box score.",
	"difficulty": 260000000.0,
	"mastery_counts": 96.0,
	"bat_count": 8,
	"strikes_required": 64,
	"balls_required": 2,
	"signature_name": "Octathulhu, God of the Eightfold Swing",
}

const SIGNATURE_NAMES := {
	0: "Little Timmy",
	2: "Milo, Breaker of Backyard Fences",
	5: "Cooper, Crown of Tee-Ball",
	8: "Kayleigh, Tyrant of Coach Pitch",
	11: "Jaxxon, Crown of Little League",
	14: "Casey, Keeper of the Hall Pass",
	17: "Valeria, Sovereign of Varsity",
	20: "Collegius, Eater of Aluminum",
	23: "The Golden Spike, Awaiting Judgment",
	26: "Bus-League Bobby, Rider of Fourteen Hours",
	29: "The Call-Up, Last of the Options",
	32: "Bambino Rex, Last of the Mortals",
	33: "Trenbolus, the Vein-Crowned",
	41: "Tripodus of the Red Diamond",
	50: "Saturnia, Crowned by Rings",
	59: "The Pennant of Andromeda",
	65: "Xylophax, Genetic Commissioner",
	66: "N'Kthra, First Omen of the Last Aeon",
	80: "Jupiter, Who Swings the Red Spot",
	95: "Charon, Keeper of the Last Dugout",
	98: "Ball-rog, the Unstrikeable",
	99: "Octathulhu, God of the Eightfold Swing",
}

static var _levels_cache: Array[Dictionary] = []

static func levels() -> Array[Dictionary]:
	if _levels_cache.is_empty():
		_levels_cache = _build_levels()
	return _levels_cache

static func level(index: int) -> Dictionary:
	var authored := levels()
	if authored.is_empty():
		return {}
	return authored[clampi(index, 0, authored.size() - 1)]

static func league_for_index(index: int) -> String:
	if index <= HUMAN_FINAL_INDEX:
		return LEAGUE_HUMAN
	if index <= ALIEN_FINAL_INDEX:
		return LEAGUE_ALIEN
	return LEAGUE_ELDRITCH

static func is_subera_finale(index: int) -> bool:
	return index == FINAL_BOSS_INDEX or (index + 1) % LEVELS_PER_SUBERA == 0

static func is_league_boss(index: int) -> bool:
	return index in [HUMAN_FINAL_INDEX, ALIEN_FINAL_INDEX, FINAL_BOSS_INDEX]

static func old_index_to_new(old_index: int) -> int:
	# Schema-25 had 30 human, 10 alien, and 5 eldritch slots. Map within the
	# authored league so a champion stays a champion and a midpoint stays near
	# the same narrative point. The old exhibition slots map to the first playable
	# level of their new league; their story flags migrate separately.
	var bounded := clampi(old_index, 0, 44)
	if bounded <= 29:
		return int(round(float(bounded) / 29.0 * float(HUMAN_FINAL_INDEX)))
	if bounded <= 39:
		return ALIEN_START_INDEX + int(round(float(bounded - 30) / 9.0 * float(ALIEN_FINAL_INDEX - ALIEN_START_INDEX)))
	return ELDRITCH_START_INDEX + int(round(float(bounded - 40) / 4.0 * float(FINAL_BOSS_INDEX - ELDRITCH_START_INDEX)))

static func _build_levels() -> Array[Dictionary]:
	var built: Array[Dictionary] = []
	for subera_index in SUBERAS.size():
		var subera: Dictionary = SUBERAS[subera_index]
		var classes: Array = subera.classes
		var bats: Array = subera.bats
		var quirks: Array = subera.quirks
		for position in LEVELS_PER_SUBERA:
			var index := built.size()
			var t := float(position) / float(LEVELS_PER_SUBERA - 1)
			var strikes := int(subera.get("strikes", 3))
			var balls := int(subera.get("balls", 4))
			var mastery_counts: Array = subera.mastery_counts
			var mastery_equivalents := lerpf(float(mastery_counts[0]), float(mastery_counts[1]), t)
			var strikeout_bounty := minf(float(strikes) * 5.0, 5.0 + float(index) * 0.75)
			var difficulty_range: Array = subera.difficulty
			var reward := _reward_for_index(index)
			built.append({
				"id": "%s_%02d" % [str(subera.league), index + 1],
				"index": index,
				"number": index + 1,
				"league": str(subera.league),
				"league_index": 0 if str(subera.league) == LEAGUE_HUMAN else (1 if str(subera.league) == LEAGUE_ALIEN else 2),
				"era": str(subera.era),
				"subera": str(subera.name),
				"subera_id": str(subera.id),
				"subera_index": subera_index,
				"subera_position": position,
				"subera_start": position == 0,
				"subera_finale": position == LEVELS_PER_SUBERA - 1,
				"league_boss": index in [HUMAN_FINAL_INDEX, ALIEN_FINAL_INDEX, ELDRITCH_FINAL_INDEX],
				"class_name": str(classes[position]),
				"bat_name": str(bats[position]),
				"quirk": str(quirks[position]),
				"name_pool": int(subera.name_pool),
				"distance_tier": int(subera.distance_tier),
				"difficulty": lerpf(float(difficulty_range[0]), float(difficulty_range[1]), t),
				"reward": reward,
				"mastery_required": strikeout_bounty * mastery_equivalents,
				"mastery_counts": mastery_equivalents,
				"strikes_required": strikes,
				"balls_required": balls,
				"bat_count": int(subera.get("bat_count", 1)),
				"trait": "standard",
				"signature_name": str(SIGNATURE_NAMES.get(index, "")),
				# The opening Backyard chapter is the fresh-run prologue. Later chapter
				# keys are presented only when the player actually enters the sub-era.
				"story_key": "prologue_little_timmy" if index == 0 else ("arrive_%s" % str(subera.id) if position == 0 else ""),
				"guaranteed_rare_offer": position == LEVELS_PER_SUBERA - 1,
				"pitch_draft": (
					(index + 1) % PITCH_DRAFT_INTERVAL == 0
					or index in [HUMAN_FINAL_INDEX, ALIEN_FINAL_INDEX, ELDRITCH_FINAL_INDEX]
				),
				"boss_pitch": index in [HUMAN_FINAL_INDEX, ALIEN_FINAL_INDEX, ELDRITCH_FINAL_INDEX],
				"speed_anchor_fps": _speed_anchor_for_index(index),
				"body_scale": _body_scale_for_index(index),
			})
	var final_index := built.size()
	var final_mastery_counts := float(FINAL_LEVEL.mastery_counts)
	var final_strikes := int(FINAL_LEVEL.strikes_required)
	built.append({
		"id": str(FINAL_LEVEL.id),
		"index": final_index,
		"number": final_index + 1,
		"league": str(FINAL_LEVEL.league),
		"league_index": 2,
		"era": str(FINAL_LEVEL.era),
		"subera": str(FINAL_LEVEL.subera),
		"subera_id": "final_inning",
		"subera_index": SUBERAS.size(),
		"subera_position": 0,
		"subera_finale": true,
		"league_boss": true,
		"class_name": str(FINAL_LEVEL.class_name),
		"bat_name": str(FINAL_LEVEL.bat_name),
		"quirk": str(FINAL_LEVEL.quirk),
		"name_pool": int(FINAL_LEVEL.name_pool),
		"distance_tier": int(FINAL_LEVEL.distance_tier),
		"difficulty": float(FINAL_LEVEL.difficulty),
		"reward": _reward_for_index(final_index),
		"mastery_required": float(final_strikes) * 5.0 * final_mastery_counts,
		"mastery_counts": final_mastery_counts,
		"strikes_required": final_strikes,
		"balls_required": int(FINAL_LEVEL.balls_required),
		"bat_count": int(FINAL_LEVEL.bat_count),
		"trait": "octopus_god",
		"signature_name": str(FINAL_LEVEL.signature_name),
		"story_key": "arrive_octathulhu_final",
		"guaranteed_rare_offer": true,
		"pitch_draft": true,
		"boss_pitch": true,
		"speed_anchor_fps": _speed_anchor_for_index(final_index),
		"body_scale": 8.0,
	})
	return built

static func _reward_for_index(index: int) -> float:
	if index <= HUMAN_FINAL_INDEX:
		return pow(1.82, float(index))
	var human_reward := pow(1.82, float(HUMAN_FINAL_INDEX))
	if index <= ALIEN_FINAL_INDEX:
		return human_reward * pow(2.35, float(index - HUMAN_FINAL_INDEX))
	var alien_reward := human_reward * pow(2.35, float(ALIEN_FINAL_INDEX - HUMAN_FINAL_INDEX))
	return alien_reward * pow(3.25, float(index - ALIEN_FINAL_INDEX))

static func _speed_anchor_for_index(index: int) -> float:
	const HUMAN_FINAL_FPS := 115.0 / 0.681818
	const MACH_5000_FPS := 1125.33 * 5000.0
	const LIGHT_5000_FPS := 983571056.0 * 5000.0
	if index <= HUMAN_FINAL_INDEX:
		return lerpf(1.0, HUMAN_FINAL_FPS, pow(float(index) / float(HUMAN_FINAL_INDEX), 1.25))
	if index <= ALIEN_FINAL_INDEX:
		var alien_t := float(index - ALIEN_START_INDEX) / float(ALIEN_FINAL_INDEX - ALIEN_START_INDEX)
		return exp(lerpf(log(HUMAN_FINAL_FPS * 1.1), log(MACH_5000_FPS), alien_t))
	var eldritch_t := float(index - ELDRITCH_START_INDEX) / float(FINAL_BOSS_INDEX - ELDRITCH_START_INDEX)
	return exp(lerpf(log(MACH_5000_FPS * 1.2), log(LIGHT_5000_FPS), eldritch_t))

static func _body_scale_for_index(index: int) -> float:
	if index <= HUMAN_FINAL_INDEX:
		# The marker is a top-down footprint, not literal height. A 0.72 opening
		# toddler against the pitcher's 1.08 body makes the pitcher exactly 50%
		# larger at equal perspective; human opponents then grow smoothly to adult
		# scale without ever covering the plate.
		return lerpf(0.72, 1.08, float(index) / float(HUMAN_FINAL_INDEX))
	if index <= ALIEN_FINAL_INDEX:
		return lerpf(0.85, 3.25, float(index - ALIEN_START_INDEX) / float(ALIEN_FINAL_INDEX - ALIEN_START_INDEX))
	return lerpf(1.2, 7.0, float(index - ELDRITCH_START_INDEX) / float(ELDRITCH_FINAL_INDEX - ELDRITCH_START_INDEX))
