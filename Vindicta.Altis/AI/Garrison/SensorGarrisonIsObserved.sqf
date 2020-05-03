#include "common.hpp"

/*
Sensor that checks if any unit of THIS garrison is spotted by enemy side.
It doesn't create data in this garrison. Instead, it sends data to enemy commander AI.
The reason why it's done this way is because it fits the concept of a sensor, also it's easier to run such checks while on server/HC machine.
Author: Sparker 28.01.2019
*/

#define pr private

// Update interval of this sensor
#define UPDATE_INTERVAL 7

// ---- Debugging defines ----


#define OOP_CLASS_NAME SensorGarrisonIsObserved
CLASS("SensorGarrisonIsObserved", "SensorGarrison")

	/*
	METHOD(new)
		params [P_THISOBJECT];
	ENDMETHOD;
	*/

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(update)
		params [P_THISOBJECT];
		
		//diag_log "UPDATE";
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");

		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		OOP_INFO_1("UPDATE: %1", GETV(_gar, "AI"));

		// Bail if there is no location (for now)
		pr _loc = CALLM0(_gar, "getLocation");
		if (_loc == "") exitWith {};

		pr _side = CALLM0(_gar, "getSide");
		pr _enemySides = [WEST, EAST, INDEPENDENT] - [_side];

		
		pr _pos = CALLM0(_gar, "getPos");
		
		// Get units that can spawn this location that are also within spawn range
		pr _enemyObjects = (CALLM1(gLUAP, "getUnitArray", _side)) select { ((_x in allPlayers) || (_x isEqualTo (leader group _x))) && ((_x distance _pos) < 1500) && (alive _x) && ((side group _x) != _side)}; // todo retrieve the proper spawn distance
		
		// Get units of this garrison
		pr _thisUnits = CALLM0(_gar, "getUnits");
		pr _thisObjects = _thisUnits apply {CALLM0(_x, "getObjectHandle")};
		
		// Check if other sides can see any unit of this garrison
		{
			pr _s = _x;
			pr _enemyObjectsSide = _enemyObjects select {side group _x == _s};
			pr _observedBySide = _enemyObjectsSide findIf {
				pr _enemyObject = _x;
				pr _enemyObservesThisUnit = _thisObjects findIf {
					(_enemyObject targetKnowledge _x) params ["_knownByGroup", "_knownByUnit", "_lastSeenTime"/*, "_lastEndangeredTime", "_targetSide", "_positionError", "_position"*/];
					_knownByUnit && ((time - _lastSeenTime) < 6.66)
				};
				_enemyObservesThisUnit != NOT_FOUND
			};
			if (_observedBySide != -1) then {
				// Send data to enemy commander of this side
				
				OOP_INFO_3("Location %1 is observed by side: %2, unit: %3", _loc, _x, _enemyObjectsSide select _observedBySide);
				
				// Report to chat for now
				//systemChat format ["Location %1 is observed by side: %2, time: %3", _loc, _x, GAME_TIME];
				
				// Report to the AICommander of the side that observes this location
				private _AICommander = CALL_STATIC_METHOD("AICommander", "getAICommander", [_s]);
				if (!IS_NULL_OBJECT(_AICommander) && _loc != "") then {
				
					//OOP_INFO_1("Reporting to AICommander: %1", _AICommander);
				
					pr _stim = STIMULUS_NEW();
					//STIMULUS_SET_SOURCE(_stim, _loc);
					STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_LOCATION);
					STIMULUS_SET_VALUE(_stim, _loc);
					
					//OOP_INFO_1("Sending stimulus: %1", _stim);
					
					// Send the stimulus if this garrison is attached to a location
					CALLM2(_AICommander, "postMethodAsync", "handleStimulus", [_stim]);
				};
			};
		} forEach _enemySides;
		
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD(getUpdateInterval)
		UPDATE_INTERVAL
	ENDMETHOD;
	
ENDCLASS;