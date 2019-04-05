#include "common.hpp"

/*
This action tries to find drivers and turret operators for vehicles in all vehicle groups
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonRebalanceVehicleGroups"

CLASS(THIS_ACTION_NAME, "ActionGarrison")

	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		OOP_INFO_0("ACTIVATE");
		
		// Give waypoint to the vehicle group
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		
		// Create a pool of units we can use to fill vehicle slots
		pr _freeUnits = [];
		pr _groupTypes = [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL, GROUP_TYPE_BUILDING_SENTRY];
		pr _freeGroups = CALLM1(_gar, "findGroupsByType", _groupTypes);
		{
			_freeUnits append CALLM0(_x, "getUnits");
		} forEach _freeGroups;
		
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		
		OOP_INFO_2("Vehicle groups: %1, free units: %2", _vehGroups, _freeUnits);
		
		// Try to add drivers to all groups
		{ // foreach _vehGroups
			pr _group = _x;
			CALLM0(_group, "getRequiredCrew") params ["_nDrivers", "_nTurrets"];
			pr _nInf = count CALLM0(_x, "getInfantryUnits");
			
			OOP_INFO_3("Analyzing vehicle group: %1, required drivers: %2, required turret operators: %3", _group, _nDrivers, _nTurrets);
			
			pr _nMoreUnitsRequired = _nDrivers + _nTurrets - _nInf;
			if (_nMoreUnitsRequired > 0) then {
				while {_nMoreUnitsRequired > 0 && (count _freeUnits > 0)} do {
					CALLM1(_group, "addUnit", _freeUnits deleteAt 0);
					_nMoreUnitsRequired = _nMoreUnitsRequired - 1;
				};
			} else {
				// If there are more units than we need in this group
				if (_nMoreUnitsRequired < 0) then {
					// Move the not needed units into any of the other groups
					pr _receivingGroup = _freeGroups select 0;
					if (isNil "_receivingGroup") then {
						pr _args = [CALLM0(_group, "getSide"), GROUP_TYPE_IDLE];
						_receivingGroup = NEW("Group", _args);
						CALLM0(_receivingGroup, "spawn");
						CALLM1(_gar, "addGroup", _receivingGroup);
						_freeGroups pushBack _receivingGroup;
					};
					
					// Move the units
					pr _groupUnits = CALLM0(_group, "getUnits");
					while {_nMoreUnitsRequired < 0} do {
						CALLM1(_receivingGroup, "addUnit", _groupUnits select ((count _groupUnits) - 1));
						_nMoreUnitsRequired = _nMoreUnitsRequired + 1;
					};
				};
			};
			
			/*
			pr _nMoreDriversRequired = _nDrivers - _nInf;
			if (_nMoreDriversRequired > 0) then {
				while {_nMoreDriversRequired > 0 && (count _freeUnits > 0)} do {
					CALLM1(_group, "addUnit", _freeUnits deleteAt 0);
					_nMoreDriversRequired = _nMoreDriversRequired - 1;
				};
			};
			*/
		} forEach _vehGroups;
		
		// Try to add turret operators to all groups
		/*
		{ // foreach _vehGroups
			pr _group = _x;
			CALLM0(_group, "getRequiredCrew") params ["_nDrivers", "_nTurrets"];
			pr _nInf = count CALLM0(_group, "getInfantryUnits");
			
			pr _nTurretOperatorsRequired = _nTurrets - _nInf - _nDrivers;
			
			if (_nTurretOperatorsRequired > 0) then {
				while {_nTurretOperatorsRequired > 0 && (count _freeUnits > 0)} do {
					CALLM1(_group, "addUnit", _freeUnits deleteAt 0);
					_nTurretOperatorsRequired = _nTurretOperatorsRequired - 1;
				};
			};
		} forEach _vehGroups;
		*/
		
		// Call the health sensor again so that it can update the world state properties
		CALLM0(GETV(_AI, "sensorState"), "update");
		
		pr _ws = GETV(_AI, "worldState");
		
		pr _state = ACTION_STATE_FAILED;
		if ([_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, true] call ws_propertyExistsAndEquals) then {
			_state = ACTION_STATE_COMPLETED;
		};
				
		// Set state
		SETV(_thisObject, "state", _state);
		
		// Return ACTIVE state
		_state		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;

ENDCLASS;