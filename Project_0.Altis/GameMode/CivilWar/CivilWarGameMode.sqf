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

/*
Class: CivilWarGameMode
A game mode that models the progress of a civil war from scratch. It moves 
through a set of phases that vary the options available to the players, and the 
reactions of the enemy.
*/
CLASS("CivilWarGameMode", "GameModeBase")
	// Gameplay phase: progresses forward from 1 to 5 only
	VARIABLE("phase");
	// So we can get delta T in the update function
	VARIABLE("lastUpdateTime");
	// Player spawn points we calculate for each city spawn point
	VARIABLE("spawnPoints");
	// All "active" cities. These are ones that have police stations, and where missions will be generated.
	VARIABLE("activeCities");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "CivilWar");
		T_SETV("spawningEnabled", false);
		T_SETV("lastUpdateTime", TIME_NOW);
		T_SETV("phase", 0);
		T_SETV("activeCities", []);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	// Overrides GameModeBase, we give only bases and police stations to enemy to start with
	/* protected override */ METHOD("getLocationOwner") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		ASSERT_OBJECT_CLASS(_loc, "Location");

		OOP_DEBUG_MSG("%1", [_loc]);
		private _type = GETV(_loc, "type");
		// Initial setup has AAF holding all bases and police stations
		if(_type == LOCATION_TYPE_BASE or _type == LOCATION_TYPE_POLICE_STATION) then {
			ENEMY_SIDE
		} else {
			if (_type == LOCATION_TYPE_OUTPOST) then {
				if (random 100 < 50) then {
					ENEMY_SIDE
				} else {
					CIVILIAN
				};
			} else {
				CIVILIAN
			};
		}
	} ENDMETHOD;

	/* protected virtual */ /* METHOD("preInitAll") {
		params [P_THISOBJECT];
	} ENDMETHOD;
	*/

	// Overrides GameModeBase, we do a bunch of custom setup here for this game mode
	/* protected override */ METHOD("initServerOnly") {
		params [P_THISOBJECT];

		// Delete all existing spawns
		{
			deleteMarker _x;
		} forEach (allMapMarkers select { _x find "respawn_west" == 0});

		// Select the cities we will consider for civil war activities
		private _activeCities = GET_STATIC_VAR("Location", "all") select { 
			// If it is a city with a police station
			// CALLM0(_x, "getType") == LOCATION_TYPE_CITY and 
			// { { CALLM0(_x, "getType") == LOCATION_TYPE_POLICE_STATION } count GETV(_x, "children") > 0 }

			// If it is any city
			CALLM0(_x, "getType") == LOCATION_TYPE_CITY
		};
		T_SETV("activeCities", _activeCities);

		// Create custom game mode data objects for active city locations
		{
			private _cityData = NEW_PUBLIC("CivilWarCityData", []);
			//SETV(_x, "gameModeData", _cityData);
			SET_VAR_PUBLIC(_x, "gameModeData", _cityData);
		} forEach _activeCities;

		// Select a city as a spawn point for players
		private _spawnPoints = [];
		private _cities = (GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_CITY });
		if (count _cities > 0) then {
			private _citySpawn = selectRandom _cities;
			CALLM2(_citySpawn, "enablePlayerRespawn", FRIENDLY_SIDE, true);
			_spawnPoints pushBack [_citySpawn, CALLM0(_citySpawn, "getPos")];
		};
		T_SETV("spawnPoints", _spawnPoints);

		// Create game mode data for police stations
		{
			private _policeStation = _x;
			// Create the game mode data object and assign it to the police station for use later by us
			private _data = NEW("CivilWarPoliceStationData", []);
			SETV(_policeStation, "gameModeData", _data);
		} forEach (GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_POLICE_STATION });


