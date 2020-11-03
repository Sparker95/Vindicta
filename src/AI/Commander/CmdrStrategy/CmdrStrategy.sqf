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
#define OOP_CLASS_NAME CmdrStrategy
CLASS("CmdrStrategy", ["RefCounted" ARG "Storable"])
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
	VARIABLE("takeLocBasePriority");
	VARIABLE("takeLocAirportPriority");
	VARIABLE("takeLocCityPriority");
	VARIABLE("takeLocRoadBlockPriority");
	VARIABLE("takeLocDynamicEnemyPriority");	// Priority of locations created dynamicly by another side
	VARIABLE("takeLocOutpostCoeff");
	VARIABLE("takeLocBaseCoeff");
	VARIABLE("takeLocAirportCoeff");
	VARIABLE("takeLocRoadBlockCoeff");
	VARIABLE("takeLocCityCoeff");

	VARIABLE("constructLocRoadblockPriority");
	VARIABLE("constructLocRoadblockCoeff");

	/*
	Constructor: new
	See implementing classes for specific contructors.
	*/
	METHOD(new)
		params [P_THISOBJECT];

		// Default is for cmdr to do everything
		T_SETV("takeLocOutpostPriority", 			1);
		T_SETV("takeLocBasePriority", 				1);
		T_SETV("takeLocAirportPriority", 			1);
		T_SETV("takeLocDynamicEnemyPriority", 		1);
		T_SETV("takeLocRoadBlockPriority", 			1);
		T_SETV("takeLocCityPriority", 				1);

		T_SETV("takeLocOutpostCoeff", 				1);
		T_SETV("takeLocBaseCoeff", 					1);
		T_SETV("takeLocAirportCoeff", 				1);
		T_SETV("takeLocRoadBlockCoeff", 			1);
		T_SETV("takeLocCityCoeff", 					1);

		T_SETV("constructLocRoadblockPriority", 	1);
		T_SETV("constructLocRoadblockCoeff", 		1);
	ENDMETHOD;

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
	public virtual METHOD(getLocationDesirability)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_loc"), P_SIDE("_side")];

		ASSERT_OBJECT_CLASS(_loc, "LocationModel");

		private _locPos = GETV(_loc, "pos");
		private _rawActivity = CALLM(_worldNow, "getActivity", [_locPos ARG 2000]);
		private _activityMult = __ACTIVITY_FUNCTION(_rawActivity);
		private _createdBy = GETV(_loc, "sideCreated");

		private _priority = 0;

		// Evaluate different general prioritites
		private _priorityGeneral = 0;
		// Priority for locations created by enemy side dynamicly
		// Typically players will create something around: camps, roadblocks, etc...
		// we want to take it first of all no matter what
		if (_createdBy != _side && _createdBy != CIVILIAN) then {
			_priorityGeneral = _priorityGeneral + T_GETV("takeLocDynamicEnemyPriority");
		};

		//
		switch(GETV(_loc, "type")) do {
			case LOCATION_TYPE_OUTPOST: {
				// We want these a bit, but more if there is activity in the area
				_priority = T_GETV("takeLocOutpostPriority") +
					T_GETV("takeLocOutpostCoeff") * _activityMult;
			};
			case LOCATION_TYPE_AIRPORT: {
				// We want them a lot all the time since we use them to bring reinforcements
				_priority = T_GETV("takeLocAirportPriority") +
					T_GETV("takeLocAirportCoeff") * _activityMult;
			};
			case LOCATION_TYPE_BASE: { 
				// We want these a normal amount but are willing to go further to capture them.
				// TODO: work out how to weight taking bases vs other stuff? 
				// Probably high priority when we are losing? This is a gameplay question.
				_priority = T_GETV("takeLocBasePriority") +
					T_GETV("takeLocBaseCoeff") * _activityMult;
			};
			case LOCATION_TYPE_ROADBLOCK: {
				// We want these if there is local activity.
				_priority = T_GETV("takeLocRoadBlockPriority") +
					T_GETV("takeLocRoadBlockCoeff") * _activityMult;
			};
			case LOCATION_TYPE_CITY: {
				// If city is under enemy influence, we should take it
				pr _influence = GETV(_loc, "influence"); // Positive influence means city is influenced by player
				// If enemy occupies this, we want to occupy this too
				pr _boostOccupiedByEnemy = 0;
				pr _actual = GETV(_loc, "actual");
				pr _sides = [EAST, WEST, INDEPENDENT] - [_side];
				pr _garrisons = CALLM1(_actual, "getGarrisons", _sides);
				if (count _garrisons > 0) then {
					_boostOccupiedByEnemy = 1;
				};
				_priority = T_GETV("takeLocCityPriority") + _boostOccupiedByEnemy + T_GETV("takeLocCityCoeff") * _influence;
			};
			case LOCATION_TYPE_CAMP: {
				// Same as outpost
				_priority = T_GETV("takeLocOutpostPriority") +
					T_GETV("takeLocOutpostCoeff") * _activityMult;
			};
			// No other locations taken by default
			default { _priority = 0 };
		};

		pr _return = _priority + _priorityGeneral;

		OOP_INFO_5("Location desirability: %1 %2 %3 at %4 : %5", GETV(_loc, "type"), _loc, CALLM0(GETV(_loc, "actual"), "getName"), GETV(_loc, "pos"), _return);

		// Sum up calculated priority and other priority boosts
		_return
	ENDMETHOD;

	/*
	Method: (virtual) getConstructLocationDesirability
	Return a value indicating the commanders desire to construct a location.
	
	Parameters:
		_worldNow - <Model.WorldModel>, the current world model (only resource requirements of new and planned actions are applied).
		_locPos - <Model.LocationModel>, location being evaluated.
		_locType - location type
		_side - Side, side of the commander being evaluated.
	
	Returns: Number, the relative desireability of the location as compared to other locations. This value has no 
	specific meaning or units.
	*/
	public virtual METHOD(getConstructLocationDesirability)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_POSITION("_locPos"), P_DYNAMIC("_locType"), P_SIDE("_side")];

		// Same as for taking locations
		private _rawActivity = CALLM(_worldNow, "getActivity", [_locPos ARG 2000]);
		//OOP_DEBUG_1(" WorldNow activity: %1", _rawActivity);
		private _activityMult = __ACTIVITY_FUNCTION(_rawActivity);

		private _priority = 0;
		switch(_locType) do {

			case LOCATION_TYPE_ROADBLOCK: {
				if (_rawActivity > MAP_LINEAR_SET_POINT(1 - vin_diff_global, 0, 15, 75)) then {
					_priority = T_GETV("constructLocRoadblockPriority") +
								T_GETV("constructLocRoadblockCoeff") * _activityMult;
				};
			};

			// No other locations can be constructed
			default { _priority = 0 };
		};

		// Old code to sort positions by priority
		/*
				if(_priority > 0) then {
			pr _args = [_locPos,
						2000,
						[LOCATION_TYPE_BASE, LOCATION_TYPE_OUTPOST, LOCATION_TYPE_CITY, LOCATION_TYPE_AIRPORT]];
			private _locs = CALLM(_worldNow, "getNearestLocations", _args) select {
				_x params ["_dist", "_loc"];
				!IS_NULL_OBJECT(CALLM(_loc, "getGarrison", [_side]))
			};
			// We build these quick around outposts, bases, cities, and airports, prioritized by distance
			if(count _locs > 0) then {
				private _distF = 0.0004 * (_locs#0#0);
				private _distCoeff = 1 / (1 + (_distF * _distF));
				_priority = _priority * 2 * _distCoeff;
			} else {
				_priority = 0;
			};
		};
		*/

		_priority

	ENDMETHOD;

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
	public virtual METHOD(getQRFScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtCluster"),
			P_ARRAY("_detachEff")];
		private _tgtClusterPos = GETV(_tgtCluster, "pos");
		private _adjustedDamage = CALLM2(_worldNow, "getDamageScore", _tgtClusterPos, 2500);
		APPLY_SCORE_STRATEGY(_defaultScore, _adjustedDamage)
	ENDMETHOD;

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
	public virtual METHOD(getPatrolScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_ARRAY("_routeTargets"),
			P_ARRAY("_detachEff")];
		_defaultScore
	ENDMETHOD;

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
	public virtual METHOD(getReinforceScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtGarr"),
			P_ARRAY("_detachEff")];
		_defaultScore
	ENDMETHOD;

	/*
	Method: (virtual) getSupplyScore
	Return a value indicating the commanders desire to send supplies from the specified source garrison to the
	specified target garrison of the specified type and amount.
	Default <CmdrAction.Actions.SupplyConvoyCmdrAction> behaviour is to send supplies whenever they are needed.
	
	Parameters:
		_action - <CmdrAction.Actions.SupplyConvoyCmdrAction>, action being evaluated.
		_defaultScore - Array of Numbers, score vector, the score as calculated by the default algorithm. This can be returned as 
			it to get default behaviour (detailed above in the method description).
		_worldNow - <Model.WorldModel>, the current world model (only resource requirements of new and planned actions are applied).
		_worldFuture - <Model.WorldModel>, the predicted future world model (in progress and planned actions are applied to completion).
		_srcGarr - <Model.GarrisonModel>, garrison that would send the supplies.
		_tgtGarr - <Model.GarrisonModel>, garrison that would receive the supplies.
		_detachEff - Array of Numbers, efficiency vector, the efficiency of the detachment the source garrison is capable of
			sending, capped against what is required by the target garrison.
		_type - Number, type of the supplies to send (as per the ACTION_SUPPLY_TYPE_* macros in SupplyConvoyCmdrAction.sqf)
		_amount - Number, 0-1 representing the amount of supplies (no specific units)

	Returns: Array of Numbers, score vector
	*/
	public virtual METHOD(getSupplyScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtGarr"),
			P_ARRAY("_detachEff"),
			P_NUMBER("_type"),
			P_NUMBER("_amount")
			];
		_defaultScore
	ENDMETHOD;

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
	public virtual METHOD(getTakeLocationScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtLoc"),
			P_ARRAY("_detachEff")];
		private _tgtPos = GETV(_tgtLoc, "pos");
		private _adjustedDamage = CALLM2(_worldNow, "getDamageScore", _tgtPos, 2500);
		APPLY_SCORE_STRATEGY(_defaultScore, _adjustedDamage)
	ENDMETHOD;

	public virtual METHOD(getConstructLocationScore)
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_POSITION("_tgtLocPos"),
			P_ARRAY("_detachEff")];
		_defaultScore
	ENDMETHOD;

	// Save all varaibles
	public override METHOD(serializeForStorage)
		params [P_THISOBJECT];
		SERIALIZE_ALL(_thisObject);
	ENDMETHOD;

	public override METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial")];
		DESERIALIZE_ALL(_thisObject, _serial);
		true
	ENDMETHOD;

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