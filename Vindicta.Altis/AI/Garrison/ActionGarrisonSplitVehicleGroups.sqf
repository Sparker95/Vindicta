#include "common.hpp"

/*
Splits vehicle group(s)
We need to split vehicle groups (after convoy move).
*/

#define pr private

#define OOP_CLASS_NAME ActionGarrisonSplitVehicleGroups
CLASS("ActionGarrisonSplitVehicleGroups", "ActionGarrison")

	protected override METHOD(activate)
		params [P_THISOBJECT];

		pr _gar = T_GETV("gar");
		CALLM0(_gar, "splitVehicleGroups");

		// We set the state explicitly as it can be indeterminate based 
		// just on measurement. i.e. if there is only one vehicle how can 
		// you tell if it is split or merged? Answer is you can't so we just
		// explicitly set the state, and the sensor will only change it when
		// it breaks constraints (e.g. more than one vehicle group means it
		// cannot be merged).
		pr _AI = T_GETV("AI");
		pr _ws = GETV(_AI, "worldState");
		[_ws, WSP_GAR_VEHICLE_GROUPS_MERGED, false] call ws_setPropertyValue;

		T_SETV("state", ACTION_STATE_COMPLETED);

		ACTION_STATE_COMPLETED

	ENDMETHOD;

ENDCLASS;