#include "common.hpp"

// Group will find a place with line of sight, fullfilling required distance, elevation and gradient requirements.
// Goal for a group to over watch area.
#define OOP_CLASS_NAME GoalGroupPatrolMounted
CLASS("GoalGroupPatrolMounted", "Goal")
	STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _group = GETV(_AI, "agent");
		private _isVehicle = CALLM0(_group, "getType") in [GROUP_TYPE_VEH ARG GROUP_TYPE_STATIC];

		private _actionSerial = NEW("ActionCompositeSerial", [_AI]);
		if(_isVehicle) then {
			// Mount vehicles
			private _actionGetInParams = [
				["onlyCombat", true] // Only combat vehicle operators must stay in vehicles
			];
			CALLSM2("Action", "mergeParameterValues", _actionGetInParams, _parameters);
			private _actionGetIn = NEW("ActionGroupGetInVehiclesAsCrew", [_AI ARG _actionGetInParams]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionGetIn);
		};
		// Patrol
		private _actionWatch = NEW("ActionGroupPatrol", [_AI ARG _parameters]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionWatch);

		_actionSerial
	ENDMETHOD;

ENDCLASS;