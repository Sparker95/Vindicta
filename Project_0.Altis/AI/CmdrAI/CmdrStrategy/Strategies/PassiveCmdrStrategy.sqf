#include "../../common.hpp"

CLASS("PassiveCmdrStrategy", "CmdrStrategy")

	METHOD("new") {
		params [P_THISOBJECT];
		// Do not take outposts
		T_SETV("takeLocOutpostPriority", 0);
		T_SETV("takeLocOutpostPriorityActivityCoeff", 0);
		// Do not take bases
		T_SETV("takeLocBasePriority", 0);
		T_SETV("takeLocBasePriorityActivityCoeff", 0);
		// Do not take roadblocks
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocRoadBlockPriorityActivityCoeff", 0);
	} ENDMETHOD;

	/* virtual */ METHOD("getQRFScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtCluster"),
			P_ARRAY("_detachEff")];
		// Do default QRFs
		_defaultScore
	} ENDMETHOD;

	/* virtual */ METHOD("getReinforceScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtGarr"),
			P_ARRAY("_detachEff")];
		// Do no reinforcing! 
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

// Unit test
#ifdef _SQF_VM
#endif