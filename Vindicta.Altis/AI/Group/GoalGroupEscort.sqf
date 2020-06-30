#include "common.hpp"

/*
Group will follow an escort target stored in AIGroup.escortObject
*/

#define pr private

#define OOP_CLASS_NAME GoalGroupEscord
CLASS("GoalGroupEscort", "GoalGroup")

	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		// This goal is relevant when we have an escort object in our memory
		pr _escortObj = GETV(_ai, "escortObject");
		if (isNull _escortObj) exitWith {0;};

		GETSV("GoalGroupEscort", "relevance");
	ENDMETHOD;
	
	public STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		private _actionSerial = NEW("ActionCompositeSerial", [_AI]);

		pr _escortObj = GETV(_ai, "escortObject");
		pr _actionParams = [[TAG_TARGET, _escortObj], [TAG_FOLLOW_RADIUS, 5]];
		private _action = NEW("ActionGroupFollow", [_AI ARG _actionParams]);
		CALLM1(_actionSerial, "addSubactionToBack", _action);
		_actionSerial;
	ENDMETHOD;

ENDCLASS;