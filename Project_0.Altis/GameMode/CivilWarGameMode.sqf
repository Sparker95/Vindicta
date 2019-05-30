#include "common.hpp"

/*
Design documentation:
https://docs.google.com/document/d/1DeFhqNpsT49aIXdgI70GI3GIR95LR2NnJ5cpAYYl3hE/edit#bookmark=id.ev4wu6mmqtgf
*/

#define ENEMY_SIDE INDEPENDENT
#define FRIENDLY_SIDE WEST

#ifndef RELEASE_BUILD
#define DEBUG_CIVIL_WAR_GAME_MODE
#endif

gCityStateNames = [
	"STABLE",
	"AGITATED",
	"IN_REVOLT",
	"SUPPRESSED",
	"LIBERATED"
];

CLASS("CivilWarGameMode", "GameModeBase")

	VARIABLE("phase");
	VARIABLE("lastUpdateTime");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "CivilWar");
		T_SETV("spawningEnabled", false);
		T_SETV("lastUpdateTime", TIME_NOW);
		T_SETV("phase", 1);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected override */ METHOD("getLocationOwner") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		OOP_DEBUG_MSG("%1", [_loc]);
		private _type = GETV(_loc, "type");
		// Initial setup has AAF holding all bases and police stations
		if(_type == LOCATION_TYPE_BASE or _type == LOCATION_TYPE_POLICE_STATION) then {
			ENEMY_SIDE
		} else {
			CIVILIAN
		}
	} ENDMETHOD;

	/* protected override */ METHOD("initServerOnly") {
		params [P_THISOBJECT];
		// Create custom game mode data objects for city locations
		{
			private _cityData = NEW("CivilWarCityData", []);
			SETV(_x, "gameModeData", _cityData);
		} forEach (GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_CITY });

		// Remove existing spawns
		{
			deleteMarker _x;
		} forEach (allMapMarkers select { _x find "respawn_west" == 0});

		// Add spawns near police stations on the map
		private _spawnPoints = [];
		{
			private _ppos = CALLM0(_x, "getPos");
			private _nearbyHouses = (_ppos nearObjects ["House", 200]) apply { [_ppos distance getPos _x, _x] };
			_nearbyHouses sort DESCENDING;
			private _spawnPos = _ppos vectorAdd [100, 100, 0];
			{
				_x params ["_dist", "_building"];
				private _positions = _building buildingPos -1;
				if(count _positions > 0) exitWith {
					_spawnPos = selectRandom _positions;
				}
			} forEach _nearbyHouses; //= _nearbyHouses findIf { count _x#1 buildingPos -1 > 0 }

			// 	_nearbyHouses#0 params ["_dist", "_building"];
			// 	private _positions = _building buildingPos -1;
			// 	if(count _positions == 0) then {
			// 		getPos _building
			// 	} else {
			// 		selectRandom _positions
			// 	};
			// };

			// Create Respawn Marker at one of the houses
			private _marker = createMarker ["respawn_west_" + GETV(_x, "name"), _spawnPos]; // magic
			_marker setMarkerAlpha 0.0;

			_spawnPoints pushBack _spawnPos;
		} forEach (GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_POLICE_STATION });

#ifndef _SQF_VM
		ASSERT_MSG(count _spawnPoints > 0, "Couldn't create any spawn points, no police stations found? Check your map setup!");
		// Single player
		if(!IS_MULTIPLAYER) then
		{
			FAILURE("CivilWar game mode doesn't support single player yet!!");
			// TODO: handle "respawn" in single player
			// player setPosATL (selectRandom _spawnPoints);
			// {
			// 	deleteVehicle _x;
			// } forEach (units group player) - [player];
			// player addItem "Map";
			// player addItem "Compass";
		};
