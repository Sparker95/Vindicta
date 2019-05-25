#include "common.hpp"

#define pr private

params [P_THISOBJECT];

ASSERT_THREAD(_thisObject);

OOP_INFO_0("UPDATE SPAWN STATE");

if(T_CALLM("isDestroyed", [])) exitWith {
	OOP_WARNING_MSG("Attempted to call function on destroyed garrison %1", [_thisObject]);
};
pr _dstSpawnMin = 1400; // Temporary, spawn distance
pr _dstSpawnMax = 1600; // Temporary, spawn distance

pr _side = T_GETV("side");
//OOP_INFO_0("...2");
//OOP_INFO_0("...3");
//OOP_INFO_1("Location: %1", _loc);
pr _loc = T_GETV("location");
pr _thisPos = if (_loc == "") then {
	CALLM0(_thisObject, "getPos")
} else {
	CALLM0(_loc, "getPos")
};
//OOP_INFO_0("...4");
// TODO: optimize

// Check garrison distances first, this should be quick
pr _speedMax = 200;

// Get distances to all garrisons of other sides
pr _garrisonDist = CALL_STATIC_METHOD("Garrison", "getAllActive", [[] ARG [_side]]) apply {CALLM(_x, "getPos", []) distance _thisPos};
pr _dstMin = if (count _garrisonDist > 0) then {selectMin _garrisonDist} else {_dstSpawnMax};
// Double check unit distances as well
if(_dstMin >= _dstSpawnMax) then {
	// TODO we should use BIS getNearest functions here maybe? It might be faster.
	pr _unitDist = CALL_METHOD(gLUAP, "getUnitArray", [_side]) apply {_x distance _thisPos};
	_dstMin = if (count _unitDist > 0) then {selectMin _unitDist} else {_speedMax*10};
};

//OOP_INFO_0("...5");
//pr _dst = (_units apply {_x distance _thisPos}) + (_garrisons apply {CALLM(_x, "getPos", []) distance _thisPos});
pr _timer = T_GETV("timer");
//OOP_INFO_0("...6");
switch (T_GETV("spawned")) do {
	case false: { // Garrison is currently not spawned
		if (_dstMin < _dstSpawnMin) then {
			OOP_INFO_0("Spawning...");

			CALLM0(_thisObject, "spawn");

			// Set timer interval
			CALLM1(_timer, "setInterval", 5);
			
			T_SETV("spawned", true);
		} else {
			// Set timer interval
			pr _dstToThreshold = _dstMin - _dstSpawnMin;
			pr _interval = (_dstToThreshold / _speedMax) max 1;
			pr _interval = 2; // todo override this some day later
			//diag_log format ["[Location] Info: interval was set to %1 for %2, distance: %3:", _interval, GET_VAR(_thisObject, "name"), _dstMin];
			CALLM1(_timer, "setInterval", _interval);
		};
	};
	case true: { // Garrison is currently spawned
		if (_dstMin > _dstSpawnMax) then {
			OOP_INFO_0("Despawning...");
			
			CALLM0(_thisObject, "despawn");
			
			T_SETV("spawned", false);
		};
	}; // case 1
}; // switch spawn state