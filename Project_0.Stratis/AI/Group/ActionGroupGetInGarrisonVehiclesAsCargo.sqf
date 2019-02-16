#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
Class: ActionGroupGetInGarrisonVehiclesAsCargo
All members of this group will mount all vehicles in this garrison as cargo.
*/

#define pr private

CLASS("ActionGroupGetInGarrisonVehiclesAsCargo", "ActionGroup")
	
	// Array with free vehicles
	VARIABLE("freeVehicles");
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		
		SETV("freeVehicles", []); 
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	// _unitsIgnore - units to ignore in assignment. For instance if this unit was destroyed.
	METHOD("activate") {
		params [["_thisObject", "", [""]], ["_unitsIgnore", []]];
		
		pr _AI = T_GETV("AI");
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _gar = CALLM0(_group, "getGarrison");
		
		// Get array of all vehicles in the garrison that can carry cargo troops
		pr _unitsVeh = CALLM0(_gar, "getVehicleUnits") select {
			pr _className = CALLM0(_x, "getClassName");\
			pr _cap = [_className] call misc_fnc_getCargoInfantryCapacity;
			OOP_INFO_2("   Vehicle: %1, cargo infantry capacity: %2", _className, _cap);
			_cap > 0 // If it can carry any troops as cargo
		};
		OOP_INFO_1("Vehicles with cargo infantry capacity: %1", _unitsVeh);
		
		// Fail if there are no vehicles with cargo infantry capacity
		if (count _unitsVeh == 0) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};
		
		T_SETV("freeVehicles", _unitsVeh);
				
		// Get all infantry
		pr _unitsInf = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitGetInVehicle", ""); // Delete any other goals like this first
			
			pr _args = [["vehicle", _unitsVeh select 0], ["vehicleRole", "CARGO"], ["turretPath", []]];
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _args, _AI);
		} forEach _unitsInf;		
		
		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// Logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _group = GETV(T_GETV("AI"), "agent");
			pr _unitsInf = CALLM0(_group, "getInfantryUnits");
			pr _nGoalsCompleted = 0;
			pr _AI = T_GETV("AI");
			pr _freeVehicles = T_GETV("freeVehicles");
			{
				pr _unitAI = CALLM0(_x, "getAI");
				pr _goalState = CALLM2(_unitAI, "getExternalGoalActionState", "GoalUnitGetInVehicle", _AI);
				
				switch (_goalState) do {
					case ACTION_STATE_ACTIVE: {
						// Probably nothing to do here...
					};
					
					case ACTION_STATE_COMPLETED: {
						_nGoalsCompleted = _nGoalsCompleted + 1;				
					};
					
					case ACTION_STATE_FAILED: {
						// Get parameters passed to this goal
						pr _parameters = CALLM2(_unitAI, "getExternalGoalParameters", "GoalUnitGetInVehicle", _AI);
						pr _assignedVehicle = CALLSM2("Action", "getParameterValue", _parameters, "vehicle");
						if (_assignedVehicle != "") then { // Just for safety
							
							// Delete this goal from the soldier
							CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitGetInVehicle", "");
						
							// Choose another vehicle to get in
							_freeVehicles pushBack (_freeVehicles deleteAt (_freeVehicles find _assignedVehicle));
							pr _vehToGetIn = _freeVehicles select 0;
							
							// Add a new goal to this unit
							pr _args = [["vehicle", _vehToGetIn], ["vehicleRole", "CARGO"], ["turretPath", []]];
							CALLM4(_unitAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _args, _AI);
							ade_dumpCallstack;
						};
					};
				};
			} forEach _unitsInf;
			
			if (_nGoalsCompleted == count _unitsInf) then {
				_state = ACTION_STATE_COMPLETED;
			};
		};
		
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]] ];
		OOP_INFO_1("Units removed: %1", _units);
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		pr _AI = T_GETV("AI");
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _gar = CALLM0(_group, "getGarrison");
		
		// Delete previously given goals
		pr _unitsInf = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitGetInVehicle", "");
		} forEach _unitsInf;
		
	} ENDMETHOD;

ENDCLASS;


/*
_unit = cursorObject; 
_goalClassName = "GoalGroupGetInVehiclesAsCrew"; 
_parameters = []; 
call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf"; 
[_unit, _goalClassName, _parameters] call AI_misc_fnc_addGroupGoal;
*/