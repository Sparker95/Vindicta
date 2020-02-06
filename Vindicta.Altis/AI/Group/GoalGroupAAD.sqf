#include "common.hpp"

/*
Author: Marvis 06.02.2020
*/

#define pr private

CLASS("GoalGroupAAD", "Goal")

STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];

		OOP_INFO_0("GoalGroupAAD: Evaluating relevance.");

		pr _relevance = 0;
		pr _suspTarget = GETV(_AI, "suspTarget");
		pr _group = GETV(_AI, "agent");
		pr _groupType = CALLM(_group, "getType", []);		
		if(!(_groupType in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL])) exitWith { 0 };

		pr _hG = CALLM0(_group, "getGroupHandle");

		if !(isNil "_suspTarget") then { 
			OOP_INFO_0("GoalGroupAAD: Evaluating relevance.");
			if (behaviour leader _hG != "COMBAT") then { 
				_relevance = 0;
			} else {
				_relevance = GETSV("GoalGroupAAD", "relevance");
			};
		};
			
		OOP_INFO_1("GoalGroupAAD Relevance: %1", _relevance);
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