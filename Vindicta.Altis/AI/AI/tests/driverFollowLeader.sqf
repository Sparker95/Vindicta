
#include "common.h"

#ifndef _SQF_VM
"ai.rpt" ofstream_write "===== DRIVER FOLLOW LEADER";
#endif

#define pr private

// Getting into vehicle
pr _wsUnitCurrent = [WSP_UNIT_HUMAN_COUNT] call ws_new;
for "_i" from 0 to (WSP_UNIT_HUMAN_COUNT-1) do { // Init all WSPs to false
	WS_SET(_wsUnitCurrent, _i, false);
};
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_AT_VEHICLE, true);
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE, true);
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE, true);
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_VEHICLE_ALLOWED, true);
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false);

pr _wsUnitGoal = [WSP_UNIT_HUMAN_COUNT] call ws_new;
WS_SET(_wsUnitGoal, WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, true);

//TAG_TARGET_UNIT, TAG_VEHICLE_ROLE
pr _unitGoalParameters = [ ];



pr _shootRange = objNull;
pr _unitActions = 		[
		"ActionUnitArrest", 				
		"ActionUnitDismountCurrentVehicle",
		"ActionUnitFlee", 			
		"ActionUnitFollow", 		
		"ActionUnitGetInVehicle", 			
		"ActionUnitIdle", 					
		"ActionUnitInfantryMove",
		"ActionUnitInfantryRegroup", 		
		"ActionUnitInfantryLeaveFormation",
		//"ActionUnitMove", // Abstract! 			
		"ActionUnitMoveMounted", 	
		"ActionUnitNothing", 		
		"ActionUnitRepairVehicle", 
		"ActionUnitSalute", 		
		"ActionUnitScareAway", 	
		"ActionUnitAmbientAnim", 	
		"ActionUnitShootAtTargetRange"
		//"ActionUnitShootLegTarget", 
		//"ActionUnitSurrender",
		//"ActionUnitVehicleUnflip"
		];

pr _args = [_wsUnitCurrent, _wsUnitGoal, _unitActions, _unitGoalParameters];
pr _plan = CALL_STATIC_METHOD("AI_GOAP", "planActions", _args);