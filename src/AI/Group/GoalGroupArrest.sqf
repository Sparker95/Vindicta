#include "common.hpp"
#include "..\..\Undercover\UndercoverMonitor.hpp"

/*
Author: Marvis 09.05.2019
*/

#define IS_ARRESTED_UNCONSCIOUS_DEAD(target) (!alive (target) || {animationState (target) in ["unconsciousoutprone", "unconsciousfacedown", "unconsciousfaceup", "unconsciousrevivedefault", "acts_aidlpsitmstpssurwnondnon_loop", "acts_aidlpsitmstpssurwnondnon01"]})
#define pr private

#define OOP_CLASS_NAME GoalGroupArrest
CLASS("GoalGroupArrest", "GoalGroup")

	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		pr _group = GETV(_AI, "agent");
		pr _groupType = CALLM0(_group, "getType");		
		if(_groupType != GROUP_TYPE_INF) exitWith { 0 };

		pr _hG = CALLM0(_group, "getGroupHandle");

		if (behaviour leader _hG == "COMBAT") exitWith { 0 };
		
		pr _suspTarget = GETV(_AI, "suspTarget");
		if (!isNull _suspTarget && {!IS_ARRESTED_UNCONSCIOUS_DEAD(_suspTarget)}) then {
			GETSV("GoalGroupArrest", "relevance");
		} else {
			0
		}

	ENDMETHOD;

	public STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		//OOP_INFO_0("GoalGroupArrest: Creating predefined action.");

		pr _target = GETV(_AI, "suspTarget");
		pr _parameters = [_AI, [[TAG_TARGET_ARREST, _target]]];
		//OOP_INFO_1("GoalGroupArrest: Target: %1", _target);

		pr _action = NEW("ActionGroupArrest", _parameters);

		//OOP_INFO_0("GoalGroupArrest: Predefined action created.");

		_action

	ENDMETHOD;

ENDCLASS;