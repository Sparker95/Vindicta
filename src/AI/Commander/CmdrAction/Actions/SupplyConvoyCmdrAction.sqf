#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.Actions.SupplyConvoyCmdrAction

Parent: <CmdrAction>
*/
#define OOP_CLASS_NAME SupplyConvoyCmdrAction
CLASS("SupplyConvoyCmdrAction", "CmdrAction")
	// Originating garrison
	VARIABLE_ATTR("srcGarrId", [ATTR_SAVE]);
	// Target garrison
	VARIABLE_ATTR("tgtGarrId", [ATTR_SAVE]);
	// Next target
	VARIABLE_ATTR("targetVar", [ATTR_SAVE]);
	// Waypoints array (including target garrison) composed of targets (see CmdrAITarget.sqf)
	VARIABLE_ATTR("routeTargets", [ATTR_SAVE]);
	// Waypoints array var wrapper (including target)
	VARIABLE_ATTR("routeTargetsVar", [ATTR_SAVE]);

	// Depart time for the next route target
	VARIABLE_ATTR("departVar", [ATTR_SAVE]);
	// Schedule for the route stops
	VARIABLE_ATTR("schedule", [ATTR_SAVE]);
	// Schedule var wrapper
	VARIABLE_ATTR("scheduleVar", [ATTR_SAVE]);

	// Detachment efficiency (calculated in score function)
	VARIABLE_ATTR("detachmentEffVar", [ATTR_SAVE]);
	// Detachment composition (calculated in score function)
	VARIABLE_ATTR("detachmentCompVar", [ATTR_SAVE]);
	// Detatchment garrison ID
	VARIABLE_ATTR("detachedGarrIdVar", [ATTR_SAVE]);

	// Type ACTION_SUPPLY_*
	VARIABLE_ATTR("type", [ATTR_SAVE]);
	// Amount - abstract value representing "how much" of the stuff to supply from 0-1.
	VARIABLE_ATTR("amount", [ATTR_SAVE]);
	VARIABLE_ATTR("cargo", [ATTR_SAVE]);

	// Array of UI names for the types of supplies
	STATIC_VARIABLE("SupplyNames");

	/*
	Constructor: new

	Create a CmdrAI action to send a detachment with supplies, from the source garrison to join
	the target garrison.
	
	Parameters:
		_srcGarrId - Number, <Model.GarrisonModel> id from which to send the patrol detachment.
		_routeTargets - Array of <CmdrAITarget>, an array of route waypoints as targets.
		_type - Number, type of supplies we are sending (from the ACTION_SUPPLY_* macros)
		_amount - Number, 0-1, how much, non-specific units
	*/
	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_NUMBER("_tgtGarrId"), P_ARRAY("_routeTargets"), P_NUMBER("_type"), P_NUMBER("_amount")];

		T_SETV("srcGarrId", _srcGarrId);
		T_SETV("tgtGarrId", _tgtGarrId);
		private _fullRoute = _routeTargets + [[TARGET_TYPE_GARRISON, _tgtGarrId]];
		T_SETV("routeTargets", +_fullRoute);
		T_SETV("schedule", []);

		T_SETV("type", _type);
		T_SETV("amount", _amount);
		T_SETV("cargo", []);

		// Desired detachment efficiency changes when updateScore is called. This shouldn't happen once the action
		// has been started, but this constructor is called before that point.
		private _detachmentEffVar = T_CALLM1("createVariable", EFF_ZERO);
		T_SETV("detachmentEffVar", _detachmentEffVar);
		private _detachmentCompVar = T_CALLM1("createVariable", +T_comp_null);
		T_SETV("detachmentCompVar", _detachmentCompVar);

		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		private _targetVar = T_CALLM("createVariable", [[]]);
		T_SETV("targetVar", _targetVar);

		// Waypoints on the route
		private _routeTargetsVar = T_CALLM("createVariable", [+_fullRoute]);
		T_SETV("routeTargetsVar", _routeTargetsVar);

		// Depart time for next route target
		private _departVar = T_CALLM("createVariable", [0]);
		T_SETV("departVar", _departVar);

		// Route schedule
		private _scheduleVar = T_CALLM("createVariable", [[]]);
		T_SETV("scheduleVar", _scheduleVar);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		{ DELETE(_x) } forEach T_GETV("transitions");

#ifdef DEBUG_CMDRAI_ACTIONS
		private _routeTargets = T_GETV("routeTargets");
		for "_i" from 0 to count _routeTargets do
		{
			deleteMarker (_thisObject + "_line" + str _i);
		};
		deleteMarker (_thisObject + "_label");
