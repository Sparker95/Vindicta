#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\stimulusTypes.hpp"
#include "..\commonStructs.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "garrisonWorldStateProperties.hpp"
#include "..\Commander\LocationData.hpp"


/*
Sensor that checks if any unit of THIS garrison is spotted by enemy side.
It doesn't create data in this garrison. Instead, it sends data to enemy commander AI.
The reason why it's done this way is because it fits the concept of a sensor, also it's easier to run such checks while on server/HC machine.
Author: Sparker 28.01.2019
*/

#define pr private

// Update interval of this sensor
#define UPDATE_INTERVAL 4

// ---- Debugging defines ----


CLASS("SensorGarrisonLocationIsObserved", "SensorGarrison")

	/*
	METHOD("new") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	*/
	
	VARIABLE("timeNextUpdate");

	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		//diag_log "UPDATE";
		
		pr _gar = T_GETV("gar");
		pr _side = CALLM0(_gar, "getSide");
		pr _enemySides = [WEST, EAST, INDEPENDENT]; // - [_side];
		
		// Bail if this garrison has no location
		pr _loc = CALLM0(_gar, "getLocation");
		if (_loc == "") exitWith {};
		pr _locPos = CALLM0(_loc, "getPos");
		
		// Get units that can spawn this location that are also within spawn range
		pr _enemyObjects = (CALLM1(gLUAP, "getUnitArray", _side)) select { ((_x in allPlayers) || (_x isEqualTo (leader group _x))) && ((_x distance _locPos) < 2000) && (alive _x) && ((side _x) != _side)}; // todo retrieve the proper spawn distance
		
		// Get units of this garrison
		pr _thisUnits = CALLM0(_gar, "getUnits");
		pr _thisObjects = _thisUnits apply {CALLM0(_x, "getObjectHandle")};
		
		// Check if other sides can see any unit of this garrison
		{
			pr _s = _x;
			pr _enemyObjectsSide = _enemyObjects select {side group _x == _s};
			pr _observedBySide = _enemyObjectsSide findIf {
				pr _enemyObject = _x;
				pr _enemyObservesThisUnit =  _thisObjects findIf {
					pr _tk = _enemyObject targetKnowledge _x;
					_tk select 1 // Known by unit
				};
				_enemyObservesThisUnit != -1
			};
			if (_observedBySide != -1) then {
				// Send data to enemy commander of this side
				
				OOP_INFO_3("Location %1 is observed by side: %2, unit: %3", _loc, _x, _enemyObjectsSide select _observedBySide);
				
				// Report to chat for now
				systemChat format ["Location %1 is observed by side: %2, time: %3", _loc, _x, time];
				
				// Report to the AICommander of the side that observes this location
				private _AICommander = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_s]);
				if (_AICommander != "") then {
				
					//OOP_INFO_1("Reporting to AICommander: %1", _AICommander);
				
					pr _stim = STIMULUS_NEW();
					//STIMULUS_SET_SOURCE(_stim, _loc);
					STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_LOCATION);
					STIMULUS_SET_VALUE(_stim, _loc);
					
					//OOP_INFO_1("Sending stimulus: %1", _stim);
					
					// Send the stimulus
					CALLM2(_AICommander, "postMethodAsync", "handleStimulus", [_stim]);
				};
			};
		} forEach _enemySides;
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD("getUpdateInterval") {
		UPDATE_INTERVAL
	} ENDMETHOD;
	
ENDCLASS;