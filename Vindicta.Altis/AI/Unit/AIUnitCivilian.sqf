#include "common.hpp"

/*
Class: AI.AIUnitCivilian

AI for wandering civilians

Author: Sparker 12.11.2018
*/

#define OOP_CLASS_NAME AIUnitCivilian
CLASS("AIUnitCivilian", "AI_GOAP")

	//                        G E T   P O S S I B L E   G O A L S
	METHOD(getPossibleGoals)
		["GoalUnitSalute","GoalUnitScareAway"]
	ENDMETHOD;

	//                      G E T   P O S S I B L E   A C T I O N S
	/*
	*/
	METHOD(getPossibleActions)
		["ActionUnitSalute","ActionUnitScareAway"]
	ENDMETHOD;

ENDCLASS;