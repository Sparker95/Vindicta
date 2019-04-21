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
		private _detachEff = CALLM(_action, "getDetachmentEff", [_world]);

		private _detachedGarr = if(GETV(_world, "isSim")) then {
									CALLM(_srcGarr, "splitSim", [_detachEff])
								} else {
									CALLM(_srcGarr, "splitActual", [_detachEff])
								};
		if(IS_NULL_OBJECT(_detachedGarr)) exitWith {
			OOP_DEBUG_MSG("[w %1 a %2] Failed to detach from %3", [_world]+[_action]+[_srcGarr]);
			false
		};
		OOP_DEBUG_MSG("[w %1 a %2] Detached %3 from %4", [_world]+[_action]+[_detachedGarr]+[_srcGarr]);

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

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_action"), P_NUMBER("_radius")];

		T_SETV("action", _action);
		T_SETV("moving", false);
		T_SETV("radius", _radius);
		T_SETV("fromStates", [CMDR_ACTION_STATE_SPLIT]);
		T_SETV("toState", CMDR_ACTION_STATE_ARRIVED);
	} ENDMETHOD;

	/* override */ METHOD("apply") { 
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_PRVAR(action);
		T_PRVAR(moving);
		T_PRVAR(radius);

		private _detachedGarrId = GETV(_action, "detachedGarrId");
		private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
		ASSERT_OBJECT(_detachedGarr);
		private _tgtGarrId = GETV(_action, "tgtGarrId");
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);

		private _isSim = GETV(_world, "isSim");
		private _tgtPos = GETV(_tgtGarr, "pos");
		private _arrived = false;
		if(_isSim) then {
			CALLM(_detachedGarr, "moveSim", [_tgtPos]);
			_arrived = true;
		} else {
			if(!_moving) then {
				// Start moving
				OOP_DEBUG_MSG("[w %1 a %2] Move %3 to %4 @%5: started", [_world]+[_action]+[_detachedGarr]+[_tgtGarr]+[_tgtPos]);
				CALLM(_detachedGarr, "moveActual", [_tgtPos]+[_radius]);
				T_SETV("moving", true);
			} else {
				// Are we there yet?
				private _done = CALLM(_detachedGarr, "moveActualComplete", []);
				if(_done) then {
					private _detachedGarrPos = GETV(_detachedGarr, "pos");
					if((_detachedGarrPos distance _tgtPos) <= _radius * 1.5) then {
						OOP_DEBUG_MSG("[w %1 a %2] Move %3@%4 to %5@%6: complete, reached target within %7m", [_world]+[_action]+[_detachedGarr]+[_detachedGarrPos]+[_tgtGarr]+[_tgtPos]+[_radius]);
						_arrived = true;
					} else {
						// Move again cos we didn't get there yet!
						OOP_DEBUG_MSG("[w %1 a %2] Move %3@%4 to %5@%6: complete, didn't reach target within %7m, moving again", [_world]+[_action]+[_detachedGarr]+[_detachedGarrPos]+[_tgtGarr]+[_tgtPos]+[_radius]);
						T_SETV("moving", false);
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
		ASSERT_OBJECT(_detachedGarr);
		private _tgtGarrId = GETV(_action, "tgtGarrId");
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);

		if(GETV(_world, "isSim")) then {
			CALLM(_detachedGarr, "mergeSim", [_tgtGarr]);
		} else {
			CALLM(_detachedGarr, "mergeActual", [_tgtGarr]);
		};
		OOP_DEBUG_MSG("[w %1 a %2] Merged %3 to %4", [_world]+[_action]+[_detachedGarr]+[_tgtGarr]);
		true
	} ENDMETHOD;
ENDCLASS;

CLASS("ReinforceCmdrAction", "CmdrAction")
	VARIABLE("srcGarrId");
	VARIABLE("tgtGarrId");
	VARIABLE("detachedGarrId");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtGarrId")];

		T_SETV("srcGarrId", _srcGarrId);
		T_SETV("tgtGarrId", _tgtGarrId);
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
		deleteMarkerLocal _thisObject + "_line";
		deleteMarkerLocal _thisObject + "_label";
	} ENDMETHOD;

	/* override */ METHOD("getLabel") {
		params [P_THISOBJECT];


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
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtGarrId);

		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);

		// Resource is how much src is *over* composition, scaled by distance (further is lower)
		// i.e. How much units/vehicles src can spare.
		private _detachEff = T_CALLM("getDetachmentEff", [_world]);
		//CALLM1(_world, "getOverDesiredEff", _srcGarr);
		private _detachEffStrength = EFF_SUB_SUM(EFF_DEF_SUB(_detachEff));

		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _tgtGarrPos = GETV(_tgtGarr, "pos");

		private _distCoeff = CALLSM("CmdrAction", "calcDistanceFalloff", [_srcGarrPos]+[_tgtGarrPos]);

		private _scoreResource = _detachEffStrength * _distCoeff;

		// TODO:OPT cache these scores!
		private _scorePriority = if(_scoreResource == 0) then {0} else {CALLM(_world, "getReinforceRequiredScore", [_tgtGarr])};

		//private _str = format ["%1->%2 _scorePriority = %3, _srcOverEff = %4, _srcOverEffScore = %5, _distCoeff = %6, _scoreResource = %7", _srcGarrId, _tgtGarrId, _scorePriority, _srcOverEff, _srcOverEffScore, _distCoeff, _scoreResource];
		//OOP_INFO_0(_str);
		// if(_scorePriority > 0 and _scoreResource > 0) then {
		private _srcEff = GETV(_srcGarr, "efficiency");
		private _tgtEff = GETV(_tgtGarr, "efficiency");

		OOP_DEBUG_MSG("[w %1 a %2] %3%10 reinforce %4%11 Score [p %5, r %6] _detachEff = %7, _detachEffStrength = %8, _distCoeff = %9", [_world]+[_thisObject]+[_srcGarr]+[_tgtGarr]+[_scorePriority]+[_scoreResource]+[_detachEff]+[_detachEffStrength]+[_distCoeff]+[_srcEff]+[_tgtEff]);

		// };
		T_SETV("scorePriority", _scorePriority);
		T_SETV("scoreResource", _scoreResource);
	} ENDMETHOD;

	// Get composition of reinforcements we should send from src to tgt. 
	// This is the min of what src has spare and what tgt wants.
	// TODO: factor out logic for working out detachments for various situations
	METHOD("getDetachmentEff") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtGarrId);

		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);

		// How much resources tgt needs
		private _tgtUnderEff = EFF_MAX_SCALAR(EFF_MUL_SCALAR(CALLM(_world, "getOverDesiredEff", [_tgtGarr]), -1), 0);
		// How much resources src can spare.
		private _srcOverEff = EFF_MAX_SCALAR(CALLM(_world, "getOverDesiredEff", [_srcGarr]), 0);

		// Min of those values
		// TODO: make this a "nice" composition. We don't want to send a bunch of guys to walk or whatever.
		private _compAvailable = EFF_MAX_SCALAR(EFF_FLOOR(EFF_MIN(_srcOverEff, _tgtUnderEff)), 0);

		OOP_DEBUG_MSG("[w %1 a %2] %3 reinforce %4 getDetachmentEff: _tgtUnderEff = %5, _srcOverEff = %6, _compAvailable = %7", [_world]+[_thisObject]+[_srcGarr]+[_tgtGarr]+[_tgtUnderEff]+[_srcOverEff]+[_compAvailable]);

		// Only send a reasonable amount at a time
		// TODO: min compositions should be different for detachments and garrisons holding outposts.
		if(!EFF_GTE(_compAvailable, EFF_MIN_EFF)) exitWith { EFF_ZERO };

		//if(_compAvailable#0 < MIN_COMP#0 or _compAvailable#1 < MIN_COMP#1) exitWith { [0,0] };
		_compAvailable
	} ENDMETHOD;

	/* override */ METHOD("debugDraw") {
		params [P_THISOBJECT];

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
		_mrk setMarkerText T_CALLM("getLabel", []);
	} ENDMETHOD;

ENDCLASS;
