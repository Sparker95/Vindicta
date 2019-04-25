#include "..\common.hpp"

#define CMDR_ACTION_STATE_SPLIT 	CMDR_ACTION_STATE_CUSTOM+1

CLASS("ReinforceSplitGarrison", "ActionStateTransition")
	VARIABLE("action");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_action")];
		T_SETV("action", _action);
		T_SETV("fromStates", [CMDR_ACTION_STATE_START]);
		T_SETV("toState", CMDR_ACTION_STATE_SPLIT);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_PRVAR(action);
		private _srcGarrId = GETV(_action, "srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		//private _detachEff = CALLM(_action, "getDetachmentEff", [_world]);

		// Get the previously calculated efficiency
		private _detachEff = GETV(_action, "detachmentEff");

		ASSERT_MSG(EFF_GTE(_detachEff, EFF_MIN_EFF), "Detachment efficiency is below min allowed");

		// Apply split to all sim worlds as it always happens immediately at the start of action
		// TODO: we need to check if this actually works.
		// TODO: some kind of failure ability for actions in general.

		// Split can happen instantly so apply it to now and future sim worlds.
		private _detachedGarr = if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
									CALLM(_srcGarr, "splitSim", [_detachEff]+[[ASSIGN_TRANSPORT]+[FAIL_UNDER_EFF]])
								} else {
									CALLM(_srcGarr, "splitActual", [_detachEff]+[[ASSIGN_TRANSPORT]+[FAIL_UNDER_EFF]])
								};

		if(IS_NULL_OBJECT(_detachedGarr)) exitWith {
			OOP_WARNING_MSG("[w %1 a %2] Failed to detach from %3", [_world]+[_action]+[_srcGarr]);
			false
		};

		private _finalDetachEff = GETV(_detachedGarr, "efficiency");
		// We want this to be impossible. Sadly it seems it isn't :/
		ASSERT_MSG(EFF_GTE(_finalDetachEff, EFF_ZERO), "Final detachment efficiency is zero!");
		//ASSERT_MSG(EFF_GTE(_finalDetachEff, _detachEff), "Final detachment efficiency is below requested");

		// This shouldn't be possible and if it does happen then we would need to do something with the resultant understaffed garrison.
		// if(!EFF_GTE(_finalDetachEff, _detachEff)) exitWith {
		// 	OOP_DEBUG_MSG("[w %1 a %2] Failed to detach from %3", [_world]+[_action]+[_srcGarr]);
		// 	false
		// };

		OOP_INFO_MSG("[w %1 a %2] Detached %3 from %4", [_world]+[_action]+[_detachedGarr]+[_srcGarr]);

		// DOING: HOW TO FIX THIS? ASTS need to save state, sometimes they modify the Action. How to 
		// apply them to simworlds in this case without breaking action state for real world?
		// simCopy actions as well? Probably make sense.
		CALLM(_detachedGarr, "setAction", [_action]);
		SETV(_action, "detachedGarrId", GETV(_detachedGarr, "id"));
		true
	} ENDMETHOD;
ENDCLASS;

#define CMDR_ACTION_STATE_ARRIVED 	CMDR_ACTION_STATE_CUSTOM+2

