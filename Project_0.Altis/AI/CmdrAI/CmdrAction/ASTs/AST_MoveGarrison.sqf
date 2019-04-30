#include "..\..\common.hpp"

CLASS("AST_MoveGarrison", "ActionStateTransition")
	VARIABLE_ATTR("action", [ATTR_PRIVATE]);
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("failGarrisonDead", [ATTR_PRIVATE]);
	VARIABLE_ATTR("failTargetDead", [ATTR_PRIVATE]);
	VARIABLE_ATTR("moving", [ATTR_PRIVATE]);
	// Inputs
	VARIABLE_ATTR("garrId", [ATTR_PRIVATE]);
	VARIABLE_ATTR("target", [ATTR_PRIVATE]);
	VARIABLE_ATTR("radius", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_OOP_OBJECT("_action"),
			P_ARRAY("_fromStates"),				// States it is valid from
			P_AST_STATE("_successState"),		// if we reached the target
			P_AST_STATE("_failGarrisonDead"), 	// if the garrison we are moving died
			P_AST_STATE("_failTargetDead"), 	// if the target died (if it can)
			// inputs
			P_AST_VAR("_garrId"), 				// garrison to move
			P_AST_VAR("_target"), 				// target [type, value] (garrison, location or position)
			P_AST_VAR("_radius") 				// radius we need to reach
		];
		ASSERT_OBJECT_CLASS(_action, "CmdrAction");

		T_SETV("action", _action);
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("failGarrisonDead", _failGarrisonDead);
		T_SETV("failTargetDead", _failTargetDead);
		T_SETV("moving", false);

		T_SETV("garrId", _garrId);
		T_SETV("target", _target);
		T_SETV("radius", _radius);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrId")]);
		ASSERT_OBJECT(_garr);

		if(CALLM(_garr, "isDead", [])) exitWith {
			T_GETV("failGarrisonDead")
		};

		T_GET_AST_VAR("target") params ["_targetType", "_target"];

		private _targetPos = switch(_targetType) do {
			case TARGET_TYPE_GARRISON: {
				private _garr = CALLM(_world, "getGarrison", [_target]);
				if(CALLM(_garr, "isDead", [])) then {
					false
				} else {
					CALLM(_garr, "getPos", [])
				}
			};
			case TARGET_TYPE_LOCATION: {
				private _loc = CALLM(_world, "getLocation", [_target]);
				CALLM(_loc, "getPos", [])
			};
			case TARGET_TYPE_POSITION: {
				_target
			};
		};
		if(!(_targetPos isEqualType [])) exitWith { T_GETV("failTargetDead") };

		private _arrived = false;

		switch(GETV(_world, "type")) do {
			// Move can't be applied instantly
			case WORLD_TYPE_SIM_NOW: {};
			// Move completes at some point in the future
			case WORLD_TYPE_SIM_FUTURE: {
				CALLM(_garr, "moveSim", [_targetPos]);
				_arrived = true;
			};
			case WORLD_TYPE_REAL: {
				private _radius = T_GET_AST_VAR("radius");
				if(!_moving) then {
					// Start moving
					OOP_INFO_MSG("[w %1] Move %3 to %4: started", [_world ARG _garr ARG _targetPos]);
					CALLM(_garr, "moveActual", [_targetPos ARG _radius]);
					T_SETV("moving", true);
				} else {
					// Are we there yet?
					private _done = CALLM(_garr, "moveActualComplete", []);
					if(_done) then {
						private _garrPos = GETV(_garr, "pos");
						if((_garrPos distance _targetPos) <= _radius * 1.5) then {
							OOP_INFO_MSG("[w %1] Move %2 to %3: complete, reached target within %4m", [_world ARG LABEL(_garr) ARG _targetPos ARG _radius]);
							_arrived = true;
						} else {
							// Move again cos we didn't get there yet!
							OOP_INFO_MSG("[w %1] Move %2 to %3: complete, didn't reach target within %4m, moving again", [_world ARG LABEL(_garr) ARG _targetPos ARG _radius]);
							T_SETV("moving", false);
						};
					};
				};
			};
		};
		if(_arrived) then {
			T_GETV("successState")
		} else {
			CMDR_ACTION_STATE_NONE
		}
	} ENDMETHOD;
ENDCLASS;

// ORIGINAL:
// // TODO: Split into Move and Retarget, see Docs\CmdrActions\TakeOrReinforce.dot.
// // Need to handle target dying etc etc.
// CLASS("MoveGarrison", "ActionStateTransition")
// 	VARIABLE("action");
// 	VARIABLE("moving");
// 	VARIABLE("radius");
// 	VARIABLE("noTarget");

// 	METHOD("new") {
// 		params [P_THISOBJECT, P_STRING("_action"), P_NUMBER("_radius")];

// 		T_SETV("action", _action);
// 		T_SETV("moving", false);
// 		T_SETV("radius", _radius);
// 		T_SETV("noTarget", false);
// 		T_SETV("fromStates", [CMDR_ACTION_STATE_SPLIT]);
// 		T_SETV("toState", CMDR_ACTION_STATE_ARRIVED);
// 	} ENDMETHOD;

// 	METHOD("selectNewTarget") {
// 		params [P_THISOBJECT, P_STRING("_world")];

// 		T_PRVAR(action);

// 		private _srcGarrId = GETV(_action, "srcGarrId");
// 		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
// 		ASSERT_OBJECT(_srcGarr);

// 		// Prefer to go back to src garrison
// 		private _newTgtGarr = NULL_OBJECT;
// 		if(!CALLM(_srcGarr, "isDead", [])) then {
// 			_newTgtGarr = _srcGarr;
// 		} else {
// 			private _detachedGarrId = GETV(_action, "detachedGarrId");
// 			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
// 			ASSERT_OBJECT(_detachedGarr);

