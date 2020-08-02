#include "common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.Actions.MoveCmdrAction
Action to make an already existing garrison reinforce something.
Target can be garrison or location.
Not meant for simulations.

Parent: <CmdrAction>
*/

#define OOP_CLASS_NAME DirectReinforceCmdrAction
CLASS("DirectReinforceCmdrAction", "CmdrAction")

	// ID of the garrison
	VARIABLE_ATTR("garrId", [ATTR_SAVE]);

	// Target where to move to
	VARIABLE_ATTR("target", [ATTR_SAVE]);

	// Move radius, only makes sense if position is specified
	// Otherwise it is determined automatically
	VARIABLE_ATTR("radius", [ATTR_SAVE]);

	// _garrID - the ID of the garrison to move
	// _target - target variable
	METHOD(new)
		PARAMS[P_THISOBJECT, P_NUMBER("_garrID"), P_ARRAY("_target") ];

		T_SETV("garrId", _garrID);
		T_SETV("target", _target);

	ENDMETHOD;

	protected override METHOD(createTransitions)
		params [P_THISOBJECT];

		private _garrId = T_GETV("garrId");
		private _target = T_GETV("target");

		// Assign the action we are performing to the garrison (so it is marked as busy for other actions)
		private _garrIdVar = T_CALLM1("createVariable", _garrId);
		private _assignAST_Args = [
				_thisObject, 						// This action, gets assigned to the garrison
				[CMDR_ACTION_STATE_START], 			// Do this at start
				CMDR_ACTION_STATE_READY_TO_MOVE, 	// State change when successful (can't fail)
				_garrIdVar]; 					// Id of garrison to assign the action to
		private _assignAST = NEW("AST_AssignActionToGarrison", _assignAST_Args);

		// Add the move action
		private _targetVar = T_CALLM1("createVariable", _target);
		private _moveAST_Args = [
				_thisObject, 						// This action (for debugging context)
				[CMDR_ACTION_STATE_READY_TO_MOVE],	// 		
				CMDR_ACTION_STATE_MOVED,			// State change when successful
				CMDR_ACTION_STATE_END,				// State change when garrison is dead (just terminate the action)
				CMDR_ACTION_STATE_END, 				// State change when target is dead
				_garrIdVar, 						// Id of garrison to move
				_targetVar, 						// Target to move to (various target types are supported by this AST)
				T_CALLM1("createVariable", 200)]; 				// Radius to move within !!! todo improve this,  
		private _moveAST = NEW("AST_MoveGarrison", _moveAST_Args);

		// Add the merge action
		private _mergeAST_Args = [
				_thisObject,
				[CMDR_ACTION_STATE_MOVED], 			// Merge once we reach the destination (whatever it is)
				CMDR_ACTION_STATE_END, 				// Once merged we are done
				CMDR_ACTION_STATE_END, 				// If the detachment is dead then we can just end the action
				CMDR_ACTION_STATE_END, 				// If the target is dead then end the action too
				_garrIdVar, 						// Id of the garrison we are merging
				_targetVar]; 						// Target to merge to (garrison or location is valid)
		private _mergeAST = NEW("AST_MergeOrJoinTarget", _mergeAST_Args);

		[_assignAST, _moveAST, _mergeAST]
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
		private _record = NEW("ReinforceCmdrActionRecord", []);

		// Fill data values
		//SETV(_record, "garRef", GETV(_garModel, "actual"));

		// Resolve target
		private _target = T_GETV("target");
		_target params ["_tgtType", "_tgtTarget"];
		switch (_tgtType) do {
			case TARGET_TYPE_LOCATION: {
				// It's a location model
				private _locModel = CALLM1(_world, "getLocation", _tgtTarget);
				SETV(_record, "locRef", GETV(_locModel, "actual"));
			};
			case TARGET_TYPE_GARRISON: {
				// It's a garrison model
				private _garModel = CALLM1(_world, "getGarrison", _tgtTarget);
				SETV(_record, "dstGarRef", GETV(_garModel, "actual"));
			};
			case TARGET_TYPE_POSITION: {
				SETV(_record, "pos", _tgtTarget);
			};
			default {
				OOP_ERROR_2("Target type %1 is not implemented, target: %1", _tgtType, _tgtTarget);
			};
		};

		// Serialize and delete it
		private _serial = SERIALIZE(_record);
		DELETE(_record);

		// Return the serialized data
		_serial
	ENDMETHOD;

ENDCLASS;