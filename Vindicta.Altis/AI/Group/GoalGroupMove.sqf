#include "common.hpp"

// Class with predefined actions in initDatabase.sqf
CLASS("GoalGroupMove", "Goal")
	STATIC_METHOD("createPredefinedAction") {
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _group = GETV(_AI, "agent");
		private _groupType = CALLM0(_group, "getType");

		// Infantry group will "clear area" by running around looking for enemies
		if (_groupType in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL]) then {
			private _args = [_AI, _parameters];
			private _action = NEW("ActionGroupInfantryMove", _args);
			_action
		} else {
			private _actionSerial = NEW("ActionCompositeSerial", [_AI]);

			// Create action to get in vehicles
			// Start clear area from center, so move there first
			private _getInParams = [
				["onlyCombat", true] // Only combat vehicle operators must stay in vehicles
			];
			CALLSM2("Action", "mergeParameterValues", _getInParams, _parameters);
			private _actionGetIn = NEW("ActionGroupGetInVehiclesAsCrew", [_AI ARG _getInParams]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionGetIn);

			// Start clear area from center, so move there first
			private _actionMove = NEW("ActionGroupMoveGroundVehicles", [_AI ARG _parameters]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionMove);
			_actionSerial
		};
	} ENDMETHOD;
ENDCLASS;
