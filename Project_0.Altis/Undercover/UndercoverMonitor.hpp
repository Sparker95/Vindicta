/*
	This file contains a number of global variables for the undercoverMonitor, as well as values for suspiciousness.
*/


// Name of the 'exposed' variable that we set on unit
#define UNDERCOVER_EXPOSED "bExposed"
#define UNDERCOVER_WANTED "bWanted"
#define UNDERCOVER_SUSPICIOUS "bSuspicious"
#define UNDERCOVER_TARGET "bArrestTarget" // true if unit is currently being arrested/target of an arrest

// Macro for getting the 'exposed' value of a unit (object handle)
#define UNDERCOVER_IS_UNIT_EXPOSED(unit) unit getVariable [UNDERCOVER_EXPOSED, false]
#define UNDERCOVER_IS_UNIT_WANTED(unit) unit getVariable [UNDERCOVER_WANTED, false]
#define UNDERCOVER_IS_UNIT_SUSPICIOUS(unit) unit getVariable [UNDERCOVER_SUSPICIOUS, false]
#define UNDERCOVER_IS_TARGET(unit) unit getVariable [UNDERCOVER_TARGET, false]

// suspicion values for various actions
#define SUSPICIOUS 0.5								// Suspiciousness at which unit passes "suspicious" threshold
#define OVERT 1.0									// Suspiciousness at which unit is overt
#define SUSP_CROUCH 0.1								// Suspiciousness gained crouching
#define SUSP_PRONE 0.2								// Suspiciousness gained prone
#define SUSP_SPEEDMAX 0.2							// Max suspiciousness gained for movement speed
#define SUSP_NOROADS 80								// Distance that is too far from roads to not be suspicious
#define SUSP_OFFROAD 0.3							// Suspiciousness gained for being too far from roads
#define SUSP_INCREMENT 0.08							// UNUSED: value for gradual increase of suspiciousness when performing suspicous behavior while seen

/*
	Suspiciousness values for different items. 
	Example calculation: Uniform (0.5) + Vest (0.5) = 1 Suspicion = fully overt/non-captive.
*/
#define SUSP_UNIFORM 0.5							// Suspiciousness gained for mil uniform
#define SUSP_VEST 0.5								// Suspiciousness gained for mil vest
#define SUSP_NVGS 0.3								// Suspiciousness gained for NVGs
#define SUSP_HEADGEAR 0.3							// Suspiciousness gained for mil headgear
#define SUSP_FACEWEAR 0.05							// Suspiciousness gained for mil facewear
#define SUSP_BACKPACK 0.1							// Suspiciousness gained for mil backpack

#define SUSP_VEH_CREW 0.1	
#define SUSP_VEH_DIST 300							// Distance at which suspiciousness starts increasing based on SUSP_VEH_DIST_MULT 
#define SUSP_VEH_DIST_MIN 15						// Distance at which player is too close to be captive with suspicious gear in a vehicle
#define SUSP_VEH_DIST_MULT 1.02/SUSP_VEH_DIST		// DO NOT MODIFY: Multiplier for distance-based fade-in of suspiciousness variable

#define TIME_SEEN 5									// Time it takes, in seconds, for player unit to go from "seen" to "unseen"
#define TIME_HOSTILITY 3							// Time in seconds player unit is overt after a hostile action
#define TIME_UNSEEN_WANTED_EXIT -1200				// Time in seconds it takes for player unit to be unseen before going from WANTED state back to UNDERCOVER state
#define WANTED_CIRCLE_RADIUS 500					// Diameter of wanted state marker. Player must be half this value from the marker to leave WANTED state.

/* 
	Player gains some camouflage for being prone, crouching, and for wearing a ghillie suit. 
	How much camouflage is gained depends on the base camouflage trait of the unit itself.
	Higher value = more camouflage. These values must not be < 0 or > 1.
*/
#define CAMO_PRONE 0.1								// Camouflage modifier for being prone
#define CAMO_CROUCH 0.05							// Camouflage modifier for being crouched
#define CAMO_GHILLIE 0.25							// Camouflage modifier for wearing a ghillie

// DO NOT MODIFY THESE
#define HINT_DISPTIME 8								// amount of time each hint is displayed

// Hint keys for which hint should be displayed. Higher value = higher relevance. Keys with higher relevance display first
#define HK_COMPROMISED 120
#define HK_ARRESTED 110
#define HK_INCAPACITATED 105
#define HK_SURRENDER 100
#define HK_HOSTILITY 95
#define HK_CLOSINGIN 90
#define HK_WEAPON 80
#define HK_MILVEH 75
#define HK_MILAREA 74
#define HK_OFFROAD 73
#define HK_SUSPGEARVEH 70
#define HK_SUSPBEHAVIOR 60
#define HK_SUSPGEAR 50
#define HK_ALLOWEDAREA 46
#define HK_OFFROAD 45
