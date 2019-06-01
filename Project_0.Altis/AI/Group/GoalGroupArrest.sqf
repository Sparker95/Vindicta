#include "common.hpp"
#include "..\..\Undercover\UndercoverMonitor.hpp"

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
			pr _group = GETV(_AI, "agent");
			pr _hG = CALLM0(_group, "getGroupHandle");

			if !(isNil "_suspTarget") then { 
				if (behaviour (leader _hG) == "COMBAT") exitWith { _relevance = 0; };
				if !(UNDERCOVER_IS_TARGET(_suspTarget)) then {
					_relevance = 120;
					//_suspTarget setVariable [UNDERCOVER_TARGET, true, true];	
				}; 
			} else {
				OOP_INFO_0("GoalGroupArrest: Evaluating relevance.");
				_relevance = 0;
			};
			
		OOP_INFO_1("GoalGroupArrest: Relevance: %1", _relevance);
		_relevance	

	} ENDMETHOD;

	STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];

		OOP_INFO_0("GoalGroupArrest: Creating predefined action.");

		pr _target = GETV(_AI, "suspTarget");
		pr _parameters = [_AI, [["target", _target]]];
		OOP_INFO_1("GoalGroupArrest: Target: %1", _target);

		pr _action = NEW("ActionGroupArrest", _parameters);

		OOP_INFO_0("GoalGroupArrest: Predefined action created.");

		_action

	} ENDMETHOD;

ENDCLASS;