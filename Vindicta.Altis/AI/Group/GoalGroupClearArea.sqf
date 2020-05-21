#include "common.hpp"
/*
Goal for a group to clear a certain area.
*/

#define pr private

#define OOP_CLASS_NAME GoalGroupClearArea
CLASS("GoalGroupClearArea", "Goal")
	
	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// By default it gets predefined action from database if it is defined and creates it, passing a goal parameter to action parameter, if it exists
	// This method must be redefined for goals that have predefined actions that require parameters not from goal parameters
	
	STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _group = GETV(_AI, "agent");
		pr _groupType = CALLM0(_group, "getType");

		// Infantry group will "clear area" by running around looking for enemies
		if (_groupType == GROUP_TYPE_INF) then {
			pr _action = NEW("ActionGroupClearArea", [_AI ARG _parameters]);
			_action
		} else {
			pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
			// pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_CLEAR_RADIUS);

			pr _actionSerial = NEW("ActionCompositeSerial", [_AI]);

			// Create action to get in vehicles
			private _getInParams = [
				["onlyCombat", true] // Only combat vehicle operators must stay in vehicles
			];
			CALLSM2("Action", "mergeParameterValues", _getInParams, _parameters);
			pr _actionGetIn = NEW("ActionGroupGetInVehiclesAsCrew", [_AI ARG _getInParams]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionGetIn);

			// Move to within the clearable area
			pr _moveRadius = CALLSM3("Action", "getParameterValue", _parameters, TAG_CLEAR_RADIUS, 100);

			// Start clear area from center, so move there first
			pr _moveParams = [
				[TAG_POS, _pos],
				[TAG_MOVE_RADIUS, _moveRadius]
			];
			CALLSM2("Action", "mergeParameterValues", _moveParams, _parameters);
			pr _actionMove = NEW("ActionGroupMove", [_AI ARG _moveParams]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionMove);

			pr _actionClear = NEW("ActionGroupClearArea", [_AI ARG _parameters]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionClear);

			_actionSerial
		};
	ENDMETHOD;

ENDCLASS;