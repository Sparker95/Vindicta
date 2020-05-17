#include "common.hpp"
/*
Goal for a garrison to repair all its vehicles
*/

#define pr private

#define OOP_CLASS_NAME GoalGarrisonRepairAllVehicles
CLASS("GoalGarrisonRepairAllVehicles", "Goal")
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		// Check world state properties
		// Return high desireability if we need repairs and an engineer is available
		pr _ws = GETV(_AI, "worldState");
		pr _notAllCanMove = [_ws, WSP_GAR_ALL_VEHICLES_CAN_MOVE, false] call ws_propertyExistsAndEquals;
		pr _brokenAndHaveEngineer = ([_ws, WSP_GAR_ALL_VEHICLES_REPAIRED, false] call ws_propertyExistsAndEquals ) && ([_ws, WSP_GAR_ENGINEER_AVAILABLE, true] call ws_propertyExistsAndEquals);
		if (_notAllCanMove || _brokenAndHaveEngineer) then {
			if (!CALLM0(_AI, "isAlerted")) then {
				// Return relevance
				GETSV("GoalGarrisonRepairAllVehicles", "relevance")
			} else {
				0
			};
		} else {
			0
		};
	ENDMETHOD;

ENDCLASS;