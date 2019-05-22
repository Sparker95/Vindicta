#include "common.hpp"


// TODO: Perhaps this should just override entire scoring system? 
// Or rather scoring should be separated from Action definition entirely.
// Strategy should always provide entire score.
// It should also profile validity of actions for generating the action lists as well.
// This will be more optimal.
CLASS("CmdrStrategy", "RefCounted")

	METHOD("new") {
		params [P_THISOBJECT];
	} ENDMETHOD;

	// Return array of modified scores
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
#endif