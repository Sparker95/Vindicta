#include "common.hpp"

/*
This sensor checks the health state of units: does infantry need to be healed, do vehicles need to be repaired

Author: Sparker 08.11.2018
*/

#define pr private

CLASS("SensorGarrisonHealth", "SensorGarrison")

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		pr _AI = GETV(_thisObject, "AI");
		pr _worldState = GETV(_AI, "worldState");
		
		// Find soldiers and check if they all are allright
		pr _soldiers = [_gar, [[T_INF, -1]]] call GETM(_gar, "findUnits");
		pr _allSoldiersHealed = true;
		{ // for each soldiers
			pr _oh = CALLM(_x, "getObjectHandle", []);
			if (getDammage _oh > 0.5) exitWith {_allSoldiersHealed = false;};
		} forEach _soldiers;
		[_worldState, WSP_GAR_ALL_HUMANS_HEALED, _allSoldiersHealed] call ws_setPropertyValue;
		
		// Find vehicles and check if they all are OK
		// todo query the group sensor instead
		pr _vehicles = [_gar, [[T_VEH, -1], [T_DRONE, -1]]] call GETM(_gar, "findUnits");
		//diag_log format ["Found vehicles: %1", _vehicles];
		pr _allVehRepaired = true;
		pr _allVehCanMove = true;
		{ // for each vehicles
			pr _oh = CALLM(_x, "getObjectHandle", []);
			//diag_log format ["Vehicle: %1, can move: %2", _oh, canMove _oh];
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID"]; //, "_className"];
			pr _isStatic = [_catID, _subcatID] in T_static;
			pr _anyWheelDamaged = if (!_isStatic) then {[_oh] call AI_misc_fnc_isAnyWheelDamaged} else {false};
			if (getDammage _oh > 0.61) then {_allVehRepaired = false;};
			if (((!canMove _oh) || _anyWheelDamaged || (fuel _oh < 0.01)) && !_isStatic) then {_allVehCanMove = false;};
		} forEach _vehicles;
		[_worldState, WSP_GAR_ALL_VEHICLES_REPAIRED, _allVehRepaired] call ws_setPropertyValue;
		[_worldState, WSP_GAR_ALL_VEHICLES_CAN_MOVE, _allVehCanMove] call ws_setPropertyValue;		
		
		/*pr _str = format ["medics:%1 engineer:%2 allHealed:%3 allVehRepaired:%4 allVehCanMove:%5 vehsHaveDrivers: %6, vehsHaveTurrets: %7, crew mounted: %8, inf mounted: %9",
			_medicAvailable, _engineerAvailable, _allSoldiersHealed, _allVehRepaired, _allVehCanMove, _haveDriversNonStatic,
			_haveTurretsStatic && _haveTurretsNonStatic, _allCrewMounted, _allInfMounted];
		OOP_INFO_0(_str);
		*/
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getUpdateInterval") {
		10
	} ENDMETHOD;	
	
ENDCLASS;