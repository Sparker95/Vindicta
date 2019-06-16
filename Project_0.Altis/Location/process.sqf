#include "..\OOP_Light\OOP_Light.h"
#include "..\MessageReceiver\MessageReceiver.hpp"

#define pr private

params [P_THISOBJECT];

ASSERT_THREAD(_thisObject);

//get list of units that can spawn in civilian
pr _units = CALL_METHOD(gLUAP, "getUnitArray", [CIVILIAN]);
pr _thisPos = T_CALLM0("getPos");
pr _dst = _units apply {_x distance _thisPos};
pr _radius = T_GETV("boundingRadius");
pr _speedMax = 100;
pr _dstMin = if (count _dst > 0) then {(selectMin _dst) - _radius} else {100000};
pr _dstSpawn = 300; // Temporary, distance from nearest player to city border when the city spawns
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
			CALLM1(_timer, "setInterval", 10);
			
			T_SETV("spawned", true);
		} else {
			// Set timer interval
			pr _dstToThreshold = _dstMin - _dstSpawn;
			pr _interval = (_dstToThreshold / _speedMax) max 4;
			// pr _interval = 2; // todo override this some day later
			
			CALLM1(_timer, "setInterval", _interval);
		};
	};
	case true: { // Location is currently spawned
		if (_dstMin > (_dstSpawn + 100)) then {
			OOP_INFO_0("Despawning...");
			
			CALLM0(_thisObject, "despawn");
			
			// Disable simulation for the built objects
			{
				_x enableSimulationGlobal false;
			} forEach T_GETV("buildObjects");

			T_SETV("spawned", false);
		};
	}; // case 1
}; // switch spawn state

