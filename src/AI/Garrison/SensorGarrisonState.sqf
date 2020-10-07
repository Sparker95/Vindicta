#include "common.hpp"

/*
This sensor checks various conditions related to general garrison state.

Author: Sparker 08.11.2018
*/

#define pr private

vin_fnc_accumulateGroupWSP = {
	pr _garValue = true;
	CRITICAL_SECTION {
		params ["_groups", "_groupWSP", "_default"];
		if (count _groups == 0) exitWith {
			_default
		};
		{
			pr _groupVal = [_x, _groupWSP] call ws_getPropertyValue;
			_garValue = _garValue && _groupVal;
		} forEach (_groups apply { CALLM0(_x, "getAI") } apply { GETV(_x, "worldState") });
	};
	_garValue
};

#define OOP_CLASS_NAME SensorGarrisonState
CLASS("SensorGarrisonState", "SensorGarrison")

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	public override METHOD(update)
		params [P_THISOBJECT];

		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");
		pr _isSpawned = CALLM0(_gar, "isSpawned");
		pr _worldState = GETV(_AI, "worldState");

		// Check if there are enough humans to operate all the vehicles
		pr _vehUnits = CALLM0(_gar, "getVehicleUnits");
		CALLSM1("Unit", "getRequiredCrew", _vehUnits) params ["_nDriversAll", "_nTurretsAll", "_nCargoAll"];

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
		pr _allGroups = CALLM0(_gar, "getGroups");
		pr _vehNonStaticGroupCount = ({ CALLM0(_x, "getType") == GROUP_TYPE_VEH } count _allGroups);
		pr _infGroups = _allGroups select { CALLM0(_x, "getType") == GROUP_TYPE_INF };
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

		// Run checks which only make sense for a spawned garrison
		if (_isSpawned) then {
			// Accumulate group state into garrison state
			// All crew is mounted if there are no vehicle groups, or all vehicle group crews are mounted
			pr _allCrewMounted = [_allGroups, WSP_GROUP_ALL_CREW_MOUNTED, true] call vin_fnc_accumulateGroupWSP;
			[_worldState, WSP_GAR_ALL_CREW_MOUNTED, _allCrewMounted] call ws_setPropertyValue;

			// // All drivers are assigned if there are no vehicle groups, all all vehicle groups have assigned drivers
			// pr _haveDrivers = [_allGroups, WSP_GROUP_DRIVERS_ASSIGNED, true] call vin_fnc_accumulateGroupWSP;
			// [_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, _haveDrivers] call ws_setPropertyValue;

			// // All turrets operators are assigned if there are no vehicle groups, all all vehicle groups have assigned turret operators
			// pr _haveTurretOperators = [_allGroups, WSP_GROUP_TURRETS_ASSIGNED, true] call vin_fnc_accumulateGroupWSP;
			// [_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, _haveTurretOperators] call ws_setPropertyValue;

			// All inf are mounted if all inf groups are mounted or there are no inf groups
			pr _allInfMounted = [_allGroups, WSP_GROUP_ALL_INFANTRY_MOUNTED, true] call vin_fnc_accumulateGroupWSP;
			[_worldState, WSP_GAR_ALL_INFANTRY_MOUNTED, _allInfMounted] call ws_setPropertyValue;

			// Aggregate landed value
			pr _allGroupsLanded = [_allGroups, WSP_GROUP_ALL_LANDED, true] call vin_fnc_accumulateGroupWSP;
			if (isNil "_allGroupsLanded") then { _allGroupsLanded = true; }; // For some reason nil is returned sometimes? :/
			[_worldState, WSP_GAR_ALL_LANDED, _allGroupsLanded] call ws_setPropertyValue;

			// Garrison position is average of group positions, if there are any
			//pr _allGroups = _infGroups + _vehGroups;
			if(count _allGroups > 0) then {
				pr _pos = [0,0,0];
				{
					_pos = _pos vectorAdd CALLM0(_x, "getPos");
				} forEach _allGroups;
				_pos = _pos vectorMultiply (1 / count _allGroups);
				_pos = ZERO_HEIGHT(_pos);
				if ((_pos#0 != 0) && (_pos#1 != 0)) then {
					CALLM1(_AI, "setPos", _pos);
				} else {
					OOP_ERROR_0("Calculated garrison position is [0,0]");
				};
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

			// All groups are considered landed always
			[_worldState, WSP_GAR_ALL_LANDED, true] call ws_setPropertyValue;
		};

		// Vehicle-related checks
		pr _requiredCrew = 0;
		pr _assignedCrew = 0;

		// Find combat vehicles which are not in groups, we must put them into groups later so that bots can use them
		pr _allCombatVehiclesInGroup = _vehUnits findIf {
			(CALLM0(_x, "getSubcategory") in T_VEH_combat) && { IS_NULL_OBJECT(CALLM0(_x, "getGroup")) }
		} == -1;

		// Find non static vehicle groups that don't have enough drivers or turret operators
		pr _haveTurretOperators = true;
		pr _haveDrivers = true;
		pr _groupTypesCorrect = true;
		//pr _correctNumberOfCrew = true;
		{
			CALLM0(_x, "getRequiredCrew") params ["_nDrivers", "_nTurrets", "_nCargo"];
			pr _type = CALLM0(_x, "getType");

			if(_nDrivers + _nTurrets > 0) then {
				pr _nInf = count CALLM0(_x, "getInfantryUnits");

				_haveDrivers = _haveDrivers && _nDrivers <= _nInf;
				_haveTurretOperators = _haveTurretOperators && _nTurrets <= _nInf - _nDrivers;

				_assignedCrew = _assignedCrew + _nInf;
				_requiredCrew = _requiredCrew + _nDrivers + _nTurrets;

				_groupTypesCorrect = _groupTypesCorrect && _type in [GROUP_TYPE_VEH, GROUP_TYPE_STATIC];
			} else {
				_groupTypesCorrect = _groupTypesCorrect && _type == GROUP_TYPE_INF;
			};
			// _unbalancedCrew = _unbalancedCrew || _nInf > _nDrivers + _nTurrets;
			//if (_nInf != _nDrivers + _nTurrets) then { _correctNumberOfCrew = false };
			//if (!_haveTurretOperators && !_haveDrivers && !_correctNumberOfCrew) exitWith {}; // Terminate the loop if we already know that this group is unbalanced
		} forEach _allGroups;

		[_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, _haveDrivers] call ws_setPropertyValue;
		[_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, _haveTurretOperators] call ws_setPropertyValue;

		// Groups are balanced if we have assigned as much crew as possible, and no more than required, and group types reflect their contents correctly
		// All other inf should be in separate groups
		pr _balanced = _assignedCrew == MINIMUM(_requiredCrew, _nInfGarrison);
		[_worldState, WSP_GAR_GROUPS_BALANCED, _balanced && _groupTypesCorrect && _allCombatVehiclesInGroup] call ws_setPropertyValue;

		//OOP_INFO_3("Infantry amount: %1, all infantry seats: %2, driver seats: %3", _nInfGarrison, _nSeatsAll, _nDriversAll);

	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	public override METHOD(getUpdateInterval)
		params [P_THISOBJECT];
		pr _gar = T_GETV("gar");
		// If garrison is not spawned, run the check less often
		if (CALLM0(_gar, "isSpawned")) then {
			13
		} else {
			120
		};
	ENDMETHOD;
	
ENDCLASS;