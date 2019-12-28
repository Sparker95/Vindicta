#include "common.hpp"

/*
Class: Phase1CmdrStrategy
Strategy for commander to use during phase 1 gameplay.
Entirely passive behaviour, no actions of any kind are taken.
*/
CLASS("Phase1CmdrStrategy", "PassiveCmdrStrategy")
	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("takeLocOutpostPriority", 0);
		T_SETV("takeLocOutpostPriorityActivityCoeff", 0);
		T_SETV("takeLocBasePriority", 0);
		T_SETV("takeLocBasePriorityActivityCoeff", 0);
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocRoadBlockPriorityActivityCoeff", 0);
		T_SETV("takeLocCityPriority", 0);
		T_SETV("takeLocCityPriorityActivityCoeff", 0);
	} ENDMETHOD;

	// We want QRFs to work even at mission start
	/* override */ METHOD("getQRFScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtCluster"),
			P_ARRAY("_detachEff")];
		// Default QRFs
		_defaultScore
	} ENDMETHOD;
ENDCLASS;
