#include "common.hpp"

/*
Author: Marvis 09.05.2019
*/

#define pr private

CLASS("GoalGroupArrest", "Goal")

	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];

		OOP_INFO_0("GoalGroupArrest: Evaluating relevance.");

			pr _relevance = 0;
			pr _suspTarget = GETV(_AI, "suspTarget");

			if !(isNil "_suspTarget") then { 
				OOP_INFO_1("GoalGroupArrest target: ", _suspTarget);
				_relevance = 30;
			} else {
				OOP_INFO_0("Evaluating relevance.");
				_relevance = 0;
			};
			
		OOP_INFO_1("GoalGroupArrest: Relevance: %1", _relevance);
		_relevance	

	} ENDMETHOD;

	STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];

	} ENDMETHOD;

ENDCLASS;