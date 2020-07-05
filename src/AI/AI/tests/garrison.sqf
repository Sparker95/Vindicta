#include "common.h"

#ifndef _SQF_VM
"ai.rpt" ofstream_write "===== GARRISON A* TESTS";
#endif

pr _actions = [
		"ActionGarrisonDefendActive",
		//"ActionGarrisonLoadCargo",
		"ActionGarrisonMountCrew",
		"ActionGarrisonMountInfantry",
		"ActionGarrisonMoveDismounted",
		//"ActionGarrisonMoveMountedToPosition",
		//"ActionGarrisonMoveMountedToLocation",
		"ActionGarrisonMoveCombined",
		"ActionGarrisonMoveMounted",
		//"ActionGarrisonMoveMountedCargo",
		"ActionGarrisonRelax",
		"ActionGarrisonRepairAllVehicles",
		//"ActionGarrisonUnloadCurrentCargo",
		"ActionGarrisonMergeVehicleGroups",
		"ActionGarrisonSplitVehicleGroups",
		"ActionGarrisonRebalanceGroups",
		"ActionGarrisonClearArea",
		"ActionGarrisonJoinLocation"
];


// Fill world states
pr _wsCurrent = [WSP_GAR_COUNT] call ws_new;

[_wsCurrent, WSP_GAR_AWARE_OF_ENEMY, false] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_VEHICLES_REPAIRED, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_VEHICLES_CAN_MOVE, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_HUMANS_HEALED, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_INFANTRY_MOUNTED, false] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_CREW_MOUNTED, false] call ws_setPropertyValue;
// Handling of vehicles and crew
[_wsCurrent, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, false] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_VEHICLES_HAVE_CREW_ASSIGNED, false] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ENGINEER_AVAILABLE, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_MEDIC_AVAILABLE, true] call ws_setPropertyValue;//								10
[_wsCurrent, WSP_GAR_ENOUGH_HUMANS_TO_DRIVE_ALL_VEHICLES, true] call ws_setPropertyValue;//			11
[_wsCurrent, WSP_GAR_ENOUGH_HUMANS_TO_TURRET_ALL_VEHICLES, true] call ws_setPropertyValue;//		12
[_wsCurrent, WSP_GAR_ENOUGH_VEHICLES_FOR_ALL_HUMANS, true] call ws_setPropertyValue;//				13
// Misc
[_wsCurrent, WSP_GAR_AT_TARGET_POS, false] call ws_setPropertyValue;//									14 // Position or the current location this garrison is attached to
[_wsCurrent, WSP_GAR_VEHICLES_AT_TARGET_POS, false] call ws_setPropertyValue;//							16
[_wsCurrent, WSP_GAR_VEHICLE_GROUPS_MERGED, false] call ws_setPropertyValue;//						17
[_wsCurrent, WSP_GAR_GROUPS_BALANCED, true] call ws_setPropertyValue;//								18
[_wsCurrent, WSP_GAR_HAS_INTERACTED, false] call ws_setPropertyValue;//								19
[_wsCurrent, WSP_GAR_HAS_CARGO, false] call ws_setPropertyValue;//									21
[_wsCurrent, WSP_GAR_AT_TARGET_LOCATION, false] call ws_setPropertyValue;//									22 // Location the garrison is attached to
[_wsCurrent, WSP_GAR_HAS_VEHICLES, true] call ws_setPropertyValue;//								23


pr _wsGoal = [WSP_GAR_COUNT, ORIGIN_GOAL_WS] call ws_new;
[_wsGoal, WSP_GAR_AT_TARGET_LOCATION, true] call ws_setPropertyGoalParameterTag;
/*
[_wsGoal, WSP_GAR_CARGO_POSITION, [6, 6, 6]] call ws_setPropertyValue;
[_wsGoal, WSP_GAR_HAS_CARGO, false] call ws_setPropertyValue;
*/

//pr _args = ["", [ ["g_pos", [6, 6, 6]] ]];
//pr _wsGoal = CALLSM("GoalGarrisonMove", "getEffects", _args);

// Run A*
//[P_THISCLASS, P_ARRAY("_currentWS"), P_ARRAY("_goalWS"), P_ARRAY("_possibleActions"), P_ARRAY("_goalParameters")];
pr _args = [_wsCurrent, _wsGoal, _actions, [[TAG_LOCATION, "123"], [TAG_POS, [1,2,3]]] ];
pr _plan = CALL_STATIC_METHOD("AI_GOAP", "planActions", _args);


// Test units

/*
// Arresting
pr _wsUnitCurrent = [WSP_UNIT_HUMAN_COUNT] call ws_new;
for "_i" from 0 to (WSP_UNIT_HUMAN_COUNT-1) do { // Init all WSPs to false
	WS_SET(_wsUnitCurrent, _i, false);
};
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_AT_VEHICLE, true);
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true);

pr _wsUnitGoal = [WSP_UNIT_HUMAN_COUNT] call ws_new;
WS_SET(_wsUnitGoal, WSP_UNIT_HUMAN_HAS_INTERACTED, true);

pr _unitGoalParameters = [[TAG_TARGET_SHOOT_RANGE, _shootRange], [TAG_MOVE_RADIUS, 3], [TAG_POS, [10, 20, 30]]];
*/