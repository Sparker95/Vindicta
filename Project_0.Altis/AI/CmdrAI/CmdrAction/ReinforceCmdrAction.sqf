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

		T_PRVAR(action);
		private _srcGarrId = GETV(_action, "srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		private _detachEff = CALLM(_action, "getDetachmentEff", [_world]);

		private _detachedGarr = if(GETV(_world, "_isSim")) then {
									CALLM(_srcGarr, "splitSim", [_detachEff])
								} else {
									CALLM(_srcGarr, "splitActual", [_detachEff])
								};
		if(!(_detachedGarr isEqualType "")) exitWith {
			false
		};
		SETV(_action, "detachedGarrId", GETV(_detachedGarr, "id"));
		true
	} ENDMETHOD;
ENDCLASS;

#define CMDR_ACTION_STATE_MOVING 	CMDR_ACTION_STATE_CUSTOM+2

CLASS("MoveGarrison", "ActionStateTransition")
	VARIABLE("action");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_action")];
		T_SETV("action", _action);
		T_SETV("fromStates", [CMDR_ACTION_STATE_SPLIT]);
		T_SETV("toState", CMDR_ACTION_STATE_MOVING);
	} ENDMETHOD;

	/* override */ METHOD("apply") { 
		params [P_THISOBJECT, P_STRING("_world")];

		T_PRVAR(action);
		private _detachedGarrId = GETV(_action, "detachedGarrId");
		private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
		CALLM(_detachedGarr, );

		private _detachedGarr = if(GETV(_world, "_isSim")) then {
									CALLM(_srcGarr, "splitSim", [_detachEff])
								} else {
									CALLM(_srcGarr, "splitActual", [_detachEff])
								};
		if(!(_detachedGarr isEqualType "")) exitWith {
			false
		};
		SETV(_action, "detachedGarrId", GETV(_detachedGarr, "id"));
		true
	} ENDMETHOD;
ENDCLASS;

