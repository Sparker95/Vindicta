#include "..\common.h"
#include "..\MessageReceiver\MessageReceiver.hpp"

#define pr private

params [P_THISOBJECT];

ASSERT_THREAD(_thisObject);

//get list of units that can spawn in civilian
pr _units = CALLM(gLUAP, "getUnitArray", [CIVILIAN]);
pr _thisPos = T_CALLM0("getPos");
pr _dst = _units apply {_x distance _thisPos};
pr _radius = T_GETV("boundingRadius");
pr _speedMax = 60;
pr _dstMin = if (count _dst > 0) then {(selectMin _dst) - _radius} else {100000};
pr _dstSpawn = 300; // Temporary, distance from nearest player to city border when the city spawns
pr _timer = T_GETV("timer");

// Update build progress every 15 mins or so
private _lastBuildProgressTime = T_GETV("lastBuildProgressTime");
private _dt = GAME_TIME - _lastBuildProgressTime;
#ifdef DEBUG_BUILDING
T_SETV("lastBuildProgressTime", GAME_TIME);
T_CALLM1("updateBuildProgress", 15 * 60);
#else
if(GAME_TIME - _lastBuildProgressTime > 15 * 60) then {
	T_SETV("lastBuildProgressTime", GAME_TIME);
	T_CALLM1("updateBuildProgress", _dt);
};
#endif


switch (T_GETV("spawned")) do {
	case false: { // Location is currently not spawned
		if (_dstMin < _dstSpawn) then {
			OOP_INFO_0("Spawning...");

			T_CALLM0("spawn");

			// Set timer interval
			CALLM1(_timer, "setInterval", 7);
			
			T_SETV("spawned", true);
		} else {
			// Set timer interval
			pr _dstToThreshold = _dstMin - _dstSpawn;
			#ifdef DEBUG_BUILDING
			pr _interval = 10;
			#else
			pr _interval = (_dstToThreshold / _speedMax) max 4; // Dynamic update interval
			#endif
			// pr _interval = 2; // todo override this some day later
			
			CALLM1(_timer, "setInterval", _interval);
		};
	};
	case true: { // Location is currently spawned
		if (_dstMin > (_dstSpawn + 100)) then {
			OOP_INFO_0("Despawning...");
			
			T_CALLM0("despawn");

			T_SETV("spawned", false);
			T_SETV("hasPlayers", false);
		} else {
			// Check if there are any players inside this location
			pr _playersInLoc = allPlayers select {T_CALLM1("isInBorder", _x)};
			if (count _playersInLoc > 0) then {
				pr _playerSides = _playersInLoc apply {side group _x};
				pr _arraySides = _playerSides arrayIntersect _playerSides;
				T_SETV("hasPlayerSides", _arraySides);
				T_SETV("hasPlayers", true);
			} else {
				T_SETV("hasPlayers", false);
				T_GETV("hasPlayerSides") resize 0;
			};
		};
	}; // case 1
}; // switch spawn state

