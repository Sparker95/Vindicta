#include "common.hpp"

/*
NOT USED ANY MORE?!?!?!?!!?!?!?!
*/

/*
Class: ActionGroup.ActionGroupOccupySentryPositions
All members of this group will move to their assigned sentry positions.
*/

#define pr private

#define OOP_CLASS_NAME ActionGroupOccupySentryPositions
CLASS("ActionGroupOccupySentryPositions", "ActionGroup")
	
	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		OOP_INFO_0("ACTIVATE");
		
		// Add goals to all units
		pr _AI = T_GETV("AI");
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _units = CALLM0(_group, "getUnits");
		{ // foreach units
			pr _unit = _x;
			pr _unitAI = CALLM0(_unit, "getAI");
			pr _sentryPos = CALLM0(_unitAI, "getSentryPos");
			
			// Remove similar external goals from this AI
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryMove", _AI);
			
			if (count _sentryPos > 0) then {
				pr _parameters = [
					[TAG_POS, _sentryPos],
					[TAG_INSTANT, _instant]
				];
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryMove", 0, _parameters, _AI);
			} else {
				pr _unitData = CALLM0(_unit, "getData");
				OOP_WARNING_2("SENTRY position not assigned for unit: %1, %2", _unit, _unitData);
			};
		} forEach _units;

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
		
	ENDMETHOD;
	
	// Logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		
		T_CALLM0("failIfEmpty");
		
		pr _state = T_CALLM0("activateIfInactive");
		
		/*
		// Shout at subordinates
		
		if (random 100 < 4) then {
			radio "Johny, stop fucking around, move into this house!";
		};
		
		if (random 100 < 4) then {
			radio "For fucks sake, did you get stuck in the middle of nowhere again?!";
		}
		*/
		
		// It's NEVER OVER!
		_state
	ENDMETHOD;
	
	public override METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		//OOP_INFO_1("Unit removed: %1", _unit);
	ENDMETHOD;

ENDCLASS;

/*
// Sentry
_unit = cursorObject;
_goalClassName = "GoalGroupOccupySentryPositions";
_parameters = [];
CALL_COMPILE_COMMON("AI\Misc\testFunctions.sqf");
[_unit, _goalClassName, _parameters] call AI_misc_fnc_addGroupGoal;
*/