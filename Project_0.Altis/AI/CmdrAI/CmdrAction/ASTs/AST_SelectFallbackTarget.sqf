#include "..\..\common.hpp"

CLASS("AST_SelectFallbackTarget", "ActionStateTransition")
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("srcGarrId", [ATTR_PRIVATE]);
	VARIABLE_ATTR("garrId", [ATTR_PRIVATE]);
	VARIABLE_ATTR("target", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_ARRAY("_fromStates"),				// States it is valid from
			P_AST_STATE("_successState"),		// state on success (can't fail)
			// inputs
			P_AST_VAR("_srcGarrId"),			// Original src garrison, default to fall back to
			P_AST_VAR("_garrId"),				// Garrison we are selecting a new target for
			// outputs
			P_AST_VAR("_target")				// new target
		];
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("srcGarrId", _srcGarrId);
		T_SETV("garrId", _garrId);
		T_SETV("target", _target);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");


		private _srcGarrId = T_GET_AST_VAR("srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);

		// Prefer to go back to src garrison
		private _newTarget = [];
		if(!CALLM(_srcGarr, "isDead", [])) then {
			_newTarget = [TARGET_TYPE_GARRISON, _srcGarrId];
		} else {
			private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrId")]);
			ASSERT_OBJECT(_garr);

			private _pos = GETV(_garr, "pos");

			// select the nearest friendly garrison
			private _nearGarrs = CALLM(_world, "getNearestGarrisons", [_pos]+[4000]) select { !CALLM(_x, "isBusy", []) and (GETV(_x, "locationId") != MODEL_HANDLE_INVALID) };
			if(count _nearGarrs == 0) then {
				// Check further
				_nearGarrs = CALLM(_world, "getNearestGarrisons", [_pos]) select { !CALLM(_x, "isBusy", []) and (GETV(_x, "locationId") != MODEL_HANDLE_INVALID) };
			};

			// If we found one then target it
			if(count _nearGarrs > 0) then {
				private _nearGarr = _nearGarrs#0;
				_newTarget = [TARGET_TYPE_GARRISON, GETV(_nearGarr, "id")];
			} else {
				// Otherwise find a nearby empty location and go there
				private _nearLocs = CALLM(_world, "getNearestLocations", [_pos]+[4000]) select { CALLM(_x, "isEmpty", []) };
				if(count _nearLocs == 0) then {
					_nearLocs = CALLM(_world, "getNearestLocations", [_pos]);
				};
				if(count _nearLocs > 0) then {
					private _nearLoc = _nearLocs#0;
					_newTarget = [TARGET_TYPE_LOCATION, GETV(_nearLoc, "id")];
				} else {
					OOP_ERROR_MSG("Couldn't find any location on map, this should be impossible!", []);
				};
			};
		};
		T_SET_AST_VAR("target", _newTarget);
		T_GETV("successState")
	} ENDMETHOD;
ENDCLASS;