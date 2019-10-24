#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryRegroup
Makes a unit follow his leader
*/

#define pr private

CLASS("ActionUnitInfantryRegroup", "ActionUnit")
	
	// ------------ N E W ------------
	
	/*
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];		
	} ENDMETHOD;
	*/
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		pr _hO = T_GETV("hO");

		// Handle AI just spawned state
		pr _AI = T_GETV("AI");
		if (GETV(_AI, "new")) then {

			// Instantly move the unit into its required formation position
			pr _pos = getPos (leader group _hO);
			_hO setPos _pos;

			SETV(_AI, "new", false);
		};

		
		// Regroup
		_hO doFollow (leader _hO);
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
		
		// Return ACTIVE state
		ACTION_STATE_COMPLETED
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	/*
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	*/
	
ENDCLASS;