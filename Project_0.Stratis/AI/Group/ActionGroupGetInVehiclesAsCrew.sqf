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
Class: ActionGroup.ActionGroupGetInVehiclesAsCrew
All members of this group will mount all vehicles in this group.
*/

#define pr private

CLASS("ActionGroupGetInVehiclesAsCrew", "ActionGroup")

	VARIABLE("driversAI");
	VARIABLE("turretsAI");
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		T_SETV("driversAI", []);
		T_SETV("turretsAI", []);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		OOP_INFO_0("Activate");
		
		pr _group = GETV(T_GETV("AI"), "agent");
		
		// Assign units to vehicles
		pr _units = CALLM0(_group, "getUnits");
		pr _vehicles = _units select {CALLM0(_x, "isVehicle")};
		// Array with standard crew for each vehicle
		pr _vehiclesStdCrew = _vehicles apply {
			[CALLM0(_x, "getClassName")] call misc_fnc_getFullCrew;
		};
		pr _crew = _units select {CALLM0(_x, "isInfantry")};
		
		// Delete previous goals of units to get into vehicles
		{
			pr _crewAI = CALLM0(_x, "getAI");
			CALLM2(_crewAI, "deleteExternalGoal", "GoalUnitGetInVehicle", "");
		} forEach _crew;
		
		// Try to assign drivers
		pr _driversAI = [];
		for "_i" from 0 to ((count _vehicles) - 1) do {
			// Does this vehicle have a driver?
			(_vehiclesStdCrew select _i) params ["_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
			if ((_n_driver > 0) && (count _crew > 0)) then {
				pr _newDriver = _crew select 0;
				pr _driverAI = CALLM0(_newDriver, "getAI");
				pr _parameters = [["vehicle", _vehicles select _i], ["vehicleRole", "DRIVER"], ["turretPath", 0]];
				
				// Add goal to this driver
				CALLM4(_driverAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _parameters, _group);
				
				// Add the AI of this driver to the array
				_driversAI pushBack _driverAI;
				
				// Don't assign this driver anywhere else
				_crew deleteat 0;
			};
		};
		
		// Try to assign standard turrets
		pr _turretsAI = [];
		for "_i" from 0 to ((count _vehicles) - 1) do {
			(_vehiclesStdCrew select _i) params ["_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
			{
				if (count _crew > 0) then {
					pr _newTurret = _crew select 0;
					pr _turretAI = CALLM0(_newTurret, "getAI");
					pr _turretPath = _x;
					pr _parameters = [["vehicle", _vehicles select _i], ["vehicleRole", "TURRET"], ["turretPath", _turretPath]];
					
					// Add goal to this turret
					CALLM4(_turretAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _parameters, _group);		
					
					_turretsAI pushback _turretAI;
					
					_crew deleteAt 0;
				};
			} forEach _stdTurrets;
		};
		
		T_SETV("driversAI", _driversAI);
		T_SETV("turretsAI", _turretsAI);
		
		
		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// Logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		OOP_INFO_1("Process: state: %1", _state);
		
		if (_state == ACTION_STATE_ACTIVE) then {
			
			// Wait until all given goals are completed
			pr _groupUnits = CALLM0(GETV(T_GETV("AI"), "agent"), "getUnits");
			pr _allAI = T_GETV("driversAI") + T_GETV("turretsAI");
			OOP_INFO_1("All AI: %1", _allAI);
			{
				pr _unitAI = CALLM0(_x, "getAI");
				pr _infActionState = CALLM2(_unitAI, "getExternalGoalActionState", "GoalUnitGetInVehicle", "");
				OOP_INFO_2("Infantry AI: %1, state: %2", _x, _infActionState);
			} forEach _groupUnits;
			if (({
					pr _unitAI = CALLM0(_x, "getAI");
					pr _infState = CALLM2(_unitAI, "getExternalGoalActionState", "GoalUnitGetInVehicle", "");
					(_infState == ACTION_STATE_COMPLETED) || (_infState == -1)
				} count _groupUnits) == (count _groupUnits)) then {
				OOP_INFO_0("Action COMPLETED");
				
				// We are done here
				T_SETV("state", ACTION_STATE_COMPLETED);
				ACTION_STATE_COMPLETED
			} else {
				OOP_INFO_0("Action is active. Not all crew is in their vehicles...");	
			
				ACTION_STATE_ACTIVE
			};
			
		} else {
			_state
		};
	} ENDMETHOD;
	
	METHOD("handleUnitRemoved") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];
		OOP_INFO_1("Unit removed: %1", _unit);
		
		pr _state = T_GETV("state");
		if (_state == ACTION_STATE_ACTIVE || _state == ACTION_STATE_COMPLETED) then {
			// Activate once again to assign the units
			CALLM0(_thisObject, "activate");
		};
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;

ENDCLASS;


/*
_unit = cursorObject; 
_goalClassName = "GoalGroupGetInVehiclesAsCrew"; 
_parameters = []; 
call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf"; 
[_unit, _goalClassName, _parameters] call AI_misc_fnc_addGroupGoal;
*/