// TODO: Split into Move and Retarget, see Docs\CmdrActions\TakeOrReinforce.dot.
// Need to handle target dying etc etc.
CLASS("MoveGarrison", "ActionStateTransition")
	VARIABLE("action");
	VARIABLE("moving");
	VARIABLE("radius");
	VARIABLE("noTarget");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_action"), P_NUMBER("_radius")];

		T_SETV("action", _action);
		T_SETV("moving", false);
		T_SETV("radius", _radius);
		T_SETV("noTarget", false);
		T_SETV("fromStates", [CMDR_ACTION_STATE_SPLIT]);
		T_SETV("toState", CMDR_ACTION_STATE_ARRIVED);
	} ENDMETHOD;

	METHOD("selectNewTarget") {
		params [P_THISOBJECT, P_STRING("_world")];

		T_PRVAR(action);

		private _srcGarrId = GETV(_action, "srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);

		// Prefer to go back to src garrison
		private _newTgtGarr = NULL_OBJECT;
		if(!CALLM(_srcGarr, "isDead", [])) then {
			_newTgtGarr = _srcGarr;
		} else {
			private _detachedGarrId = GETV(_action, "detachedGarrId");
			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
			ASSERT_OBJECT(_detachedGarr);

			private _pos = GETV(_detachedGarr, "pos");
			// select the nearest friendly garrison
			private _nearGarrs = CALLM(_world, "getNearestGarrisons", [_pos]+[4000]) select { !CALLM(_x, "isBusy", []) and (GETV(_x, "locationId") != MODEL_HANDLE_INVALID) };
			if(count _nearGarrs == 0) then {
				_nearGarrs = CALLM(_world, "getNearestGarrisons", [_pos]) select { !CALLM(_x, "isBusy", []) and (GETV(_x, "locationId") != MODEL_HANDLE_INVALID) };
			};
			if(count _nearGarrs > 0) then {
				_newTgtGarr = _nearGarrs#0;
			};
		};
		_newTgtGarr
	} ENDMETHOD;

	/* virtual */ METHOD("isAvailable") { 
		params [P_THISOBJECT, P_STRING("_world")];
		!T_GETV("noTarget")
	} ENDMETHOD;

	/* override */ METHOD("apply") { 
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_PRVAR(action);
		T_PRVAR(moving);
		T_PRVAR(radius);

		private _detachedGarrId = GETV(_action, "detachedGarrId");
		private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
		private _tgtGarrId = GETV(_action, "tgtGarrId");
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_detachedGarr);
		ASSERT_OBJECT(_tgtGarr);

		private _arrived = false;

		switch(GETV(_world, "type")) do {
			// Move can't be applied instantly
			case WORLD_TYPE_SIM_NOW: {};
			// Move completes at some point in the future
			case WORLD_TYPE_SIM_FUTURE: {
				private _tgtPos = GETV(_tgtGarr, "pos");
				CALLM(_detachedGarr, "moveSim", [_tgtPos]);
				_arrived = true;
			};
			case WORLD_TYPE_REAL: {
				// If target is dead then we better cancel move and pick a new one.
				if(CALLM(_tgtGarr, "isDead", [])) then {
					if(_moving) then
					{
						CALLM(_detachedGarr, "cancelMoveActual", []);
						_moving = false;
						T_SETV("moving", false);
					};
					private _newTgtGarr = T_CALLM("selectNewTarget", [_world]);
					if(IS_NULL_OBJECT(_newTgtGarr)) then {
						// TODO: Now what?
						// We just cancel the action for now. Maybe another action will pick up this garrison?
						T_SETV("noTarget", true);
					} else {
						OOP_INFO_MSG("[w %1 a %2] Target %3 is dead, picking %4 as a new target", [_world]+[_action]+[_tgtGarr]+[_newTgtGarr]);
						T_SETV("moving", false);
						private _newTgtGarrId = GETV(_newTgtGarr, "id");
						// Update the target Id in the action.
						SETV(_action, "tgtGarrId", _newTgtGarrId);
						_tgtGarr = _newTgtGarr;
					};
				};

				private _tgtPos = GETV(_tgtGarr, "pos");
				if(!_moving) then {
					// Start moving
					OOP_INFO_MSG("[w %1 a %2] Move %3 to %4@%5: started", [_world]+[_action]+[_detachedGarr]+[_tgtGarr]+[_tgtPos]);
					CALLM(_detachedGarr, "moveActual", [_tgtPos]+[_radius]);
					T_SETV("moving", true);
				} else {
					// Are we there yet?
					private _done = CALLM(_detachedGarr, "moveActualComplete", []);
					if(_done) then {
						private _detachedGarrPos = GETV(_detachedGarr, "pos");
						if((_detachedGarrPos distance _tgtPos) <= _radius * 1.5) then {
							OOP_INFO_MSG("[w %1 a %2] Move %3@%4 to %5@%6: complete, reached target within %7m", [_world]+[_action]+[_detachedGarr]+[_detachedGarrPos]+[_tgtGarr]+[_tgtPos]+[_radius]);
							_arrived = true;
						} else {
							// Move again cos we didn't get there yet!
							OOP_INFO_MSG("[w %1 a %2] Move %3@%4 to %5@%6: complete, didn't reach target within %7m, moving again", [_world]+[_action]+[_detachedGarr]+[_detachedGarrPos]+[_tgtGarr]+[_tgtPos]+[_radius]);
							T_SETV("moving", false);
						};
					};
				};
			};
		};
		_arrived
	} ENDMETHOD;
ENDCLASS;

