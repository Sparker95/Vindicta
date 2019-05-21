#include "common.hpp"


/*
Sensor for a group to check its health properties.
*/

#define pr private

// Update interval of this sensor
#define UPDATE_INTERVAL 10

CLASS("SensorGroupHealth", "SensorGroup")

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]]];
	} ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _ws = GETV(_AI, "worldState");
		
		// Check if vehicles need unflipping
		pr _vehicles = (
			(CALLM0(_group, "getUnits") select {CALLM0(_x, "isVehicle")}) apply {CALLM0(_x, "getObjectHandle")}
		);
		pr _allTouchingGround = (_vehicles findIf {[_x] call misc_fnc_isVehicleFlipped}) == -1;
		[_ws, WSP_GROUP_ALL_VEHICLES_TOUCHING_GROUND, _allTouchingGround] call ws_setPropertyValue;
		
		// Check if vehicles need repairs
		pr _allRepaired = (_vehicles findIf {! (canMove _x)}) == -1;
		[_ws, WSP_GROUP_ALL_VEHICLES_REPAIRED, _allRepaired] call ws_setPropertyValue;
		
		// Check if there are any null objects
		pr _units = CALLM0(_group, "getUnits");
		{
			if (isNull CALLM0(_x, "getObjectHandle")) then {
				OOP_ERROR_1("UNIT OBJECT IS NULL: %1", _x);
			};
		} forEach _units;

		// Check if all infantry units are in vehicles
		pr _infantryUnits = CALLM0(_group, "getInfantryUnits");
		pr _infantry = _infantryUnits apply {CALLM0(_x, "getObjectHandle")};
		pr _allInfMounted = (_infantry findIf {(vehicle _x) == _x}) == -1;
		[_ws, WSP_GROUP_ALL_INFANTRY_MOUNTED, _allInfMounted] call ws_setPropertyValue;
		
		// Check if all infantry units are in proper group
		// Sometimes units get ungrouped when entering vehicles >_< WTF this shit is so annoying, BIS why do you make broken things everywhere
		pr _hG = CALLM0(_group, "getGroupHandle");
		{
			pr _hO = CALLM0(_x, "getObjectHandle");
			pr _infGroup = group _hO;
			if (! (_infGroup isEqualTo _hG)) then {
				OOP_INFO_3("UNIT IS IN WRONG GROUP: unit: %1, unit's current group handle: %2, required group handle: %3", _x, _infGroup, _hG);
				
				// Force the unit to join the proper group
				[_hO] joinSilent _hG;
				[_hO] joinSilent _hG;
			};
		} forEach _infantryUnits;

		// Check if the group leader is the proper unit
		// ... just to be sure
		pr _hActualLeader = leader _hG;
		pr _actualLeaderUnit = CALLSM1("Unit", "getUnitFromObjectHandle", _hActualLeader);
		pr _properLeaderUnit = CALLM0(_group, "getLeader");
		pr _hProperLeader = if (_properLeaderUnit != "") then { CALLM0(_properLeaderUnit, "getObjectHandle") } else {objNull};
		if (_actualLeaderUnit != _properLeaderUnit) then {
			if (alive _hActualLeader && _properLeaderUnit != "") then {
				OOP_ERROR_5("WRONG GROUP LEADER in group %1: Actual leader: %2, %3,    proper group leader: %4, %5", _group, _hActualLeader, _actualLeaderUnit, _hProperLeader, _properLeaderUnit); 
			};
			if (_properLeaderUnit != "") then { CALLM1(_group, "setLeader", _properLeaderUnit); };
		};
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD("getUpdateInterval") {
		UPDATE_INTERVAL
	} ENDMETHOD;
	
ENDCLASS;