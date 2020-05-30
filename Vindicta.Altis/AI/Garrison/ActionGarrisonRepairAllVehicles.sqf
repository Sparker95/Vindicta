#include "common.hpp"
FIX_LINE_NUMBERS()
/*
Garrison moves on available vehicles
*/

#define pr private

#define OOP_CLASS_NAME ActionGarrisonRepairAllVehicles
CLASS("ActionGarrisonRepairAllVehicles", "ActionGarrison")

	VARIABLE("repairUnit"); // The unit that will perform repairs on vehicles
	VARIABLE("fubarcar"); // The broken vehicle, beyond all repair

	METHOD(new)
		params [P_THISOBJECT];

		T_SETV("repairUnit", NULL_OBJECT);
		T_SETV("fubarcar", NULL_OBJECT);
	ENDMETHOD;


	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");
		
		// Find all broken vehicles
		pr _vehicles = CALLM0(_gar, "getVehicleUnits");
		pr _brokenVehicles = _vehicles select { CALLM0(_x, "isDamaged") };

		// Magic refueling...
		{
			CALLM0(_x, "getObjectHandle") setFuel 1;
		} forEach _vehicles;

		OOP_INFO_1("Broken vehicles: %1", _brokenVehicles);

		if (count _brokenVehicles == 0) exitWith {
			T_SETV("state", ACTION_STATE_COMPLETED);
			// Return ACTIVE state
			ACTION_STATE_COMPLETED
		};
		
		// Find all infantry
		// Find all engineers
		pr _infUnits = CALLM0(_gar, "getInfantryUnits");
		pr _engineerUnits = _infUnits select {
			pr _hO = CALLM0(_x, "getObjectHandle");
			_hO getUnitTrait "engineer"
		};
		
		// Send a random guy to perform repairs for now
		if (count _infUnits > 0 || count _engineerUnits > 0) then {
			// Just repair one vehicle at a time for now
			pr _brokenVehicle = _brokenVehicles select 0;
			T_SETV("fubarcar", _brokenVehicle);
			pr _brokenVehicleHandle = CALLM0(_brokenVehicle, "getObjectHandle");
		
			pr _repairUnit = if (count _engineerUnits > 0) then {selectRandom _engineerUnits} else {
				// Sort all units by distance to the broken vehicle
				pr _infUnitsSorted = _infUnits apply {[CALLM0(_x, "getPos") distance2D _brokenVehicleHandle, _x]};
				_infUnitsSorted sort true; // Ascending
				// Return
				_infUnitsSorted select 0 select 1
			};
			T_SETV("repairUnit", _repairUnit);
			pr _repairUnitAI = CALLM0(_repairUnit, "getAI");
			
			// Add goals to the repair unit
			/*
			{				
				pr _args = ["GoalUnitRepairVehicle", 0, [["vehicle", _x]], _AI, false];
				CALLM2(_repairUnitAI, "postMethodAsync", "addExternalGoal", _args);
			} forEach _brokenVehicles;
			*/
			
			pr _args = ["GoalUnitRepairVehicle", 0, [["vehicle", _brokenVehicle], [TAG_INSTANT, _instant]], _AI, false];
			CALLM2(_repairUnitAI, "postMethodAsync", "addExternalGoal", _args);
			
			T_SETV("state", ACTION_STATE_ACTIVE);
			ACTION_STATE_ACTIVE
		} else {
			// Set state
			T_SETV("state", ACTION_STATE_FAILED);
			// Return ACTIVE state
			ACTION_STATE_FAILED
		};
				
	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];

		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {T_GETV("state")};
		
		pr _state = T_CALLM0("activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _AI = T_GETV("AI");
			pr _repairUnit = T_GETV("repairUnit");
			pr _goalState = CALLM2(CALLM0(_repairUnit, "getAI"), "getExternalGoalActionState", "GoalUnitRepairVehicle", _AI);
			if (_goalState == ACTION_STATE_COMPLETED) then {
				// Update sensors affected by this action
				CALLM0(GETV(_AI, "sensorState"), "update");
				
				_state = ACTION_STATE_COMPLETED;
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		pr _AI = T_GETV("AI");
		
		// Delete assigned goal
		pr _repairUnit = T_GETV("repairUnit");
		if (_repairUnit != "") then {
			pr _repairUnitAI = CALLM0(_repairUnit, "getAI");
			pr _args = ["GoalUnitRepairVehicle", _AI];
			CALLM2(_repairUnitAI, "postMethodAsync", "deleteExternalGoal", _args);
		};
		
	ENDMETHOD;
	


	METHOD(handleGroupsAdded)
		params [P_THISOBJECT, P_ARRAY("_groups")];
		
		{
			T_CALLM1("handleUnitsAdded", CALLM0(_x, "getUnits"));
		} forEach _groups;
		
		nil
	ENDMETHOD;

	METHOD(handleGroupsRemoved)
		params [P_THISOBJECT, P_ARRAY("_groups")];
		
		{
			T_CALLM1("handleUnitsRemoved", CALLM0(_x, "getUnits"));
		} forEach _groups;
		
		nil
	ENDMETHOD;
	
	METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		
			// Fail if either broken vehicle or repair unit is in the array with removed units
			if (count ([T_GETV("fubarcar"), T_GETV("repairUnit")] arrayIntersect _units) != 0) then {
				T_SETV("fubarcar", "");
				T_SETV("repairUnit", "");
				T_SETV("state", ACTION_STATE_FAILED);
			};
		
		nil
	ENDMETHOD;

	METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units")];
			
		nil
	ENDMETHOD;

ENDCLASS;