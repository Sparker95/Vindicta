#include "../../common.hpp"

/*
Unused.
*/
#define OOP_CLASS_NAME SuppressCmdrStrategy
CLASS("SuppressCmdrStrategy", "CmdrStrategy")

	METHOD(new)
		params [P_THISOBJECT];
		// Take outposts in areas with activity
		T_SETV("takeLocOutpostPriority", 0);
		T_SETV("takeLocOutpostCoeff", 1);
		// Do not take bases
		T_SETV("takeLocBasePriority", 0);
		T_SETV("takeLocBaseCoeff", 0);
		// Take roadblocks in areas with activity
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocRoadBlockCoeff", 2);
	ENDMETHOD;

	public override METHOD(getQRFScore)
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
	ENDMETHOD;

	public override METHOD(getReinforceScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtGarr"),
			P_ARRAY("_detachEff")];
		// Default reinforcing
		_defaultScore
	ENDMETHOD;

	public override METHOD(getTakeLocationScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtLoc"),
			P_ARRAY("_detachEff")];
		// Default take location, modified by the priorities we changed in constructor
		_defaultScore

		// // Occupying road blocks is allowed, but other locations
		// // are not.
		// if(GETV(_tgtLoc, "type") == LOCATION_TYPE_ROADBLOCK) then {
		// 	APPLY_SCORE_STRATEGY(_defaultScore, 1)
		// } else {
		// 	APPLY_SCORE_STRATEGY(_defaultScore, 0)
		// }
	ENDMETHOD;
ENDCLASS;

// Unit test
#ifdef _SQF_VM
#endif