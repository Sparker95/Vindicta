#include "common.hpp"

/*
Class: AI.AIUnitCivilian

AI for wandering civilians

Author: Sparker 12.11.2018
*/

#define pr private

#define OOP_CLASS_NAME AIUnitCivilian
CLASS("AIUnitCivilian", "AIUnitHuman")

	// This guy feels in danger
	VARIABLE("danger");

	// Civilian presence module
	VARIABLE("civPresence");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent"), P_OOP_OBJECT("_civPresence")];

		ASSERT_OBJECT_CLASS(_civPresence, "CivPresence");
		
		T_SETV("danger", false);
		T_SETV("civPresence", _civPresence);

		pr _hO = CALLM0(_agent, "getObjectHandle");

		// Add event handlers
		_ho addEventHandler ["hit", {
			CALLSM1("AIUnitCivilian", "dangerEventHandler", _this select 0);
		}];

		_ho addEventHandler ["firedNear", {
			CALLSM1("AIUnitCivilian", "dangerEventHandler", _this select 0);
		}];
	ENDMETHOD;

	// Event Handler attached to arma object handle
	STATIC_METHOD(dangerEventHandler)
		params ["_thisClass", "_hO"];
		pr _civ = CALLSM1("Civilian", "getCivilianFromObjectHandle", _hO);
		pr _ai = CALLM0(_civ, "getAI");

		// Bail of no AI
		if (IS_NULL_OBJECT(_ai)) exitWith { nil };

		SETV(_ai, "danger", true);
		CALLM0(_ai, "setUrgentPriority");

		// Return nothing if this EH is stacked, we don't override anything
		nil
	ENDMETHOD;

	/* override */ METHOD(start)
		params [P_THISOBJECT];
		T_CALLM1("addToProcessCategory", "MiscLowPriority");
	ENDMETHOD;

	//                        G E T   P O S S I B L E   G O A L S
	METHOD(getPossibleGoals)
		[
			"GoalCivilianPanicNearest",
			"GoalCivilianPanicAway"
		]
	ENDMETHOD;

	//                      G E T   P O S S I B L E   A C T I O N S
	METHOD(getPossibleActions)
		[]
	ENDMETHOD;

	// Returns array of class-specific additional variable names to be transmitted to debug UI
	/* override */ METHOD(getDebugUIVariableNames)
		[
			"danger",
			"civPresence"
		]
	ENDMETHOD;

ENDCLASS;