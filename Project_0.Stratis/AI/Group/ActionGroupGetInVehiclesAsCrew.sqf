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
	// _unitsIgnore - units to ignore in assignment. For instance if this unit was destroyed.
	METHOD("activate") {
		params [["_thisObject", "", [""]], ["_unitsIgnore", []]];
		
		OOP_INFO_0("ACTIVATE");
		
		pr _AI = T_GETV("AI");
		pr _group = GETV(T_GETV("AI"), "agent");
		
		// Assign units to vehicles
		pr _units = CALLM0(_group, "getUnits") - _unitsIgnore;
		pr _vehicles = (_units select {CALLM0(_x, "isVehicle")}) - _unitsIgnore; // _unitsIgnore can also contain vehicles
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
				CALLM4(_driverAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _parameters, _AI);
				
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
					CALLM4(_turretAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _parameters, _AI);		
					
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
			pr _group = GETV(T_GETV("AI"), "agent");
			pr _groupUnits = CALLM0(_group, "getInfantryUnits");
			if (CALLSM3("AI", "allAgentsCompletedExternalGoal", _groupUnits, "GoalUnitGetInVehicle", "")) then {
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
	
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]] ];
		OOP_INFO_1("Units removed: %1", _units);
		
		// Call activate method, pass the unit that was removed
		CALLM1(_thisObject, "activate", _units);
		
		/*
		pr _state = T_GETV("state");
		if (_state == ACTION_STATE_ACTIVE || _state == ACTION_STATE_COMPLETED) then {
			// At next process call activate once again to assign the units
			T_SETV("state", ACTION_STATE_INACTIVE);
		};
		*/
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