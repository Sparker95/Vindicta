#include "common.hpp"

/*
Unused, not necessarily fully implemented, not tested.
CmdrAI garrison retreat from current location to target location.
TODO: Could this just be a general move action? Perhaps specific behaviours
apply when retreating that don't for a normal move. Careless mode etc?
*/
#define OOP_CLASS_NAME RetreatCmdrAction
CLASS("RetreatCmdrAction", "CmdrAction")
	VARIABLE_ATTR("srcGarrId", [ATTR_SAVE]);
	VARIABLE_ATTR("targetVar", [ATTR_SAVE]);
	VARIABLE_ATTR("startDateVar", [ATTR_SAVE]);

	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_srcGarrId"), P_ARRAY("_target")];

		T_SETV("srcGarrId", _srcGarrId);
		// Target can be modified during the action, if the initial target dies, so we want it to save/restore.
		private _targetVar = T_CALLM("createVariable", [_target]);
		T_SETV("targetVar", _targetVar);

		// Start date for this action, default to immediate
		private _startDateVar = T_CALLM1("createVariable", DATE_NOW);
		T_SETV("startDateVar", _startDateVar);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		{ DELETE(_x) } forEach T_GETV("transitions");

#ifdef DEBUG_CMDRAI
		deleteMarker (_thisObject + "_line");
		deleteMarker (_thisObject + "_label");
