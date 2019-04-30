#include "..\common.hpp"

#define CMDR_ACTION_STATE_SPLIT				CMDR_ACTION_STATE_CUSTOM+1
#define CMDR_ACTION_STATE_READY				CMDR_ACTION_STATE_CUSTOM+2
#define CMDR_ACTION_STATE_MOVED				CMDR_ACTION_STATE_CUSTOM+3
#define CMDR_ACTION_STATE_TARGET_DEAD		CMDR_ACTION_STATE_CUSTOM+4

#define CMDR_ACTION_STATE_ARRIVED 			CMDR_ACTION_STATE_CUSTOM+5

// Reads the position of a garrison into a position variable for use in other commands
CLASS("AST_SelectNewTarget", "ActionStateTransition")
	VARIABLE_ATTR("successState", [ATTR_PRIVATE]);
	VARIABLE_ATTR("garrId", [ATTR_PRIVATE]);
	VARIABLE_ATTR("target", [ATTR_PRIVATE]);

	METHOD("new") {
		params [P_THISOBJECT, 
			P_ARRAY("_fromStates"),				// States it is valid from
			P_AST_STATE("_successState"),		// state on success (can't fail)
			// inputs
			P_AST_VAR("_garrId"),
			// outputs
			P_AST_VAR("_target")+				// new target
		];
		T_SETV("fromStates", _fromStates);
		T_SETV("successState", _successState);
		T_SETV("garrId", _garrId);
		T_SETV("target", _target);
	} ENDMETHOD;

	/* override */ METHOD("apply") {
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		private _garr = CALLM(_world, "getGarrison", [T_GET_AST_VAR("garrId")]);
		ASSERT_OBJECT(_garr);
		// TODO: select new target (copy from old MoveGarrison command)
		T_SET_AST_VAR("target", ...);
	} ENDMETHOD;
ENDCLASS;

CLASS("ReinforceCmdrAction", "CmdrAction")
	VARIABLE("srcGarrId");
	VARIABLE("targetVar");
	VARIABLE("detachmentEffVar");
	VARIABLE("detachedGarrIdVar");

	VARIABLE("pushedState");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtGarrId")];

		T_SETV("srcGarrId", _srcGarrId);
		
		private _detachmentEffVar = T_CALLM("createVariable", EFF_ZERO);
		T_SETV("detachmentEffVar", T_CALLM("createVariable", EFF_ZERO));

		private _splitGarrIdVar = T_CALLM("createVariable", -1);
		T_SETV("detachedGarrIdVar", _splitGarrIdVar);

		//private _srcGarrIdVar = T_CALLM("createVariable", -1);
		private _targetVar = T_CALLM("createVariable", [_tgtGarrId]+[TARGET_TYPE_GARRISON]);
		T_SETV("targetVar", _targetVar);

		private _transitions = [
			NEW("AST_SplitGarrison", 
				[_thisObject]+ 						// This action (for debugging context)
				[[CMDR_ACTION_STATE_START]]+ 		// First action we do
				[CMDR_ACTION_STATE_SPLIT]+ 			// State change if successful
				[CMDR_ACTION_STATE_END]+ 			// State change if failed (go straight to end of action)
				[MAKE_AST_VAR(_srcGarrId)]+ 		// Garrison to split (constant)
				[_detachmentEffVar]+ 	// Efficiency we want the detachment to have (constant)
				[MAKE_AST_VAR([ASSIGN_TRANSPORT]+[FAIL_UNDER_EFF])]+ // Flags for split operation
				[_splitGarrIdVar] 					// variable to recieve Id of the garrison after it is split
				),
			NEW("AST_AssignActionToGarrison", 
				[_thisObject]+ 						// This action, gets assigned to the garrison
				[[CMDR_ACTION_STATE_SPLIT]]+ 		// Do this after splitting
				[CMDR_ACTION_STATE_READY]+ 			// State change when successful (can't fail)
				[_splitGarrIdVar] 					// Id of garrison to assign the action to
				),
			NEW("AST_MoveGarrison",
				[_thisObject]+ 						// This action (for debugging context)
				[[CMDR_ACTION_STATE_READY]]+ 		
				[CMDR_ACTION_STATE_MOVED]+ 			// State change when successful
				[CMDR_ACTION_STATE_END]+ 			// State change when garrison is dead (just terminate the action)
				[CMDR_ACTION_STATE_TARGET_DEAD]+ 	// State change when target is dead
				[_splitGarrIdVar]+ 					// Id of garrison to move
				[_targetVar]+ 						// Target to move to (initially the target garrison)
				[MAKE_AST_VAR(200)] 				// Radius to move within
			),
			NEW("AST_SelectNewTarget",
				[[CMDR_ACTION_STATE_TARGET_DEAD]]+ 	// We select a new target when the old one is dead
				[CMDR_ACTION_STATE_READY]+ 			// State change when successful
				[_splitGarrIdVar]+ 					// Id of the garrison we are moving (for context)
				[_targetVar] 						// New target
			),
			NEW("AST_MergeOrJoinTarget",
				[[CMDR_ACTION_STATE_MOVED]]+ 		// Merge once we reach the destination (whatever it is)
				[CMDR_ACTION_STATE_END]+ 			// Once merged we are done
				[CMDR_ACTION_STATE_END]+ 			// If the detachment is dead then we can just end the action
				[CMDR_ACTION_STATE_TARGET_DEAD]+ 	// If the target is dead then reselect a new target
				[_splitGarrIdVar]+ 					// Id of the garrison we are merging
				[_targetVar] 						// Target to merge to (garrison or location is valid)
			)
		];
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

		T_GET_AST_VAR("targetVar") params ["_targetType", "_target"];

		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// DOING: Formatting for the label here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		//private (_tgtGarr) = GETV(_tgtGarr, "actual");
		private _tgtEff = GETV(_tgtGarr, "efficiency");

		private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		if(_detachedGarrId == -1) then {
			format ["reinf %1%2 -> %3%4", LABEL(_srcGarr), _srcEff, LABEL(_tgtGarr), _tgtEff]
		} else {
			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
			//private _detachedAc = GETV(_detachedGarr, "actual");
			private _detachedEff = GETV(_detachedGarr, "efficiency");
			format ["reinf %1%2 -> %3%4 -> %5%6", LABEL(_srcGarr), _srcEff, LABEL(_detachedGarr), _detachedEff, LABEL(_tgtGarr), _tgtEff]
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

		T_PRVAR(tgtGarrId);
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);
		private _tgtGarrPos = GETV(_tgtGarr, "pos");

		[_srcGarrPos, _tgtGarrPos, "ColorBlack", 5, _thisObject + "_line"] call misc_fnc_mapDrawLine;

		private _centerPos = _srcGarrPos vectorAdd ((_tgtGarrPos vectorDiff _srcGarrPos) apply { _x * 0.5 });
		private _mrk = createmarker [_thisObject + "_label", _centerPos];
		_mrk setMarkerType "mil_objective";
		_mrk setMarkerColor "ColorWhite";
		_mrk setMarkerAlpha 1;
		_mrk setMarkerText T_CALLM("getLabel", [_world]);
	} ENDMETHOD;

ENDCLASS;
