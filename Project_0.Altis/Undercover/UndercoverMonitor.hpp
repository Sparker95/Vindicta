// Name of the 'exposed' variable that we set on unit
#define UNDERCOVER_EXPOSED "bExposed"
#define UNDERCOVER_WANTED "bWanted"
#define UNDERCOVER_SUSPICIOUS "bSuspicious"
#define UNDERCOVER_SUSPICION "suspicion"

// Macro for getting the 'exposed' value of a unit (object handle)
#define UNDERCOVER_IS_UNIT_EXPOSED(unit) unit getVariable [UNDERCOVER_EXPOSED, false]
#define UNDERCOVER_IS_UNIT_WANTED(unit) unit getVariable [UNDERCOVER_WANTED, false]
#define UNDERCOVER_IS_UNIT_SUSPICIOUS(unit) unit getVariable [UNDERCOVER_SUSPICIOUS, false]
#define UNDERCOVER_GET_SUSPICION(unit) unit getVariable [UNDERCOVER_SUSPICION, 0]

// suspicion values for various actions
#define SUSPICIOUS 0.5								// suspiciousness at which unit becomes suspicious
#define OVERT 1.0									// suspiciousness at which unit is overt
#define SUSP_CROUCH 0.1								// suspiciousness gained crouching
#define SUSP_PRONE 0.2								// suspiciousness gained prone
#define SUSP_SPEEDMAX 0.35							// suspiciousness gained for movement speed
#define SUSP_NOROADS 80								// distance that is too far from road to not be suspicious
#define SUSP_OFFROAD 0.3							// suspiciousness gained for being too far from roads
#define SUSP_INCREMENT 0.08							// value for gradual increase of suspiciousness when performing suspicous behavior while seen

// suspicion values for each equipment type
#define SUSP_UNIFORM 0.5							// suspiciousness gained for mil uniform
#define SUSP_VEST 0.5								// suspiciousness gained for mil vest
#define SUSP_NVGS 0.5								// suspiciousness gained for NVGs
#define SUSP_HEADGEAR 0.5							// suspiciousness gained for mil headgear
#define SUSP_FACEWEAR 0.1							// suspiciousness gained for mil facewear
#define SUSP_BACKPACK 0.2							// suspiciousness gained for mil backpack

#define SUSP_VEH_CREW 0.1	
#define SUSP_VEH_DIST 300							// distance at which suspiciousness starts increasing based on SUSP_VEH_DIST_MULT 
#define SUSP_VEH_DIST_MIN 15						// distance at which player is too close to be undercover with suspicious gear in a vehicle
#define SUSP_VEH_DIST_MULT 1.02/SUSP_VEH_DIST		// multiplier for distance-based fade-in of suspiciousness variable

#define TIME_SEEN 5									// time it takes, in seconds, for player unit to go from "seen" to "unseen"
#define TIME_HOSTILITY 3							// time in seconds player unit is overt after a hostile action
#define TIME_UNSEEN_WANTED_EXIT -1200				// time in seconds it takes for player unit to be unseen before going from WANTED state back to UNDERCOVER state
#define WANTED_CIRCLE_RADIUS 500					// diameter of wanted state marker

#define CAMO_PRONE 0.1								// camouflage modifier for being prone
#define CAMO_CROUCH 0.05							// camouflage modifier for being crouched
#define CAMO_GHILLIE 0.25							// camouflage modifier for wearing a ghillie

#define HINT_DISPTIME 8								// amount of time each hint is displayed
// Hint keys for which hint should be displayed. Higher value = higher relevance
#define HK_INCAPACITATED 105
#define HK_SURRENDER 100
#define HK_HOSTILITY 95
#define HK_CLOSINGIN 90
#define HK_WEAPON 80
#define HK_MILVEH 75
#define HK_OFFROAD 73
#define HK_SUSPGEARVEH 70
#define HK_SUSPBEHAVIOR 60
#define HK_SUSPGEAR 50
#define HK_ALLOWEDAREA 46
#define HK_OFFROAD 45
