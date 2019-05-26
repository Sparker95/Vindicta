#include "..\..\common.hpp"


CLASS("PatrolCmdrAction", "CmdrAction")
	VARIABLE("srcGarrId");
	VARIABLE("routeTargets");
	VARIABLE("splitFlagsVar");
	VARIABLE("detachmentEffVar");
	VARIABLE("detachedGarrIdVar");
	VARIABLE("startDateVar");

	VARIABLE("targetVar");
	VARIABLE("routeTargetsVar");

#ifdef DEBUG_CMDRAI
	VARIABLE("debugColor");
	VARIABLE("debugSymbol");
#endif

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_ARRAY("_routeTargets")];

		T_SETV("srcGarrId", _srcGarrId);
		T_SETV("routeTargets", +_routeTargets);

#ifdef DEBUG_CMDRAI
		T_SETV("debugColor", "ColorYellow");
		T_SETV("debugSymbol", "mil_pickup");
#endif

		// Start date for this action, default to immediate
		private _detachmentEffVar = MAKE_AST_VAR(DATE_NOW);
		T_SETV("startDateVar", _detachmentEffVar);

		// Desired detachment efficiency changes when updateScore is called. This shouldn't happen once the action
		// has been started, but this constructor is called before that point.
		private _detachmentEffVar = MAKE_AST_VAR(EFF_ZERO);
		T_SETV("detachmentEffVar", _detachmentEffVar);

		// Target is the next waypoint or the RTB target
		private _targetVar = T_CALLM("createVariable", [[]]);
		T_SETV("targetVar", _targetVar);

		// Waypoints on the route
		private _routeTargetsVar = T_CALLM("createVariable", [+_routeTargets]);
		T_SETV("routeTargetsVar", _routeTargetsVar);

		// Flags to use when splitting off the detachment garrison		
		private _splitFlagsVar = T_CALLM("createVariable", [[PATROL_FORCE_HINT]]);
		T_SETV("splitFlagsVar", _splitFlagsVar);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		{ DELETE(_x) } forEach T_GETV("transitions");

#ifdef DEBUG_CMDRAI
		T_PRVAR(routeTargets);
		for "_i" from 0 to count _routeTargets do
		{
			deleteMarker (_thisObject + "_line" + str _i);
		};
		deleteMarker (_thisObject + "_label");
