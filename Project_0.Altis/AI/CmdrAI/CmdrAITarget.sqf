#include "common.hpp"

Target_fnc_GetPos = {
	params ["_world", "_targetObj"];
	_targetObj params ["_targetType", "_target"];

	private _targetPos = false;
	switch(_targetType) do {
		case TARGET_TYPE_GARRISON: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON target type expects a garrison ID");
			private _garr = CALLM(_world, "getGarrison", [_target]);
			ASSERT_OBJECT(_garr);
			_targetPos = if(CALLM(_garr, "isDead", [])) then {
				false
			} else {
				GETV(_garr, "pos")
			};
		};
		case TARGET_TYPE_LOCATION: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION target type expects a location ID");
			private _loc = CALLM(_world, "getLocation", [_target]);
			ASSERT_OBJECT(_loc);
			_targetPos = GETV(_loc, "pos");
		};
		case TARGET_TYPE_POSITION: {
			ASSERT_MSG(_target isEqualType [], "TARGET_TYPE_POSITION target type expects a position [x,y,z]");
			_targetPos = _target;
		};
		default {
			FAILURE("Target is not valid");
		};
	};
	_targetPos
};

Target_fnc_GetLabel = {
	params ["_world", "_targetObj"];

	_targetObj params ["_targetType", "_target"];
	private _targetName = "unknown";
	switch(_targetType) do {
		case TARGET_TYPE_GARRISON: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON target type expects a garrison ID");
			private _garr = CALLM(_world, "getGarrison", [_target]);
			ASSERT_OBJECT(_garr);
			_targetName = LABEL(_garr) + str GETV(_tgtGarr, "efficiency");
		};
		case TARGET_TYPE_LOCATION: {
			ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION target type expects a location ID");
			private _loc = CALLM(_world, "getLocation", [_target]);
			ASSERT_OBJECT(_loc);
			_targetName = LABEL(_loc);
		};
		case TARGET_TYPE_POSITION: {
			ASSERT_MSG(_target isEqualType [], "TARGET_TYPE_POSITION target type expects a position [x,y,z]");
			_targetName = str(_target);
		};
		default {
			FAILURE("Target is not valid");
		};
	};
	_targetName
}