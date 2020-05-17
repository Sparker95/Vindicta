#include "common.hpp"

#define OOP_CLASS_NAME GoalGarrisonAirRtB
CLASS("GoalGarrisonAirRtB", "Goal")
	/* override */ STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		private _garr = GETV(_AI, "agent");
		if(CALLM0(_garr, "getLocation") == NULL_OBJECT) then {
			GETSV("GoalGarrisonAirRtB", "relevance")
		} else {
			0
		}
	ENDMETHOD;

	/* override */ STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		// Return to home base
		private _garr = GETV(_AI, "agent");
		private _home = CALLM0(_garr, "getHome");

		// TODO: check home is still held by us, select new home if its not appropriate
		if(_home != NULL_OBJECT) then {
			private _args = [_AI, _parameters + [[TAG_LOCATION, _home]]];
			private _action = NEW("ActionGarrisonJoinLocation", _args);
			_action
		} else {
			NULL_OBJECT
		}
	ENDMETHOD;
ENDCLASS;