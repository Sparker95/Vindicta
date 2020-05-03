#include "common.hpp"

/*
Class: AI.AIUnitCivilian

AI for wandering civilians

Author: Sparker 12.11.2018
*/

#define OOP_CLASS_NAME AIUnitCivilian
CLASS("AIUnitCivilian", "AI_GOAP")

	// This guy feels in danger
	VARIABLE("danger");

	// Civilian presence module
	VARIABLE("cpModule");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent"), P_OBJECT("_cpModule")];
		
		T_SETV("danger", false);
		T_SETV("cpModule", _cpModule);
	ENDMETHOD;

	//                        G E T   P O S S I B L E   G O A L S
	METHOD(getPossibleGoals)
		[]
	ENDMETHOD;

	//                      G E T   P O S S I B L E   A C T I O N S
	/*
	*/
	METHOD(getPossibleActions)
		[]
	ENDMETHOD;

ENDCLASS;