#include "../common.hpp"

CLASS("CmdrStrategy", "")

	VARIABLE("takeLocOutpostPriority");
	VARIABLE("takeLocOutpostPriorityActivityCoeff");
	VARIABLE("takeLocBasePriority");
	VARIABLE("takeLocBasePriorityActivityCoeff");
	VARIABLE("takeLocRoadBlockPriority");
	VARIABLE("takeLocRoadBlockPriorityActivityCoeff");

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("takeLocOutpostPriority", 0.5);
		T_SETV("takeLocOutpostPriorityActivityCoeff", 1);
		T_SETV("takeLocBasePriority", 2);
		T_SETV("takeLocBasePriorityActivityCoeff", 0);
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocRoadBlockPriorityActivityCoeff", 2);
	} ENDMETHOD;

	// Default QRF behaviour is to send QRFs always,
	// from any location that can spare the entire required efficiency.
	/* virtual */ METHOD("getQRFScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtCluster"),
			P_ARRAY("_detachEff")];
		_defaultScore
	} ENDMETHOD;

	// Default Reinforce behaviour is to send reinforcements whenever they are needed, 
	// from any location that can spare the entire required efficiency.
	/* virtual */ METHOD("getReinforceScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtGarr"),
			P_ARRAY("_detachEff")];
		_defaultScore
	} ENDMETHOD;

	// Default TakeLocation behaviour is to always take bases and outposts,
	// but only take roadblocks if there is both nearby activity and a nearby friendly location.
	// It prefer locations in this order generally:
	// base > outpost > roadblock
	// However roadblocks become more important the stronger activity is in the
	// area, such that they can be the most important with high activity.
	/* virtual */ METHOD("getTakeLocationScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtLoc"),
			P_ARRAY("_detachEff")];
		_defaultScore
	} ENDMETHOD;
ENDCLASS;

gCmdrStrategyDefault = NEW("CmdrStrategy", []);

// Unit test
#ifdef _SQF_VM
["CmdrStrategy.new", {
	private _obj = NEW("CmdrStrategy", []);
	
	private _class = OBJECT_PARENT_CLASS_STR(_obj);
	["Object exists", !(isNil "_class")] call test_Assert;
}] call test_AddTest;
#endif