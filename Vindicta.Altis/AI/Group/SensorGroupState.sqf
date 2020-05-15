#include "common.hpp"
FIX_LINE_NUMBERS()

/*
Sensor for a group to check its health properties.
*/

#define pr private

// Update interval of this sensor
#define UPDATE_INTERVAL 10

#define OOP_CLASS_NAME SensorGroupState
CLASS("SensorGroupState", "SensorGroup")

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
	ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(update)
		params [P_THISOBJECT];

		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _ws = GETV(_AI, "worldState");

		// Check if vehicles need unflipping
		pr _units = CALLM0(_group, "getUnits");
		pr _vehicleUnits = _units select { CALLM0(_x, "isVehicle") };
		pr _vehicleHandles = _vehicleUnits apply { CALLM0(_x, "getObjectHandle") };
		pr _infantryUnits = _units select { CALLM0(_x, "isInfantry") };
		pr _infantryHandles = _infantryUnits apply { CALLM0(_x, "getObjectHandle") };

		pr _allTouchingGround = _vehicleHandles findIf {[_x] call misc_fnc_isVehicleFlipped} == NOT_FOUND;
		[_ws, WSP_GROUP_ALL_VEHICLES_UPRIGHT, _allTouchingGround] call ws_setPropertyValue;

		// Check if vehicles are landed (or inf is in landed vehicle)
		pr _allLanded = _infantryHandles findIf { !isTouchingGround vehicle _x } == NOT_FOUND &&
			{ _vehicleHandles findIf { !isTouchingGround _x } == NOT_FOUND };

		[_ws, WSP_GROUP_ALL_LANDED, _allLanded] call ws_setPropertyValue;

		// Check if vehicles need repairs
		pr _allRepaired = _vehicleHandles findIf { !canMove _x } == NOT_FOUND;
		[_ws, WSP_GROUP_ALL_VEHICLES_REPAIRED, _allRepaired] call ws_setPropertyValue;

		// Check if there are any null objects  (can get this due to either bugs or deleting units in Zeus)
		{
			if (isNull CALLM0(_x, "getObjectHandle")) then {
				OOP_WARNING_1("UNIT OBJECT IS NULL: %1, cleaning it up", _x);
				CALLM2(gMessageLoopMainManager, "postMethodAsync", "UnitKilled", [_x]);
			};
		} forEach _units;

		// Check if all infantry units are in vehicles
		pr _allInfMounted = (_infantryHandles findIf { vehicle _x == _x }) == NOT_FOUND;
		[_ws, WSP_GROUP_ALL_INFANTRY_MOUNTED, _allInfMounted] call ws_setPropertyValue;

		//pr _allCrewMounted = (_allCrewHandles findIf { vehicle _x == _x }) == NOT_FOUND;
		CALLM0(_group, "getRequiredCrew") params ["_reqDrivers", "_reqTurrets"];

		pr _allCrewMounted = if(_reqDrivers > 0 || _reqTurrets > 0) then {
			pr _infantryAI = _infantryUnits apply { CALLM0(_x, "getAI") };
			pr _allMountedDrivers = _infantryAI select { 
				CALLM0(_x, "getAssignedVehicleRole") isEqualTo "DRIVER"
			} apply {
				GETV(_x, "hO")
			} select {
				vehicle _x != _x && {driver vehicle _x == _x}
			};

			pr _allTurretOperators = _infantryAI select { 
				CALLM0(_x, "getAssignedVehicleRole") isEqualTo "TURRET"
			} apply {
				GETV(_x, "hO")
			} select {
				vehicle _x != _x // && {_x in (fullCrew [vehicle _x, "Turret", false] apply { _x#0 })} This doesn't work for some reason, we will just assume if they are mounted they are in the correct seat...
			};
			pr _infCount = count _infantryUnits;
			// All possible driving positions are filled
			pr _driversMounted = MINIMUM(_infCount, _reqDrivers) == count _allMountedDrivers;
			// All possible turret positions are filled
			pr _turretOperatorsMounted = MINIMUM(_infCount - _reqDrivers, _reqTurrets) == count _allTurretOperators;
			_driversMounted && _turretOperatorsMounted
		} else {
			true
		};

		[_ws, WSP_GROUP_ALL_CREW_MOUNTED, _allCrewMounted] call ws_setPropertyValue;
		// [_ws, WSP_GROUP_DRIVERS_ASSIGNED, _driversAssigned] call ws_setPropertyValue;
		// [_ws, WSP_GROUP_TURRETS_ASSIGNED, _turretsAssigned] call ws_setPropertyValue;

		// Check if all infantry units are in proper group
		// Sometimes units get ungrouped when entering vehicles >_< WTF this shit is so annoying, BIS why do you make broken things everywhere
		pr _hG = CALLM0(_group, "getGroupHandle");
		// There are inf but group handle is null or some inf are in the wrong group.
		if(count _infantryHandles != 0 && {isNull _hG || {(_infantryHandles findIf { group _x != _hG }) != NOT_FOUND}}) then {
			OOP_WARNING_1("%1 group handle is null or some units are not in the correct group", _group);
			// This will assign all units to the leaders group
			CALLM0(_group, "rectifyGroupHandle");
		};

		// {
		// 	pr _hO = CALLM0(_x, "getObjectHandle");
		// 	pr _infGroup = group _hO;
		// 	if (! (_infGroup isEqualTo _hG)) then {
		// 		OOP_WARNING_MSG("UNIT IS IN WRONG GROUP: unit: %1, unit's current group handle: %2, required group handle: %3, unit is alive: %4", [_x ARG _infGroup ARG _hG ARG alive _hO]);

		// 		// Force the unit to join the proper group
		// 		[_hO] joinSilent _hG;
		// 		[_hO] joinSilent _hG;
		// 	};
		// } forEach _infantryUnits;

		// Check if the group leader is the proper unit
		// ... just to be sure
		pr _hActualLeader = leader _hG;
		// Only interfere if leader isn't a player
		if !(_hActualLeader in allPlayers) then {
			pr _actualLeaderUnit = CALLSM1("Unit", "getUnitFromObjectHandle", _hActualLeader);
			pr _properLeaderUnit = CALLM0(_group, "getLeader");
			pr _hProperLeader = if (_properLeaderUnit != "") then { CALLM0(_properLeaderUnit, "getObjectHandle") } else {objNull};
			if (_actualLeaderUnit != _properLeaderUnit) then {
				if (alive _hActualLeader && _properLeaderUnit != "") then {
					OOP_WARNING_MSG("WRONG GROUP LEADER in group %1: Actual leader: %2, %3,    proper group leader: %4, %5, %6", [_group ARG _hActualLeader ARG _actualLeaderUnit ARG _hProperLeader ARG _properLeaderUnit ARG alive _hProperLeader]);
				};
				if (_properLeaderUnit != "") then { CALLM1(_group, "setLeader", _properLeaderUnit); };
			};
		};

	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD(getUpdateInterval)
		UPDATE_INTERVAL
	ENDMETHOD;
	
ENDCLASS;