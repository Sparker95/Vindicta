#include "common.hpp"

/*
This sensor checks the health state of units: does infantry need to be healed, do vehicles need to be repaired

Author: Sparker 08.11.2018
*/

#define pr private

#define OOP_CLASS_NAME SensorGarrisonHealth
CLASS("SensorGarrisonHealth", "SensorGarrison")

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	public override METHOD(update)
		params [P_THISOBJECT];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) then {
			// If not spawned

			pr _AI = T_GETV("AI");
			pr _worldState = GETV(_AI, "worldState");

			[_worldState, WSP_GAR_ALL_HUMANS_HEALED, true] call ws_setPropertyValue;
			[_worldState, WSP_GAR_ALL_VEHICLES_REPAIRED, true] call ws_setPropertyValue;
			[_worldState, WSP_GAR_ALL_VEHICLES_CAN_MOVE, true] call ws_setPropertyValue;

		} else {
			// If spawned

			pr _AI = T_GETV("AI");
			pr _worldState = GETV(_AI, "worldState");
			
			// Find soldiers and check if they all are allright
			pr _soldiers = CALLM0(_gar, "getInfantryUnits");
			
			pr _allSoldiersHealed = _soldiers findIf { damage CALLM0(_x, "getObjectHandle") > 0.5 } == NOT_FOUND;
			[_worldState, WSP_GAR_ALL_HUMANS_HEALED, _allSoldiersHealed] call ws_setPropertyValue;
			
			// Find vehicles and check if they all are OK
			// todo query the group sensor instead
			pr _vehicles = CALLM0(_gar, "getVehicleUnits");

			//diag_log format ["Found vehicles: %1", _vehicles];
			pr _allVehRepaired = _vehicles findIf { CALLM0(_x, "isDamaged") } == NOT_FOUND;
			pr _allVehCanMove = _vehicles findIf { !CALLM0(_x, "canMove") } == NOT_FOUND;

			[_worldState, WSP_GAR_ALL_VEHICLES_REPAIRED, _allVehRepaired] call ws_setPropertyValue;
			[_worldState, WSP_GAR_ALL_VEHICLES_CAN_MOVE, _allVehCanMove] call ws_setPropertyValue;
			
			/*pr _str = format ["medics:%1 engineer:%2 allHealed:%3 allVehRepaired:%4 allVehCanMove:%5 vehsHaveDrivers: %6, vehsHaveTurrets: %7, crew mounted: %8, inf mounted: %9",
				_medicAvailable, _engineerAvailable, _allSoldiersHealed, _allVehRepaired, _allVehCanMove, _haveDriversNonStatic,
				_haveTurretsStatic && _haveTurretsNonStatic, _allCrewMounted, _allInfMounted];
			OOP_INFO_0(_str);
			*/
		};
		
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	public override METHOD(getUpdateInterval)
		params [P_THISOBJECT];

		pr _gar = T_GETV("gar");
		[60, 14] select CALLM0(_gar, "isSpawned");
	ENDMETHOD;
	
ENDCLASS;