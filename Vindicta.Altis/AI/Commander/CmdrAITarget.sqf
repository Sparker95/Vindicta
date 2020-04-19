#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAITarget
A general reference to a target that can be used in AI where the type of target can vary.

Not actually a class, but a set of functions and macros.

See <CmdrAction.TARGET_TYPE>
*/

/*
Method: IS_NULL_TARGET

Parameters:
	target - the CmdrAITarget to test

Returns: Boolean, true if the CmdrAITarget is null
*/

/*
Method: Target_fnc_GetPos
Get the position of the target, if it can be evaluated.

Parameters: 
	_world - <AI.CmdrAI.Model.WorldModel>, world with which to lookup the target (if required)
	_targetObj - <AI.CmdrAI.CmdrAITarget>, the target to get the position of.

Returns: Position
*/
Target_fnc_GetPos = {
	params ["_world", "_targetObj"];
	_targetObj params ["_targetType", "_target"];

	private _targetPos = false;
	switch(_targetType) do {
		case TARGET_TYPE_GARRISON: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON expects a garrison ID");
			private _garr = CALLM(_world, "getGarrison", [_target]);
			ASSERT_OBJECT(_garr);
			/*
			_targetPos = if(CALLM0(_garr, "isDead")) then {
				false
			} else {
				GETV(_garr, "pos")
			};
			*/
			_targetPos = GETV(_garr, "pos");
		};
		case TARGET_TYPE_LOCATION: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION expects a location ID");
			private _loc = CALLM(_world, "getLocation", [_target]);
			ASSERT_OBJECT(_loc);
			_targetPos = GETV(_loc, "pos");
		};
		case TARGET_TYPE_POSITION: {
			ASSERT_MSG(_target isEqualType [], "TARGET_TYPE_POSITION expects a position [x,y,z]");
			_targetPos = _target;
		};
		case TARGET_TYPE_CLUSTER: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_CLUSTER expects a cluster ID");
			private _cluster = CALLM(_world, "getCluster", [_target]);
			ASSERT_OBJECT(_cluster);
			_targetPos = GETV(_cluster, "pos");
		};
		default {
			FAILURE("Target is not valid");
		};
	};

	OOP_INFO_2("TARGET GET POS: %1, return: %2", _targetObj, _targetPos);

	_targetPos
};

/*
Method: Target_fnc_GetLabel
Get a text label for the target, useful for debugging.

Parameters: 
	_world - <AI.CmdrAI.Model.WorldModel>, world with which to lookup the target (if required)
	_targetObj - <AI.CmdrAI.CmdrAITarget>, the target to get the position of.
	_default - String, defaults to "invalid", default value to return if the target cannot be resolved.

Returns: String
*/
Target_fnc_GetLabel = {
	params ["_world", "_targetObj", ["_default", "invalid", [""]]];

	if(IS_NULL_TARGET(_targetObj)) exitWith { _default };

	_targetObj params ["_targetType", "_target"];
	private _targetName = _default;
	switch(_targetType) do {
		case TARGET_TYPE_GARRISON: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON expects a garrison ID");
			private _garr = CALLM(_world, "getGarrison", [_target]);
			ASSERT_OBJECT(_garr);
			_targetName = LABEL(_garr) + str GETV(_garr, "efficiency");
		};
		case TARGET_TYPE_LOCATION: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION expects a location ID");
			private _loc = CALLM(_world, "getLocation", [_target]);
			ASSERT_OBJECT(_loc);
			_targetName = LABEL(_loc);
		};
		case TARGET_TYPE_POSITION: {
			ASSERT_MSG(_target isEqualType [], "TARGET_TYPE_POSITION expects a position [x,y,z]");
			_targetName = str(_target);
		};
		case TARGET_TYPE_CLUSTER: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_CLUSTER expects a cluster ID");
			private _cluster = CALLM(_world, "getCluster", [_target]);
			ASSERT_OBJECT(_cluster);
			_targetName = LABEL(_cluster);
		};
		default {
			FAILURE("Target is not valid");
		};
	};
	_targetName
};
