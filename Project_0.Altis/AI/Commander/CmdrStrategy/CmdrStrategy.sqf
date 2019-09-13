#include "../common.hpp"

/*
Class: AI.CmdrAI.CmdrStrategy.CmdrStrategy

Base class for command strategy implementations.

Acts as a customization entry point for driving commander behaviour to achieve
specific gameplay.
e.g If you want to change the criteria the commander will use to decide 
when to occupy a specific location then you can derive a custom `CmdrStrategy`
and override `getLocationDesirability` (or modify the `takeLoc*` member values).

Paremt: <RefCounted>
*/
CLASS("CmdrStrategy", "RefCounted")
	// takeLoc*Priority are the base priorities the commander will apply when deciding
	// whether to occupy a location. If it is non zero then the commander will always
	// desire the location to a certain degree. This value has real no units, but as it 
	// forms part of a calculation that can include activity values it could be considered
	// "base activity" for the calculation.
	VARIABLE("takeLocOutpostPriority");
	// takeLoc*PriorityActivityCoeff are the activity multiplier the commander will
	// apply when deciding whether to occupy a location. If it is non zero then it
	// is applied as a multiplier to the activity in the area of the location being
	// evaluated. So if there is local activity and the multipler is non zero then 
	// the commander will desire the location to that degree.
	VARIABLE("takeLocOutpostPriorityActivityCoeff");
	VARIABLE("takeLocBasePriority");
	VARIABLE("takeLocBasePriorityActivityCoeff");
	VARIABLE("takeLocRoadBlockPriority");
	VARIABLE("takeLocRoadBlockPriorityActivityCoeff");
	VARIABLE("takeLocCityPriority");
	VARIABLE("takeLocCityPriorityActivityCoeff");

	/*
	Constructor: new
	See implementing classes for specific contructors.
	*/
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

	/*
	Method: (virtual) getLocationDesirability
	Return a value indicating the commanders desire to occupy the specified location.
	
	Parameters:
		_worldNow - <Model.WorldModel>, the current world model (only resource requirements of new and planned actions are applied).
		_loc - <Model.LocationModel>, location being evaluated.
		_side - Side, side of the commander being evaluated.
	
	Returns: Number, the relative desireability of the location as compared to other locations. This value has no 
	specific meaning or units.
	*/
	/* virtual */ METHOD("getLocationDesirability") {
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

	/*
	Method: (virtual) getQRFScore
	Return a value indicating the commanders desire to send a QRF in response to the specified cluster,
	from the specified garrison.
	Default <CmdrAction.Actions.QRFCmdrAction> behaviour is to send QRFs always, from any location that can spare the 
	entire required efficiency.
	
	Parameters:
		_action - <CmdrAction.Actions.QRFCmdrAction>, action being evaluated.
		_defaultScore - Array of Numbers, score vector, the score as calculated by the default algorithm. This can be returned as 
				it to get default behaviour (detailed above in the method description).
		_worldNow - <Model.WorldModel>, the current sim world model (only resource requirements of new and planned actions are applied).
		_worldFuture - <Model.WorldModel>, the future sim world model (in progress and planned actions are applied to completion).
		_srcGarr - <Model.GarrisonModel>, garrison that would send the QRF.
		_tgtCluster - <Model.ClusterModel>, cluster the QRF would be sent against.
		_detachEff - Array of Numbers, efficiency vector, the efficiency of the detachment the source garrison is capable of sending, capped against 
				what is required to deal with the target cluster.

	Returns: Array of Numbers, score vector
	*/
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

	/*
	Method: (virtual) getPatrolScore
	Return a value indicating the commanders desire to send a patrol from the specified source garrison on the 
	specified route.
	Default <CmdrAction.Actions.PatrolCmdrAction> behaviour is to send patrols always, from any location that can spare
	any efficiency,	to all surrounding city locations.
	
	Parameters:
		_action - <CmdrAction.Actions.PatrolCmdrAction>, action being evaluated.
		_defaultScore - Array of Numbers, score vector, the score as calculated by the default algorithm. This can be returned as 
			it to get default behaviour (detailed above in the method description).
		_worldNow - <Model.WorldModel>, the current world model (only resource requirements of new and planned actions are applied).
		_worldFuture - <Model.WorldModel>, the predicted future world model (in progress and planned actions are applied to completion).
		_srcGarr - <Model.GarrisonModel>, garrison that would send the patrol.
		_routeTargets - Array of <CmdrAITargets>, the patrol route.
		_detachEff - Array of Numbers, efficiency vector, the efficiency of the detachment the source garrison is capable of sending, capped against 
			what is required for the patrol route.
	
	Returns: Array of Numbers, score vector
	*/
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

	/*
	Method: (virtual) getReinforceScore
	Return a value indicating the commanders desire to send reinforcements from the specified source garrison to the
	specified target garrison.
	Default <CmdrAction.Actions.ReinforceCmdrAction> behaviour is to send reinforcements whenever they are needed,
	from any location that can spare the entire required efficiency.
	
	Parameters:
		_action - <CmdrAction.Actions.ReinforceCmdrAction>, action being evaluated.
		_defaultScore - Array of Numbers, score vector, the score as calculated by the default algorithm. This can be returned as 
			it to get default behaviour (detailed above in the method description).
		_worldNow - <Model.WorldModel>, the current world model (only resource requirements of new and planned actions are applied).
		_worldFuture - <Model.WorldModel>, the predicted future world model (in progress and planned actions are applied to completion).
		_srcGarr - <Model.GarrisonModel>, garrison that would send the reinforcements.
		_tgtGarr - <Model.GarrisonModel>, garrison that would receive the reinforements.
		_detachEff - Array of Numbers, efficiency vector, the efficiency of the detachment the source garrison is capable of
			sending, capped against what is required by the target garrison.

	Returns: Array of Numbers, score vector
	*/
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

	/*
	Method: (virtual) getTakeLocationScore
	Return a value indicating the commanders desire to take the specified location using the specified source 
	garrison.
	Default <CmdrAction.Actions.TakeLocationCmdrAction> behaviour is to always take bases and outposts, but only take roadblocks if there is both 
	nearby activity and a nearby friendly location. 
	It prefer locations in this order generally: base >> outpost >> roadblock
	However roadblocks become more important the stronger activity is in the area, such that they can be the most 
	important with high activity.
	
	Parameters:
		_action - <CmdrAction.Actions.TakeLocationCmdrAction>, action being evaluated.
		_defaultScore - Array of Numbers, score vector, the score as calculated by the default algorithm. This can be returned as 
			it to get default behaviour (detailed above in the method description).
		_worldNow - <Model.WorldModel>, the current world model (only resource requirements of new and planned actions are applied).
		_worldFuture - <Model.WorldModel>, the predicted future world model (in progress and planned actions are applied to completion).
		_srcGarr - <Model.GarrisonModel>, garrison that would send the detachment.
		_tgtLoc - <Model.LocationModel>, location that would be taken.
		_detachEff - Array of Numbers, efficiency vector, the efficiency of the detachment the source garrison is capable of sending, capped against 
			what is required to take the location.
	
	Returns: Array of Numbers, score vector
	*/
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

// Default strategy object, applied when no custom one is specified.
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