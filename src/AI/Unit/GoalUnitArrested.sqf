#include "common.hpp"

/*
Active when unit is arrested.
The bot will just sit and do nothing.
*/

#define OOP_CLASS_NAME GoalUnitArrested
CLASS("GoalUnitArrested", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [] ],	// Required parameters
			[ [] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		// Relevant if arrested
		if (GETV(_ai, "arrested")) then {
			GETSV(_thisClass, "relevance");
		} else {
			0
		};
	ENDMETHOD;

ENDCLASS;