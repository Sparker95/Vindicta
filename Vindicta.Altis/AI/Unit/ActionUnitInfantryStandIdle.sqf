#include "common.hpp"

/*
Unit will stand at one place for fixed amount of time.
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitInfantryStandIdle
CLASS("ActionUnitInfantryStandIdle", "ActionUnit")
	
	VARIABLE("timeComplete"); // Time when this is complete
	VARIABLE("duration");

	METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_STAND_IDLE, [[], objNull, NULL_OBJECT] ], [TAG_DURATION_SECONDS, [0]] ],	// Required parameters
			[ [TAG_BUILDING_POS_ID, [0]] ]	// Optional parameters
		]
	ENDMETHOD;
	
	// ------------ N E W ------------
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _duration = GET_PARAMETER_VALUE(_parameters, TAG_DURATION_SECONDS);
		T_SETV("duration", _duration);
		T_SETV("timeComplete", 0); // It's changed in activate
	ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT];
		
		pr _timeComplete = T_GETV("duration") + GAME_TIME;
		T_SETV("timeComplete", T_GETV("duration") + GAME_TIME);
		
		pr _ai = T_GETV("ai");
		CALLM0(_ai, "stopMoveToTarget"); // Orders unit to stop

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];
		
		pr _state = T_CALLM0("activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			if (GAME_TIME > T_GETV("timeComplete")) then {
				CALLM1(T_GETV("ai"), "setHasInteractedWSP", true);
				_state = ACTION_STATE_COMPLETED;
			};
		};
		
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	/*
	METHOD(terminate)
		params [P_THISOBJECT];
	ENDMETHOD;
	*/
	
ENDCLASS;