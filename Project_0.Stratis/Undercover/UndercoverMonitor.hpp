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

// ----------------------------------------------------------------------
// |                U N D E R C O V E R  D E F I N E S                  |
// ----------------------------------------------------------------------

#define SUSPICIOUS 0.6								// suspiciousness gained while being "suspicious" 
#define SUSP_CROUCH 0.1								// suspiciousness gained crouching
#define SUSP_PRONE 0.2								// suspiciousness gained prone
#define SUSP_SPEEDMAX 0.35							// suspiciousness gained for movement speed
#define SUSP_NOROADS 80								// distance that is too far from road to not be suspicious
#define SUSP_OFFROAD 0.3							// suspiciousness gained for being too far from roads

// suspicion values for each equipment type
#define SUSP_UNIFORM 0.6							// suspiciousness gained for mil uniform
#define SUSP_VEST 0.6								// suspiciousness gained for mil vest
#define SUSP_NVGS 0.6								// suspiciousness gained for NVGs
#define SUSP_HEADGEAR 0.5							// suspiciousness gained for mil headgear
#define SUSP_FACEWEAR 0.1							// suspiciousness gained for mil facewear
#define SUSP_BACKPACK 0.3							// suspiciousness gained for mil backpack

// values for
#define SUSP_VEH_DIST 100							// distance at which suspiciousness starts increasing based on SUSP_VEH_DIST_MULT 
#define SUSP_VEH_DIST_MIN 15						// distance at which player is too close to be undercover with suspicious gear in a vehicle
#define SUSP_VEH_DIST_MULT 1.12/SUSP_VEH_DIST;		// multiplier for distance-based fade-in of suspiciousness variable

#define TIME_SEEN 5									// time it takes, in seconds, for player unit to go from "seen" to "unseen"
#define TIME_HOSTILITY 10							// time in seconds player unit is overt after a hostile action
#define TIME_UNSEEN_WANTED_EXIT -240				// time in seconds it takes for player unit to be unseen before going from WANTED state back to UNDERCOVER state

#define WANTED_CIRCLE_RADIUS 500