#endif
	} ENDMETHOD;

	/* protected override */ METHOD("createTransitions") {
		params [P_THISOBJECT];

		T_PRVAR(srcGarrId);
		T_PRVAR(detachmentEffVar);
		T_PRVAR(splitFlagsVar);
		T_PRVAR(targetVar);
		T_PRVAR(startDateVar);
		T_PRVAR(routeTargetsVar);

		// Call MAKE_AST_VAR directly because we don't won't the CmdrAction to automatically push and pop this value 
		// (it is a constant for this action so it doesn't need to be saved and restored)
		private _srcGarrIdVar = MAKE_AST_VAR(_srcGarrId);

		// Split garrison Id is set by the split AST, so we want it to be saved and restored when simulation is run
		// (so the real value isn't affected by simulation runs, see CmdrAction.applyToSim for details).
		private _splitGarrIdVar = T_CALLM("createVariable", [MODEL_HANDLE_INVALID]);
		T_SETV("detachedGarrIdVar", _splitGarrIdVar);

		private _splitAST_Args = [
				_thisObject,						// This action (for debugging context)
				[CMDR_ACTION_STATE_START], 			// First action we do
				CMDR_ACTION_STATE_SPLIT, 			// State change if successful
				CMDR_ACTION_STATE_END, 				// State change if failed (go straight to end of action)
				_srcGarrIdVar, 						// Garrison to split (constant)
				_detachmentEffVar, 					// Efficiency we want the detachment to have (constant)
				_splitFlagsVar, 					// Flags for split operation
				_splitGarrIdVar]; 					// variable to recieve Id of the garrison after it is split
		private _splitAST = NEW("AST_SplitGarrison", _splitAST_Args);

		private _assignAST_Args = [
				_thisObject, 						// This action, gets assigned to the garrison
				[CMDR_ACTION_STATE_SPLIT], 			// Do this after splitting
				CMDR_ACTION_STATE_NEXT_WAYPOINT, 	// State change when successful (can't fail)
				_splitGarrIdVar]; 					// Id of garrison to assign the action to
		private _assignAST = NEW("AST_AssignActionToGarrison", _assignAST_Args);

		// private _attackAST_Args = [
		// 		_thisObject,
		// 		[CMDR_ACTION_STATE_READY_TO_MOVE], 	// Once we are split and assigned the action we can go
		// 		CMDR_ACTION_STATE_RTB_SELECT_TARGET,// State when we succeed, it leads to selecting new target (usually home)
		// 		CMDR_ACTION_STATE_END, 				// If we are dead then go to end
		// 		CMDR_ACTION_STATE_RTB_SELECT_TARGET,// If we timeout then RTB
		// 		_splitGarrIdVar, 					// Id of the garrison doing the attacking
		// 		_targetVar, 						// Target to attack (cluster or garrison supported)
		// 		MAKE_AST_VAR(200)];					// Move radius
		// private _attackAST = NEW("AST_GarrisonAttackTarget", _attackAST_Args);

		private _nextWaypointAST_Args = [
				[CMDR_ACTION_STATE_NEXT_WAYPOINT], 		
				CMDR_ACTION_STATE_READY_TO_MOVE,	// State change when waypoints remain
				CMDR_ACTION_STATE_RTB_SELECT_TARGET,// State change when no waypoints remain
				CMDR_ACTION_STATE_READY_TO_MOVE,	// State change when on last waypoint
				_routeTargetsVar, 					// The route waypoints
				_targetVar]; 						// The waypoint we are on
		private _nextWaypointAST = NEW("AST_ArrayPopFront", _nextWaypointAST_Args);

		private _moveWaypointsAST_Args = [
				_thisObject, 						// This action (for debugging context)
				[CMDR_ACTION_STATE_READY_TO_MOVE], 		
				CMDR_ACTION_STATE_NEXT_WAYPOINT, 	// State change when successful
				CMDR_ACTION_STATE_END,				// State change when garrison is dead (just terminate the action)
				CMDR_ACTION_STATE_NEXT_WAYPOINT,	// State change when target is we go to next waypoint
				_splitGarrIdVar, 					// Id of garrison to move
				_targetVar, 						// Target to move to (next waypoint)
				MAKE_AST_VAR(100)]; 				// Radius to move within
		// We use attack instead of just move so that garrison will march around a bit at each waypoint. 
		private _moveWaypointsAST = NEW("AST_GarrisonAttackTarget", _moveWaypointsAST_Args);

		private _newRtbTargetAST_Args = [
				[CMDR_ACTION_STATE_RTB_SELECT_TARGET],
				CMDR_ACTION_STATE_RTB, 				// RTB after we selected a target
				_srcGarrIdVar, 						// Originating garrison (default we return to)
				_splitGarrIdVar, 					// Id of the garrison we are moving (for context)
				_targetVar]; 						// New target
		private _newRtbTargetAST = NEW("AST_SelectFallbackTarget", _newRtbTargetAST_Args);

		private _rtbAST_Args = [
				_thisObject, 						// This action (for debugging context)
				[CMDR_ACTION_STATE_RTB], 			// Required state
				CMDR_ACTION_STATE_RTB_SUCCESS, 		// State change when successful
				CMDR_ACTION_STATE_END,				// State change when garrison is dead (just terminate the action)
				CMDR_ACTION_STATE_RTB_SELECT_TARGET,// State change when target is dead. We will select another RTB target
				_splitGarrIdVar, 					// Id of garrison to move
				_targetVar, 						// Target to move to (initially the target cluster)
				MAKE_AST_VAR(200)]; 				// Radius to move within
		private _rtbAST = NEW("AST_MoveGarrison", _rtbAST_Args);

		private _mergeBackAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_RTB_SUCCESS], 	// Merge once we reach the destination (whatever it is)
				CMDR_ACTION_STATE_END, 				// Once merged we are done
				CMDR_ACTION_STATE_END, 				// If the detachment is dead then we can just end the action
				CMDR_ACTION_STATE_RTB_SELECT_TARGET,// If the target is dead then reselect a new target
				_splitGarrIdVar, 					// Id of the garrison we are merging
				_targetVar]; 						// Target to merge to (garrison or location is valid)
		private _mergeBackAST = NEW("AST_MergeOrJoinTarget", _mergeBackAST_Args);

		[_splitAST, _assignAST, _nextWaypointAST, _moveWaypointsAST, _newRtbTargetAST, _rtbAST, _mergeBackAST]
	} ENDMETHOD;
	
	/* protected override */ METHOD("getLabel") {
		params [P_THISOBJECT, P_STRING("_world")];

		T_PRVAR(srcGarrId);
		T_PRVAR(state);
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		private _srcEff = GETV(_srcGarr, "efficiency");

		private _startDate = T_GET_AST_VAR("startDateVar");
		private _timeToStart = if(_startDate isEqualTo []) then {
			" (unknown)"
		} else {
			private _numDiff = (dateToNumber _startDate - dateToNumber DATE_NOW);
			if(_numDiff > 0) then {
				private _dateDiff = numberToDate [0, _numDiff];
				private _mins = _dateDiff#4 + _dateDiff#3*60;

				format [" (start in %1 mins)", _mins]
			} else {
				" (started)"
			}
		};

		private _targetName = [_world, T_GET_AST_VAR("targetVar")] call Target_fnc_GetLabel;
		private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		if(_detachedGarrId == MODEL_HANDLE_INVALID) then {
			format ["%1 %2%3 -> %4%5", _thisObject, LABEL(_srcGarr), _srcEff, _targetName, _timeToStart]
		} else {
			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
			private _detachedEff = GETV(_detachedGarr, "efficiency");
			format ["%1 %2%3 -> %4%5 -> %6%7", _thisObject, LABEL(_srcGarr), _srcEff, LABEL(_detachedGarr), _detachedEff, _targetName, _timeToStart]
		};
	} ENDMETHOD;

	METHOD("updateIntelFromDetachment") {
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_OOP_OBJECT("_intel")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		ASSERT_OBJECT_CLASS(_intel, "IntelCommanderActionPatrol");
		
		// Update progress of the detachment
		private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		if(_detachedGarrId != MODEL_HANDLE_INVALID) then {
			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
			SETV(_intel, "garrison", GETV(_detachedGarr, "actual"));
			SETV(_intel, "pos", GETV(_detachedGarr, "pos"));
			SETV(_intel, "posCurrent", GETV(_detachedGarr, "pos"));
			SETV(_intel, "strength", GETV(_detachedGarr, "efficiency"));
		};
	} ENDMETHOD;
	
	/* protected override */ METHOD("debugDraw") {
		params [P_THISOBJECT, P_STRING("_world")];

		T_PRVAR(srcGarrId);
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _routeTargetPositions = T_GETV("routeTargets") apply { [_world, _x] call Target_fnc_GetPos };

		T_PRVAR(debugColor);
		T_PRVAR(debugSymbol);
		
		private _lastPos = _srcGarrPos;
		{
			[_lastPos, _x, _debugColor, 8, _thisObject + "_line" + str _forEachIndex] call misc_fnc_mapDrawLine;
			_lastPos = _x;
		} forEach (_routeTargetPositions + [_srcGarrPos]);

		private _centerPos = _srcGarrPos vectorAdd ((_routeTargetPositions#0 vectorDiff _srcGarrPos) apply { _x * 0.25 });
		private _mrk = _thisObject + "_label";
		createmarker [_mrk, _centerPos];
		_mrk setMarkerType _debugSymbol;
		_mrk setMarkerColor _debugColor;
		_mrk setMarkerPos _centerPos;
		_mrk setMarkerAlpha 1;
		_mrk setMarkerText T_CALLM("getLabel", [_world]);

		// private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		// if(_detachedGarrId != MODEL_HANDLE_INVALID) then {
		// 	private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
		// 	ASSERT_OBJECT(_detachedGarr);
		// 	private _detachedGarrPos = GETV(_detachedGarr, "pos");
		// 	[_detachedGarrPos, _centerPos, "ColorBlack", 4, _thisObject + "_line2"] call misc_fnc_mapDrawLine;
		// };
	} ENDMETHOD;


	/* override */ METHOD("updateScore") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtLocId);

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		if(CALLM(_srcGarr, "isDead", [])) exitWith {
			T_CALLM("setScore", ZERO_SCORE);
		};

		private _side = GETV(_srcGarr, "side");

		private _srcGarrPos = GETV(_srcGarr, "pos");
		T_PRVAR(routeTargets);
		private _routeTargetPositions = T_GETV("routeTargets") apply { [_worldNow, _x] call Target_fnc_GetPos };
		private _maxDistance = 0;

		private _lastPos = _srcGarrPos;
		{
			_maxDistance = _maxDistance max (_lastPos distance _x);
			_lastPos = _x;
		} forEach ( _routeTargetPositions + [_srcGarrPos]);

		// Resource is how much src is *over* composition, scaled by distance (further is lower)
		// i.e. How much units/vehicles src can spare.
		private _detachEff = EFF_ZERO;
		//private _desiredEff = EFF_FOOT_PATROL_EFF;
		private _transportationScore = 0;
		if(_maxDistance < 2000) then {
			T_SET_AST_VAR("splitFlagsVar", [PATROL_FORCE_HINT]);
			_detachEff = T_CALLM("getDetachmentEff", [_worldNow ARG _worldFuture ARG EFF_FOOT_PATROL_EFF]);
			_transportationScore = 1;
		} else {
			// We will force transport on top of scoring if we need to.
			T_SET_AST_VAR("splitFlagsVar", [ASSIGN_TRANSPORT ARG PATROL_FORCE_HINT]);
			_detachEff = T_CALLM("getDetachmentEff", [_worldNow ARG _worldFuture ARG EFF_MOUNTED_PATROL_EFF]);
			_transportationScore = CALLM(_srcGarr, "transportationScore", [_detachEff])
		};

		// Save the calculation for use if we decide to perform the action 
		// We DON'T want to try and recalculate the detachment against the real world state when the action actually runs because
		// it won't be correctly taking into account our knowledge about other actions (as represented in the sim world models)
		T_SET_AST_VAR("detachmentEffVar", _detachEff);

		private _detachEffStrength = EFF_SUB_SUM(EFF_DEF_SUB(_detachEff));

		private _strategy = CALL_STATIC_METHOD("AICommander", "getCmdrStrategy", [_side]);

		private _scoreResource = _detachEffStrength * _transportationScore;
		private _scorePriority = 1;

		// Work out time to start based on how much force we mustering.
		// https://www.desmos.com/calculator/mawpkr88r3
#ifndef RELEASE_BUILD
		private _delay = random 2;
#else
		private _delay = 50 * log (0.1 * _detachEffStrength + 1) + random 18;
#endif

		// Shouldn't need to cap it, the functions above should always return something reasonable, if they don't then fix them!
		// _delay = 0 max (120 min _delay);
		private _startDate = DATE_NOW;

		_startDate set [4, _startDate#4 + _delay];

		T_SET_AST_VAR("startDateVar", _startDate);

		// OOP_DEBUG_MSG("[w %1 a %2] %3 take %4 Score %5, _detachEff = %6, _detachEffStrength = %7, _distCoeff = %8, _transportationScore = %9",
		// 	[_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG LABEL(_tgtLoc) ARG [_scorePriority ARG _scoreResource] 
		// 	ARG _detachEff ARG _detachEffStrength ARG _distCoeff ARG _transportationScore]);
		private _baseScore = MAKE_SCORE_VEC(_scorePriority, _scoreResource, 1, 1);
		private _score = CALLM(_strategy, "getPatrolScore", [_thisObject ARG _baseScore ARG _worldNow ARG _worldFuture ARG _srcGarr ARG _routeTargets ARG _detachEff]);
		T_CALLM("setScore", [_score]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Patrol"", ""src_garrison"": ""%2"", ""score_priority"": %3, ""score_resource"": %4, ""score_strategy"": %5, ""score_completeness"": %6}}", 
			_side, LABEL(_srcGarr), _score#0, _score#1, _score#2, _score#3];
		OOP_INFO_MSG(_str, []);
		#endif
	} ENDMETHOD;

	// Get composition of patrol we should send
	// TODO: factor out logic for working out detachments for various situations
	/* private */ METHOD("getDetachmentEff") {
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture"), P_ARRAY("_desiredEff")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		T_PRVAR(srcGarrId);
		T_PRVAR(tgtLocId);

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);

		// How much resources src can spare, we allow garrison to take up to half of force for
		private _srcOverMinEff = EFF_MAX_SCALAR(EFF_DIFF(GETV(_srcGarr, "efficiency"), EFF_MIN_EFF), 0);
		private _halfEff = EFF_MUL_SCALAR(GETV(_srcGarr, "efficiency"), 0.5);
		private _srcOverEff = EFF_MIN(_srcOverMinEff, _halfEff);
		//private _srcOverEff = EFF_MAX_SCALAR(, 0);
		// Min of those values
		private _effAvailable = EFF_MAX_SCALAR(EFF_FLOOR(EFF_MIN(_srcOverEff, _desiredEff)), 0);

		_effAvailable
	} ENDMETHOD;
ENDCLASS;
