#include "..\..\common.h"
#include "..\WorldState\WorldState.hpp"

/*
Class: Goal
Every goal is static, that is, not instantiated.
*/

#define pr private

#define OOP_CLASS_NAME Goal
CLASS("Goal", "")

	STATIC_VARIABLE("effects"); // Effects world state
	STATIC_VARIABLE("predefinedAction"); // A single action which clearly satisfies this goal, if A* usage is not intended for this goal
	STATIC_VARIABLE("relevance");

	// We don't need NEW and DELETE because goals don't need to be instantiated

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------

	METHOD(new)
		params [P_THISOBJECT];
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------

	METHOD(delete)
		params [P_THISOBJECT];
	ENDMETHOD;



	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	// By default returns instrinsic goal relevance

	/* virtual */ STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		pr _intrinsicRelevance = GET_STATIC_VAR(_thisClass, "relevance");
		 // Return relevance
		_intrinsicRelevance
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// By default it gets predefined action from database if it is defined and creates it, passing a goal parameter to action parameter, if it exists
	// This method must be redefined for goals that have predefined actions that require parameters not from goal parameters

	/* virtual */ STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		// Return predefined action from the database
		pr _actionClass = GET_STATIC_VAR(_thisClass, "predefinedAction");
		if (!(isNil "_actionClass")) then {
			if (!(_actionClass == "")) then {
				// Also pass the parameter from the goal to the action
				pr _args = [_AI, _parameters];
				pr _action = NEW(_actionClass, _args);
				_action
			} else {
				// Return no action
				""
			};
		} else {
			// Return no action
			""
		};
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                      G E T   E F F E C T S
	// ----------------------------------------------------------------------
	// This method is only needed for goals without predefined actions, because they must use A* planner instead
	// By default this method returns the value from the database
	// This method must be redefined for goals that return effects which are not static and are not dependant on goal parameter
	// Example: "Move" goal can return world state with 'position' property equal to parameter thus does not need to reimplement this method
	// "HealYourself" goal can return a standard world state effect from database, thus doesn't need to reimplement this method
	// "GoToNearestCover" can't derive its effect from parameter and is not static, but is supplied by internal logic, therefore this goal must implement this method

	/* virtual */ STATIC_METHOD(getEffects)
		pr _paramsGood = params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		if (!_paramsGood) then {
			DUMP_CALLSTACK;
		};

		// Return effects from the database
		pr _effects = GET_STATIC_VAR(_thisClass, "effects");
		_effects = +_effects;

		// If the parameters were specified, try to apply them to the effects
		if ((count _parameters) > 0) then {
			pr _success = [_effects, _parameters] call ws_applyParametersToGoalEffects;

			// If parameter could not be matched to a world state property, print an error
			if (!_success) then {
				diag_log format ["[%1::getEffects] Error: Parameter was supplied but could not be applied to goal effect! WS: %2,  parameters: %3",
					_thisClass, [_effects] call ws_toString, _parameters];

				// Clear all properties
				pr _size = [_effects] call ws_getSize;
				for "_i" from 0 to (_size - 1) do {
					[_effects, _i] call ws_clearProperty;
				};
				_effects
			} else {
				_effects;
			}
		} else {
			_effects
		};
	ENDMETHOD;

	// Gets called when an external goal of this class is added to AI
	STATIC_METHOD(onGoalAdded)
		params ["_thisClass", P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
	ENDMETHOD;

	// Gets called when an external goal of this class is removed from an AI
	STATIC_METHOD(onGoalDeleted)
		params ["_thisClass", P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
	ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR("Goal", "effects", []);
