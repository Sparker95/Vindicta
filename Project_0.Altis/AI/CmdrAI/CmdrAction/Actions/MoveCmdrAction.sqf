#include "..\..\common.hpp"

CLASS("MoveCmdrAction", "CmdrAction")

	// ID of the garrison
	VARIABLE("garrId");

	// Target where to move to
	VARIABLE("target");

	// Move radius, only makes sense if position is specified
	// Otherwise it is determined automatically
	VARIABLE("radius");

	// _garrID - the ID of the garrison to move
	// _target - target variable
	METHOD("new") {
		PARAMS[P_THISOBJECT, P_NUMBER("_garrID"), P_ARRAY("_target"), ["_radius", 100] ];

		T_SETV("garrId", _garrID);
		T_SETV("target", _target);
		T_SETV("radius", _radius);


	} ENDMETHOD;

	/* protected override */ METHOD("createTransitions") {
		params [P_THISOBJECT];

		T_PRVAR(garrId);
		T_PRVAR(target);

		// Assign the action we are performing to the garrison (so it is marked as busy for other actions)
		private _assignAST_Args = [
				_thisObject, 						// This action, gets assigned to the garrison
				[CMDR_ACTION_STATE_START], 			// Do this at start
				CMDR_ACTION_STATE_READY_TO_MOVE, 	// State change when successful (can't fail)
				_garrId]; 					// Id of garrison to assign the action to
		private _assignAST = NEW("AST_AssignActionToGarrison", _assignAST_Args);

		// Add the move action
		private _garrIdVar = MAKE_AST_VAR(_garrId);
		private _targetVar = MAKE_AST_VAR(_target);
		private _moveAST_Args = [
				_thisObject, 						// This action (for debugging context)
				[CMDR_ACTION_STATE_READY_TO_MOVE],	// 		
				CMDR_ACTION_STATE_END, 				// State change when successful
				CMDR_ACTION_STATE_END,				// State change when garrison is dead (just terminate the action)
				CMDR_ACTION_STATE_END, 				// State change when target is dead
				_garrIdVar, 						// Id of garrison to move
				_targetVar, 						// Target to move to (various target types are supported by this AST)
				MAKE_AST_VAR(150)]; 				// Radius to move within !!! todo improve this,  
		private _moveAST = NEW("AST_MoveGarrison", _moveAST_Args);

		[_assignAST, _moveAST]
	} ENDMETHOD;

ENDCLASS;