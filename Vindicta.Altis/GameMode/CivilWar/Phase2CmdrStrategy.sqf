#include "common.hpp"

/*
Class: Phase1CmdrStrategy
Strategy for commander to use during phase 2 gameplay.
Sends QRFs, deploys roadblocks, doesn't capture anything.
*/
CLASS("Phase2CmdrStrategy", "CmdrStrategy")
	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("takeLocOutpostPriority", 0);
		T_SETV("takeLocBasePriority", 0);
		// leave default T_SETV("takeLocAirportPriority", 6);				// We want them very much since we bring reinforcements through them
		// leave default T_SETV("takeLocDynamicEnemyPriority", 4);			// Big priority for everything created by players or enemies dynamicly
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocCityPriority", 0);					// 

		// We don't want to capture anything if there is activity in the area
		T_SETV("takeLocOutpostPriorityActivityCoeff", 0);	//
		T_SETV("takeLocBasePriorityActivityCoeff", 0);		//
		T_SETV("takeLocRoadBlockPriorityActivityCoeff", 0);	//
		T_SETV("takeLocCityPriorityActivityCoeff", 0);		//
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
