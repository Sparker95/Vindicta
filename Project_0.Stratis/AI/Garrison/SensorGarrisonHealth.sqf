/*
This sensor checks the health state of units: does infantry need to be healed, do vehicles need to be repaired

Author: Sparker 08.11.2018
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "garrisonWorldStateProperties.hpp"

#define pr private

CLASS("SensorGarrisonHealth", "Sensor")

	VARIABLE("agent"); // Pointer to the unit which holds this AI object
	VARIABLE("timeNextUpdate");

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		pr _AI = GETV(_thisObject, "AI");
		pr _gar = GETV(_AI, "agent");
		pr _worldState = GETV(_AI, "worldState");
		
		// Find medics
		pr _medics = [_gar, [[T_INF, T_INF_medic], [T_INF, T_INF_recon_medic]]] call GETM(_gar, "findUnits");
		pr _medicAvailable = (count _medics) > 0;
		[_worldState, WSP_GAR_MEDIC_AVAILABLE, _medicAvailable] call ws_setPropertyValue;
		
		// Find engineers
		pr _engineers = [_gar, [[T_INF, T_INF_engineer]]] call GETM(_gar, "findUnits");
		pr _engineerAvailable = (count _engineers) > 0;
		[_worldState, WSP_GAR_ENGINEER_AVAILABLE, _engineerAvailable] call ws_setPropertyValue;
		
		// Find soldiers and check if they all are allright
		pr _soldiers = [_gar, [[T_INF, -1]]] call GETM(_gar, "findUnits");
		pr _allSoldiersHealed = true;
		{ // for each soldiers
			pr _oh = CALLM(_x, "getObjectHandle", []);
			if (getDammage _oh > 0.5) exitWith {_allSoldiersHealed = false;};
		} forEach _soldiers;
		[_worldState, WSP_GAR_ALL_HUMANS_HEALED, _allSoldiersHealed] call ws_setPropertyValue;
		
		// Find vehicles and check if they all are OK
		pr _vehicles = [_gar, [[T_VEH, -1], [T_DRONE, -1]]] call GETM(_gar, "findUnits");
		//diag_log format ["Found vehicles: %1", _vehicles];
		pr _allVehRepaired = true;
		{ // for each vehicles
			pr _oh = CALLM(_x, "getObjectHandle", []);
			//diag_log format ["Vehicle: %1, can move: %2", _oh, canMove _oh];
			if (getDammage _oh > 0.2 || !canMove _oh) exitWith {_allVehRepaired = false;};
		} forEach _vehicles;
		[_worldState, WSP_GAR_ALL_VEHICLES_REPAIRED, _allVehRepaired] call ws_setPropertyValue;
		
		diag_log format ["SensorGarrisonHealth: %1 %2 %3 %4", _medicAvailable, _engineerAvailable, _allSoldiersHealed, _allVehRepaired];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getUpdateInterval") {
		5
	} ENDMETHOD;	
	
ENDCLASS;