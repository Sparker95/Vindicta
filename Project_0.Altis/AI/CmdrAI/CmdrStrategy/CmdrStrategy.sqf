#include "../common.hpp"

CLASS("CmdrStrategy", "RefCounted")

	VARIABLE("takeLocOutpostPriority");
	VARIABLE("takeLocOutpostPriorityActivityCoeff");
	VARIABLE("takeLocBasePriority");
	VARIABLE("takeLocBasePriorityActivityCoeff");
	VARIABLE("takeLocRoadBlockPriority");
	VARIABLE("takeLocRoadBlockPriorityActivityCoeff");
	VARIABLE("takeLocCityPriority");
	VARIABLE("takeLocCityPriorityActivityCoeff");

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("takeLocOutpostPriority", 0.5);
		T_SETV("takeLocOutpostPriorityActivityCoeff", 1);
		T_SETV("takeLocBasePriority", 2);
		T_SETV("takeLocBasePriorityActivityCoeff", 0);
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocRoadBlockPriorityActivityCoeff", 2);
		T_SETV("takeLocCityPriority", 0);
		T_SETV("takeLocCityPriorityActivityCoeff", 1);	
	} ENDMETHOD;

	METHOD("getLocationDesirability") {
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_loc"), P_SIDE("_side")];
		private _locPos = GETV(_loc, "pos");
		private _activity = log (0.09 * CALLM(_worldNow, "getActivity", [_locPos ARG 2000]) + 1);

		private _priority = 1;
		switch(GETV(_loc, "type")) do {
			case LOCATION_TYPE_OUTPOST: {
				// We want these a bit, but more if there is activity in the area
				_priority = T_GETV("takeLocOutpostPriority") + T_GETV("takeLocOutpostPriorityActivityCoeff") * _activity;
			};
			case LOCATION_TYPE_BASE: { 
				// We want these a normal amount but are willing to go further to capture them.
				// TODO: work out how to weight taking bases vs other stuff? 
				// Probably high priority when we are losing? This is a gameplay question.
				_priority = T_GETV("takeLocBasePriority") + T_GETV("takeLocBasePriorityActivityCoeff") * _activity;
			};
			case LOCATION_TYPE_ROADBLOCK: {
				// We want these if there is local activity.
				_priority = T_GETV("takeLocRoadBlockPriority") +
					T_GETV("takeLocRoadBlockPriorityActivityCoeff") * _activity;

				if(_priority > 0) then {
					private _locs = CALLM(_worldNow, "getNearestLocations", [_locPos ARG 2000 ARG [LOCATION_TYPE_BASE ARG LOCATION_TYPE_OUTPOST]]) select {
						_x params ["_dist", "_loc"];
						!IS_NULL_OBJECT(CALLM(_loc, "getGarrison", [_side]))
					};
					// We build these quick if we have an outpost or base nearby, prioritized by distance
					if(count _locs > 0) then {
						private _distF = 0.0004 * (_locs#0#0);
						private _distCoeff = 1 / (1 + (_distF * _distF));
						_priority = _priority * 2 * _distCoeff;
					} else {
						_priority = 0;
					};
				};
			};
			case LOCATION_TYPE_CITY: { 
				_priority = T_GETV("takeLocCityPriority") + T_GETV("takeLocCityPriorityActivityCoeff") * _activity;
			};
			// No other locations taken by default
			default { _priority = 0 };
		};
		_priority
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

	// Default Patrol behaviour is to send patrols always,
	// from any location that can spare any efficiency, to
	// all surrounding city locations
	/* virtual */ METHOD("getPatrolScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_ARRAY("_routeTargets"),
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
// Make sure it never gets deleted
REF(gCmdrStrategyDefault);

// Unit test
#ifdef _SQF_VM
["CmdrStrategy.new", {
	private _obj = NEW("CmdrStrategy", []);
	
	private _class = OBJECT_PARENT_CLASS_STR(_obj);
	["Object exists", !(isNil "_class")] call test_Assert;
}] call test_AddTest;
#endif