#endif
	} ENDMETHOD;

	/* protected override */METHOD("playerSpawn") {
		params [P_THISOBJECT, P_OBJECT("_newUnit"), P_OBJECT("_oldUnit"), "_respawn", "_respawnDelay"];
		switch T_GETV("phase") do {
			// Player is spawning in cities give them a pistol or something.
			case 1: {
				_newUnit addItem "hgun_Pistol_heavy_01_F";
				_newUnit addMagazine "11Rnd_45ACP_Mag";
				_newUnit addMagazine "11Rnd_45ACP_Mag";
				_newUnit addItem "ItemMap";
				_newUnit addItem "ItemCompass";
				_newUnit addItem "ItemWatch";
			};
		};
	} ENDMETHOD;

	/* protected override */METHOD("update") {
		params [P_THISOBJECT];

		T_PRVAR(lastUpdateTime);
		private _dt = TIME_NOW - _lastUpdateTime;
		T_SETV("lastUpdateTime", TIME_NOW);

		// Update city stability and state
		{
			private _loc = _x;
			private _cityData = GETV(_loc, "gameModeData");
			private _state = GETV(_cityData, "state");
			// if City is stable or agitated then instability is a factor
			if(_state == CITY_STATE_STABLE or _state == CITY_STATE_AGITATED) then {
				private _cityPos = CALLM0(_loc, "getPos");
				private _cityRadius = 500 max GETV(_loc, "boundingRadius");
				private _enemyCmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [ENEMY_SIDE]);
				private _activity = CALLM(_enemyCmdr, "getActivity", [_cityPos ARG _cityRadius]);
				// For now we will just have instability directly related to activity (activity fades over time just
				// as we want instability to)
				SETV(_cityData, "instability", _activity);
				_state = switch true do {
					case (_activity > 200): { CITY_STATE_IN_REVOLT };
					case (_activity > 100): { CITY_STATE_AGITATED };
					default { CITY_STATE_STABLE };
				};
			};
			SETV(_cityData, "state", _state);
#ifdef DEBUG_CIVIL_WAR_GAME_MODE
			private _mrk = GETV(_loc, "name") + "_gamemode_data";
			createMarker [_mrk, CALLM0(_loc, "getPos") vectorAdd [0, 100, 0]];
			_mrk setMarkerType "mil_marker";
			_mrk setMarkerColor "ColorBlue";
			_mrk setMarkerText (format ["%1 (%2)", gCityStateNames select _state, GETV(_cityData, "instability")]);
			_mrk setMarkerAlpha 1;
#endif
			switch _state do {
				case CITY_STATE_STABLE: {
					// TODO: police harass civilians
				};
				case CITY_STATE_AGITATED: {
					// TODO: if local garrison is spawned then
					//	a) spawn a civ or two with weapons to attack them
					//	b) spawn an IED with proximity detonation
				};
				case CITY_STATE_IN_REVOLT: {
					// TODO: if local garrison is spawned then
					//	a) arm all civs, put them on player side
					//	b) spawn an timed IED blowing up a building or two (police station maybe?)
				};
				case CITY_STATE_SUPPRESSED: {
					// TODO: keep spawned civilians inside
					// TODO: modify cmdr strategy to occupy this town
				};
				case CITY_STATE_LIBERATED: {
					// TODO: police is on player side
				};
			};

			// Do spawning at police stations
			private _policeStation = GETV(_loc, "policeStation");

			if(!IS_NULL_OBJECT(_policeStation)) then {
				private _garrisons = CALLM0(_policeStation, "getGarrisons");
				// TODO: add forces if depleted {!EFF_LTE(CALLM0(_garrisons#0, "getEfficiencyMobile")}
				if (count _garrisons == 0) then {
					private _side = if(_state != CITY_STATE_LIBERATED) then { ENEMY_SIDE } else { FRIENDLY_SIDE };
					private _cInf = CALLM(_policeStation, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
					private _cVehGround = CALLM(_policeStation, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
					private _newGarrison = CALL_STATIC_METHOD("GameModeBase", "createGarrison", ["police" ARG _side ARG _cInf ARG _cVehGround]);
					private _locPos = CALLM0(_policeStation, "getPos");
					private _playerBlacklistAreas = playableUnits apply { [getPos _x, 1000] };
					private _spawnInPos = [_locPos, 1000, 4000, 0, 0, 1, 0, _playerBlacklistAreas, _locPos] call BIS_fnc_findSafePos;
					CALLM2(_AI, "postMethodAsync", "setPos", [_spawnInPos]);
					private _AI = CALLM(_newGarrison, "getAI", []);
					private _args = ["GoalGarrisonJoinLocation", 0, [[TAG_LOCATION, _policeStation]], _thisObject];
					CALLM2(_AI, "postMethodAsync", "addExternalGoal", _args);
				};
			};
		} forEach (GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_CITY });
	} ENDMETHOD;
ENDCLASS;

CLASS("CivilWarCityData", "")
	VARIABLE("state");
	VARIABLE("instability");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("state", CITY_STATE_STABLE);
		T_SETV("instability", 0);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
	} ENDMETHOD;
ENDCLASS;