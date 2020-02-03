#include "common.hpp"

/*
Class: Phase1CmdrStrategy
Strategy for commander to use during phase 1 gameplay.
Sends QRFs, doesn't deploy roadblocks, doesn't capture anything.
*/
CLASS("Phase1CmdrStrategy", "CmdrStrategy")
	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("takeLocOutpostPriority", 0);
		T_SETV("takeLocBasePriority", 0);
		T_SETV("takeLocAirportPriority", 6);				// We want them very much since we bring reinforcements through them
		T_SETV("takeLocDynamicEnemyPriority", 4);			// Big priority for everything created by players or enemies dynamicly
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocCityPriority", 0);					// Don't hold cities

		// We don't want to capture anything if there is activity in the area
		T_SETV("takeLocOutpostCoeff", 0);					//
		T_SETV("takeLocBaseCoeff", 0);						//
		T_SETV("takeLocRoadBlockCoeff", 0);					//
		T_SETV("takeLocCityCoeff", 0.5);					// Take cities with enemy activity
	} ENDMETHOD;

	// We aren't deploying new locations at this stage
		/* virtual */ METHOD("getConstructLocationScore") {
	params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_POSITION("_tgtLocPos"),
			P_ARRAY("_detachEff")];
		// Deploy no new locations (roadblocks)
		APPLY_SCORE_STRATEGY(_defaultScore, 0)
	} ENDMETHOD;

	/* virtual */ METHOD("getTakeLocationScore") {
	params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtLoc"),
			P_ARRAY("_detachEff")];
		// Take no locations!
		APPLY_SCORE_STRATEGY(_defaultScore, 0)
	} ENDMETHOD;

ENDCLASS;
