#include "common.hpp"
/*
Goal for a garrison to relax
*/

#define pr private

CLASS("GoalGarrisonRelax", "Goal")

	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		if (time - GETV(_AI, "lastBusyTime") > AI_GARRISON_IDLE_TIME_THRESHOLD) then { // Have we been idling for too long?
			GETSV("GoalGarrisonRelax", "relevance")
		} else {
			0
		};
	} ENDMETHOD;

	STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]]];
		
		pr _ws = GETV(_AI, "worldState");

		pr _actionSerial = NEW("ActionCompositeSerial", [_AI]);

		// If groups are merged, split them
		// Split them anyway every time, because we currently don't update the world state property value periodically anyway
		//if ([_ws, WSP_GAR_VEHICLE_GROUPS_MERGED, true] call ws_propertyExistsAndEquals) then {
			pr _parameters = [[TAG_MERGE, false]];
			pr _args = [_AI, _parameters];
			pr _actionSplit = NEW("ActionGarrisonMergeVehicleGroups", _args);
			CALLM1(_actionSerial, "addSubactionToBack", _actionSplit);
		//};

		// Add final relaxa(ct)ion
		pr _actionRelax = NEW("ActionGarrisonRelax", [_AI]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionRelax);

		_actionSerial
	} ENDMETHOD;

ENDCLASS;