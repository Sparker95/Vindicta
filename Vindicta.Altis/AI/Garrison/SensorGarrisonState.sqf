#include "common.hpp"

/*
This sensor checks various conditions related to general garrison state.

Author: Sparker 08.11.2018
*/

#define pr private

CLASS("SensorGarrisonState", "SensorGarrison")

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		pr _AI = GETV(_thisObject, "AI");
		pr _gar = T_GETV("gar");
		pr _isSpawned = CALLM0(_gar, "isSpawned");
		pr _worldState = GETV(_AI, "worldState");
		
		// Check if all crew and infantry are in vehicles
		pr _infGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_IDLE ARG GROUP_TYPE_PATROL]);
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH_STATIC ARG GROUP_TYPE_VEH_NON_STATIC]);
		
		// Run checks which only make sense for a spawned garrison
		if (_isSpawned) then {
			// Query world states of vehicle groups and AND all their values
			pr _allCrewMounted = true;
			if (count _vehGroups == 0) then { // If there are no vehicle groups, set property to false
				_allCrewMounted = false;
			} else {
				{
					pr _groupAI = CALLM0(_x, "getAI");
					pr _groupWS = GETV(_groupAI, "worldState");
					pr _val = [_groupWS, WSP_GROUP_ALL_INFANTRY_MOUNTED] call ws_getPropertyValue;
					_allCrewMounted = _allCrewMounted && _val;
				} forEach _vehGroups;
			};
			[_worldState, WSP_GAR_ALL_CREW_MOUNTED, _allCrewMounted] call ws_setPropertyValue;

			// Query world state of infantry groups
			pr _allInfMounted = true;
			if (count _infGroups == 0) then {
				_allInfMounted = true;
			} else {
				{
					pr _groupAI = CALLM0(_x, "getAI");
					pr _groupWS = GETV(_groupAI, "worldState");
					pr _val = [_groupWS, WSP_GROUP_ALL_INFANTRY_MOUNTED] call ws_getPropertyValue;
					_allInfMounted = _allInfMounted && _val;
				} forEach _infGroups;
			};
			[_worldState, WSP_GAR_ALL_INFANTRY_MOUNTED, _allInfMounted] call ws_setPropertyValue;
		};

		// Vehicle-related checks

		// Check if all vehicles have enough crew
		pr _vehGroupsStatic = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		pr _vehGroupsNonStatic = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC);

		// Find static vehicle groups that don't have enough infantry to operate all guns
		pr _haveTurretsStatic = true;
		{
			CALLM0(_x, "getRequiredCrew") params ["_nDrivers", "_nTurrets", "_nCargo"];
			pr _nInf = count CALLM0(_x, "getInfantryUnits");
			if (_nTurrets > _nInf) then { _haveTurretsStatic = false; };
		} forEach _vehGroupsStatic;

		// Find non static vehicle groups that don't have enough drivers or turret operators
		pr _haveTurretsNonStatic = true;
		pr _haveDriversNonStatic = true;
		pr _correctNumberOfCrew = true;
		{
			CALLM0(_x, "getRequiredCrew") params ["_nDrivers", "_nTurrets", "_nCargo"];
			pr _nInf = count CALLM0(_x, "getInfantryUnits");
			if (_nDrivers > _nInf) then { _haveDriversNonStatic = false };
			if (_nTurrets > (_nInf-_nDrivers)) then { _haveTurretsNonStatic = false };
			if (_nInf != _nDrivers + _nTurrets) then { _correctNumberOfCrew = false };
			if (!_haveTurretsNonStatic && !_haveDriversNonStatic && !_correctNumberOfCrew) exitWith {}; // Terminate the loop if we already know that this group is unbalanced
		} forEach _vehGroupsNonStatic;
		
		[_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, _haveDriversNonStatic] call ws_setPropertyValue;
		[_worldState, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, _haveTurretsStatic && _haveTurretsNonStatic] call ws_setPropertyValue;
		
		pr _unbalancedGroups = _infGroups apply {
			count CALLM0(_x, "getInfantryUnits")
		} select {
			// Weird inf group sizes
			// _x < 2 && count _infGroups > 1 || 
			_x > 12
		};
		[_worldState, WSP_GAR_VEHICLE_GROUPS_BALANCED, _correctNumberOfCrew && count _unbalancedGroups == 0] call ws_setPropertyValue;
		
		// Check if there are enough humans to operate all the vehicles
		pr _vehUnits = CALLM0(_gar, "getVehicleUnits");
		CALLSM("Unit", "getRequiredCrew", [_vehUnits]) params ["_nDriversAll", "_nTurretsAll", "_nCargoAll"];
		// Drivers
		pr _query = [[T_INF, -1]];
		pr _nInfGarrison = CALLM1(_gar, "countUnits", _query);
		pr _enoughHumansForAllVehicles = _nInfGarrison > _nDriversAll;	
		[_worldState, WSP_GAR_ENOUGH_HUMANS_TO_DRIVE_ALL_VEHICLES, _enoughHumansForAllVehicles] call ws_setPropertyValue;
		// Turrets
		pr _enoughHumansToTurretAllVehicles = _nInfGarrison > (_nDriversAll + _nTurretsAll);
		[_worldState, WSP_GAR_ENOUGH_HUMANS_TO_TURRET_ALL_VEHICLES, _enoughHumansToTurretAllVehicles] call ws_setPropertyValue;

		// Check if there are enough seats for all humans
		pr _nSeatsAll = _nCargoAll + _nTurretsAll + _nDriversALl;
		pr _enoughVehicles = _nInfGarrison <= _nSeatsAll;
		[_worldState, WSP_GAR_ENOUGH_VEHICLES_FOR_ALL_HUMANS, _enoughVehicles] call ws_setPropertyValue;


		// Check if all vehicle groups are merged or not
		/*
		// It's not what it looks like!
		// We must keep this world state property at 'false' 
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH_NON_STATIC]);
		pr _merged = (count _vehGroups) <= 1;
		[_worldState, WSP_GAR_VEHICLE_GROUPS_MERGED, _merged] call ws_setPropertyValue;
		*/

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