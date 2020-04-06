#include "common.hpp"
#include "..\..\Undercover\UndercoverMonitor.hpp"

/*
Author: Marvis 09.05.2019
*/

#define IS_ARRESTED_UNCONSCIOUS_DEAD(target) (!alive (target) || {animationState (target) in ["unconsciousoutprone", "unconsciousfacedown", "unconsciousfaceup", "unconsciousrevivedefault", "acts_aidlpsitmstpssurwnondnon_loop", "acts_aidlpsitmstpssurwnondnon01"]})
#define pr private

CLASS("GoalGroupArrest", "Goal")

	STATIC_METHOD("calculateRelevance") {
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		pr _group = GETV(_AI, "agent");
		pr _groupType = CALLM(_group, "getType", []);

		if(!(_groupType in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL])) exitWith { 0 };

		pr _hG = CALLM0(_group, "getGroupHandle");

		if (behaviour leader _hG == "COMBAT") exitWith { 0 };
		
		pr _suspTarget = GETV(_AI, "suspTarget");
		if (!isNil "_suspTarget" && {!IS_ARRESTED_UNCONSCIOUS_DEAD(_suspTarget)}) then {
			GETSV("GoalGroupArrest", "relevance");
		} else {
			0
		}

	} ENDMETHOD;

	STATIC_METHOD("createPredefinedAction") {
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		//OOP_INFO_0("GoalGroupArrest: Creating predefined action.");

		pr _target = GETV(_AI, "suspTarget");
		pr _parameters = [_AI, [[TAG_TARGET, _target]]];
		//OOP_INFO_1("GoalGroupArrest: Target: %1", _target);

		pr _action = NEW("ActionGroupArrest", _parameters);

		//OOP_INFO_0("GoalGroupArrest: Predefined action created.");

		_action

	} ENDMETHOD;

ENDCLASS;