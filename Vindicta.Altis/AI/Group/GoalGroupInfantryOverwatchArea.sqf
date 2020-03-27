#include "common.hpp"

// Group will find a place with line of sight, fullfilling required distance, elevation and gradient requirements.
// Goal for a group to over watch area.
CLASS("GoalGroupInfantryOverwatchArea", "Goal")
	STATIC_METHOD("createPredefinedAction") {
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		private _distMin = CALLSM2("Action", "getParameterValue", _parameters, TAG_OVERWATCH_DISTANCE_MIN);
		private _distMax = CALLSM2("Action", "getParameterValue", _parameters, TAG_OVERWATCH_DISTANCE_MAX);
		private _dir = CALLSM3("Action", "getParameterValue", _parameters, TAG_OVERWATCH_DIRECTION, random 360);
		private _elevation = CALLSM2("Action", "getParameterValue", _parameters, TAG_OVERWATCH_ELEVATION);
		private _gradient = CALLSM2("Action", "getParameterValue", _parameters, TAG_OVERWATCH_GRADIENT);
		//private _behaviour = CALLSM3("Action", "getParameterValue", _parameters, TAG_BEHAVIOUR, "STEALTH");
		//private _combatMode = CALLSM3("Action", "getParameterValue", _parameters, TAG_COMBAT_MODE, "GREEN");

		// Try find a good overwatch position
		private _valid = false;
		private _overwatchPos = [];
		private _attempt = 0;

		private _center = _pos vectorAdd ([sin _dir, cos _dir, 0] vectorMultiply ((_distMax + _distMin) / 2));

		while {!_valid && { _attempt < 20 }} do {
			_overwatchPos = [_pos, _distMax, _distMin, _elevation, _pos, _center, _gradient] call pr0_fnc_findOverwatch;
			_valid = terrainIntersect [_pos, _overwatchPos];
			_attempt = _attempt + 1;
		};

		private _actionSerial = NEW("ActionCompositeSerial", [_AI]);

		// Move to target
		private _actionMoveParams = [
			[TAG_POS, _overwatchPos],
			[TAG_MOVE_RADIUS, 10]
		];
		CALLSM2("Action", "mergeParameterValues", _actionMoveParams, _parameters);
		private _actionMove = NEW("ActionGroupInfantryMove", [_AI ARG _actionMoveParams]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionMove);
		
		// Watch target forever (until garrison action completes)
		private _actionWatchParams = [
			[TAG_POS, _pos]
		];
		CALLSM2("Action", "mergeParameterValues", _actionWatchParams, _parameters);
		private _actionWatch = NEW("ActionGroupWatchPosition", [_AI ARG _actionWatchParams]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionWatch);

		_actionSerial
	} ENDMETHOD;

ENDCLASS;