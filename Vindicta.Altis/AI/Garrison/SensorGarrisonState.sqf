#include "common.hpp"

/*
This sensor checks various conditions related to general garrison state.

Author: Sparker 08.11.2018
*/

#define pr private

pr0_fnc_accumulateGroupWSP = {
	params ["_groups", "_groupWSP", "_default"];
	if (count _groups == 0) exitWith {
		_default
	};
	pr _garValue = true;
	{
		pr _groupVal = [_x, _groupWSP] call ws_getPropertyValue;
		_garValue = _garValue && _groupVal;
	} forEach (_groups apply { CALLM0(_x, "getAI") } apply { GETV(_x, "worldState") });
	_garValue
};

CLASS("SensorGarrisonState", "SensorGarrison")

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];

		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");
		pr _isSpawned = CALLM0(_gar, "isSpawned");
		pr _worldState = GETV(_AI, "worldState");

		// Check if there are enough humans to operate all the vehicles
		pr _vehUnits = CALLM0(_gar, "getVehicleUnits");
		CALLSM("Unit", "getRequiredCrew", [_vehUnits]) params ["_nDriversAll", "_nTurretsAll", "_nCargoAll"];

		// Drivers
		//pr _query = [[T_INF, -1]];
		pr _nInfGarrison = CALLM0(_gar, "countInfantryUnits");
		pr _enoughHumansForAllVehicles = _nInfGarrison >= _nDriversAll;	
		[_worldState, WSP_GAR_ENOUGH_HUMANS_TO_DRIVE_ALL_VEHICLES, _enoughHumansForAllVehicles] call ws_setPropertyValue;

		// Turrets
		pr _enoughHumansToTurretAllVehicles = _nInfGarrison >= (_nDriversAll + _nTurretsAll);
		[_worldState, WSP_GAR_ENOUGH_HUMANS_TO_TURRET_ALL_VEHICLES, _enoughHumansToTurretAllVehicles] call ws_setPropertyValue;

		// Check if there are enough seats for all humans
		pr _nSeatsAll = _nCargoAll + _nTurretsAll + _nDriversAll;
		pr _enoughVehicles = _nInfGarrison <= _nSeatsAll;
		[_worldState, WSP_GAR_ENOUGH_VEHICLES_FOR_ALL_HUMANS, _enoughVehicles] call ws_setPropertyValue;

		// Check if all vehicle groups are merged or not
		// Merged vehicle groups is somewhat indeterminate when there is only one vehicle,
		// so we can only change the state here when it is obviously wrong.
		// Otherwise we rely on the action itself to change the state to be logically correct.
		// i.e. even when there is only one vehicle we still need to set the state correctly for 
		// actions that desire merged groups or split groups, thus the action must change the 
		// state itself.
		pr _isMerged = [_worldState, WSP_GAR_VEHICLE_GROUPS_MERGED] call ws_getPropertyValue;
		pr _vehNonStaticGroupCount = count CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH_NON_STATIC]);
		pr _infGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_IDLE ARG GROUP_TYPE_PATROL]);
		switch true do {
			// Obviously if there is more than one group then its not merged any more
			case (_isMerged && _vehNonStaticGroupCount > 1);
			// If there is any vehicles in non vehicle groups its not merged
			case (_isMerged && {(_infGroups findIf { count CALLM0(_x, "getVehicleUnits") > 0 }) != NOT_FOUND}): {
				[_worldState, WSP_GAR_VEHICLE_GROUPS_MERGED, false] call ws_setPropertyValue;
			};
			// If there is only one group and more than 1 vehicle then it IS merged by strict definition
			case (!_isMerged && _vehNonStaticGroupCount == 1 && CALLM0(_gar, "countVehicleUnits") > 0): {
				[_worldState, WSP_GAR_VEHICLE_GROUPS_MERGED, true] call ws_setPropertyValue;
			};
		};

		// Check if all crew and infantry are in vehicles
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH_STATIC ARG GROUP_TYPE_VEH_NON_STATIC]);

		// Run checks which only make sense for a spawned garrison
		if (_isSpawned) then {
			// Accumulate group state into garrison state
			// All crew is mounted if there are no vehicle groups, or all vehicle group crews are mounted
			pr _allCrewMounted = [_vehGroups, WSP_GROUP_ALL_CREW_MOUNTED, true] call pr0_fnc_accumulateGroupWSP;
			[_worldState, WSP_GAR_ALL_CREW_MOUNTED, _allCrewMounted] call ws_setPropertyValue;

			// // All drivers are assigned if there are no vehicle groups, all all vehicle groups have assigned drivers
			// pr _haveDrivers = [_vehGroups, WSP_GROUP_DRIVERS_ASSIGNED, true] call pr0_fnc_accumulateGroupWSP;
			// [_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, _haveDrivers] call ws_setPropertyValue;

			// // All turrets operators are assigned if there are no vehicle groups, all all vehicle groups have assigned turret operators
			// pr _haveTurretOperators = [_vehGroups, WSP_GROUP_TURRETS_ASSIGNED, true] call pr0_fnc_accumulateGroupWSP;
			// [_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, _haveTurretOperators] call ws_setPropertyValue;

			// All inf are mounted if all inf groups are mounted or there are no inf groups
			pr _allInfMounted = [_infGroups, WSP_GROUP_ALL_INFANTRY_MOUNTED, true] call pr0_fnc_accumulateGroupWSP;
			[_worldState, WSP_GAR_ALL_INFANTRY_MOUNTED, _allInfMounted] call ws_setPropertyValue;

			// Garrison position is average of group positions, if there are any
			pr _allGroups = _infGroups + _vehGroups;
			if(count _allGroups > 0) then {
				pr _pos = [0,0,0];
				{
					_pos = _pos vectorAdd CALLM0(_x, "getPos");
				} forEach _allGroups;
				_pos = _pos vectorMultiply (1 / count _allGroups);
				_pos = ZERO_HEIGHT(_pos);
				CALLM1(_AI, "setPos", _pos);
				// [_worldState, WSP_GAR_POSITION, _pos] call ws_setPropertyValue;
			};
		} else {
			// When unspawned the group specific states related to units can be assumed based on unit counts
			// All crew is always considerd mounted when unspawned
			[_worldState, WSP_GAR_ALL_CREW_MOUNTED, true] call ws_setPropertyValue;

			// // All drivers are assigned if there are enough inf for all driver positions
			// [_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, _enoughHumansForAllVehicles] call ws_setPropertyValue;

			// // All turrets operators are assigned if there are enough inf for all driver and turret positions
			// [_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, _enoughHumansToTurretAllVehicles] call ws_setPropertyValue;

			// All inf are considered mounted always
			[_worldState, WSP_GAR_ALL_INFANTRY_MOUNTED, true] call ws_setPropertyValue;
		};

		// Vehicle-related checks

		// Check if all vehicles have enough crew
		pr _vehGroupsStatic = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		pr _vehGroupsNonStatic = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC);

		// Find static vehicle groups that don't have enough infantry to operate all guns
		pr _haveTurretsStatic = true;
		pr _requiredCrew = 0;
		pr _assignedCrew = 0;
		{
			CALLM0(_x, "getRequiredCrew") params ["_nDrivers", "_nTurrets", "_nCargo"];
			pr _nInf = count CALLM0(_x, "getInfantryUnits");
			
			_haveTurretsStatic = _haveTurretsStatic && _nTurrets <= _nInf;

			_assignedCrew = _assignedCrew + _nInf;
			_requiredCrew = _requiredCrew + _nTurrets;
		} forEach _vehGroupsStatic;

		// Find non static vehicle groups that don't have enough drivers or turret operators
		pr _haveTurretsNonStatic = true;
		pr _haveDriversNonStatic = true;
		//pr _correctNumberOfCrew = true;
		{
			CALLM0(_x, "getRequiredCrew") params ["_nDrivers", "_nTurrets", "_nCargo"];
			pr _nInf = count CALLM0(_x, "getInfantryUnits");

			_haveDriversNonStatic = _haveDriversNonStatic && _nDrivers <= _nInf;
			_haveTurretsNonStatic = _haveTurretsNonStatic && _nTurrets <= _nInf-_nDrivers;

			_assignedCrew = _assignedCrew + _nInf;
			_requiredCrew = _requiredCrew + _nTurrets;

			// _unbalancedCrew = _unbalancedCrew || _nInf > _nDrivers + _nTurrets;
			//if (_nInf != _nDrivers + _nTurrets) then { _correctNumberOfCrew = false };
			//if (!_haveTurretsNonStatic && !_haveDriversNonStatic && !_correctNumberOfCrew) exitWith {}; // Terminate the loop if we already know that this group is unbalanced
		} forEach _vehGroupsNonStatic;

		[_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, _haveDriversNonStatic] call ws_setPropertyValue;
		[_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, _haveTurretsStatic && _haveTurretsNonStatic] call ws_setPropertyValue;

		// Groups are balanced if we have assigned as much crew as possible, and no more than required
		// All other inf should be in separate groups
		pr _balanced = _assignedCrew == MINIMUM(_requiredCrew, _nInfGarrison);
		[_worldState, WSP_GAR_VEHICLE_GROUPS_BALANCED, _balanced] call ws_setPropertyValue;

		//OOP_INFO_3("Infantry amount: %1, all infantry seats: %2, driver seats: %3", _nInfGarrison, _nSeatsAll, _nDriversAll);

	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getUpdateInterval") {
		params ["_thisObject"];
		pr _gar = T_GETV("gar");
		// If garrison is not spawned, run the check less often
		if (CALLM0(_gar, "isSpawned")) then {
			10
		} else {
			120
		};
	} ENDMETHOD;	
	
ENDCLASS;