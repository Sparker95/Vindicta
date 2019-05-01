#include "..\common.hpp"

#define CMDR_ACTION_STATE_SPLIT				(CMDR_ACTION_STATE_CUSTOM+1)
#define CMDR_ACTION_STATE_READY_TO_MOVE		(CMDR_ACTION_STATE_CUSTOM+2)
#define CMDR_ACTION_STATE_MOVED				(CMDR_ACTION_STATE_CUSTOM+3)
#define CMDR_ACTION_STATE_TARGET_DEAD		(CMDR_ACTION_STATE_CUSTOM+4)
#define CMDR_ACTION_STATE_ARRIVED 			(CMDR_ACTION_STATE_CUSTOM+5)

// Reads the position of a garrison into a position variable for use in other commands
CLASS("AST_SelectNewTarget", "ActionStateTransition")
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

CLASS("ReinforceCmdrAction", "CmdrAction")
	VARIABLE("srcGarrId");
	VARIABLE("tgtGarrId");
	VARIABLE("targetVar");
	VARIABLE("detachmentEffVar");
	VARIABLE("detachedGarrIdVar");

	VARIABLE("pushedState");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtGarrId")];

		T_SETV("srcGarrId", _srcGarrId);
		T_SETV("tgtGarrId", _tgtGarrId);
		
		// Call MAKE_AST_VAR directly because we don't won't the CmdrAction to automatically push and pop this value 
		// (it is a constant for this action so it doesn't need to be saved and restored)
		private _srcGarrIdVar = MAKE_AST_VAR(_srcGarrId);

		// Desired detachment efficiency changes when updateScore is called. This shouldn't happen once the action
		// has been started, but this constructor is called before that point.
		private _detachmentEffVar = MAKE_AST_VAR(EFF_ZERO); //T_CALLM("createVariable", EFF_ZERO);
		T_SETV("detachmentEffVar", _detachmentEffVar);

		// Split garrison Id is set by the split AST, so we want it to be saved and restored when simulation is run
		// (so the real value isn't affected by simulation runs, see CmdrAction.applyToSim for details).
		private _splitGarrIdVar = T_CALLM("createVariable", [-1]);
		T_SETV("detachedGarrIdVar", _splitGarrIdVar);

		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		private _targetVar = T_CALLM("createVariable", [[TARGET_TYPE_GARRISON]+[_tgtGarrId]]);
		T_SETV("targetVar", _targetVar);

		private _splitAST_Args = [
				_thisObject,						// This action (for debugging context)
				[CMDR_ACTION_STATE_START], 			// First action we do
				CMDR_ACTION_STATE_SPLIT, 			// State change if successful
				CMDR_ACTION_STATE_END, 				// State change if failed (go straight to end of action)
				_srcGarrIdVar, 						// Garrison to split (constant)
				_detachmentEffVar, 					// Efficiency we want the detachment to have (constant)
				MAKE_AST_VAR([ASSIGN_TRANSPORT]+[FAIL_UNDER_EFF]), // Flags for split operation
				_splitGarrIdVar]; 					// variable to recieve Id of the garrison after it is split
		private _splitAST = NEW("AST_SplitGarrison", _splitAST_Args);

		private _assignAST_Args = [
				_thisObject, 						// This action, gets assigned to the garrison
				[CMDR_ACTION_STATE_SPLIT], 			// Do this after splitting
				CMDR_ACTION_STATE_READY_TO_MOVE, 	// State change when successful (can't fail)
				_splitGarrIdVar]; 					// Id of garrison to assign the action to
		private _assignAST = NEW("AST_AssignActionToGarrison", _assignAST_Args);

		private _moveAST_Args = [
				_thisObject, 						// This action (for debugging context)
				[CMDR_ACTION_STATE_READY_TO_MOVE], 		
				CMDR_ACTION_STATE_MOVED, 			// State change when successful
				CMDR_ACTION_STATE_END,				// State change when garrison is dead (just terminate the action)
				CMDR_ACTION_STATE_TARGET_DEAD, 		// State change when target is dead
				_splitGarrIdVar, 					// Id of garrison to move
				_targetVar, 						// Target to move to (initially the target garrison)
				MAKE_AST_VAR(200)]; 				// Radius to move within
		private _moveAST = NEW("AST_MoveGarrison", _moveAST_Args);

		private _mergeAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_MOVED], 			// Merge once we reach the destination (whatever it is)
				CMDR_ACTION_STATE_END, 				// Once merged we are done
				CMDR_ACTION_STATE_END, 				// If the detachment is dead then we can just end the action
				CMDR_ACTION_STATE_TARGET_DEAD, 		// If the target is dead then reselect a new target
				_splitGarrIdVar, 					// Id of the garrison we are merging
				_targetVar]; 						// Target to merge to (garrison or location is valid)
		private _mergeAST = NEW("AST_MergeOrJoinTarget", _mergeAST_Args);

		private _newTargetAST_Args = [
				[CMDR_ACTION_STATE_TARGET_DEAD], 	// We select a new target when the old one is dead
				CMDR_ACTION_STATE_READY_TO_MOVE, 	// State change when successful
				_srcGarrIdVar, 						// Id of the garrison we are moving (for context)
				_splitGarrIdVar, 					// Originating garrison (default we return to)
				_targetVar]; 						// New target
		private _newTargetAST = NEW("AST_SelectNewTarget", _newTargetAST_Args);

		private _transitions = [_splitAST, _assignAST, _moveAST, _mergeAST, _newTargetAST];
		T_SETV("transitions", _transitions);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		deleteMarker (_thisObject + "_line");
		deleteMarker (_thisObject + "_label");
	} ENDMETHOD;

	/* override */ METHOD("getLabel") {
		params [P_THISOBJECT, P_STRING("_world")];

		T_PRVAR(srcGarrId);
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		//private _srcAc = GETV(_srcGarr, "actual");
		private _srcEff = GETV(_srcGarr, "efficiency");

		//T_GET_AST_VAR("targetVar") params ["_targetType", "_target"];

		private _targetName = [_world, T_GET_AST_VAR("targetVar")] call Target_fnc_GetLabel;
		// "unknown";
		// switch(_targetType) do {
		// 	case TARGET_TYPE_GARRISON: {
		// 		ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_GARRISON target type expects a garrison ID");
		// 		private _garr = CALLM(_world, "getGarrison", [_target]);
		// 		ASSERT_OBJECT(_garr);
		// 		_targetName = LABEL(_garr) + str GETV(_tgtGarr, "efficiency");
		// 	};
		// 	case TARGET_TYPE_LOCATION: {
		// 		ASSERT_MSG(_target isEqualType 0, "TARGET_TYPE_LOCATION target type expects a location ID");
		// 		private _loc = CALLM(_world, "getLocation", [_target]);
		// 		ASSERT_OBJECT(_loc);
		// 		_targetName = LABEL(_loc);
		// 	};
		// 	case TARGET_TYPE_POSITION: {
		// 		ASSERT_MSG(_target isEqualType [], "TARGET_TYPE_POSITION target type expects a position [x,y,z]");
		// 		_targetName = str(_target);
		// 	};
		// 	default {
		// 		FAILURE("Target is not valid");
		// 	};
		// };
		private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		if(_detachedGarrId == -1) then {
			format ["reinf %1%2 -> %3", LABEL(_srcGarr), _srcEff, _targetName]
		} else {
			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
			//private _detachedAc = GETV(_detachedGarr, "actual");
			private _detachedEff = GETV(_detachedGarr, "efficiency");
			format ["reinf %1%2 -> %3%4 -> %5", LABEL(_srcGarr), _srcEff, LABEL(_detachedGarr), _detachedEff, _targetName]
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
		private _detachEff = T_CALLM("getDetachmentEff", [_worldNow ARG _worldFuture]);
		// Save the calculation for use if we decide to perform the action 
		// We DON'T want to try and recalculate the detachment against the real world state when the action actually runs because
		// it won't be correctly taking into account our knowledge about other actions (as represented in the sim world models)
		T_SET_AST_VAR("detachmentEffVar", _detachEff);

		//CALLM1(_worldNow, "getOverDesiredEff", _srcGarr);
		private _detachEffStrength = EFF_SUB_SUM(EFF_DEF_SUB(_detachEff));

		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _tgtGarrPos = GETV(_tgtGarr, "pos");

		private _distCoeff = CALLSM("CmdrAction", "calcDistanceFalloff", [_srcGarrPos ARG _tgtGarrPos]);

		private _scoreResource = _detachEffStrength * _distCoeff;

		// TODO:OPT cache these scores!
		private _scorePriority = if(_scoreResource == 0) then {0} else {CALLM(_worldFuture, "getReinforceRequiredScore", [_tgtGarr])};

		//private _str = format ["%1->%2 _scorePriority = %3, _srcOverEff = %4, _srcOverEffScore = %5, _distCoeff = %6, _scoreResource = %7", _srcGarrId, _tgtGarrId, _scorePriority, _srcOverEff, _srcOverEffScore, _distCoeff, _scoreResource];
		//OOP_INFO_0(_str);
		// if(_scorePriority > 0 and _scoreResource > 0) then {
		private _srcEff = GETV(_srcGarr, "efficiency");
		private _tgtEff = GETV(_tgtGarr, "efficiency");

		//OOP_DEBUG_MSG("[w %1 a %2] %3%10 reinforce %4%11 Score [p %5, r %6] _detachEff = %7, _detachEffStrength = %8, _distCoeff = %9", [_worldNow ARG _thisObject ARG _srcGarr ARG _tgtGarr ARG _scorePriority ARG _scoreResource ARG _detachEff ARG _detachEffStrength ARG _distCoeff ARG _srcEff ARG _tgtEff]);

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

		// OOP_DEBUG_MSG("[w %1 a %2] %3 reinforce %4 getDetachmentEff: _tgtUnderEff = %5, _srcOverEff = %6, _effAvailable = %7", [_worldNow ARG _thisObject ARG _srcGarr ARG _tgtGarr ARG _tgtUnderEff ARG _srcOverEff ARG _effAvailable]);

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

		private _targetPos = [_world, T_GET_AST_VAR("target")] call Target_fnc_GetPos;
		// T_PRVAR(tgtGarrId);
		// private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		// ASSERT_OBJECT(_tgtGarr);
		// private _tgtGarrPos = GETV(_tgtGarr, "pos");

		[_srcGarrPos, _targetPos, "ColorBlack", 8, _thisObject + "_line"] call misc_fnc_mapDrawLine;

		private _centerPos = _srcGarrPos vectorAdd ((_targetPos vectorDiff _srcGarrPos) apply { _x * 0.5 });
		private _mrk = createmarker [_thisObject + "_label", _centerPos];
		_mrk setMarkerType "mil_objective";
		_mrk setMarkerColor "ColorWhite";
		_mrk setMarkerAlpha 1;
		_mrk setMarkerText T_CALLM("getLabel", [_world]);

		private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		if(_detachedGarrId != -1) then {
			private _detachedGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
			ASSERT_OBJECT(_detachedGarr);
			private _detachedGarrPos = GETV(_detachedGarr, "pos");
			[_detachedGarrPos, _centerPos, "ColorBlack", 4, _thisObject + "_line2"] call misc_fnc_mapDrawLine;
		};
	} ENDMETHOD;

ENDCLASS;

#ifdef _SQF_VM

#define SRC_POS [0, 0, 0]
#define TARGET_POS [1, 2, 3]

["ReinforceCmdrAction", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _srcEff = [100,100,100,100,100,100,100,100];
	SETV(_garrison, "efficiency", _srcEff);
	SETV(_garrison, "pos", SRC_POS);

	private _targetGarrison = NEW("GarrisonModel", [_world]);
	private _targetEff = [1,0,0,0,0,0,0,0];
	SETV(_targetGarrison, "efficiency", _targetEff);
	SETV(_targetGarrison, "pos", TARGET_POS);

	private _thisObject = NEW("ReinforceCmdrAction", [GETV(_garrison, "id"), GETV(_targetGarrison, "id")]);
	
	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	CALLM(_thisObject, "updateScore", [_world, _future]);

	CALLM(_thisObject, "applyToSim", [_world]);
	true
	// ["Object exists", !(isNil "_class")] call test_Assert;
	// ["Initial state is correct", GETV(_obj, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

#endif