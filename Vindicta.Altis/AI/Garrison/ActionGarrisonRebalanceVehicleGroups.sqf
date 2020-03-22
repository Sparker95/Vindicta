#include "common.hpp"

/*
This action tries to find drivers and turret operators for vehicles in all vehicle groups
*/

#define pr private

CLASS("ActionGarrisonRebalanceVehicleGroups", "ActionGarrison")

	// ------------ N E W ------------
	
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];
		
		OOP_INFO_0("ACTIVATE");
		
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		
		// ===== Ensure all vehicles are manned first =====
		// Create a pool of units we can use to fill vehicle slots
		pr _freeUnits = [];
		pr _freeGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_IDLE ARG GROUP_TYPE_PATROL]);
		{
			_freeUnits append CALLM0(_x, "getUnits");
		} forEach _freeGroups;
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH_NON_STATIC ARG GROUP_TYPE_VEH_STATIC]);
		
		// We can also take units from vehicle turrets if we really need it
		{// forEach _vehGroups;
			pr _group = _x;
			CALLM0(_group, "getRequiredCrew") params ["_nDrivers", "_nTurrets"];
			pr _infUnits = CALLM0(_x, "getInfantryUnits");
			while {(count _infUnits) > _nDrivers} do { // Just add all the units except for drivers
				_freeUnits pushBack (_infUnits deleteAt ((count _infUnits) - 1));
			};
		} forEach _vehGroups;

		OOP_INFO_2("Vehicle groups: %1, free units: %2", _vehGroups, _freeUnits);
		
		// Try to add drivers and turret operators to all groups
		{// foreach _vehGroups
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
						//CALLM0(_receivingGroup, "spawnAtLocation");
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
		{// foreach _vehGroups
			pr _group = _x;
			CALLM0(_group, "getRequiredCrew") params ["_nDrivers", "_nTurrets"];
			pr _nInf = count CALLM0(_group, "getInfantryUnits");
			
			pr _nTurretOperatorsRequired = _nTurrets - _nInf - _nDrivers;
			
			if (_nTurretOperatorsRequired > 0) then {
				while {_nTurretOperatorsRequired > 0 && (count _freeUnits > 0)} do {
					CALLM1(_group, "addUnit", _freeUnits deleteAt 0);
					_nTurretOperatorsRequired = _nTurretOperatorsRequired - 1;
				};
			} else {
				
			};
		} forEach _vehGroups;

		// Delete empty groups
		CALLM0(_gar, "deleteEmptyGroups");

		#define DESIRED_GROUP_SIZE 6
		// ===== Now rebalance remaining inf into effective squads =====
		pr _infGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_IDLE ARG GROUP_TYPE_PATROL]) apply {
			[
				CALLM0(_x, "getUnits"),
				_x
			]
		};
		pr _tooBig = _infGroups select { count (_x#0) > DESIRED_GROUP_SIZE };
		pr _tooSmall = _infGroups select { count (_x#0) < DESIRED_GROUP_SIZE };
		pr _side = CALLM0(_gar, "getSide");

		// Take parts of groups that are too big and join them to smaller (or new empty) groups
		{// forEach _tooBig;
			_x params ["_srcUnits", "_srcGrp"];
			pr _spareUnits = _srcUnits select [6, count _srcUnits];
			while { count _spareUnits > 0 } do {
				if(count _tooSmall == 0) then {
					// create a new group
					pr _args = [
						_side,
						selectRandom [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL]
					];
					pr _newGroup = NEW("Group", _args);
					CALLM0(_newGroup, "spawnAtLocation");
					CALLM1(_gar, "addGroup", _newGroup);
					_tooSmall pushBack [[], _newGroup];
				};
				(_tooSmall#0) params ["_tgtUnits", "_tgtGrp"];
				pr _numToAssign = (count _spareUnits) min (DESIRED_GROUP_SIZE - count _tgtUnits);
				pr _unitsToAssign = _spareUnits select [0, _numToAssign];
				_spareUnits = _spareUnits select [_numToAssign, count _spareUnits];
				CALLM1(_tgtGrp, "addUnits", _unitsToAssign);
				_tgtUnits append _unitsToAssign;
				if(count _tgtUnits >= DESIRED_GROUP_SIZE ) then {
					_tooSmall deleteAt 0;
				};
			};
		} forEach _tooBig;

		// Take groups that are too small and merge them
		while { count _tooSmall > 1 } do {
			_tooSmall#0 params ["_srcUnits", "_srcGrp"];
			while { count _srcUnits > 0 && { count _tooSmall > 1 } } do {
				(_tooSmall#1) params ["_tgtUnits", "_tgtGrp"];
				pr _numToAssign = (count _srcUnits) min (DESIRED_GROUP_SIZE - count _tgtUnits);
				pr _unitsToAssign = _srcUnits select [0, _numToAssign];
				_srcUnits = _srcUnits select [_numToAssign, count _srcUnits];
				CALLM1(_tgtGrp, "addUnits", _unitsToAssign);
				_tgtUnits append _unitsToAssign;
				if(count _tgtUnits >= DESIRED_GROUP_SIZE ) then {
					_tooSmall deleteAt 1;
				};
			};
		};

		// Delete empty groups once more
		CALLM0(_gar, "deleteEmptyGroups");

		// Call the health sensor again so that it can update the world state properties
		CALLM0(GETV(_AI, "sensorState"), "update");
		
		pr _ws = GETV(_AI, "worldState");
		
		pr _state = ACTION_STATE_FAILED;
		if ([_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, true] call ws_propertyExistsAndEquals) then {
			_state = ACTION_STATE_COMPLETED;
		};

		// Set state
		T_SETV("state", _state);
		
		// Return ACTIVE state
		_state		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
		
	} ENDMETHOD;

ENDCLASS;