CLASS("ReinforceAction", "CmdrAction")
	VARIABLE("srcGarrId");
	VARIABLE("tgtGarrId");
	VARIABLE("detachedGarrId");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtGarrId")];

		T_SETV("srcGarrId", _srcGarrId);
		T_SETV("tgtGarrId", _tgtGarrId);
		T_SETV("detachedGarrId", -1);

		private _asts = [
			NEW("ReinforceSplitGarrison", [_thisObject])
		];

	} ENDMETHOD;

	METHOD("getLabel") {
		params [P_THISOBJECT];
		T_PRVAR(tgtGarrId);
		T_PRVAR(stage);
		format ["reinf o%1 - %2", _tgtGarrId, _stage]
	} ENDMETHOD;

	METHOD("updateScore") {
		params [P_THISOBJECT, P_STRING("_world")];

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtGarrId);

		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);

		// TODO:OPT cache these scores!
		private _scorePriority = CALLM(_world, "getReinforceRequiredScore", [_tgtGarr]);

		// Resource is how much src is *over* composition, scaled by distance (further is lower)
		// i.e. How much units/vehicles src can spare.
		private _detachEff = T_CALLM("getDetachmentEff", [_world]);
		//CALLM1(_world, "getOverDesiredEff", _srcGarr);
		private _detachEffStrength = EFF_SUB_SUM(EFF_DEF_SUB(_detachEff));

		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _tgtGarrPos = GETV(_tgtGarr, "pos");

		private _distCoeff = CALLSM("Action", "calcDistanceFalloff", [_srcGarrPos]+[_tgtGarrPos]);

		private _scoreResource = _detachEffStrength * _distCoeff;
		// private _str = format ["%1->%2 _scorePriority = %3, _srcOverEff = %4, _srcOverEffScore = %5, _distCoeff = %6, _scoreResource = %7", _srcGarrId, _tgtGarrId, _scorePriority, _srcOverEff, _srcOverEffScore, _distCoeff, _scoreResource];
		// OOP_INFO_0(_str);

		T_SETV("scorePriority", _scorePriority);
		T_SETV("scoreResource", _scoreResource);
	} ENDMETHOD;

	// METHOD("applyToSim") {
	// 	params [P_THISOBJECT, P_STRING("_world")];

	// 	T_PRVAR(complete);
	// 	if(_complete) exitWith {
	// 		OOP_WARNING_0("applyToSim after action is complete");
	// 	};

	// 	T_PRVAR(srcGarrId);
	// 	T_PRVAR(tgtGarrId);
	// 	private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
	// 	private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);

	// 	T_PRVAR(stage);

	// 	// If we didn't start the action yet then we need to subtract from srcGarr
	// 	if(_stage == "new") then {
	// 		private _sentEff = T_CALLM1("getDetachmentEff", _world);
	// 		private _negSentEff = _sentEff apply { _x * -1 };
	// 		// Remove from source garrison
	// 		CALLM1(_srcGarr, "modComp", _negSentComp);
	// 		// Add to target garrison
	// 		CALLM1(_tgtGarr, "modComp", _sentEff);
	// 	} else {
	// 		T_PRVAR(detachedGarrId);

	// 		private _detachedGarr = CALLM1(_world, "getGarrison", _detachedGarrId);
	// 		CALLM1(_tgtGarr, "mergeGarrison", _detachedGarr);
	// 	};
	// } ENDMETHOD;

	// Get composition of reinforcements we should send from src to tgt. 
	// This is the min of what src has spare and what tgt wants.
	// TODO: factor out logic for working out detachments for various situations
	METHOD("getDetachmentEff") {
		params [P_THISOBJECT, P_STRING("_world")];
		T_PRVAR(srcGarrId);
		T_PRVAR(tgtGarrId);

		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);

		// How much resources tgt needs
		private _tgtUnderEff = EFF_MAX_SCALAR(EFF_MUL_SCALAR(CALLM(_world, "getOverDesiredEff", [_tgtGarr]), -1), 0);
		// How much resources src can spare.
		private _srcOverEff = EFF_MAX_SCALAR(CALLM(_world, "getOverDesiredEff", [_srcGarr]), 0);

		// Min of those values
		// TODO: make this a "nice" composition. We don't want to send a bunch of guys to walk or whatever.
		private _compAvailable = EFF_MAX_SCALAR(EFF_FLOOR(EFF_MIN(_srcOverEff, _tgtUnderEff)), 0);

		// Only send a reasonable amount at a time
		// TODO: min compositions should be different for detachments and garrisons holding outposts.
		if(EFF_SUM(EFF_MIN_SCALAR(EFF_DIFF(_compAvailable, EFF_MIN_EFF), 0)) < 0) exitWith { EFF_ZERO };

		//if(_compAvailable#0 < MIN_COMP#0 or _compAvailable#1 < MIN_COMP#1) exitWith { [0,0] };
		_compAvailable
	} ENDMETHOD;

	// METHOD("update") {
	// 	params [P_THISOBJECT, P_STRING("_world")];

	// 	T_PRVAR(complete);
	// 	if(_complete) exitWith {
	// 		OOP_WARNING_0("update after action is complete");
	// 	};

	// 	T_PRVAR(srcGarrId);
	// 	T_PRVAR(tgtGarrId);

	// 	private _srcGarr = CALLM1(_world, "getGarrison", _srcGarrId);
	// 	private _tgtGarr = CALLM1(_world, "getGarrison", _tgtGarrId);

	// 	T_PRVAR(stage);

	// 	switch(_stage) do {
	// 		case "new": {
	// 			OOP_INFO_2("ReinforceAction g%1->g%2 starting", _srcGarrId, _tgtGarrId);

	// 			// We only care about the source garrison being dead at this point, after this 
	// 			// detachment has already left.
	// 			// TODO: use actual intel to determine if/when target is dead.
	// 			if(CALLM0(_srcGarr, "isDead")) exitWith {
	// 				T_SETV("complete", true);
	// 				OOP_INFO_2("ReinforceAction g%1->g%2 completed: g%1 died", _srcGarrId, _tgtGarrId);
	// 			};

	// 			if(CALLM0(_tgtGarr, "isDead")) exitWith {
	// 				// TODO: What do if target garrison is dead? Should still go there probably?
	// 				// Maybe fall back and wait? Return to origin?
	// 				// Probably we want to abort this action and just let commander decide what to 
	// 				// do with a floating free garrison.
	// 				T_SETV("complete", true);
	// 				OOP_INFO_2("ReinforceAction g%1->g%2 completed: g%2 died", _srcGarrId, _tgtGarrId);
	// 			};

	// 			// We didn't split the source garrison yet, so do it now.
	// 			private _detachedEff = T_CALLM1("getDetachmentEff", _world);
	// 			if(_detachedEff#0 == 0 and _detachedEff#1 == 0) exitWith {
	// 				T_SETV("complete", true);
	// 				OOP_INFO_2("ReinforceAction g%1->g%2 completed: detachment comp was empty", _srcGarrId, _tgtGarrId);
	// 			};
	// 			private _detachedGarr = CALLM1(_srcGarr, "splitGarrison", _detachedEff);
	// 			private _detachedGarrId = CALLM1(_world, "addGarrison", _detachedGarr);
	// 			T_SETV("detachedGarrId", _detachedGarrId);

	// 			// Assign action to the detached garrison.
	// 			CALLM1(_detachedGarr, "setAction", _thisObject);

	// 			// Next stage
	// 			T_SETV("stage", "moving");

	// 			OOP_INFO_4("ReinforceAction g%1->g%2 sending g%3 %4", _srcGarrId, _tgtGarrId, _detachedGarrId, _detachedEff);
	// 		};
	// 		case "moving": {
	// 			T_PRVAR(detachedGarrId);

	// 			private _detachedGarr = CALLM1(_world, "getGarrison", _detachedGarrId);
	// 			private _detachedPos = CALLM0(_detachedGarr, "getPos");
	// 			//OOP_INFO_4("ReinforceAction g%1->g%3->g%2 pos: g%4", _srcGarrId, _tgtGarrId, _detachedGarrId, _detachedPos);
	// 			if(CALLM0(_detachedGarr, "isDead")) exitWith {
	// 				CALLM0(_detachedGarr, "clearAction");
	// 				T_SETV("complete", true);
	// 				OOP_INFO_3("ReinforceAction g%1->g%3->g%2 completed: g%3 died", _srcGarrId, _tgtGarrId, _detachedGarrId);
	// 			};

	// 			// If target is dead then rtb
	// 			if(CALLM0(_tgtGarr, "isDead")) exitWith {
	// 				// TODO: What do if target garrison is dead? Should still go there probably?
	// 				// Maybe fall back and wait? Return to origin?
	// 				// Probably we want to abort this action and just let commander decide what to 
	// 				// do with a floating free garrison.

	// 				// RTB
	// 				//CALLM0(_detachedGarr, "cancelOrder");
	// 				// Give another move order as we didn't reach target yet.
	// 				private _targetPos = CALLM0(_srcGarr, "getPos");
	// 				private _args = [ format["g%1 rtb to g%2", _detachedGarr, _srcGarrId], _detachedGarrId, _targetPos];
	// 				private _moveOrder = NEW("MoveOrder", _args);
	// 				CALLM1(_detachedGarr, "giveOrder", _moveOrder);
	// 				// Set target to source
	// 				T_SETV("tgtGarrId", _srcGarrId);
	// 				OOP_INFO_3("ReinforceAction g%1->g%3->g%2 rtb: g%2 already dead", _srcGarrId, _tgtGarrId, _detachedGarrId);
	// 			};

	// 			if(CALLM0(_detachedGarr, "isOrderEfflete")) then {
	// 				OOP_INFO_3("ReinforceAction g%1->g%3->g%2 move order completed", _srcGarrId, _tgtGarrId, _detachedGarrId);
					
	// 				private _targetPos = CALLM0(_tgtGarr, "getPos");
	// 				private _dist = _detachedPos distance _targetPos;
	// 				OOP_INFO_4("ReinforceAction g%1->g%3->g%2 dist: %4", _srcGarrId, _tgtGarrId, _detachedGarrId, _dist);
	// 				// If we reached the target then merge the garrisons
	// 				if(_dist < 100) then {
	// 					OOP_INFO_3("ReinforceAction g%1->g%3->g%2 merging g%3 to target", _srcGarrId, _tgtGarrId, _detachedGarrId);
	// 					CALLM1(_tgtGarr, "mergeGarrison", _detachedGarr);
	// 					CALLM0(_detachedGarr, "clearAction");
	// 					T_SETV("complete", true);
	// 				} else {
	// 					OOP_INFO_3("ReinforceAction g%1->g%3->g%2 moving g%3 to target", _srcGarrId, _tgtGarrId, _detachedGarr);

	// 					// Give another move order as we didn't reach target yet.
	// 					private _args = [ format["g%1 reinforcing g%2", _detachedGarrId, _tgtGarrId], _detachedGarrId, _targetPos];
	// 					private _moveOrder = NEW("MoveOrder", _args);
	// 					CALLM1(_detachedGarr, "giveOrder", _moveOrder);
	// 				};
	// 			};
	// 		};
	// 	};
	// } ENDMETHOD;
ENDCLASS;
