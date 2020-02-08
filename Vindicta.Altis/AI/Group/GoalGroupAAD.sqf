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

		pr _group = GETV(_AI, "agent");
		pr _groupType = CALLM(_group, "getType", []);		
		if(!(_groupType in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL])) exitWith { 0 };
		_relevance = GETSV("GoalGroupAAD", "relevance");	
		OOP_INFO_1("GoalGroupAAD final relevance: %1", _relevance);
		_relevance	

	} ENDMETHOD;

	STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];

		OOP_INFO_0("GoalGroupAAD: Creating predefined action.");

		pr _target = GETV(_AI, "suspTarget");
		pr _parameters = [_AI, [["target", _target]]];
		OOP_INFO_1("GoalGroupAAD: Target: %1", _target);

		pr _action = NEW("ActionGroupAAD", _parameters);

		OOP_INFO_0("GoalGroupAAD: Predefined action created.");

		_action

	} ENDMETHOD;

ENDCLASS;