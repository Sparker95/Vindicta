#include "common.hpp"

/*
Design documentation:
https://docs.google.com/document/d/1DeFhqNpsT49aIXdgI70GI3GIR95LR2NnJ5cpAYYl3hE/edit#bookmark=id.ev4wu6mmqtgf
*/

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
	VARIABLE("spawnPoints");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "CivilWar");
		T_SETV("spawningEnabled", false);
		T_SETV("lastUpdateTime", TIME_NOW);
		T_SETV("phase", 0);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected override */ METHOD("getLocationOwner") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		ASSERT_OBJECT_CLASS(_loc, "Location");

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
			private _policeStation = _x;
			// Create the game mode data object and assign it to the police station for use later by us
			private _data = NEW("CivilWarPoliceStationData", []);
			SETV(_policeStation, "gameModeData", _data);

			private _ppos = CALLM0(_policeStation, "getPos");
			private _nearbyHouses = (_ppos nearObjects ["House", 200]) apply { [_ppos distance getPos _x, _x] };
			_nearbyHouses sort DESCENDING;
			private _spawnPos = _ppos vectorAdd [100, 100, 0];
			{
				_x params ["_dist", "_building"];
				private _positions = _building buildingPos -1;
				if(count _positions > 0) exitWith {
					_spawnPos = selectRandom _positions;
				}
			} forEach _nearbyHouses;

			// Create Respawn Marker at one of the houses
			private _marker = createMarker ["respawn_west_" + GETV(_x, "name"), _spawnPos]; // magic
			_marker setMarkerAlpha 0.0;
			private _city = GETV(_policeStation, "parent");
			_spawnPoints pushBack [GETV(_city, "name"), _spawnPos];
		} forEach (GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_POLICE_STATION });
		T_SETV("spawnPoints", _spawnPoints);

