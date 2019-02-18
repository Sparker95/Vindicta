#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "garrisonWorldStateProperties.hpp"

/*
Garrison moves on available vehicles
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonRepairAllVehicles"

CLASS(THIS_ACTION_NAME, "ActionGarrison")

	VARIABLE("repairUnit"); // The unit that will perform repairs on vehicles

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];
		
		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");
		
		// Find all broken vehicles
		pr _vehicles = [_gar, [[T_VEH, -1], [T_DRONE, -1]]] call GETM(_gar, "findUnits");
		pr _brokenVehicles = _vehicles select {
			pr _hO = CALLM(_x, "getObjectHandle", []);
			(getDammage _hO > 0.61) || (!canMove _hO)
		};
		
		OOP_INFO_1("Broken vehicles: %1", _brokenVehicles);
		
		if (count _brokenVehicles == 0) exitWith {
			SETV(_thisObject, "state", ACTION_STATE_COMPLETED);			
			// Return ACTIVE state
			ACTION_STATE_COMPLETED
		};
		
		// Find all infantry
		// Find all engineers
		pr _infUnits = CALLM0(_gar, "getInfantryUnits");
		pr _engineerUnits = _infUnits select {
			pr _hO = CALLM(_x, "getObjectHandle", []);
			(_hO getUnitTrait "engineer")
		};
		
		// Send a random guy to perform repairs for now
		if (count _infUnits > 0 || count _engineerUnits > 0) then {
			pr _repairUnit = if (count _engineerUnits > 0) then {selectRandom _engineerUnits} else {selectRandom _infUnits};
			T_SETV("repairUnit", _repairUnit);
			pr _repairUnitAI = CALLM0(_repairUnit, "getAI");
			
			// Add goals to the repair unit
			/*
			{				
				pr _args = ["GoalUnitRepairVehicle", 0, [["vehicle", _x]], _AI, false];
				CALLM2(_repairUnitAI, "postMethodAsync", "addExternalGoal", _args);
			} forEach _brokenVehicles;
			*/
			
			// Just repair one vehicle at a time for now
			pr _brokenVehicle = _brokenVehicles select 0;
			pr _args = ["GoalUnitRepairVehicle", 0, [["vehicle", _brokenVehicle]], _AI, false];
			CALLM2(_repairUnitAI, "postMethodAsync", "addExternalGoal", _args);
			
			T_SETV("state", ACTION_STATE_ACTIVE);
			ACTION_STATE_ACTIVE
		} else {
			// Set state
			SETV(_thisObject, "state", ACTION_STATE_FAILED);			
			// Return ACTIVE state
			ACTION_STATE_FAILED
		};
				
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _AI = T_GETV("AI");
			pr _repairUnit = T_GETV("repairUnit");
			pr _goalState = CALLM2(CALLM0(_repairUnit, "getAI"), "getExternalGoalActionState", "GoalUnitRepairVehicle", _AI);
			if (_goalState == ACTION_STATE_COMPLETED) then {
				// Update sensors affected by this action
				CALLM0(GETV(_AI, "sensorHealth"), "update");
				
				_state = ACTION_STATE_COMPLETED;
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		pr _AI = T_GETV("AI");
		
		// Delete assigned goal
		pr _repairUnit = T_GETV("repairUnit");
		pr _repairUnitAI = CALLM0(_repairUnit, "getAI");
		pr _args = ["GoalUnitRepairVehicle", _AI];
		CALLM2(_repairUnitAI, "postMethodAsync", "deleteExternalGoal", _args);
		
	} ENDMETHOD;

ENDCLASS;