// 			private _pos = GETV(_detachedGarr, "pos");
// 			// select the nearest friendly garrison
// 			private _nearGarrs = CALLM(_world, "getNearestGarrisons", [_pos ARG 4000]) select { !CALLM(_x, "isBusy", []) and (GETV(_x, "locationId") != MODEL_HANDLE_INVALID) };
// 			if(count _nearGarrs == 0) then {
// 				_nearGarrs = CALLM(_world, "getNearestGarrisons", [_pos]) select { !CALLM(_x, "isBusy", []) and (GETV(_x, "locationId") != MODEL_HANDLE_INVALID) };
// 			};
// 			if(count _nearGarrs > 0) then {
// 				_newTgtGarr = _nearGarrs#0;
// 			};
// 		};
// 		_newTgtGarr
// 	} ENDMETHOD;

// 	/* virtual */ METHOD("isAvailable") { 
// 		params [P_THISOBJECT, P_STRING("_world")];
// 		!T_GETV("noTarget")
// 	} ENDMETHOD;

// 	/* override */ METHOD("apply") { 
// 		params [P_THISOBJECT, P_STRING("_world")];
// 		ASSERT_OBJECT_CLASS(_world, "WorldModel");

// 		T_PRVAR(action);
// 		T_PRVAR(moving);
// 		T_PRVAR(radius);

// 		private _detachedGarrId = GETV(_action, "detachedGarrId");
// 		private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
// 		ASSERT_OBJECT(_detachedGarr);

// 		private _tgtGarrId = GETV(_action, "tgtGarrId");
// 		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
// 		ASSERT_OBJECT(_tgtGarr);

// 		// If the detachment died then we just finish the whole action immediately
// 		if(CALLM(_detachedGarr, "isDead", [])) exitWith { 
// 			OOP_WARNING_MSG("[w %1 a %2] Detached garrison %3 is dead so can't complete move to %4 (aborting the action)", [_world ARG _action ARG LABEL(_detachedGarr) ARG LABEL(_tgtGarr)]);
// 			// HACK: Return true to indicate we "succeeded" until AST can support failure conditions.
// 			true
// 		};

// 		private _arrived = false;

// 		switch(GETV(_world, "type")) do {
// 			// Move can't be applied instantly
// 			case WORLD_TYPE_SIM_NOW: {};
// 			// Move completes at some point in the future
// 			case WORLD_TYPE_SIM_FUTURE: {
// 				private _tgtPos = GETV(_tgtGarr, "pos");
// 				CALLM(_detachedGarr, "moveSim", [_tgtPos]);
// 				_arrived = true;
// 			};
// 			case WORLD_TYPE_REAL: {
// 				// If target is dead then we better cancel move and pick a new one.
// 				if(CALLM(_tgtGarr, "isDead", [])) then {
// 					if(_moving) then
// 					{
// 						CALLM(_detachedGarr, "cancelMoveActual", []);
// 						_moving = false;
// 						T_SETV("moving", false);
// 					};
// 					private _newTgtGarr = T_CALLM("selectNewTarget", [_world]);
// 					if(IS_NULL_OBJECT(_newTgtGarr)) then {
// 						// TODO: Now what?
// 						// We just cancel the action for now. Maybe another action will pick up this garrison?
// 						T_SETV("noTarget", true);
// 					} else {
// 						OOP_INFO_MSG("[w %1 a %2] Target %3 is dead, picking %4 as a new target", [_world ARG _action ARG LABEL(_tgtGarr) ARG LABEL(_newTgtGarr)]);
// 						T_SETV("moving", false);
// 						private _newTgtGarrId = GETV(_newTgtGarr, "id");
// 						// Update the target Id in the action.
// 						SETV(_action, "tgtGarrId", _newTgtGarrId);
// 						_tgtGarr = _newTgtGarr;
// 					};
// 				};

// 				private _tgtPos = GETV(_tgtGarr, "pos");
// 				if(!_moving) then {
// 					// Start moving
// 					OOP_INFO_MSG("[w %1 a %2] Move %3 to %4@%5: started", [_world ARG _action ARG (_detachedGarr) ARG (_tgtGarr) ARG _tgtPos]);
// 					CALLM(_detachedGarr, "moveActual", [_tgtPos ARG _radius]);
// 					T_SETV("moving", true);
// 				} else {
// 					// Are we there yet?
// 					private _done = CALLM(_detachedGarr, "moveActualComplete", []);
// 					if(_done) then {
// 						private _detachedGarrPos = GETV(_detachedGarr, "pos");
// 						if((_detachedGarrPos distance _tgtPos) <= _radius * 1.5) then {
// 							OOP_INFO_MSG("[w %1 a %2] Move %3@%4 to %5@%6: complete, reached target within %7m", [_world ARG _action ARG LABEL(_detachedGarr) ARG _detachedGarrPos ARG LABEL(_tgtGarr) ARG _tgtPos ARG _radius]);
// 							_arrived = true;
// 						} else {
// 							// Move again cos we didn't get there yet!
// 							OOP_INFO_MSG("[w %1 a %2] Move %3@%4 to %5@%6: complete, didn't reach target within %7m, moving again", [_world ARG _action ARG LABEL(_detachedGarr) ARG _detachedGarrPos ARG LABEL(_tgtGarr) ARG _tgtPos ARG _radius]);
// 							T_SETV("moving", false);
// 						};
// 					};
// 				};
// 			};
// 		};
// 		_arrived
// 	} ENDMETHOD;
// ENDCLASS;