#ifndef _SQF_VM
		ASSERT_MSG(count _spawnPoints > 0, "Couldn't create any spawn points, no police stations found? Check your map setup!");

		// Single player
		if(!IS_MULTIPLAYER) then {
			{
				deleteVehicle _x;
			} forEach units spawnGroup1 + units spawnGroup2 - [player];

			player addEventHandler ["Killed", { CALLM(gGameMode, "singlePlayerRespawn", [_this select 0]) }];
			player setPosATL ((selectRandom _spawnPoints)#1);
			T_CALLM("playerSpawn", [player ARG objNull ARG 0 ARG 0]);
		};
#endif
	} ENDMETHOD;

	METHOD("initClientOnly") {
		params [P_THISOBJECT];

		["Add activity here", {
			CALL_STATIC_METHOD("AICommander", "addActivity", [ENEMY_SIDE ARG getPos player ARG 50]);
		}] call pr0_fnc_addDebugMenuItem;
		["Get local info", {
			private _enemyCmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [ENEMY_SIDE]);
			private _activity = CALLM(_enemyCmdr, "getActivity", [getPos player ARG 500]);
			systemChat format["Phase %1, local activity %2", GETV(gGameMode, "phase"), _activity];
		}] call pr0_fnc_addDebugMenuItem;
	} ENDMETHOD;
	
	/* private */ METHOD("singlePlayerRespawn") {
		params [P_THISOBJECT, P_OBJECT("_oldUnit")];
		T_PRVAR(spawnPoints);

		private _respawnLoc = selectRandom _spawnPoints;
		private _tmpGroup = createGroup (side _oldUnit);
		private _newUnit = _tmpGroup createUnit [typeOf _oldUnit, _respawnLoc#1, [], 0, "NONE"];
		[_newUnit] joinSilent (group _oldUnit);
		deleteGroup _tmpGroup;
		selectPlayer _newUnit;
		unassignCurator zeus1;
		player assignCurator zeus1;
		T_CALLM("playerSpawn", [player ARG objNull ARG 0 ARG 0]);
		[_newUnit, _oldUnit, 0, 0] call compile preprocessFileLineNumbers "onPlayerRespawn.sqf";
		[_oldUnit] joinSilent grpNull;
		_newUnit addEventHandler ["Killed", { CALLM(gGameMode, "singlePlayerRespawn", [_this select 0]) }];
		(_respawnLoc#0) spawn {
			cutText [format["<t color='#ffffff' size='3'>You died!<br/>But you were born again in %1!</t>", _this], "BLACK IN", 10, true, true];
			BIS_DeathBlur ppEffectAdjust [0.0];
			BIS_DeathBlur ppEffectCommit 0.0;
		};
	} ENDMETHOD;

	/* protected override */METHOD("playerSpawn") {
		params [P_THISOBJECT, P_OBJECT("_newUnit"), P_OBJECT("_oldUnit"), "_respawn", "_respawnDelay"];
		switch T_GETV("phase") do {
			// Player is spawning in cities give them a pistol or something.
			case 1: {
				player call fnc_selectPlayerSpawnLoadout;
				// Holster pistol
				player action ["SWITCHWEAPON", player, player, -1];

				// _newUnit spawn {
				// 	while {!isNull (group _this)} do {
				// 		waitUntil {isNull (group _this) or {currentWeapon _this == handgunWeapon _this}};
				// 		if(!isNull (group _this)) then {
				// 			private _action = player addAction [
				// 				"Holster your weapon", 
				// 				{
				// 					params ["_target", "_caller", "_actionId", "_arguments"];
				// 					player action ["SWITCHWEAPON", player, player, -1];
				// 				}
				// 			];
				// 			waitUntil {isNull (group _this) or {currentWeapon _this != handgunWeapon _this}};
				// 			if(!isNull (group _this)) then {
				// 				player removeAction _action;
				// 			};
				// 		};
				// 	};
				// };
			};
			default {

			};
		};
	} ENDMETHOD;

	/* protected override */METHOD("update") {
		params [P_THISOBJECT];
		
		T_CALLM("updatePhase", []);

		T_PRVAR(lastUpdateTime);
		private _dt = TIME_NOW - _lastUpdateTime;
		T_SETV("lastUpdateTime", TIME_NOW);

		// Update city stability and state
		{
			private _city = _x;
			private _cityData = GETV(_city, "gameModeData");
			CALLM(_cityData, "update", [_city]);
		} forEach (GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_CITY });

	} ENDMETHOD;

	METHOD("updatePhase") {
		params [P_THISOBJECT];

		switch(T_GETV("phase")) do {
			case 0: {
				systemChat "Moving to phase 1";
				// Scenario just initialized so do setup
				// Disable camp creation
				SET_STATIC_VAR("ClientMapUI", "campAllowed", false);
				PUBLIC_STATIC_VAR("ClientMapUI", "campAllowed");
				// Set enemy commander strategy
				private _strategy = NEW("Phase1CmdrStrategy", []);
				CALL_STATIC_METHOD("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);
				T_SETV("phase", 1);
			};
			/*
			Phase 1 (fairly short)
				Player can spawn at designated city only.
				AAF Cmdr is passive. No outposts taken, limited QRF, no reinforcements.
				Police are mildly annoying?
				Missions relating to disruption and propaganda
			Transition to Phase 2 once player has pushed a city into Revolt?
			*/
			case 1: {
				// If player managed to push city to revolt then move to next phase
				if( GET_STATIC_VAR("Location", "all") findIf {
						CALLM0(_x, "getType") == LOCATION_TYPE_CITY and 
						{ GETV(GETV(_x, "gameModeData"), "state") >= CITY_STATE_IN_REVOLT }} != -1 ) 
				then {
					systemChat "Moving to phase 2";

					// Enable camp creation
					SET_STATIC_VAR("ClientMapUI", "campAllowed", true);
					PUBLIC_STATIC_VAR("ClientMapUI", "campAllowed");

					// Set enemy commander strategy
					private _strategy = NEW("Phase2CmdrStrategy", []);
					CALL_STATIC_METHOD("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);

					T_SETV("phase", 2);
				} else {
					// update phase 1 stuff here
				};
			};
			/*
			Phase 2 (should be fairly short)
				Player can build a camp and recruit civilians.
				HR is available to recruit units for squad.
				AAF Cmdr will start responding to player activity, but otherwise remain passive.
			Transition to Phase 3 once player has taken a city (liberated).
			*/
			case 2: {
				// If player managed to push city to revolt then move to next phase
				if( GET_STATIC_VAR("Location", "all") findIf {
					CALLM0(_x, "getType") == LOCATION_TYPE_CITY and 
					{ GETV(GETV(_x, "gameModeData"), "state") >= CITY_STATE_LIBERATED }} != -1 ) 
				then {
					systemChat "Moving to phase 3";

					// // Set enemy commander strategy
					// private _strategy = NEW("Phase2CmdrStrategy", []);
					// CALL_STATIC_METHOD("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);

					T_SETV("phase", 2);
				} else {
					// update phase 2 stuff here
				};
			};
			/*
			Phase 3 (long)
				Player can create garrisons, occupy locations with them etc.
				AAF Cmdr will start more proactive behaviours, occupying strategic outposts, building roadblocks etc.
				NATO interaction available.
			Transition to Phase 4 once player has taken some significant portion of the island, or maybe an AAF base?
			*/
			case 3: {

			};
			/*
			Phase 4 (not sure, medium?)
				AAF get support from Russia (or whoever the other faction is).
				Nature of NATO involvement changes somehow? Perhaps more powerful support? What makes sense here? Given we want to end with all factions in open war probably NATO involvement should increase on your side, but perhaps they also start doing their own missions without your involvement.
			Transition to Phase 5 once NATO occupy a certain number of outposts?
			*/
			case 4: {

			};
			/*
			Phase 5 (final phase)
				NATO become enemy to player.
				Russian involvement increases to counter NATO incursion.
			How does it end?
			*/
			case 4: {

			};
		}
	} ENDMETHOD;

	// Override this to perform actions when a location spawns
	/* protected override */METHOD("locationSpawned") {
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "Location");
		
		private _type = GETV(_location, "type");
		if(_type == LOCATION_TYPE_CITY) then {
			private _cityData = GETV(_location, "gameModeData");
			CALLM(_cityData, "spawned", [_location]);
		};
	} ENDMETHOD;

	// Override this to perform actions when a location despawns
	/* protected override */METHOD("locationDespawned") {
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "Location");

		private _type = GETV(_location, "type");
		if(_type == LOCATION_TYPE_CITY) then {
			private _cityData = GETV(_location, "gameModeData");
			CALLM(_cityData, "despawned", [_location]);
		};
	} ENDMETHOD;
