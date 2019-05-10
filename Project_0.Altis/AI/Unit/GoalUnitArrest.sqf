#include "common.hpp"

/*
Author: Marvis 09.05.2019
*/

#define pr private

CLASS("GoalUnitArrest", "Goal")

	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];

			OOP_INFO_0("Evaluating relevance.");

	} ENDMETHOD;


ENDCLASS;