#ifndef _SQF_VM
		//ASSERT_MSG(count _spawnPoints > 0, "Couldn't create any spawn points, no police stations found? Check your map setup!");

		// Single player specific setup
		if(!IS_MULTIPLAYER) then {
			// Cleanup the extra MP playables
			{
				deleteVehicle _x;
			} forEach units spawnGroup1 + units spawnGroup2 - [player];
			// We need to catch player death so we can "respawn" them fakely
			player addEventHandler ["Killed", { CALLM(gGameMode, "singlePlayerRespawn", [_this select 0]) }];
			// Move player to a random spawn point to start with
			player setPosATL ((selectRandom _spawnPoints)#1);
			T_CALLM("playerSpawn", [player ARG objNull ARG 0 ARG 0]);
		};
#endif
	} ENDMETHOD;

	// Overrides GameModeBase, we want to add some debug menu items on the clients
	/* protected virtual */ METHOD("initClientOnly") {
		params [P_THISOBJECT];

		["Game Mode", "Add activity here", {
			// Call to server to add the activity
			[[getPos player], {
				params ["_playerPos"];
				CALL_STATIC_METHOD("AICommander", "addActivity", [ENEMY_SIDE ARG _playerPos ARG 50]);
			}] remoteExec ["call", 0];
		}] call pr0_fnc_addDebugMenuItem;

		["Game Mode", "Get local info", {
			// Call to server to get the info
			[[getPos player, clientOwner], {
				params ["_playerPos", "_clientOwner"];
				private _enemyCmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [ENEMY_SIDE]);
				private _activity = CALLM(_enemyCmdr, "getActivity", [_playerPos ARG 500]);
				// Callback to client with the result
				[format["Phase %1, local activity %2", GETV(gGameMode, "phase"), _activity]] remoteExec ["systemChat", _clientOwner];				
			}] remoteExec ["call", 0];
		}] call pr0_fnc_addDebugMenuItem;

	} ENDMETHOD;
	
	// Overrides GameModeBase, we want to add some debug menu items on the clients
	/* private */ METHOD("singlePlayerRespawn") {
		params [P_THISOBJECT, P_OBJECT("_oldUnit")];
		T_PRVAR(spawnPoints);

		// Select a random spawn point, create a unit and give player control of it.
		private _respawnLoc = selectRandom _spawnPoints;
		private _tmpGroup = createGroup (side _oldUnit);
		private _newUnit = _tmpGroup createUnit [typeOf _oldUnit, _respawnLoc#1, [], 0, "NONE"];
		[_newUnit] joinSilent (group _oldUnit);
		deleteGroup _tmpGroup;
		_newUnit setName name _oldUnit;
		selectPlayer _newUnit;
		unassignCurator zeus1;
		player assignCurator zeus1;
		// Call the general MP player spawn function
		T_CALLM("playerSpawn", [player ARG objNull ARG 0 ARG 0]);
		// Need to call this manually as well
		[_newUnit, _oldUnit, 0, 0] call compile preprocessFileLineNumbers "onPlayerRespawn.sqf";
		[_oldUnit] joinSilent grpNull;
		_newUnit addEventHandler ["Killed", { CALLM(gGameMode, "singlePlayerRespawn", [_this select 0]) }];
		// Show a quick cutscene
		(_respawnLoc#0) spawn {
			cutText [format["<t color='#ffffff' size='3'>You died!<br/>But you were born again in %1!</t>", _this], "BLACK IN", 10, true, true];
			BIS_DeathBlur ppEffectAdjust [0.0];
			BIS_DeathBlur ppEffectCommit 0.0;
		};
	} ENDMETHOD;

	// Overrides GameModeBase, we want to give the player some starter gear and holster their weapon for them.
	/* protected override */ METHOD("playerSpawn") {
		params [P_THISOBJECT, P_OBJECT("_newUnit"), P_OBJECT("_oldUnit"), "_respawn", "_respawnDelay"];

		// Always spawn with a random civi kit and pistol.
		player call fnc_selectPlayerSpawnLoadout;
		// Holster pistol
		player action ["SWITCHWEAPON", player, player, -1];
	} ENDMETHOD;

	/* protected override */ METHOD("update") {
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
		} forEach T_GETV("activeCities");

	} ENDMETHOD;

	METHOD("updatePhase") {
		params [P_THISOBJECT];

		T_PRVAR(activeCities);

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
				if( (_activeCities findIf { GETV(GETV(_x, "gameModeData"), "state") >= CITY_STATE_IN_REVOLT }) != -1 ) then {
					"MOVING TO PHASE 2\nCreation of camps is now enabled!\nEnemy commander will respond to unrest." remoteExec ["hint"];

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
				if( _activeCities findIf {
					CALLM0(_x, "getType") == LOCATION_TYPE_CITY and 
					{ GETV(GETV(_x, "gameModeData"), "state") >= CITY_STATE_LIBERATED }} != -1 ) 
				then {
					"MOVING TO PHASE 3\Creation of garrisons enabled.\nEnemy commander will be aggressive." remoteExec ["hint"];

					// Set enemy commander strategy
					private _strategy = NEW("Phase3CmdrStrategy", []);
					CALL_STATIC_METHOD("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);

					T_SETV("phase", 3);
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
				// // If player managed to push city to revolt then move to next phase
				// private _cities = GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_CITY };
				// if( GET_STATIC_VAR("Location", "all") findIf {
				// 	CALLM0(_x, "getType") == LOCATION_TYPE_CITY and 
				// 	{ GETV(GETV(_x, "gameModeData"), "state") >= CITY_STATE_LIBERATED }} != -1 ) 
				// then {
				// 	"MOVING TO PHASE 3\Creation of garrisons enabled.\nEnemy commander will be aggressive." remoteExec ["hint"];

				// 	// // Set enemy commander strategy
				// 	// private _strategy = NEW("Phase2CmdrStrategy", []);
				// 	// CALL_STATIC_METHOD("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);

				// 	T_SETV("phase", 3);
				// } else {
				// 	// update phase 2 stuff here
				// };
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

	// Overrides GameModeBase, we want to spawn missions etc in some locations
	/* protected override */ METHOD("locationSpawned") {
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "Location");
		T_PRVAR(activeCities);
		if(_location in _activeCities) then {
			private _cityData = GETV(_location, "gameModeData");
			CALLM(_cityData, "spawned", [_location]);
		};
	} ENDMETHOD;

	// Overrides GameModeBase, we want to despawn missions etc in some locations
	/* protected override */METHOD("locationDespawned") {
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "Location");
		T_PRVAR(activeCities);
		if(_location in _activeCities) then {
			private _cityData = GETV(_location, "gameModeData");
			CALLM(_cityData, "despawned", [_location]);
		};
	} ENDMETHOD;

	// Returns the the distance in meters, how far we can recruit units from a location which we own
	STATIC_METHOD("getRecruitmentRadius") {
		params [P_THISCLASS];
		2000
	} ENDMETHOD;

	// Returns an array of cities where we can recruit from
	STATIC_METHOD("getRecruitCities") {
		params [P_THISCLASS, P_POSITION("_pos")];
		private _radius = CALLSM0("CivilWarGameMode", "getRecruitmentRadius");

		// Get nearby cities
		private _cities = ( CALLSM2("Location", "nearLocations", _pos, _radius) select {CALLM0(_x, "getType") == LOCATION_TYPE_CITY} ) select {
			private _gmdata = GETV(_x, "gameModeData");
			CALLM0(_gmData, "getRecruitCount") > 0
		};

		_cities
	} ENDMETHOD;

	// Returns how many recruits we can get at a certain place from nearby cities
	STATIC_METHOD("getRecruitCount") {
		params [P_THISCLASS, P_ARRAY("_cities")];

		private _sum = 0;
		{
			private _gmdata = GETV(_x, "gameModeData");
			_sum = _sum + CALLM0(_gmData, "getRecruitCount");
		} forEach _cities;

		_sum
	} ENDMETHOD;
ENDCLASS;

/*
Class: CivilWarCityData
City data specific to this game mode.
*/
CLASS("CivilWarCityData", "")
	// City state (stable, agitated, in revolt, suppressed, liberated)
	VARIABLE("state");
	// Stability value based on local player activity
	VARIABLE("instability");
	// Ambient missions, active while location is spawned
	VARIABLE("ambientMissions");
	// Amount of available recruits
	VARIABLE("nRecruits");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("state", CITY_STATE_STABLE);
		T_SETV("instability", 0);
		T_SETV("ambientMissions", []);
		SET_VAR_PUBLIC(_thisObject, "nRecruits", 0);
	} ENDMETHOD;

	METHOD("spawned") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		OOP_INFO_MSG("Spawning %1", [_city]);

		T_PRVAR(ambientMissions);
		private _pos = CALLM0(_city, "getPos");
		private _radius = GETV(_city, "boundingRadius");

		_ambientMissions pushBack (NEW("HarassedCiviliansAmbientMission", [_city ARG [CITY_STATE_STABLE]]));
		_ambientMissions pushBack (NEW("MilitantCiviliansAmbientMission", [_city ARG [CITY_STATE_AGITATED]]));
		_ambientMissions pushBack (NEW("SaboteurCiviliansAmbientMission", [_city ARG [CITY_STATE_AGITATED ARG CITY_STATE_IN_REVOLT]]));
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
		private _cityRadius = 300 max GETV(_city, "boundingRadius");

		// Increase recruit count from instability
		private _inst = T_GETV("instability");
		private _nRecruitsMax = _cityRadius*_cityRadius/8123; // Magic numbers
		private _nRecruits = T_GETV("nRecruits");
		if (_nRecruits < _nRecruitsMax) then {
			private _recruitIncome = _inst / 12; // todo scale this properly
			T_CALLM1("addRecruits", _recruitIncome);
		};

		// If City is stable or agitated then instability is a factor
		if(_state in [CITY_STATE_STABLE, CITY_STATE_AGITATED]) then {
			private _enemyCmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [ENEMY_SIDE]);
			private _activity = CALLM(_enemyCmdr, "getActivity", [_cityPos ARG _cityRadius]);

			// For now we will just have instability directly related to activity (activity fades over time just
			// as we want instability to)
			// Instability is activity / radius
			// TODO: add other interesting factors here to the instability rate.
			private _instability = _activity * 1000 / _cityRadius;
			T_SETV("instability", _instability);
			// TODO: scale the instability limits using settings
			switch true do {
				case (_instability > 100): { _state = CITY_STATE_IN_REVOLT; };
				case (_instability > 50): { _state = CITY_STATE_AGITATED; };
				default { _state = CITY_STATE_STABLE; };
			};
		} else {
			// If there is a military garrison occupying the city then it is suppressed
			if(count CALLM(_city, "getGarrisons", [ENEMY_SIDE]) > 0) then {
				_state = CITY_STATE_SUPPRESSED;
			} else {
				// If the location is spawned and there is more friendly than enemy units then it is liberated
				if(CALLM(_city, "isSpawned", [])) then {
					private _enemyCount = count (CALL_METHOD(gLUAP, "getUnitArray", [FRIENDLY_SIDE]) select {_x distance _cityPos < _cityRadius * 1.5});
					private _friendlyCount = count (CALL_METHOD(gLUAP, "getUnitArray", [ENEMY_SIDE]) select {_x distance _cityPos < _cityRadius * 1.5});
					if(_friendlyCount > _enemyCount * 2) then {
						_state = CITY_STATE_LIBERATED;
					};
				};
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
		// Update police stations (spawning reinforcements etc)
		private _policeStations = GETV(_city, "children") select { GETV(_x, "type") == LOCATION_TYPE_POLICE_STATION };
		{
			private _policeStation = _x;
			private _data = GETV(_policeStation, "gameModeData");
			CALLM(_data, "update", [_policeStation ARG _state]);
		} forEach _policeStations;

		// Update our ambient missions
		T_PRVAR(ambientMissions);
		{
			CALLM(_x, "update", [_city]);
		} forEach _ambientMissions;
	} ENDMETHOD;

	// Add/remove recruits

	METHOD("addRecruits") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_NUMBER("_amount")];

			private _n = T_GETV("nRecruits");
			_n = (_n + _amount) max 0;
			SET_VAR_PUBLIC(_thisObject, "nRecruits", _n);
		};
	} ENDMETHOD;

	METHOD("removeRecruits") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_NUMBER("_amount")];

			private _n = T_GETV("nRecruits");
			_n = (_n - _amount) max 0;
			SET_VAR_PUBLIC(_thisObject, "nRecruits", _n);
		};
	} ENDMETHOD;

	METHOD("getRecruitCount") {
		private _return = 0;
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			_return = floor T_GETV("nRecruits");
		};
		_return
	} ENDMETHOD;

