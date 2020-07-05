#include "common.hpp"

// Group will find a place with line of sight, fullfilling required distance, elevation and gradient requirements.
// Goal for a group to over watch area.
#define OOP_CLASS_NAME GoalGroupOverwatchArea
CLASS("GoalGroupOverwatchArea", "GoalGroup")
	public STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _group = GETV(_AI, "agent");
		private _isVehicle = CALLM0(_group, "getType") in [GROUP_TYPE_VEH ARG GROUP_TYPE_STATIC];

		private _gradientDefault = if(_isVehicle) then { 0.4 } else { 0.6 };

		private _pos 			= CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		private _distMin 		= CALLSM3("Action", "getParameterValue", _parameters, TAG_OVERWATCH_DISTANCE_MIN, 250);
		private _distMax 		= CALLSM3("Action", "getParameterValue", _parameters, TAG_OVERWATCH_DISTANCE_MAX, 500);
		private _dir 			= CALLSM3("Action", "getParameterValue", _parameters, TAG_OVERWATCH_DIRECTION, random 360);

		private _elevation 		= CALLSM3("Action", "getParameterValue", _parameters, TAG_OVERWATCH_ELEVATION, 20);
		private _gradient 		= CALLSM3("Action", "getParameterValue", _parameters, TAG_OVERWATCH_GRADIENT, _gradientDefault);
		//private _behaviour = CALLSM3("Action", "getParameterValue", _parameters, TAG_BEHAVIOUR, "STEALTH");
		//private _combatMode = CALLSM3("Action", "getParameterValue", _parameters, TAG_COMBAT_MODE, "GREEN");


		// Try find a good overwatch position
		private _valid = false;
		private _overwatchPos = [];

		private _center = _pos vectorAdd ([sin _dir, cos _dir, 0] vectorMultiply ((_distMax + _distMin) / 2));

		// Find unpathable places so we can avoid them
		private _wfQuery = WF_NEW();
		[_wfQuery, WF_TYPE_UNIT_UNPATHABLE] call wf_fnc_setType;

		private _blacklist = CALLM1(_AI, "findWorldFacts", _wfQuery) apply { [WF_GET_POS(_x), 25] };
		private _attempt = 0;
		while {!_valid && { _attempt < 20 }} do {
			_overwatchPos = [_pos, _distMax, _distMin, _elevation, _center, _gradient, _blacklist] call vin_fnc_findOverwatch;
			_valid = terrainIntersect [_pos, _overwatchPos];
			_attempt = _attempt + 1;
		};

		private _actionSerial = NEW("ActionCompositeSerial", [_AI]);

		if(_isVehicle) then {
			// Mount vehicles
			private _actionGetInParams = [
				[TAG_ONLY_COMBAT_VEHICLES, true] // Only combat vehicle operators must stay in vehicles
			];
			CALLSM2("Action", "mergeParameterValues", _actionGetInParams, _parameters);
			private _actionGetIn = NEW("ActionGroupGetInVehiclesAsCrew", [_AI ARG _actionGetInParams]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionGetIn);
		};

		// Move to target
		private _actionMoveParams = [
			[TAG_POS, _overwatchPos],
			[TAG_MOVE_RADIUS, 15]
		];
		CALLSM2("Action", "mergeParameterValues", _actionMoveParams, _parameters);
		private _actionMove = NEW("ActionGroupMove", [_AI ARG _actionMoveParams]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionMove);

		// Watch target forever (until garrison action completes)
		private _actionWatchParams = [
			[TAG_POS, _pos]
		];
		CALLSM2("Action", "mergeParameterValues", _actionWatchParams, _parameters);
		private _actionWatch = NEW("ActionGroupWatchPosition", [_AI ARG _actionWatchParams]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionWatch);

		_actionSerial
	ENDMETHOD;

ENDCLASS;