ENDCLASS;

CLASS("CivilWarCityData", "")
	VARIABLE("state");
	VARIABLE("instability");
	VARIABLE("ambientMissions");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("state", CITY_STATE_STABLE);
		T_SETV("instability", 0);
		T_SETV("ambientMissions", []);
	} ENDMETHOD;

	METHOD("spawned") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		OOP_INFO_MSG("Spawning %1", [_city]);

		T_PRVAR(state);
		T_PRVAR(ambientMissions);
		private _pos = CALLM0(_city, "getPos");
		private _radius = GETV(_city, "boundingRadius");

		switch _state do {
			case CITY_STATE_STABLE: {
				_ambientMissions pushBack (NEW("HarassedCiviliansAmbientMission", [_city]));
				// private _civies = _cityPos nearEntities["Man", _cityRadius] select { !isNil {_x getVariable CIVILIAN_PRESENCE_CIVILIAN_VAR_NAME} };
				// {
				// 	_x setVariable [UNDERCOVER_SUSPICION, 0, true];
				// } forEach _civies;
			};
			case CITY_STATE_AGITATED: {
				_ambientMissions pushBack (NEW("MilitantCiviliansAmbientMission", [_city]));
				// TODO: if local garrison is spawned then
				//	a) spawn a civ or two with weapons to attack them
				//	b) spawn an IED with proximity detonation
			};
			case CITY_STATE_IN_REVOLT: {
				_ambientMissions pushBack (NEW("SaboteurCiviliansAmbientMission", [_city]));
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
	} ENDMETHOD;

	METHOD("despawned") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		OOP_INFO_MSG("Despawning %1", [_city]);

		T_PRVAR(ambientMissions);
		{
			DELETE(_x);
		} forEach _ambientMissions;
		T_SETV("ambientMissions", []);
	} ENDMETHOD;
	
	METHOD("update") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");
		T_PRVAR(state);

		private _cityPos = CALLM0(_city, "getPos");
		private _cityRadius = 500 max GETV(_city, "boundingRadius");

		// if City is stable or agitated then instability is a factor
		if(_state == CITY_STATE_STABLE or _state == CITY_STATE_AGITATED) then {
			private _enemyCmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [ENEMY_SIDE]);
			private _activity = CALLM(_enemyCmdr, "getActivity", [_cityPos ARG _cityRadius]);

			// For now we will just have instability directly related to activity (activity fades over time just
			// as we want instability to)
			// Instability is activity / radius
			// TODO: add other interesting factors here to the instability rate.
			private _instability = _activity * 500 / _cityRadius;
			T_SETV("instability", _instability);
			_state = switch true do {
				case (_instability > 200): { CITY_STATE_IN_REVOLT };
				case (_instability > 100): { CITY_STATE_AGITATED };
				default { CITY_STATE_STABLE };
			};
		};
		T_SETV("state", _state);

