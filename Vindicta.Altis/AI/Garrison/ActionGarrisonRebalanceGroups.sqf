#include "common.hpp"

/*
This action tries to ensure that vehicle groups have the crew they require and no more, and that inf
groups are appropriate balanced.
*/

#define OOP_CLASS_NAME ActionGarrisonRebalanceGroups
CLASS("ActionGarrisonRebalanceGroups", "ActionGarrison")

	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT];

		OOP_INFO_0("ACTIVATE");

		private _gar = T_GETV("gar");
		CALLM0(_gar, "rebalanceGroups");

		private _AI = T_GETV("AI");

		// Call the health sensor again so that it can update the world state properties
		CALLM0(GETV(_AI, "sensorState"), "update");

		private _ws = GETV(_AI, "worldState");
		private _state = if ([_ws, WSP_GAR_GROUPS_BALANCED, true] call ws_propertyExistsAndEquals) then {
			ACTION_STATE_COMPLETED
		} else {
			ACTION_STATE_FAILED
		};

		T_SETV("state", _state);
		
		_state
	ENDMETHOD;

ENDCLASS;