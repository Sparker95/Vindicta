#include "common.hpp"
/*
Goal for a group to clear a certain area.
*/

#define pr private

CLASS("GoalGroupClearArea", "Goal")
	
	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// By default it gets predefined action from database if it is defined and creates it, passing a goal parameter to action parameter, if it exists
	// This method must be redefined for goals that have predefined actions that require parameters not from goal parameters
	
	STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]]];
		
		pr _group = GETV(_AI, "agent");
		pr _groupType = CALLM0(_group, "getType");
		
		if (_groupType in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL]) exitWith {
			pr _args = [_AI, _parameters];
			pr _action = NEW("ActionGroupInfantryClearArea", _args);
			_action
		};
		
		// Now it's one of the vehicle groups
		pr _actionSerial = NEW("ActionCompositeSerial", [_AI]);
		pr _args = [_AI, [["onlyCombat", true]] ]; // Only combat vehicle operators must stay in vehicles
		
		// Create action to get in vehicles
		pr _actionGetIn = NEW("ActionGroupGetInVehiclesAsCrew", _args);
		
		// Create action to move
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		pr _args = [_AI, [[TAG_POS, _pos], [TAG_MOVE_RADIUS, 75]] ];
		pr _actionMove = NEW("ActionGroupMoveGroundVehicles", _args);
		
		// Add actions
		CALLM1(_actionSerial, "addSubactionToBack", _actionGetIn);
		CALLM1(_actionSerial, "addSubactionToBack", _actionMove);
		_actionSerial
	} ENDMETHOD;

ENDCLASS;