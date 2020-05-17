#include "common.hpp"

// Class: AI.Garrison.GoalGarrisonRelax
// Garrison will let down their guard.
// Only allowed when garrison is not in a vigilant state
#define OOP_CLASS_NAME GoalGarrisonRelax
CLASS("GoalGarrisonRelax", "Goal")

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		// What is the garrison alert level?
		if (GAME_TIME - GETV(_AI, "lastBusyTime") > AI_GARRISON_IDLE_TIME_THRESHOLD && { !CALLM0(_AI, "isVigilant") }) then { // Have we been idling for too long?
			GETSV("GoalGarrisonRelax", "relevance")
		} else {
			0
		};
	ENDMETHOD;

	STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _ws = GETV(_AI, "worldState");

		private _actionSerial = NEW("ActionCompositeSerial", [_AI]);

		// If groups are merged, split them
		// Split them anyway every time, because we currently don't update the world state property value periodically anyway
		// :// It seems to break something, let's disable it for now :(
		//if ([_ws, WSP_GAR_VEHICLE_GROUPS_MERGED, true] call ws_propertyExistsAndEquals) then {
			/*
			private _parameters = [[TAG_MERGE, false]];
			private _args = [_AI, _parameters];
			private _actionSplit = NEW("ActionGarrisonMergeVehicleGroups", _args);
			CALLM1(_actionSerial, "addSubactionToBack", _actionSplit);
			*/
		//};

		// Add final relaxa(ct)ion
		private _actionRelax = NEW("ActionGarrisonRelax", [_AI]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionRelax);

		_actionSerial
	ENDMETHOD;

ENDCLASS;