#endif
	ENDMETHOD;

	/* protected override */ METHOD(createTransitions)
		params [P_THISOBJECT];

		private _srcGarrId = T_GETV("srcGarrId");
		private _targetVar = T_GETV("targetVar");
		private _startDateVar = T_GETV("startDateVar");

		// Call MAKE_AST_VAR directly because we don't won't the CmdrAction to automatically push and pop this value 
		// (it is a constant for this action so it doesn't need to be saved and restored)
		private _srcGarrIdVar = T_CALLM1("createVariable", _srcGarrId);

		private _assignAST_Args = [
				_thisObject, 						// This action, gets assigned to the garrison
				[CMDR_ACTION_STATE_START], 			// Do this after splitting
				CMDR_ACTION_STATE_ASSIGNED, 		// State change when successful (can't fail)
				_srcGarrIdVar]; 					// Id of garrison to assign the action to
		private _assignAST = NEW("AST_AssignActionToGarrison", _assignAST_Args);

		private _waitAST_Args = [
				_thisObject,						// This action (for debugging context)
				[CMDR_ACTION_STATE_ASSIGNED], 		// Start wait after we assigned the action to the detachment
				CMDR_ACTION_STATE_READY_TO_MOVE, 	// State change if successful2
				CMDR_ACTION_STATE_END, 				// State change if failed (go straight to end of action)
				_startDateVar,						// Date to wait until
				_srcGarrIdVar];						// Garrison to wait (checks it is still alive)
		private _waitAST = NEW("AST_WaitGarrison", _waitAST_Args);

		T_GET_AST_VAR(_targetVar) params ["_targetType", "_target"];

		private _moveAST = if(_targetType == TARGET_TYPE_GARRISON) then {
			// If we are merging to a garrison we will just move there and merge
			private _moveAST_Args = [
					_thisObject, 						// This action (for debugging context)
					[CMDR_ACTION_STATE_READY_TO_MOVE], 		
					CMDR_ACTION_STATE_MOVED, 			// State change when successful
					CMDR_ACTION_STATE_END,				// State change when garrison is dead (just terminate the action)
					CMDR_ACTION_STATE_TARGET_DEAD, 		// State change when target is dead
					_srcGarrIdVar, 						// Id of garrison to move
					_targetVar, 						// Target to move to (initially the target garrison)
					T_CALLM1("createVariable", 200)]; 				// Radius to move within
			NEW("AST_MoveGarrison", _moveAST_Args)
		} else {
			// If we are occupying a location we will attack and clear the area then occupy it (attack includes move)
			private _attackAST_Args = [
					_thisObject,
					[CMDR_ACTION_STATE_READY_TO_MOVE], 	// Once we are split and assigned the action we can go
					CMDR_ACTION_STATE_MOVED,			// State when we succeed, it leads to occupying the location
					CMDR_ACTION_STATE_END, 				// If we are dead then go to end
					CMDR_ACTION_STATE_MOVED,			// If we timeout then occupy the location
					_srcGarrIdVar, 						// Id of the garrison doing the attacking
					_targetVar, 						// Target to attack (cluster or garrison supported)
					T_CALLM1("createVariable", 500)];					// Move radius
			NEW("AST_GarrisonAttackTarget", _attackAST_Args)
		};

		private _mergeAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_MOVED], 			// Merge once we reach the destination (whatever it is)
				CMDR_ACTION_STATE_END, 				// Once merged we are done
				CMDR_ACTION_STATE_END, 				// If the detachment is dead then we can just end the action
				CMDR_ACTION_STATE_TARGET_DEAD, 		// If the target is dead then reselect a new target
				_srcGarrIdVar, 						// Id of the garrison we are merging
				_targetVar]; 						// Target to merge to (garrison or location is valid)
		private _mergeAST = NEW("AST_MergeOrJoinTarget", _mergeAST_Args);

		private _newTargetAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_TARGET_DEAD], 	// We select a new target when the old one is dead
				CMDR_ACTION_STATE_READY_TO_MOVE, 	// State change when successful
				T_CALLM1("createVariable", MODEL_HANDLE_INVALID), // No src garrison as we are retreating
				_srcGarrIdVar, 						// Id of the garrison we are moving (for context)
				_targetVar]; 						// New target
		private _newTargetAST = NEW("AST_SelectFallbackTarget", _newTargetAST_Args);

		[_assignAST, _waitAST, _moveAST, _mergeAST, _newTargetAST]
	ENDMETHOD;
	
	/* protected override */ METHOD(getLabel)
		params [P_THISOBJECT, P_STRING("_world")];

		private _srcGarrId = T_GETV("srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		private _srcEff = GETV(_srcGarr, "efficiency");
		private _state = T_GETV("state");

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
		format ["%1 %2%3 -> %4%5", _thisObject, LABEL(_srcGarr), _srcEff, _targetName, _timeToStart]
	ENDMETHOD;

/* protected override */ METHOD(updateIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");
		ASSERT_MSG(CALLM0(_world, "isReal"), "Can only updateIntel from real world, this shouldn't be possible as updateIntel should ONLY be called by CmdrAction");

		T_GET_AST_VAR("targetVar") params ["_targetType", "_target"];
		private _srcGarrId = T_GETV("srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);

		private _intelClone = T_GETV("intelClone");
		private _intel = NULL_OBJECT;

		private _intelNotCreated = IS_NULL_OBJECT(_intelClone);
		if(_intelNotCreated) then
		{
			// Create new intel object and fill in the constant values
			_intel = NEW("IntelCommanderActionRetreat", []);
			CALLM0(_intel, "create");
		
			switch(_targetType) do {
				case TARGET_TYPE_LOCATION: {
					private _tgtLoc = CALLM(_world, "getLocation", [_target]);
					ASSERT_OBJECT(_tgtLoc);
					SETV(_intel, "tgtLocation", GETV(_tgtLoc, "actual"));
					SETV(_intel, "posTgt", GETV(_tgtLoc, "pos"));
				};
				case TARGET_TYPE_GARRISON: {
					private _tgtGarr = CALLM(_world, "getGarrison", [_target]);
					ASSERT_OBJECT(_tgtGarr);
					SETV(_intel, "tgtGarrison", GETV(_tgtGarr, "actual"));
					SETV(_intel, "posTgt", GETV(_tgtGarr, "pos"));
				};
			};

		};

		// Update progress of the garrison
		private _srcGarrId = T_GETV("srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		private _intelUpdate = if (_intelNotCreated) then {_intel} else {_intelClone};
		SETV(_intelUpdate, "garrison", GETV(_srcGarr, "actual"));
		SETV(_intelUpdate, "pos", GETV(_srcGarr, "pos"));
		SETV(_intelUpdate, "posCurrent", GETV(_srcGarr, "pos"));
		SETV(_intelUpdate, "strength", GETV(_srcGarr, "efficiency"));

		// If we just created this intel then register it now 
		// (we don't want to do this above before we have updated it or it will result in a partial intel record)
		if(_intelNotCreated) then {
			_intelClone = CALL_STATIC_METHOD("AICommander", "registerIntelCommanderAction", [_intel]);
			T_SETV("intelClone", _intelClone);
		} else {
			CALLM0(_intelClone, "updateInDb");
		};

		// If we have reached a certain state, mark action intel as active
		if (T_GETV("state") == CMDR_ACTION_STATE_READY_TO_MOVE) then {
			T_CALLM1("setIntelState", INTEL_ACTION_STATE_ACTIVE);
		};
	ENDMETHOD;
	
	/* protected override */ METHOD(debugDraw)
		params [P_THISOBJECT, P_STRING("_world")];

		private _srcGarrId = T_GETV("srcGarrId");
		private _srcGarr = CALLM(_world, "getGarrison", [_srcGarrId]);
		ASSERT_OBJECT(_srcGarr);
		private _srcGarrPos = GETV(_srcGarr, "pos");

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

		// private _detachedGarrId = T_GET_AST_VAR("detachedGarrIdVar");
		// if(_detachedGarrId != MODEL_HANDLE_INVALID) then {
		// 	private _detachedGarr = CALLM(_world, "getGarrison", [_detachedGarrId]);
		// 	ASSERT_OBJECT(_detachedGarr);
		// 	private _detachedGarrPos = GETV(_detachedGarr, "pos");
		// 	[_detachedGarrPos, _centerPos, "ColorBlack", 4, _thisObject + "_line2"] call misc_fnc_mapDrawLine;
		// };
	ENDMETHOD;

ENDCLASS;
