
#include "common.h"

#ifndef _SQF_VM
"ai.rpt" ofstream_write "===== CIVILIAN PANIC";
#endif

#define pr private

// Getting into vehicle
pr _wsUnitCurrent = [WSP_UNIT_HUMAN_COUNT] call ws_new;
for "_i" from 0 to (WSP_UNIT_HUMAN_COUNT-1) do { // Init all WSPs to false
	WS_SET(_wsUnitCurrent, _i, false);
};
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_VEHICLE_ALLOWED, false);
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_IN_DANGER, true);

pr _wsUnitGoal = [WSP_UNIT_HUMAN_COUNT] call ws_new;
WS_SET(_wsUnitGoal, WSP_UNIT_HUMAN_IN_DANGER, false);

//TAG_TARGET_UNIT, TAG_VEHICLE_ROLE
pr _unitGoalParameters = [ [TAG_POS, [1,2,3]], [TAG_MOVE_RADIUS, 10]];


pr _shootRange = objNull;
pr _unitActions = 		[
			"ActionUnitInfantryMove",
			"ActionUnitFlee",
			"ActionUnitDismountCurrentVehicle",
			"ActionUnitAmbientAnim",
			"ActionUnitInfantryStandIdle"
		];

pr _args = [_wsUnitCurrent, _wsUnitGoal, _unitActions, _unitGoalParameters];
pr _plan = CALL_STATIC_METHOD("AI_GOAP", "planActions", _args);