#ifdef DEBUG_CIVIL_WAR_GAME_MODE
		private _mrk = GETV(_city, "name") + "_gamemode_data";
		createMarker [_mrk, CALLM0(_city, "getPos") vectorAdd [0, 100, 0]];
		_mrk setMarkerType "mil_marker";
		_mrk setMarkerColor "ColorBlue";
		_mrk setMarkerText (format ["%1 (%2)", gCityStateNames select _state, T_GETV("instability")]);
		_mrk setMarkerAlpha 1;
#endif
		switch _state do {
			case CITY_STATE_STABLE: {
				// if({_x getVariable ""} count _civies)
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
		private _policeStations = GETV(_city, "children") select { GETV(_x, "type") == LOCATION_TYPE_POLICE_STATION };

		{
			private _policeStation = _x;
			private _data = GETV(_policeStation, "gameModeData");
			CALLM(_data, "update", [_policeStation ARG _state]);
		} forEach _policeStations;

		T_PRVAR(ambientMissions);
		{
			CALLM(_x, "update", [_city]);
		} forEach _ambientMissions;

	} ENDMETHOD;

ENDCLASS;

CLASS("CivilWarPoliceStationData", "")
	VARIABLE_ATTR("reinfGarrison", [ATTR_REFCOUNTED]);

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV_REF("reinfGarrison", NULL_OBJECT);
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_OOP_OBJECT("_policeStation"), P_NUMBER("_cityState")];
		ASSERT_OBJECT_CLASS(_policeStation, "Location");

		T_PRVAR(reinfGarrison);
		if(!IS_NULL_OBJECT(_reinfGarrison)) then {
			// If reinf garrison arrived or died
			if(CALLM0(_reinfGarrison, "isEmpty") or { CALLM0(_reinfGarrison, "getLocation") == _policeStation }) then {
				T_SETV_REF("reinfGarrison", NULL_OBJECT);
			};
		} else {
			private _garrisons = CALLM0(_policeStation, "getGarrisons");
			// TODO: add forces if depleted {!EFF_LTE(CALLM0(_garrisons#0, "getEfficiencyMobile")}
			if (count _garrisons == 0) then {
				OOP_INFO_MSG("Spawning police reinforcements for %1 as the garrison is dead", [_policeStation]);
				private _side = if(_cityState != CITY_STATE_LIBERATED) then { ENEMY_SIDE } else { FRIENDLY_SIDE };
				private _cInf = CALLM(_policeStation, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
				private _cVehGround = CALLM(_policeStation, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);

				private _locPos = CALLM0(_policeStation, "getPos");
				private _playerBlacklistAreas = playableUnits apply { [getPos _x, 1000] };
				private _spawnInPos = [_locPos, 1000, 4000, 0, 0, 1, 0, _playerBlacklistAreas, _locPos] call BIS_fnc_findSafePos;
				if(count _spawnInPos == 2) then { _spawnInPos pushBack 0; };
				private _newGarrison = CALL_STATIC_METHOD("GameModeBase", "createGarrison", ["police" ARG _side ARG _cInf ARG _cVehGround]);
				T_SETV_REF("reinfGarrison", _newGarrison);

				CALLM2(_newGarrison, "postMethodAsync", "setPos", [_spawnInPos]);
				CALLM2(_newGarrison, "postMethodAsync", "activate", []);
				private _AI = CALLM(_newGarrison, "getAI", []);
				private _args = ["GoalGarrisonJoinLocation", 0, [[TAG_LOCATION, _policeStation]], _thisObject];
				CALLM2(_AI, "postMethodAsync", "addExternalGoal", _args);
			};
		};
	} ENDMETHOD;
ENDCLASS;
