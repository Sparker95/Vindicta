#include "..\OOP_Light\OOP_Light.h"
#include "..\MessageReceiver\MessageReceiver.hpp"

#define pr private

params [P_THISOBJECT];

ASSERT_THREAD(_thisObject);

//get list of units that can spawn in civilian
pr _units = CALL_METHOD(gLUAP, "getUnitArray", [CIVILIAN]);
pr _thisPos = T_CALLM0("getPos");
pr _dst = _units apply {_x distance _thisPos};
pr _speedMax = 100;
pr _dstMin = if (count _dst > 0) then {selectMin _dst;} else {_speedMax*10};
pr _dstSpawn = 1500; // Temporary, spawn distance
pr _timer = T_GETV("timer");



switch (T_GETV("spawned")) do {
	case false: { // Location is currently not spawned
		if (_dstMin < _dstSpawn) then {
			OOP_INFO_0("Spawning...");

			CALLM0(_thisObject, "spawn");

			// Enable simulation for the build objects
			{
				_x enableSimulationGlobal true;
			} forEach T_GETV("buildObjects");

			// Set timer interval
			CALLM1(_timer, "setInterval", 5);
			
			T_SETV("spawned", true);
		} else {
			// Set timer interval
			pr _dstToThreshold = _dstMin - _dstSpawn;
			pr _interval = (_dstToThreshold / _speedMax) max 3;
			pr _interval = 2; // todo override this some day later
			
			CALLM1(_timer, "setInterval", _interval);
		};
	};
	case true: { // Location is currently spawned
		if (_dstMin > _dstSpawn) then {
			OOP_INFO_0("Despawning...");
			
			CALLM0(_thisObject, "despawn");
			
			// Disable simulation for the build objects
			{
				_x enableSimulationGlobal false;
			} forEach T_GETV("buildObjects");

			T_SETV("spawned", false);
		};
	}; // case 1
}; // switch spawn state