CLASS("MergeGarrison", "ActionStateTransition")
	VARIABLE("action");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_action")];

		T_SETV("action", _action);
		T_SETV("fromStates", [CMDR_ACTION_STATE_ARRIVED]);
		T_SETV("toState", CMDR_ACTION_STATE_END);
	} ENDMETHOD;

	/* override */ METHOD("apply") { 
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_PRVAR(action);
		private _detachedGarrId = GETV(_action, "detachedGarrId");
		private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
		private _tgtGarrId = GETV(_action, "tgtGarrId");
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_detachedGarr);
		ASSERT_OBJECT(_tgtGarr);
		ASSERT_MSG(!CALLM(_detachedGarr, "isDead", []), "Garrison to merge from is dead");
		ASSERT_MSG(!CALLM(_tgtGarr, "isDead", []), "Garrison to merge to is dead");

		// Merge can happen instantly so apply it to now and future sim worlds.
		if(GETV(_world, "type") != WORLD_TYPE_REAL) then {
			CALLM(_detachedGarr, "mergeSim", [_tgtGarr]);
		} else {
			CALLM(_detachedGarr, "mergeActual", [_tgtGarr]);
			CALLM(_detachedGarr, "killed", []);
			private _rc = GETV(_action, "refCount");
			OOP_INFO_MSG("[w %1 a %2] After merged action has ref count %3", [_world]+[_action]+[_rc]);
		};
		OOP_INFO_MSG("[w %1 a %2] Merged %3 to %4", [_world]+[_action]+[_detachedGarr]+[_tgtGarr]);
		true
	} ENDMETHOD;
ENDCLASS;