#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	protected override METHOD(createTransitions)
		params [P_THISOBJECT];

		private _srcGarrId = T_GETV("srcGarrId");
		private _detachmentEffVar = T_GETV("detachmentEffVar");
		private _detachmentCompVar = T_GETV("detachmentCompVar");
		private _targetVar = T_GETV("targetVar");
		private _routeTargetsVar = T_GETV("routeTargetsVar");
		private _departVar = T_GETV("departVar");
		private _scheduleVar = T_GETV("scheduleVar");

		// Call MAKE_AST_VAR directly because we don't won't the CmdrAction to automatically push and pop this value 
		// (it is a constant for this action so it doesn't need to be saved and restored)
		private _srcGarrIdVar = T_CALLM1("createVariable", _srcGarrId);

		// Split garrison Id is set by the split AST, so we want it to be saved and restored when simulation is run
		// (so the real value isn't affected by simulation runs, see CmdrAction.applyToSim for details).
		private _splitGarrIdVar = T_CALLM("createVariable", [MODEL_HANDLE_INVALID]);
		T_SETV("detachedGarrIdVar", _splitGarrIdVar);

		private _targetVar = T_GETV("targetVar");	// T_GET_AST_VAR("targetVar");

		private _asts = [];

		private _splitAST_Args = [
				_thisObject,						// This action (for debugging context)
				[CMDR_ACTION_STATE_START], 			// First action we do
				CMDR_ACTION_STATE_SPLIT, 			// State change if successful
				CMDR_ACTION_STATE_END, 				// State change if failed (go straight to end of action)
				_srcGarrIdVar, 						// Garrison to split (constant)
				_detachmentCompVar,					// COmposition of detachment
				_detachmentEffVar, 					// Efficiency we want the detachment to have (constant)
				_splitGarrIdVar]; 					// variable to recieve Id of the garrison after it is split
		_asts pushBack NEW("AST_SplitGarrison", _splitAST_Args);

		private _perpareAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_SPLIT],			// Do this after splitting
				CMDR_ACTION_STATE_PREPARED,			// If preperation was successful
				_splitGarrIdVar,
				T_GETV("cargo")
		];
		_asts pushBack NEW("AST_AssignCargo", _perpareAST_Args);

		private _assignAST_Args = [
				_thisObject, 						// This action, gets assigned to the garrison
				[CMDR_ACTION_STATE_PREPARED], 		// Do this after preperation
				CMDR_ACTION_STATE_ASSIGNED, 		// State change when successful (can't fail)
				_splitGarrIdVar]; 					// Id of garrison to assign the action to
		_asts pushBack NEW("AST_AssignActionToGarrison", _assignAST_Args);

		// Select next waypoint for the patrol assigning it to targetVar
		private _nextDepartTimeAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_ASSIGNED],
				CMDR_ACTION_STATE_WAIT_TO_DEPART,	// State change when waypoints remain
				CMDR_ACTION_STATE_ARRIVED,			// State change when no waypoints remain
				CMDR_ACTION_STATE_WAIT_TO_DEPART,	// State change when on last waypoint
				_scheduleVar, 						// The route schedule
				_departVar]; 						// The next departure time
		_asts pushBack NEW("AST_ArrayPopFront", _nextDepartTimeAST_Args);

		private _waitAST_Args = [
				_thisObject,						// This action (for debugging context)
				[CMDR_ACTION_STATE_WAIT_TO_DEPART], // Start wait after we assigned the action to the detachment
				CMDR_ACTION_STATE_NEXT_WAYPOINT, 	// State change if successful
				CMDR_ACTION_STATE_END, 				// State change if failed (go straight to end of action)
				_departVar,							// Date to wait until
				_splitGarrIdVar];					// Garrison to wait (checks it is still alive)
		_asts pushBack NEW("AST_WaitGarrison", _waitAST_Args);

		// Select next waypoint for the patrol assigning it to targetVar
		private _nextWaypointAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_NEXT_WAYPOINT],
				CMDR_ACTION_STATE_READY_TO_MOVE,	// State change when waypoints remain
				CMDR_ACTION_STATE_RTB_SELECT_TARGET,// State change when no waypoints remain (shouldn't get here)
				CMDR_ACTION_STATE_READY_TO_MOVE,	// State change when on last waypoint
				_routeTargetsVar, 					// The route waypoints
				_targetVar]; 						// The waypoint we are on
		_asts pushBack NEW("AST_ArrayPopFront", _nextWaypointAST_Args);

		// Moving on waypoints to target
		private _moveToAST_Args = [
				_thisObject, 						// This action (for debugging context)
				[CMDR_ACTION_STATE_READY_TO_MOVE], 		
				CMDR_ACTION_STATE_ASSIGNED,			// State change when successful
				CMDR_ACTION_STATE_END,				// State change when garrison is dead (just terminate the action)
				CMDR_ACTION_STATE_ASSIGNED,			// If we timeout then go to next
				_splitGarrIdVar, 					// Id of garrison to move
				_targetVar, 						// Target to move to (initially the target garrison)
				T_CALLM1("createVariable", 100)]; 	// Radius to move within
		_asts pushBack NEW("AST_MoveGarrison", _moveToAST_Args);

		// Arrived at target, "unload" the goods
		private _arriveAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_ARRIVED],		// Called after move complete
				CMDR_ACTION_STATE_RTB_SELECT_TARGET,// If we should auto select a new target (will default to home again)
				_splitGarrIdVar]; 					// Id of the garrison we are merging
		_asts pushBack NEW("AST_ClearCargo", _arriveAST_Args);

		// Select rtb target (default will be source garrison)
		private _newTargetAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_RTB_SELECT_TARGET],// We select a new target when the old one is dead
				CMDR_ACTION_STATE_RTB, 				// State change when successful
				_srcGarrIdVar, 						// Originating garrison (default we return to)
				_splitGarrIdVar, 					// Id of the garrison we are moving (for context)
				_targetVar]; 						// New target
		_asts pushBack NEW("AST_SelectFallbackTarget", _newTargetAST_Args);

		// RTB move
		private _rtbAST_Args = [
				_thisObject, 						// This action (for debugging context)
				[CMDR_ACTION_STATE_RTB], 		
				CMDR_ACTION_STATE_PREMERGE,			// State change when successful
				CMDR_ACTION_STATE_END,				// State change when garrison is dead (just terminate the action)
				CMDR_ACTION_STATE_RTB_SELECT_TARGET,// State change when target is dead
				_splitGarrIdVar, 					// Id of garrison to move
				_targetVar, 						// Target to move to (initially the target garrison)
				T_CALLM1("createVariable", 200)]; 	// Radius to move within
		_asts pushBack NEW("AST_MoveGarrison", _rtbAST_Args);

		// Arrived back at base, clear cargo if its not already (it would only not be clear if we aborted the mission before arriving)
		private _preMergeAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_PREMERGE],		// Called after rtb, before merge to target (for cleanup etc)
				CMDR_ACTION_STATE_MERGE,			// Complete the merge
				_splitGarrIdVar]; 					// Id of the garrison we are merging
		_asts pushBack NEW("AST_ClearCargo", _preMergeAST_Args);
		
		// Merge back to source garrison (or alternate RTB we choose)
		private _mergeAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_MERGE], 			// Merge once we reach the destination (whatever it is)
				CMDR_ACTION_STATE_END, 				// Once merged we are done
				CMDR_ACTION_STATE_END, 				// If the detachment is dead then we can just end the action
				CMDR_ACTION_STATE_RTB_SELECT_TARGET,// If the target is dead then reselect a new target
				_splitGarrIdVar, 					// Id of the garrison we are merging
				_targetVar]; 						// Target to merge to (garrison or location is valid)
		_asts pushBack NEW("AST_MergeOrJoinTarget", _mergeAST_Args);
		_asts
	ENDMETHOD;

	protected override METHOD(getLabel)
		params [P_THISOBJECT, P_STRING("_world")];

		private _srcGarrId = T_GETV("srcGarrId");
		private _state = T_GETV("state");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		private _srcEff = GETV(_srcGarr, "efficiency");

		private _startDate = T_GET_AST_VAR("departVar");
		private _timeToStart = if(_startDate isEqualTo []) then {
			" (unknown)"
		} else {
			#ifndef _SQF_VM
			private _numDiff = (dateToNumber _startDate - dateToNumber DATE_NOW);
			if(_numDiff > 0) then {
				private _dateDiff = numberToDate [0, _numDiff];
				private _mins = _dateDiff#4 + _dateDiff#3*60;

				format [" (start in %1 mins)", _mins]
			} else {
				" (started)"
			}
			#else
			""
			#endif
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
	ENDMETHOD;

	protected virtual METHOD(updateIntelFromDetachment)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_OOP_OBJECT("_intel")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		//ASSERT_OBJECT_CLASS(_intel, "IntelCommanderActionAttack");
		
		// Update progress of the detachment
		private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		if(_detachedGarrId != MODEL_HANDLE_INVALID) then {
			private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
			SETV(_intel, "garrison", GETV(_detachedGarr, "actual"));
			SETV(_intel, "pos", GETV(_detachedGarr, "pos"));
			SETV(_intel, "posCurrent", GETV(_detachedGarr, "pos"));
			SETV(_intel, "strength", GETV(_detachedGarr, "efficiency"));

			// Send intel to the garrison doing this action
			T_CALLM1("setPersonalGarrisonIntel", _detachedGarr);

			if (T_GETV("state") == CMDR_ACTION_STATE_READY_TO_MOVE) then {
				T_CALLM1("setIntelState", INTEL_ACTION_STATE_ACTIVE);
			};
		};
	ENDMETHOD;
	
	protected override METHOD(debugDraw)
		params [P_THISOBJECT, P_STRING("_world")];

		private _srcGarrId = T_GETV("srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _srcGarrPos = GETV(_srcGarr, "pos");

		/*
		// Debug drawing of this is broken now, no idea why
		private _targetPos = [_world, T_GET_AST_VAR("targetVar")] call Target_fnc_GetPos;

		if(_targetPos isEqualType []) then {
			GET_DEBUG_MARKER_STYLE(_thisObject) params ["_debugColor", "_debugSymbol"];

			[_srcGarrPos, _targetPos, _debugColor, 8, _thisObject + "_line"] call misc_fnc_mapDrawLine;

			private _centerPos = _srcGarrPos vectorAdd ((_targetPos vectorDiff _srcGarrPos) apply { _x * 0.25 });
			private _mrk = _thisObject + "_label";
			createmarker [_mrk, _centerPos];
			_mrk setMarkerType _debugSymbol;
			_mrk setMarkerColor _debugColor;
			_mrk setMarkerPos _centerPos;
			_mrk setMarkerAlpha 1;
			_mrk setMarkerText T_CALLM("getLabel", [_world]);
		};
		*/

		// private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		// if(_detachedGarrId != MODEL_HANDLE_INVALID) then {
		// 	private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
		// 	ASSERT_OBJECT(_detachedGarr);
		// 	private _detachedGarrPos = GETV(_detachedGarr, "pos");
		// 	[_detachedGarrPos, _centerPos, "ColorBlack", 4, _thisObject + "_line2"] call misc_fnc_mapDrawLine;
		// };
	ENDMETHOD;

	protected override METHOD(updateIntel)
		params [P_THISOBJECT, P_STRING("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		ASSERT_MSG(CALLM0(_world, "isReal"), "Can only updateIntel from real world, this shouldn't be possible as updateIntel should ONLY be called by CmdrAction");

		private _srcGarrId = T_GETV("srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtGarrId = T_GETV("tgtGarrId");
		private _tgtGarr = CALLM(_world, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);

		private _intel = NULL_OBJECT;
		private _intelClone = T_GETV("intelClone");

		private _intelNotCreated = IS_NULL_OBJECT(_intelClone);
		if(_intelNotCreated) then {
			// Create new intel object and fill in the constant values
			_intel = NEW("IntelCommanderActionSupplyConvoy", []);

			private _routeTargets = T_GETV("routeTargets");
			private _routeTargetPositions = _routeTargets apply { [_world, _x] call Target_fnc_GetPos };
			private _locations = _routeTargets select { 
				_x#0 == TARGET_TYPE_LOCATION
			} apply { 
				private _locId = _x#1;
				private _loc = CALLM(_world, "getLocation", [_locId]);
				GETV(_loc, "actual")
			};

			private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
			private _srcGarrPos = GETV(_srcGarr, "pos");
			_routeTargetPositions pushBack _srcGarrPos;

			private _typeName = GETSV("SupplyConvoyCmdrAction", "SupplyNames") select T_GETV("type");
			SETV(_intel, "type", _typeName);
			private _amount = T_GETV("amount");
			SETV(_intel, "amount", _amount);

			SETV(_intel, "waypoints", _routeTargetPositions);
			private _srcLocation = CALLM0(GETV(_srcGarr, "actual"), "getLocation");
			private _tgtLocation = CALLM0(GETV(_tgtGarr, "actual"), "getLocation");
			SETV(_intel, "locations", [_srcLocation] + _locations + [_tgtLocation]);
			private _schedule = T_GETV("schedule");
			SETV(_intel, "schedule", +_schedule);
			SETV(_intel, "side", GETV(_srcGarr, "side"));
			SETV(_intel, "posSrc", GETV(_srcGarr, "pos"));
			SETV(_intel, "posTgt", GETV(_tgtGarr, "pos"));
			SETV(_intel, "dateDeparture", _schedule select 0);

			CALLM0(_intel, "create");

			T_CALLM("updateIntelFromDetachment", [_world ARG _intel]);

			// If we just created this intel then register it now 
			_intelClone = CALLSM("AICommander", "registerIntelCommanderAction", [_intel]);
			T_SETV("intelClone", _intelClone);

			// Send the intel to some places that should "know" about it
			{
				T_CALLM("addIntelAt", [_world ARG _x]);
			} forEach _routeTargetPositions;

			// // Reveal some friendly locations near the destination to the garrison performing the task
			// private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
			// if(_detachedGarrId != MODEL_HANDLE_INVALID) then {
			// 	private _detachedGarrModel = CALLM(_world, "getGarrison", [_detachedGarrId]);
			// 	{
			// 		CALLM2(_x, "addKnownFriendlyLocationsActual", GETV(_tgtGarr, "pos"), 2000); // Reveal friendly locations to src. and detachment which are within 2000 meters from destination
			// 	} forEach [_srcGarr, _detachedGarrModel];
			// 	CALLM2(_tgtGarr, "addKnownFriendlyLocationsActual", GETV(_srcGarr, "pos"), 2000); // Reveal friendly locations to dest. which are within 2000 meters from source
			// };

		} else {
			T_CALLM("updateIntelFromDetachment", [_world ARG _intelClone]);
			CALLM0(_intelClone, "updateInDb");
		};
	ENDMETHOD;

	public override METHOD(updateScore)
		params [P_THISOBJECT, P_STRING("_worldNow"), P_STRING("_worldFuture")];
		ASSERT_OBJECT_CLASS(_worldNow, "WorldModel");
		ASSERT_OBJECT_CLASS(_worldFuture, "WorldModel");

		private _srcGarrId = T_GETV("srcGarrId");
		private _tgtGarrId = T_GETV("tgtGarrId");

		private _srcGarr = CALLM(_worldNow, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _tgtGarr = CALLM(_worldFuture, "getGarrison", [_tgtGarrId]);
		ASSERT_OBJECT(_tgtGarr);

		// Bail if src or dst are dead
		if(CALLM0(_srcGarr, "isDead") or {CALLM0(_tgtGarr, "isDead")}) exitWith {
			OOP_DEBUG_0("Src or dst garrison is dead");
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		private _side = GETV(_srcGarr, "side");
		private _tgtGarrEff = GETV(_tgtGarr, "efficiency");
		private _srcGarrEff = GETV(_srcGarr, "efficiency");
		private _srcGarrComp = GETV(_srcGarr, "composition");

		private _allocationFlags = [
			SPLIT_VALIDATE_ATTACK,		// Validate our escort strength	
			SPLIT_VALIDATE_CREW,		// Ensure we can drive our vehicles
			SPLIT_VALIDATE_CREW_EXT,	// Ensure we provide enough crew to destination
			SPLIT_VALIDATE_TRANSPORT	// Definitely need transport as we are moving supplies
		];

		// Try to allocate units
		private _payloadWhitelistMask = T_comp_ground_or_infantry_mask;
		// Don't take static weapons or cargo under any conditions
		// (we will manually assign cargo to our trucks, don't need T_CARGO stuff)
		private _payloadBlacklistMask = T_comp_static_or_cargo_mask;
		// Take ground units, take any infantry to satisfy crew requirements
		private _transportWhitelistMask = T_comp_ground_or_infantry_mask;
		private _transportBlacklistMask = [];
		// Obviously we need a cargo truck!
		private _requiredComp =  [
			[T_VEH, T_VEH_truck_ammo, 1]
		];

		private _amount = T_GETV("amount");

		// Determine an appropriate escort for our cargo
		private _requiredEff = +T_eff_null;

		// Add some armor if we need it
		_requiredEff set [T_EFF_soft, floor (12 + 24 * _amount)];
		_requiredEff set [T_EFF_medium, floor (3 * _amount)];
		_requiredEff set [T_EFF_armor, floor (3 * _amount)];

		// [6, 0, 0, 0, 6, 0, 0, 0, 0, 6, 0, 0, 0, 6]
		private _args = [_requiredEff, _allocationFlags, _srcGarrComp, _srcGarrEff,
					_payloadWhitelistMask, _payloadBlacklistMask,
					_transportWhitelistMask, _transportBlacklistMask,
					_requiredComp];
		private _allocResult = CALLSM("GarrisonModel", "allocateUnits", _args);

		// Bail if we have failed to allocate resources
		if ((count _allocResult) == 0) exitWith {
			OOP_DEBUG_MSG("Failed to allocate resources", []);
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		_allocResult params ["_compAllocated", "_effAllocated", "_compRemaining", "_effRemaining"];

		ASSERT(_compAllocated#T_VEH#T_VEH_truck_ammo >= 1);

		private _srcGarrPos = GETV(_srcGarr, "pos");
		private _srcDesiredEff = CALLM1(_worldNow, "getDesiredEff", _srcGarrPos);

		// Bail if remaining efficiency is below minimum level for this garrison
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateAttack) > 0) exitWith {
			OOP_DEBUG_2("Remaining attack capability requirement not satisfied: %1 VS %2", _effRemaining, _srcDesiredEff);
			T_CALLM("setScore", [ZERO_SCORE]);
		};
		if (count ([_effRemaining, _srcDesiredEff] call eff_fnc_validateCrew) > 0 ) exitWith {	// we must have enough crew to operate vehicles ...
			OOP_DEBUG_1("Remaining crew requirement not satisfied: %1", _effRemaining);
			T_CALLM("setScore", [ZERO_SCORE]);
		};

		T_SET_AST_VAR("detachmentEffVar", _effAllocated);
		T_SET_AST_VAR("detachmentCompVar", _compAllocated);

		// How much to scale the score for distance to target
		private _tgtGarrPos = GETV(_tgtGarr, "pos");

		private _dist = _srcGarrPos distance _tgtGarrPos;
		// Prefer distance of 7km for convoys, so offset distance by that before calculating falloff score
		private _distCoeff = CALLSM1("CmdrAction", "calcDistanceFalloff", _dist - 7000);
		private _detachEffStrength = CALLSM1("CmdrAction", "getDetachmentStrength", _effAllocated); // A number!

		// Our final resource score combining available efficiency, distance and transportation.
		private _scoreResource = _detachEffStrength * _distCoeff;

		// CALCULATE START DATE
		// Work out time to start based on amount of supplies we mustering and distance we are travelling.
		// linear * https://www.desmos.com/calculator/0vb92pzcz8 * 0.1
		
		private _delay = 50 * (_amount + 0.5) * (1 + 2 * log (0.0003 * _dist + 1)) * 0.1 + (30 + random 15);

		// Shouldn't need to cap it, the functions above should always return something reasonable, if they don't then fix them!
		// _delay = 0 max (120 min _delay);
		private _startDate = [DATE_NOW, _delay] call vin_fnc_addMinutesToDate;
		private _routeTargets = T_GETV("routeTargets");
		private _schedule = [];
		{
			_schedule pushBack _startDate;
			// Just random fixed range for now, ignore distance
			_startDate = [_startDate, 15 + random 30] call vin_fnc_addMinutesToDate; // set [4, _startDate#4 + 15 + random 30];
			// if(_forEachIndex +1 < count _routeTargets) then {
			// 	private _nextPos = _routeTargets#(_forEachIndex + 1);
			// 	private _dist = _currPos 
			// 	_startDate set [4, _startDate#4 + ];
			// };
		} forEach _routeTargets;
		T_SETV("schedule", _schedule);
		T_SET_AST_VAR("scheduleVar", +_schedule);

		private _type = T_GETV("type");
		private _typeName = GETSV("SupplyConvoyCmdrAction", "SupplyNames") select _type;
		OOP_DEBUG_MSG("[w %1 a %2] %3 supply %4 with %5 %6, Score %7 _detachEff = %8 _detachEffStrength = %9 _distCoeff = %10", 
			[_worldNow ARG _thisObject ARG LABEL(_srcGarr) ARG LABEL(_tgtGarr) ARG _typeName ARG _amount ARG [1 ARG _scoreResource] ARG _effAllocated ARG _detachEffStrength ARG _distCoeff]);

		// APPLY STRATEGY
		// Get our Cmdr strategy implementation and apply it
		private _strategy = CALLSM("AICommander", "getCmdrStrategy", [_side]);
		private _baseScore = MAKE_SCORE_VEC(1, _scoreResource, 1, 1);
		private _score = CALLM(_strategy, "getSupplyScore", [_thisObject ARG _baseScore ARG _worldNow ARG _worldFuture ARG _srcGarr ARG _tgtGarr ARG _effAllocated ARG _type ARG _amount]);
		T_CALLM("setScore", [_score]);

		// Calculate the cargo content
		T_CALLM1("calculateCargo", _worldNow);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Reinforce"", ""src_garrison"": ""%2"", ""tgt_garrison"": ""%3"", ""score_priority"": %4, ""score_resource"": %5, ""score_strategy"": %6, ""score_completeness"": %7}}", 
			_side, LABEL(_srcGarr), LABEL(_tgtGarr), _score#0, _score#1, _score#2, _score#3];
		OOP_INFO_MSG(_str, []);
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	/*
	Method: (virtual) getRecordSerial
	Returns a serialized CmdrActionRecord associated with this action.
	Derived classes should implement this to have proper support for client's UI.
	
	Parameters:	
		_world - <Model.WorldModel>, real world model that is being used.
	*/
	public override METHOD(getRecordSerial)
		params [P_THISOBJECT, P_OOP_OBJECT("_garModel"), P_OOP_OBJECT("_world")];

		// Create a record
		private _record = NEW("SupplyConvoyCmdrActionRecord", []);

		// // Fill data values
		// //SETV(_record, "garRef", GETV(_garModel, "actual"));
		// private _tgtGarModel = CALLM1(_world, "getGarrison", T_GETV("tgtGarrId"));
		// SETV(_record, "dstGarRef", GETV(_tgtGarModel, "actual"));

		// Serialize and delete it
		private _serial = SERIALIZE(_record);
		DELETE(_record);

		// Return the serialized data
		_serial
	ENDMETHOD;

	STATIC_METHOD(randomAmount)
		params [P_THISCLASS, P_NUMBER("_base"), P_NUMBER("_variation")];
		#ifdef _SQF_VM
		1
		#else
		floor (_base + _variation * random [0, 0.5, 1])
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	METHOD(calculateCargo)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		private _type = T_GETV("type");
		private _amount = T_GETV("amount");
		private _cargo = T_GETV("cargo");

		// Cargo/inventory array format:
		// 	[
		//		[[weapon, count],...],
		//		[[item, count],...],
		//		[[mag, count],...],
		//		[[backpack, count],...]
		// 	]
		#define CARGO_WEAPONS 0
		#define CARGO_ITEMS 1
		#define CARGO_MAGS 2
		#define CARGO_BACKPACKS 3
		_cargo set [CARGO_WEAPONS, []];
		_cargo set [CARGO_ITEMS, []];
		_cargo set [CARGO_MAGS, []];
		_cargo set [CARGO_BACKPACKS, []];

		switch (_type) do {
			case ACTION_SUPPLY_TYPE_BUILDING: {
				_cargo set [CARGO_ITEMS, [
					["vin_build_res_0", CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 250, 500 * _amount)]
				]];
			};
			case ACTION_SUPPLY_TYPE_AMMO: {
				private _srcGarrId = T_GETV("srcGarrId");
				private _tgtGarrId = T_GETV("tgtGarrId");
				private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
				private _side = GETV(_srcGarr, "side");
				private _t = CALLM2(gGameMode, "getTemplate", _side, "military");
				private _tInv = _t#T_INV;

				// Add weapons and magazines
				private _arr = [[T_INV_handgun, ceil (1 + random 2), CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 2, 5 * _amount)]];
				_arr = _arr + (if(random 10 < 7) then {
					[[T_INV_primary, ceil (1 + random 2), CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 20 * _amount)]]
				} else {
					[[T_INV_secondary, ceil (1 + random 2), CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 10 * _amount)]]
				});

				private _weapons = [];
				private _mags = [];

				{ // forEach _arr;
					_x params ["_subcatID", "_nTypes", "_nOfEach"];
					if (count (_tInv#_subcatID) > 0) then { // If there are any weapons in this subcategory
						private _weaponsAndMags = (+_tInv#_subcatID) call BIS_fnc_arrayShuffle;
						private _maxType = _nTypes min count _weaponsAndMags;
						for "_i" from 0 to (_maxType-1) do {
							private _weaponAndMag = _weaponsAndMags#_i;
							_weaponAndMag params ["_weaponClassName", "_magazines"];
							_weapons = _weapons + [[_weaponClassName, ceil (_nOfEach * random[0.5, 1, 1.5])]];
							if(count _magazines > 0) then {
								private _nMags = ceil (_nOfEach * 10 * random[0.5, 1, 1.5]);
								private _newMags = _magazines apply { [_x, 0] } ;
								while {_nMags > 0} do {
									private _mag = selectRandom _newMags;
									_mag set [1, _mag#1 + 1];
									_nMags = _nMags - 1;
								};
								_mags = _mags + (_newMags select { 
									_x#1 > 0
								} apply {
									// Scale by mag size
									_x params ["_magType", "_count"];
									private _magSize = getNumber (configfile >> "CfgMagazines" >> _magType >> "count");
									[_magType, _count * _magSize]
								} select { 
									// Check again as some mags have no actual rounds (fake weapons etc.)
									_x#1 > 0
								});
							};
						};
					};
				} forEach _arr;
				_cargo set [CARGO_WEAPONS, _weapons];
				_cargo set [CARGO_MAGS, _mags];
			};
			case ACTION_SUPPLY_TYPE_EXPLOSIVES: {
				_cargo set [CARGO_ITEMS, [
					["IEDLandSmall_Remote_Mag", 	CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 4, 10 * _amount)],
					["IEDUrbanSmall_Remote_Mag", 	CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 4, 10 * _amount)],
					["IEDLandBig_Remote_Mag", 		CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 0, 10 * _amount)],
					["IEDUrbanBig_Remote_Mag", 		CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 0, 10 * _amount)],
					["DemoCharge_Remote_Mag", 		CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 0, 5 * _amount)],
					["SatchelCharge_Remote_Mag", 	CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 0, 5 * _amount)],
					["TrainingMine_Mag", 			CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 20 * _amount)],
					["ACE_DeadManSwitch", 			CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 10 * _amount)],
					["ACE_DefusalKit", 				CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 10 * _amount)],
					["ACE_M26_Clacker", 			CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 10 * _amount)],
					["ACE_Clacker", 				CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 10 * _amount)],
					["MineDetector", 				CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 10 * _amount)]
				]];
			};
			case ACTION_SUPPLY_TYPE_MEDICAL;
			case ACTION_SUPPLY_TYPE_MISC: {
				// Add ACE medical items
				private _medical = if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then {
					("true" configClasses (configfile >> "CfgVehicles" >> "ACE_medicalSupplyCrate_advanced" >> "TransportItems")) apply {
						private _itemName = getText (_x >> "name");
						private _itemCount = getNumber (_x >> "count");
						[_itemName, CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 2 * _itemCount, 3 * _itemCount * _amount)]
					}
				} else {
					// wat
					[]
				};
				// Add ADV medical items
				// Defibrilator
				if (isClass (configfile >> "CfgPatches" >> "adv_aceCPR")) then {
					_medical pushBack ["adv_aceCPR_AED", CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 10 * _amount)];
				};
				// Splint
				if (isClass (configfile >> "CfgPatches" >> "adv_aceSplint")) then {
					_medical pushBack ["adv_aceSplint_splint", CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 10, 30 * _amount)];
				};

				_medical pushBack ["FirstAidKit", CALLSM2("SupplyConvoyCmdrAction", "randomAmount", 5, 15 * _amount)];
				_cargo set [CARGO_ITEMS, _medical];
			};
		}
	ENDMETHOD;

