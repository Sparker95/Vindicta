#include "common.hpp"

#define pr private

FIX_LINE_NUMBERS()

params [P_THISOBJECT];

ASP_SCOPE_START(Garrison_fnc_updateSpawnState);

ASSERT_THREAD(_thisObject);

pr _type = T_GETV("type");

if !(_type in GARRISON_TYPES_AUTOSPAWN) exitWith {
	// Not an autospawning garrison
};

if !T_GETV("active") exitWith {
	// Not yet active
};

if(T_CALLM0("isDestroyed")) exitWith {
	OOP_WARNING_MSG("Attempted to call function on destroyed garrison %1", [_thisObject]);
	DUMP_CALLSTACK;
};

pr _spawned = T_GETV("spawned");
pr _hysteresis = [0, 100] select _spawned; // If we are currently spawned, we check objects in a slightly bigger distance

pr _side = T_GETV("side");
pr _pos = locationPosition T_GETV("helperObject");

// Resolve the spawn distance depending on type
pr _minDistToPlayer = 0;
pr _minDistToAi = 0;

if (_type == GARRISON_TYPE_ANTIAIR) then {
	// Anti-air garrison is very special
	_minDistToPlayer = 10000;	// These are hardcoded for now
	_minDistToAi = 4000;
} else {
	_minDistToPlayer = vin_spawnDist_garrisonToPlayer;
	_minDistToAi = vin_spawnDist_garrisonToAI;
};

// Check if there are any enemy garrisons nearby
pr _nearEnemyGarrisons = false;
pr _nearPlayers = false;
pr _nearEnemyAI = false;

if (_side != CIVILIAN) then {	// Ignore garrisons for civilian garrisons
	pr _nearGarHelpers = nearestLocations  [_pos, ["vin_garrison"], _minDistToAi + _hysteresis];
	pr _ignoreSides = [_side, CIVILIAN];
	pr _index = _nearGarHelpers findIf {
		pr _gar = GET_GARRISON_FROM_HELPER_OBJECT(_x);
		GETV(_gar, "active") &&											// Is active
		{ !(GETV(_gar, "side") in _ignoreSides) } && 				// Side is not our side and is not civilian
		{ (GETV(_gar, "countInf") > 0) || (GETV(_gar, "countDrone") > 0) }	// There is some infantry or drones
	};
	_nearEnemyGarrisons = _index != -1;
};


// Check if there are any players nearby
if (!_nearEnemyGarrisons) then {
	pr _distanceCheck = _minDistToPlayer + _hysteresis;
	pr _index = allPlayers findIf {
		(_x distance2D _pos) < _distanceCheck;
	};
	_nearPlayers = _index != -1;
};

// Check if there are enemy AIs nearby
if (!_nearEnemyGarrisons && !_nearPlayers) then {
	pr _distanceCheck = _minDistToAi + _hysteresis;
	pr _index = CALLM(gLUAP, "getUnitArray", [_side]) findIf {(_x distance2D _pos) < _distanceCheck};
	_nearEnemyAI = _index != -1;
};

//OOP_INFO_4("UPDATE SPAWN STATE: side: %1, garrisons: %2, players: %3, AIs: %4", _side, _nearEnemyGarrisons, _nearPlayers, _nearEnemyAI);

switch (T_GETV("spawned")) do {
	case false: { // Garrison is currently not spawned

		pr _timer = T_GETV("timer");

		if (_nearEnemyGarrisons || _nearPlayers || _nearEnemyAI) then {
			//OOP_INFO_0("  Posting spawn method call...");
			T_CALLM2("postMethodAsync", "spawn", [true]); // instant action: true
			// Set timer interval
			//pr _interval = 4;
			//OOP_INFO_1("  Set interval: %1", _interval);
			CALLM1(_timer, "setInterval", 10); // Despawn conditions can be evaluated with even lower frequency
		} else {
			// Set timer interval
			//pr _interval = 2; // todo override this some day later
			//diag_log format ["[Location] Info: interval was set to %1 for %2, distance: %3:", _interval, T_GETV("name"), _dstMin];
			//OOP_INFO_1("  Set interval: %1", _interval);
			CALLM1(_timer, "setInterval", 6);
		};
	};

	case true: { // Garrison is currently spawned
		if (!_nearEnemyGarrisons && !_nearPlayers && !_nearEnemyAI) then {
			//OOP_INFO_0("  Despawning...");
			T_CALLM2("postMethodAsync", "despawn", []);
		};
	}; // case 1
}; // switch spawn state