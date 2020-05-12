#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\Action\Action.hpp"
#include "..\..\defineCommon.inc"
#include "..\goalRelevance.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "AI.hpp"
#include "..\WorldState\WorldState.hpp"
#include "..\Garrison\garrisonWorldStateProperties.hpp"
#include "..\Unit\unitHumanWorldStateProperties.hpp"
#include "..\parameterTags.hpp"

// Initialize test functions
//call compile preprocessFileLineNumbers "Tests\initTests.sqf";

// Init OOP
OOP_Light_initialized = true;
call compile preprocessFileLineNumbers "OOP_Light\OOP_Light_init.sqf";

// Init dependent classes
call compile preprocessFileLineNumbers "SaveSystem\initClasses.sqf";
call compile preprocessFileLineNumbers "AI\AI\GOAP_Agent.sqf";
call compile preprocessFileLineNumbers "MessageReceiver\MessageReceiver.sqf";
call compile preprocessFileLineNumbers "MessageReceiverEx\MessageReceiverEx.sqf";
call compile preprocessFileLineNumbers "AI\Misc\databaseFunctions.sqf";
call compile preprocessFileLineNumbers "AI\Misc\repairFunctions.sqf";
call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf";
call compile preprocessFileLineNumbers "AI\WorldState\WorldState.sqf";
call compile preprocessFileLineNumbers "AI\WorldFact\WorldFact.sqf";
call compile preprocessFileLineNumbers "AI\Misc\initFunctions.sqf";
call compile preprocessFileLineNumbers "AI\Action\Action.sqf";
call compile preprocessFileLineNumbers "AI\Sensor\Sensor.sqf";
call compile preprocessFileLineNumbers "AI\SensorStimulatable\SensorStimulatable.sqf";
call compile preprocessFileLineNumbers "AI\ActionComposite\ActionComposite.sqf";
call compile preprocessFileLineNumbers "AI\ActionCompositeParallel\ActionCompositeParallel.sqf";
call compile preprocessFileLineNumbers "AI\ActionCompositeSerial\ActionCompositeSerial.sqf";
call compile preprocessFileLineNumbers "AI\Goal\Goal.sqf";
call compile preprocessFileLineNumbers "AI\AI\AI.sqf";
call compile preprocessFileLineNumbers "AI\AI\AI_GOAP.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\initClasses.sqf";
call compile preprocessFileLineNumbers "AI\Unit\initClasses.sqf";
//call compile preprocessFileLineNumbers "AI\initClasses.sqf";

/*
A script to test how AStar works
Author: Sparker 08.12.2018
*/

#define pr private

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
		"ActionGarrisonClearArea"//,
		//"ActionGarrisonJoinLocation"
];


// Fill world states
pr _wsCurrent = [WSP_GAR_COUNT] call ws_new;

[_wsCurrent, WSP_GAR_AWARE_OF_ENEMY, false] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_VEHICLES_REPAIRED, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_VEHICLES_CAN_MOVE, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_HUMANS_HEALED, true] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_INFANTRY_MOUNTED, false] call ws_setPropertyValue;
[_wsCurrent, WSP_GAR_ALL_CREW_MOUNTED, true] call ws_setPropertyValue;
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
[_wsCurrent, WSP_GAR_POSITION, [1, 2, 3]] call ws_setPropertyValue;//									14 // Position or the current location this garrison is attached to
[_wsCurrent, WSP_GAR_CARGO_POSITION, [1, 2, 3]] call ws_setPropertyValue;//								15
[_wsCurrent, WSP_GAR_VEHICLES_POSITION, [1, 2, 3]] call ws_setPropertyValue;//							16
[_wsCurrent, WSP_GAR_VEHICLE_GROUPS_MERGED, false] call ws_setPropertyValue;//						17
[_wsCurrent, WSP_GAR_GROUPS_BALANCED, true] call ws_setPropertyValue;//								18
[_wsCurrent, WSP_GAR_CLEARING_AREA, false] call ws_setPropertyValue;//								19
[_wsCurrent, WSP_GAR_CARGO, false] call ws_setPropertyValue;//										20
[_wsCurrent, WSP_GAR_HAS_CARGO, false] call ws_setPropertyValue;//									21
[_wsCurrent, WSP_GAR_LOCATION, "somePlace"] call ws_setPropertyValue;//									22 // Location the garrison is attached to
[_wsCurrent, WSP_GAR_HAS_VEHICLES, true] call ws_setPropertyValue;//								23


pr _wsGoal = [WSP_GAR_COUNT, ORIGIN_GOAL_WS] call ws_new;
//[_wsGoal, WSP_GAR_POSITION, [6, 7, 8]] call ws_setPropertyValue;
[_wsGoal, WSP_GAR_POSITION, "goalTag_position"] call ws_setPropertyGoalParameterTag;
/*
[_wsGoal, WSP_GAR_CARGO_POSITION, [6, 6, 6]] call ws_setPropertyValue;
[_wsGoal, WSP_GAR_HAS_CARGO, false] call ws_setPropertyValue;
*/

//pr _args = ["", [ ["g_pos", [6, 6, 6]] ]];
//pr _wsGoal = CALLSM("GoalGarrisonMove", "getEffects", _args);

// Run A*
//[P_THISCLASS, P_ARRAY("_currentWS"), P_ARRAY("_goalWS"), P_ARRAY("_possibleActions"), P_ARRAY("_goalParameters")];
pr _args = [_wsCurrent, _wsGoal, _actions, [[TAG_MOVE_RADIUS, 100]]];
pr _plan = CALL_STATIC_METHOD("AI_GOAP", "planActions", _args);


// Test units

pr _wsUnitCurrent = [WSP_UNIT_HUMAN_COUNT] call ws_new;
for "_i" from 0 to (WSP_UNIT_HUMAN_COUNT-1) do { // Init all WSPs to false
	WS_SET(_ws, _i, false);
};
WS_SET(_wsUnitCurrent, WSP_UNIT_HUMAN_AT_VEHICLE, true);


pr _wsUnitGoal = [WSP_UNIT_HUMAN_COUNT] call ws_new;
WS_SET(_wsUnitGoal, WSP_UNIT_HUMAN_HAS_INTERACTED, true);

pr _shootRange = objNull;
pr _unitGoalParameters = [[TAG_TARGET_SHOOT_RANGE, _shootRange], [TAG_MOVE_RADIUS, 3], [TAG_POS, [10, 20, 30]]];
pr _unitActions = 		[
		"ActionUnitArrest", 				
		"ActionUnitDismountCurrentVehicle",
		"ActionUnitFlee", 			
		"ActionUnitFollow", 		
		"ActionUnitGetInVehicle", 			
		"ActionUnitIdle", 					
		"ActionUnitInfantryMove", 	
		"ActionUnitInfantryMoveBuilding",
		"ActionUnitInfantryMoveToUnit",
		"ActionUnitInfantryRegroup", 		
		"ActionUnitInfantryLeaveFormation",
		//"ActionUnitMove", 			
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