ENDCLASS;

/*
Class: CivilWarPoliceStationData
Police station data specific to this game mode.
*/
CLASS("CivilWarPoliceStationData", "")
	// If a reinforcement regiment is on the way then it goes here. We ref count it ourselves as well
	// so it doesn't get deleted until we are done with it.
	VARIABLE_ATTR("reinfGarrison", [ATTR_REFCOUNTED]);

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV_REF("reinfGarrison", NULL_OBJECT);
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_OOP_OBJECT("_policeStation"), P_NUMBER("_cityState")];
		ASSERT_OBJECT_CLASS(_policeStation, "Location");

		T_PRVAR(reinfGarrison);
		// If there is an active reinforcement garrison...
		if(!IS_NULL_OBJECT(_reinfGarrison)) then {
			// If reinf garrison arrived or died then we delete it
			if(CALLM0(_reinfGarrison, "isEmpty") or { CALLM0(_reinfGarrison, "getLocation") == _policeStation }) then {
				T_SETV_REF("reinfGarrison", NULL_OBJECT);
			};
		} else {
			// If we have no or weakened garrison then we spawn a new one to reinforce/
			// TODO: make this a bit better, maybe have them come from nearest town held by the same side.
			// We need some way to reinforce police generally probably?
			private _garrisons = CALLM0(_policeStation, "getGarrisons");
			if (count _garrisons == 0 or { 
				private _garr = _garrisons#0;
				CALLM(_garr, "countInfantryUnits", []) <= 4
			}) then {
				OOP_INFO_MSG("Spawning police reinforcements for %1 as the garrison is dead", [_policeStation]);
				// If we liberated the city then we spawn police on our own side!
				private _side = if(_cityState != CITY_STATE_LIBERATED) then { ENEMY_SIDE } else { FRIENDLY_SIDE };
				// Check how much inf and veh we want based on the location
				private _cInf = CALLM(_policeStation, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
				private _cVehGround = CALLM(_policeStation, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
				// Work out where to start the garrison, we don't want to be near to active players as it will appear out of nowhere
				private _locPos = CALLM0(_policeStation, "getPos");
				private _playerBlacklistAreas = playableUnits apply { [getPos _x, 1000] };
				private _spawnInPos = [_locPos, 1000, 4000, 0, 0, 1, 0, _playerBlacklistAreas, _locPos] call BIS_fnc_findSafePos;
				// This function returns 2D vector for some reason
				if(count _spawnInPos == 2) then { _spawnInPos pushBack 0; };
				// [P_THISOBJECT, P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry"), P_NUMBER("_cCargoBoxes")];
				private _newGarrison = CALL_STATIC_METHOD("GameModeBase", "createGarrison", ["police" ARG _side ARG _cInf ARG _cVehGround ARG 0 ARG 0 ARG 0]);
				T_SETV_REF("reinfGarrison", _newGarrison);

				CALLM2(_newGarrison, "postMethodAsync", "setPos", [_spawnInPos]);
				CALLM(_newGarrison, "activateOutOfThread", []);
				private _AI = CALLM(_newGarrison, "getAI", []);
				// Send the garrison to join the police station location
				private _args = ["GoalGarrisonJoinLocation", 0, [[TAG_LOCATION, _policeStation]], _thisObject];
				CALLM2(_AI, "postMethodAsync", "addExternalGoal", _args);
			};
		};
	} ENDMETHOD;

	/* public virtual override*/ METHOD("getPlayerSide") {
		FRIENDLY_SIDE // from common.hpp
	} ENDMETHOD;
ENDCLASS;