ENDCLASS;

REGISTER_DEBUG_MARKER_STYLE("SupplyConvoyCmdrAction", "ColorPink", "mil_pickup");

if(isNil { GETSV("SupplyConvoyCmdrAction", "SupplyNames")}) then {
	private _actionSupplyNames = [
		"Building Supplies",
		"Ammunition",
		"Explosives",
		"Medical",
		"Miscellaneous"
	];
	SETSV("SupplyConvoyCmdrAction", "SupplyNames", _actionSupplyNames);
};

#ifdef _SQF_VM

#define SRC_POS [1, 2, 0]
#define TARGET_POS [1000, 2, 3]

["SupplyConvoyCmdrAction", {

	CALLSM0("AICommander", "initStrategicNavGrid");

	private _realworld = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _world = CALLM(_realworld, "simCopy", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _srcComp = [30] call comp_fnc_new;
	for "_i" from 0 to (T_INF_SIZE-1) do {
		(_srcComp#T_INF) set [_i, 100]; // Otherwise crew requirement will fail
	};
	private _srcEff = [_srcComp] call comp_fnc_getEfficiency;
	SETV(_garrison, "efficiency", _srcEff);
	SETV(_garrison, "composition", _srcComp);
	SETV(_garrison, "pos", SRC_POS);
	SETV(_garrison, "side", WEST);

	private _targetGarrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _targetComp = +T_comp_null;
	(_targetComp#T_INF) set [T_INF_rifleman, 4];
	private _targetEff = [_targetComp] call comp_fnc_getEfficiency;
	SETV(_targetGarrison, "efficiency", _targetEff);
	SETV(_targetGarrison, "composition", _targetComp);
	SETV(_targetGarrison, "pos", TARGET_POS);

	private _route = [
		[TARGET_TYPE_POSITION, [0,0,0]],
		[TARGET_TYPE_POSITION, [0,0,0]],
		[TARGET_TYPE_POSITION, [0,0,0]]
	];

	private _thisObject = NEW("SupplyConvoyCmdrAction", [
		GETV(_garrison, "id") ARG 
		GETV(_targetGarrison, "id") ARG 
		_route ARG 
		ACTION_SUPPLY_TYPE_BUILDING ARG 
		0.2
	]);

	private _future = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);
	T_CALLM("updateScore", [_world ARG _future]);
	private _finalScore = T_CALLM("getFinalScore", []);

	["Score is above zero", _finalScore > 0] call test_Assert;

	T_CALLM("applyToSim", [_world]);
	true
	// ["Object exists", !(isNil "_class")] call test_Assert;
	// ["Initial state is correct", GETV(_obj, "state") == CMDR_ACTION_STATE_START] call test_Assert;
}] call test_AddTest;

#endif