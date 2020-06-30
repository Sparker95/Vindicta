#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.ASTs.AST_SelectFallbackTarget
Select a target for a garrison that it can reasonably fallback to. e.g. RTB or retreat
target.

Parent: <ActionStateTransition>
*/
#define OOP_CLASS_NAME AST_SelectFallbackTarget
CLASS("AST_SelectFallbackTarget", "ActionStateTransition")
	VARIABLE_ATTR("successState", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("srcGarrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("garrIdVar", [ATTR_PRIVATE ARG ATTR_SAVE]);
	VARIABLE_ATTR("targetVar", [ATTR_PRIVATE ARG ATTR_SAVE]);

	/*
	Method: new
	Create an AST to select or find a target for a garrison that it can reasonably fallback to. e.g. RTB or retreat
	target. 
	
	Parameters:
		_fromStates - Array of <CMDR_ACTION_STATE>, states this AST is valid from
		_successState - <CMDR_ACTION_STATE>, state to return after success
		_srcGarrIdVar - IN <AST_VAR>(Number), <Model.GarrisonModel> Id of the garrison to use as a default fallback.
			e.g. The original source garrison of a detachment.
		_garrIdVar - IN <AST_VAR>(Number), <Model.GarrisonModel> Id of the garrison to select a fallback target for.
		_targetVar - OUT <AST_VAR>(<CmdrAITarget>), target selected by this AST
	*/
	METHOD(new)
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),
			P_AST_STATE("_successState"),
			P_AST_VAR("_srcGarrIdVar"),
			P_AST_VAR("_garrIdVar"),
			P_AST_VAR("_targetVar")
		];
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("srcGarrIdVar", _srcGarrIdVar);
		T_SETV("garrIdVar", _garrIdVar);
		T_SETV("targetVar", _targetVar);
	ENDMETHOD;

	public override METHOD(apply)
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrIdVar")]);
		ASSERT_OBJECT(_garr);

		private _srcGarrId = T_GET_AST_VAR("srcGarrIdVar");
		private _srcGarr = if(_srcGarrId != MODEL_HANDLE_INVALID) then { 
			CALLM(_world, "getGarrison", [_srcGarrId]) 
		} else {
			NULL_OBJECT
		};

		// Prefer to fallback to src garrison unless it is dead
		private _newTarget = [];
		if(!IS_NULL_OBJECT(_srcGarr) and {!CALLM0(_srcGarr, "isDead")}) then {
			_newTarget = [TARGET_TYPE_GARRISON, _srcGarrId];
			OOP_INFO_MSG_REAL_ONLY(_world, "Selected new fallback target for %1: %2", [LABEL(_garr) ARG LABEL(_srcGarr)]);
		} else {
			private _pos = GETV(_garr, "pos");

			// select the nearest friendly garrison
			private _nearGarrs = CALLM(_world, "getNearestGarrisons", [_pos ARG 4000]) select {
				_x params ["_dist", "_garr"];
				!CALLM0(_garr, "isBusy") and (GETV(_garr, "locationId") != MODEL_HANDLE_INVALID) 
			};
			if(count _nearGarrs == 0) then {
				// Check further
				_nearGarrs = CALLM1(_world, "getNearestGarrisons", _pos) select { 
					_x params ["_dist", "_garr"];
					!CALLM0(_garr, "isBusy") and (GETV(_garr, "locationId") != MODEL_HANDLE_INVALID) 
				};
			};

			// If we found one then target it
			if(count _nearGarrs > 0) then {
				private _nearDistGarr = _nearGarrs#0;
				_nearDistGarr params ["_dist", "_nearGarr"];
				_newTarget = [TARGET_TYPE_GARRISON, GETV(_nearGarr, "id")];
				OOP_INFO_MSG_REAL_ONLY(_world, "Selected new fallback target for %1: %2", [LABEL(_garr) ARG LABEL(_nearGarr)]);
			} else {
				// Otherwise find a nearby empty location and go there
				private _nearLocs = CALLM2(_world, "getNearestLocations", _pos, 4000) select { CALLM0(_x select 1, "isEmpty") };
				if(count _nearLocs == 0) then {
					_nearLocs = CALLM1(_world, "getNearestLocations", _pos);
				};
				if(count _nearLocs > 0) then {
					private _nearLoc = _nearLocs#0;
					_nearLoc params ["_dist", "_nearLoc"];
					_newTarget = [TARGET_TYPE_LOCATION, GETV(_nearLoc, "id")];
					OOP_INFO_MSG_REAL_ONLY(_world, "Selected new fallback target for %1: %2", [LABEL(_garr) ARG LABEL(_nearLoc)]);
				} else {
					OOP_ERROR_MSG("Couldn't find any location on map, this should be impossible!", []);
				};
			};
		};
		T_SET_AST_VAR("targetVar", _newTarget);
		T_GETV("successState")
	ENDMETHOD;
ENDCLASS;
