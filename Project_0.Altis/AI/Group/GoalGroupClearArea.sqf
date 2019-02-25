#include "common.hpp"
/*
Goal for a group to clear a certain area.
*/

#define pr private

CLASS("MyGoal", "Goal")
	
	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// By default it gets predefined action from database if it is defined and creates it, passing a goal parameter to action parameter, if it exists
	// This method must be redefined for goals that have predefined actions that require parameters not from goal parameters
	
	STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]]];
		
		pr _group = GETV(_AI, "agent");
		pr _groupType = CALLM0(_group, "getType");
		
		if (_groupType in [GROUP_TYPE_IDLE, GROUP_TYPE_BUILDING_SENTRY, GROUP_TYPE_PATROL]) exitWith {
			pr _args = [_AI, _parameters];
			pr _action = NEW("ActionGroupInfantryClearArea", _args);
			_action
		};
		
		// Now it's one of the vehicle groups
		pr _args = [_AI, _parameters];
		pr _action = NEW("ActionGroupVehicleClearArea", _args);
		_action
	} ENDMETHOD;

ENDCLASS;