CLASS("ReinforceCmdrAction", "CmdrAction")
	VARIABLE("srcGarrId");
	VARIABLE("tgtGarrId");
	VARIABLE("detachmentEff");
	VARIABLE("detachedGarrId");
	VARIABLE("pushedState");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtGarrId")];

		T_SETV("srcGarrId", _srcGarrId);
		T_SETV("tgtGarrId", _tgtGarrId);
		T_SETV("detachmentEff", EFF_ZERO);
		T_SETV("detachedGarrId", -1);

		private _transitions = [
			NEW("ReinforceSplitGarrison", [_thisObject]),
			NEW("MoveGarrison", [_thisObject]+[200]),
			NEW("MergeGarrison", [_thisObject])
		];
		T_SETV("transitions", _transitions);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		deleteMarker (_thisObject + "_line");
		deleteMarker (_thisObject + "_label");
	} ENDMETHOD;

	
	/* virtual */ METHOD("pushState") {
		params [P_THISOBJECT];
		T_PRVAR(detachedGarrId);
		T_SETV("pushedState", [_detachedGarrId]);
	} ENDMETHOD;
	
	/* virtual */ METHOD("popState") {
		params [P_THISOBJECT];
		T_PRVAR(pushedState);
		T_SETV("detachedGarrId", _pushedState select 0);
	} ENDMETHOD;

	/* override */ METHOD("getLabel") {
		params [P_THISOBJECT, P_STRING("_world")];

		T_PRVAR(srcGarrId);
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		private _srcAc = GETV(_srcGarr, "actual");
		private _srcEff = GETV(_srcGarr, "efficiency");
		T_PRVAR(tgtGarrId);
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		private _tgtAc = GETV(_tgtGarr, "actual");
		private _tgtEff = GETV(_tgtGarr, "efficiency");
		T_PRVAR(detachedGarrId);
		if(_detachedGarrId == -1) then {
			format ["reinf %1%2 -> %3%4", _srcAc, _srcEff, _tgtAc, _tgtEff]
		} else {
			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
			private _detachedAc = GETV(_detachedGarr, "actual");
			private _detachedEff = GETV(_detachedGarr, "efficiency");
			format ["reinf %1%2 -> %3%4 -> %5%6", _srcAc, _srcEff, _detachedAc, _detachedEff, _tgtAc, _tgtEff]
		};
	} ENDMETHOD;

	/* override */ METHOD("updateScore") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtGarrId);

		// TODO: do this properly wrt to now and future
		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtGarr = CALLM(_worldFuture, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);

		// Resource is how much src is *over* composition, scaled by distance (further is lower)
		// i.e. How much units/vehicles src can spare.
		private _detachEff = T_CALLM("getDetachmentEff", [_worldNow]+[_worldFuture]);
		// Save the calculation for use if we decide to perform the action 
		// We DON'T want to try and recalculate the detachment against the real world state when the action actually runs because
		// it won't be correctly taking into account our knowledge about other actions (as represented in the sim world models)
		T_SETV("detachmentEff", _detachEff);

		//CALLM1(_worldNow, "getOverDesiredEff", _srcGarr);
		private _detachEffStrength = EFF_SUB_SUM(EFF_DEF_SUB(_detachEff));

		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _tgtGarrPos = GETV(_tgtGarr, "pos");

		private _distCoeff = CALLSM("CmdrAction", "calcDistanceFalloff", [_srcGarrPos]+[_tgtGarrPos]);

		private _scoreResource = _detachEffStrength * _distCoeff;

		// TODO:OPT cache these scores!
		private _scorePriority = if(_scoreResource == 0) then {0} else {CALLM(_worldFuture, "getReinforceRequiredScore", [_tgtGarr])};

		//private _str = format ["%1->%2 _scorePriority = %3, _srcOverEff = %4, _srcOverEffScore = %5, _distCoeff = %6, _scoreResource = %7", _srcGarrId, _tgtGarrId, _scorePriority, _srcOverEff, _srcOverEffScore, _distCoeff, _scoreResource];
		//OOP_INFO_0(_str);
		// if(_scorePriority > 0 and _scoreResource > 0) then {
		private _srcEff = GETV(_srcGarr, "efficiency");
		private _tgtEff = GETV(_tgtGarr, "efficiency");

		//OOP_DEBUG_MSG("[w %1 a %2] %3%10 reinforce %4%11 Score [p %5, r %6] _detachEff = %7, _detachEffStrength = %8, _distCoeff = %9", [_worldNow]+[_thisObject]+[_srcGarr]+[_tgtGarr]+[_scorePriority]+[_scoreResource]+[_detachEff]+[_detachEffStrength]+[_distCoeff]+[_srcEff]+[_tgtEff]);

		// };
		T_SETV("scorePriority", _scorePriority);
		T_SETV("scoreResource", _scoreResource);
	} ENDMETHOD;

	// Get composition of reinforcements we should send from src to tgt. 
	// This is the min of what src has spare and what tgt wants.
	// TODO: factor out logic for working out detachments for various situations
	METHOD("getDetachmentEff") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtGarrId);

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtGarr = CALLM(_worldFuture, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);

		// How much resources src can spare.
		private _srcOverEff = EFF_MAX_SCALAR(CALLM(_worldNow, "getOverDesiredEff", [_srcGarr]), 0);
		// How much resources tgt needs
		private _tgtUnderEff = EFF_MAX_SCALAR(EFF_MUL_SCALAR(CALLM(_worldFuture, "getOverDesiredEff", [_tgtGarr]), -1), 0);

		// Min of those values
		// TODO: make this a "nice" composition. We don't want to send a bunch of guys to walk or whatever.
		private _effAvailable = EFF_MAX_SCALAR(EFF_FLOOR(EFF_MIN(_srcOverEff, _tgtUnderEff)), 0);

		// OOP_DEBUG_MSG("[w %1 a %2] %3 reinforce %4 getDetachmentEff: _tgtUnderEff = %5, _srcOverEff = %6, _effAvailable = %7", [_worldNow]+[_thisObject]+[_srcGarr]+[_tgtGarr]+[_tgtUnderEff]+[_srcOverEff]+[_effAvailable]);

		// Only send a reasonable amount at a time
		// TODO: min compositions should be different for detachments and garrisons holding outposts.
		if(!EFF_GTE(_effAvailable, EFF_MIN_EFF)) exitWith { EFF_ZERO };

		//if(_effAvailable#0 < MIN_COMP#0 or _effAvailable#1 < MIN_COMP#1) exitWith { [0,0] };
		_effAvailable
	} ENDMETHOD;

	/* override */ METHOD("debugDraw") {
		params [P_THISOBJECT, P_STRING("_world")];

		T_PRVAR(srcGarrId);
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _srcGarrPos = GETV(_srcGarr, "pos");

		T_PRVAR(tgtGarrId);
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);
		private _tgtGarrPos = GETV(_tgtGarr, "pos");

		[_srcGarrPos, _tgtGarrPos, "ColorBlack", 5, _thisObject + "_line"] call misc_fnc_mapDrawLine;

		private _mrk = createmarker [_thisObject + "_label", _srcGarrPos];
		_mrk setMarkerType "mil_objective";
		_mrk setMarkerColor "ColorWhite";
		_mrk setMarkerAlpha 1;
		_mrk setMarkerText T_CALLM("getLabel", [_world]);
	} ENDMETHOD;

ENDCLASS;
