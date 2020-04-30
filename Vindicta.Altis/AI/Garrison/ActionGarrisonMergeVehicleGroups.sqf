#include "common.hpp"

/*
Merges vehicle group(s)
We need to merge vehicle groups into one group (before convoy move).
This action also moves ungrouped vehicles into the common vehicle group.
*/

#define pr private

#define OOP_CLASS_NAME ActionGarrisonMergeVehicleGroups
CLASS("ActionGarrisonMergeVehicleGroups", "ActionGarrison")

	METHOD(activate)
		params [P_THISOBJECT];

		pr _gar = T_GETV("gar");
		CALLM0(_gar, "mergeVehicleGroups");

		// We set the state explicitly as it can be indeterminate based 
		// just on measurement. i.e. if there is only one vehicle how can 
		// you tell if it is split or merged? Answer is you can't so we just
		// explicitly set the state, and the sensor will only change it when
		// it breaks constraints (e.g. more than one vehicle group means it
		// cannot be merged).
		pr _AI = T_GETV("AI");
		pr _ws = GETV(_AI, "worldState");
		[_ws, WSP_GAR_VEHICLE_GROUPS_MERGED, true] call ws_setPropertyValue;

		T_SETV("state", ACTION_STATE_COMPLETED);

		ACTION_STATE_COMPLETED

	ENDMETHOD;

ENDCLASS;