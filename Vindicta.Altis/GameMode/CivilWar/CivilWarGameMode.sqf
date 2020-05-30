#include "common.hpp"

/*
Design documentation:
https://docs.google.com/document/d/1DeFhqNpsT49aIXdgI70GI3GIR95LR2NnJ5cpAYYl3hE/edit#bookmark=id.ev4wu6mmqtgf
*/

#define pr private

#ifndef RELEASE_BUILD
#define DEBUG_CIVIL_WAR_GAME_MODE
#endif
FIX_LINE_NUMBERS()

gCityStateData = [
	["Stable",     [1.0 , 1.0 , 1.0 , 1.0], "#FFFFFF"], /* CITY_STATE_STABLE */
	["Agitated",   [1.0 , 0.96, 0.6 , 1.0], "#FFF599"], /* CITY_STATE_AGITATED */
	["In Revolt!", [1.0 , 0.62, 0.28, 1.0], "#FF9e47"], /* CITY_STATE_IN_REVOLT */
	["Suppressed", [1.0 , 0.28, 0.28, 1.0], "#FF4747"], /* CITY_STATE_SUPPRESSED */
	["Liberated!", [0.44, 1.0 , 0.28, 1.0], "#70FF47"]  /* CITY_STATE_LIBERATED */
];

/*
Class: CivilWarGameMode
A game mode that models the progress of a civil war from scratch. It moves 
through a set of phases that vary the options available to the players, and the 
reactions of the enemy.
*/
#define OOP_CLASS_NAME CivilWarGameMode
CLASS("CivilWarGameMode", "GameModeBase")
	// Gameplay phase: progresses forward from 1 to 5 only
	VARIABLE_ATTR("phase", [ATTR_SAVE]);
	// So we can get delta T in the update function
	VARIABLE_ATTR("lastUpdateTime", [ATTR_SAVE]);
	// Player spawn points we calculate for each city spawn point
	VARIABLE_ATTR("spawnPoints", [ATTR_SAVE]);
	// All "active" cities. These are ones that have police stations, and where missions will be generated.
	VARIABLE_ATTR("activeCities", [ATTR_SAVE]);
	// Amount of casualties during the campaign, used in getCampaignProgess method
	VARIABLE_ATTR("casualties", [ATTR_SAVE]);
	// Campaign progress cached value
	VARIABLE("campaignProgress");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("name", "CivilWar");
		T_SETV("spawningEnabled", false);
		T_SETV("lastUpdateTime", GAME_TIME);
		T_SETV("phase", 0);
		T_SETV("activeCities", []);
		T_SETV("casualties", 0);
		T_SETV("campaignProgress", 0);
		if (IS_SERVER) then {	// Makes no sense for client
			T_PUBLIC_VAR("casualties");
			T_PUBLIC_VAR("campaignProgress");
		};
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

	ENDMETHOD;

	/* virtual */ METHOD(startCommanders)
		_this spawn {
			params [P_THISOBJECT];
			// Add some delay so that we don't start processing instantly, because we might want to synchronize intel with players
			uisleep 10;
			CALLM1(T_GETV("AICommanderInd"), "enablePlanning", true);
			CALLM1(T_GETV("AICommanderWest"), "enablePlanning", false);
			CALLM1(T_GETV("AICommanderEast"), "enablePlanning", false);
			{
				// We postMethodAsync them, because we don't want to start processing right after mission start
				CALLM2(T_GETV(_x), "postMethodAsync", "start", []);
			} forEach ["AICommanderInd", "AICommanderWest", "AICommanderEast"];
		};
	ENDMETHOD;

	// Creates gameModeData of a location
	/* protected override */	METHOD(initLocationGameModeData)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		private _type = CALLM0(_loc, "getType");
		switch (_type) do {
			case LOCATION_TYPE_CITY : {
				private _cityData = NEW_PUBLIC("CivilWarCityData", [_loc]); // City data is public!
				SETV(_loc, "gameModeData", _cityData);
			};
			case LOCATION_TYPE_POLICE_STATION : {
				private _data = NEW_PUBLIC("CivilWarPoliceStationData", [_loc]);
				SETV(_loc, "gameModeData", _data);
			};
			default {
				// Other locations get generic location game mode data
				private _data = NEW_PUBLIC("CivilWarLocationData", [_loc]);
				SETV(_loc, "gameModeData", _data);
			};
		};

		PUBLIC_VAR(_loc, "gameModeData");

		// Update respawn rules
		if (_type != LOCATION_TYPE_CITY) then { // Cities will search for other nearby locations which will slow down everything probably, let's not use that
			private _gmdata = CALLM0(_loc, "getGameModeData");
			CALLM0(_gmdata, "updatePlayerRespawn");
		};

		// Return
		CALLM0(_loc, "getGameModeData")
	ENDMETHOD;

	// Overrides GameModeBase, we give only bases and police stations to enemy to start with
	/* protected override */ METHOD(getLocationOwner)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		ASSERT_OBJECT_CLASS(_loc, "Location");

		OOP_DEBUG_MSG("%1", [_loc]);
		private _type = GETV(_loc, "type");
		// Initial setup has AAF holding all bases and police stations
		if(_type in [LOCATION_TYPE_BASE, LOCATION_TYPE_POLICE_STATION, LOCATION_TYPE_AIRPORT]) then {
			ENEMY_SIDE
		} else {
			if (_type == LOCATION_TYPE_OUTPOST) then {
				if (random 100 < 50) then {
					//selectRandom [ENEMY_SIDE, WEST]
					ENEMY_SIDE
				} else {
					CIVILIAN
				};
			} else {
				CIVILIAN
			};
		};
	ENDMETHOD;

	/* protected virtual */ /* METHOD(preInitAll)
		params [P_THISOBJECT];
	ENDMETHOD;
	*/

	// Overrides GameModeBase, we do a bunch of custom setup here for this game mode
	/* protected override */ METHOD(initServerOnly)
		params [P_THISOBJECT];

		// Call base
		CALL_CLASS_METHOD("GameModeBase", _thisObject, "initServerOnly", []);
	
		// Select the cities we will consider for civil war activities
		private _activeCities = GET_STATIC_VAR("Location", "all") select { 
			// If it is a city with a police station
			// CALLM0(_x, "getType") == LOCATION_TYPE_CITY and 
			// { { CALLM0(_x, "getType") == LOCATION_TYPE_POLICE_STATION } count GETV(_x, "children") > 0 }

			// If it is any city
			CALLM0(_x, "getType") == LOCATION_TYPE_CITY
		};
		T_SETV("activeCities", _activeCities);

		// Create game mode data for police stations
		{
			private _policeStation = _x;
			// Create the game mode data object and assign it to the police station for use later by us
			private _data = NEW("CivilWarPoliceStationData", [_x]);
			SETV(_policeStation, "gameModeData", _data);
		} forEach (GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_POLICE_STATION });


		// Create LocationGameModeData objects for all locations
		{
			private _loc = _x;
			T_CALLM1("initLocationGameModeData", _loc);
		} forEach GET_STATIC_VAR("Location", "all");

		// Select a city as a spawn point for players
		private _spawnPoints = [];
		private _cities = (GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_CITY });
		if (count _cities > 0) then {
			private _citySpawn = selectRandom _cities;
			private _gmdata = CALLM0(_citySpawn, "getGameModeData");
			CALLM1(_gmdata, "forceEnablePlayerRespawn", true);
			CALLM0(_gmdata, "updatePlayerRespawn");
			_spawnPoints pushBack [_citySpawn, CALLM0(_citySpawn, "getPos")];

			// Create a dummy tiny location here
			private _locPos = CALLM0(_citySpawn, "getPlayerRespawnPos");
			private _respawnLoc = NEW_PUBLIC("Location", [_locPos]);
			CALLM1(_respawnLoc, "setName", "Initial Respawn Point");
			CALLM1(_respawnLoc, "setType", LOCATION_TYPE_RESPAWN);
			CALLM1(_respawnLoc, "setBorderCircle", 0.1);
			{ CALLM2(_respawnLoc, "enablePlayerRespawn",_x, true); } forEach [WEST, EAST, INDEPENDENT];

			// Reveal that location to commanders
			{
				if (!IS_NULL_OBJECT(_x)) then {
					OOP_INFO_1("  revealing to commander: %1", _x);
					CALLM2(_x, "postMethodAsync", "updateLocationData", [_respawnLoc ARG CLD_UPDATE_LEVEL_TYPE ARG sideUnknown ARG false ARG false]);
				};
			} forEach [T_GETV("AICommanderWest"), T_GETV("AICommanderEast"), T_GETV("AICommanderInd")];

			// Register the location here
			T_CALLM1("registerLocation", _respawnLoc);
		};
		T_SETV("spawnPoints", _spawnPoints);

	ENDMETHOD;

	// Overrides GameModeBase, we want to add some debug menu items on the clients
	/* protected virtual */ METHOD(initClientOnly)
		params [P_THISOBJECT];

		CALL_CLASS_METHOD("GameModeBase", _thisObject, "initClientOnly", []);
		
		["Game Mode", "Add 10 activity here", {
			// Call to server to add the activity
			[[getPos player], {
				params ["_playerPos"];
				CALL_STATIC_METHOD("AICommander", "addActivity", [ENEMY_SIDE ARG _playerPos ARG 10]);
			}] remoteExec ["call", ON_SERVER];
		}] call pr0_fnc_addDebugMenuItem;

		["Game Mode", "Add 50 activity here", {
			// Call to server to add the activity
			[[getPos player], {
				params ["_playerPos"];
				CALL_STATIC_METHOD("AICommander", "addActivity", [ENEMY_SIDE ARG _playerPos ARG 50]);
			}] remoteExec ["call", ON_SERVER];
		}] call pr0_fnc_addDebugMenuItem;

		["Game Mode", "Update game mode now", {
			// Call to server to get the info
			//CALLM2(gGameModeServer, "postMethodAsync", "update");
			REMOTE_EXEC_METHOD(gGameModeServer, "postMethodAsync", ["update"], ON_SERVER)
		}] call pr0_fnc_addDebugMenuItem;

		["Game Mode", "Flush Messages", {
			// Call to server to get the info
			REMOTE_EXEC_METHOD(gGameModeServer, "postMethodAsync", ["flushMessageQueues"], ON_SERVER)
		}] call pr0_fnc_addDebugMenuItem;

		["Game Mode", "Suspend", {
			// Call to server to get the info
			REMOTE_EXEC_METHOD(gGameModeServer, "postMethodAsync", ["suspend" ARG ["Suspended manually from debug menu"]], ON_SERVER)
		}] call pr0_fnc_addDebugMenuItem;

		["Game Mode", "Resume", {
			// Call to server to get the info
			REMOTE_EXEC_METHOD(gGameModeServer, "postMethodAsync", ["resume"], ON_SERVER)
		}] call pr0_fnc_addDebugMenuItem;
	ENDMETHOD;

	// Overrides GameModeBase, we want to give the player some starter gear and holster their weapon for them.
	/* protected override */ METHOD(playerSpawn)
		params [P_THISOBJECT, P_OBJECT("_newUnit"), P_OBJECT("_oldUnit"), "_respawn", "_respawnDelay", P_ARRAY("_restoreData"), P_BOOL("_restorePosition")];

		// Bail if player has joined one of the not supported sides
		private _isAdmin = call misc_fnc_isAdminLocal;
		if (! (T_CALLM0("getPlayerSide") == playerSide) && !_isAdmin) exitWith {
			0 spawn {
				waitUntil {!isNull (findDisplay 46)};
				CALLSM1("NotificationFactory", "createSystem", "This player slot is meant for debug and can be used by administration only.");
			};
			_newUnit spawn {
				sleep 1.5;
				_this setDamage 1;
			};
		};

		// Call the base class method
		pr _restored = CALL_CLASS_METHOD("GameModeBase", _thisObject, "playerSpawn", [_newUnit ARG _oldUnit ARG _respawn ARG _respawnDelay ARG _restoreData ARG _restorePosition]);
		if(!_restored) then {
			// Select random player gear
			private _civTemplate = CALLM1(gGameModeServer, "getTemplate", civilian);
			private _templateClass = [_civTemplate, T_INF, T_INF_rifleman, -1] call t_fnc_select;
			if ([_templateClass] call t_fnc_isLoadout) then {
				[_newUnit, _templateClass] call t_fnc_setUnitLoadout;
			} else {
				OOP_ERROR_0("Only loadouts are valid for Civilian T_INF_rifleman faction templates (not classes)");
			};
			// Holster pistol
			_newUnit action ["SWITCHWEAPON", player, player, -1];

			// Give player a lockpick
			player addItemToUniform "ACE_key_lockpick";
		};

	ENDMETHOD;

	/* protected override */ METHOD(update)
		params [P_THISOBJECT];
		
		T_CALLM("updateCampaignProgress", []);

		T_CALLM("updatePhase", []);
		
		//T_CALLM("updateEndCondition", []); // No need for it right now

		private _lastUpdateTime = T_GETV("lastUpdateTime");
		private _dt = 0 max (GAME_TIME - _lastUpdateTime) min 120; // It can be negative at start??
		T_SETV("lastUpdateTime", GAME_TIME);

		// Update city stability and state
		{
			private _city = _x;
			private _cityData = GETV(_city, "gameModeData");
			CALLM(_cityData, "update", [_city ARG _dt]);
		} forEach T_GETV("activeCities");

	ENDMETHOD;

	METHOD(updateCampaignProgress)
		params [P_THISOBJECT];
		private _totalInstability = 0;
		private _maxInstability = 1;

		{
			_totalInstability = _totalInstability + _x;
			_maxInstability = _maxInstability + 1;
		} forEach (T_GETV("activeCities") 
			apply { GETV(_x, "gameModeData") }
			apply { GETV(_x, "instability") });

		private _stabRatio = _totalInstability / _maxInstability;
		// https://www.desmos.com/calculator/nttiqqlvg9
		// Hits 0.2 when _stabRatio is 0.05 and 1 when _stabRatio is 0.8
		//private _campaignProgress = 1 min (0.9 * log(15 * _stabRatio + 1));
		T_SETV_PUBLIC("campaignProgress", _stabRatio);
	ENDMETHOD;
	
	METHOD(updatePhase)
		params [P_THISOBJECT];

		private _activeCities = T_GETV("activeCities");

		pr _prog = T_CALLM0("getCampaignProgress");

		switch(T_GETV("phase")) do {
			case 0: {
				#ifndef RELEASE_BUILD
				systemChat "Moving to phase 1";
				#endif
				FIX_LINE_NUMBERS()

				// Scenario just initialized so do setup
				
				// Set enemy commander strategy
				private _strategy = NEW("Phase1CmdrStrategy", []);
				CALL_STATIC_METHOD("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);
				T_SETV("phase", 1);
			};
			/*
			Locations are not taken, roadblocks are not deployed
			*/
			case 1: {
				// We want to start deploying roadblocks fairly early
				if (_prog > 0.1) then {
					#ifndef RELEASE_BUILD
					"MOVING TO PHASE 2" remoteExec ["hint"];
					#endif
					FIX_LINE_NUMBERS()

					// Set enemy commander strategy
					private _strategy = NEW("Phase2CmdrStrategy", []);
					CALL_STATIC_METHOD("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);

					T_SETV("phase", 2);
				} else {
					
				};
			};
			/*
			Phase 2
			Roadblocks can be deployed. Only locations created by player are captured.
			*/
			case 2: {
				if (_prog > 0.65) then {
					#ifndef RELEASE_BUILD
					"MOVING TO PHASE 3" remoteExec ["hint"];
					#endif
					FIX_LINE_NUMBERS()

					// Set enemy commander strategy
					private _strategy = NEW("Phase3CmdrStrategy", []);
					CALL_STATIC_METHOD("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);

					T_SETV("phase", 3);
				} else {
					
				};
			};
			/*
			Phase 3 (long)
			All locations can be captured by commander.
			*/
			case 3: {
				// Phase continues until the end...
			};
		}
	ENDMETHOD;

	METHOD(updateEndCondition)
		params [P_THISOBJECT];

		pr _airports = CALLSM0("Location", "getAll") select {
			CALLM0(_x, "getType") == LOCATION_TYPE_AIRPORT
		};

		OOP_INFO_1("Airports: %1", _airports);

		pr _campaignProgress = T_CALLM0("getCampaignProgress");
		pr _playerSide = T_CALLM0("getPlayerSide");
		pr _nAirportsOwned = 0;

		// Lock main thread since this thread doesn't own any garrisons
		CALLM0(gMessageLoopMain, "lock");

		{
			pr _garrisons = CALLM1(_x, "getGarrisons", _playerSide);
			if (count _garrisons > 0) then {
				_nAirportsOwned = _nAirportsOwned + 1;
				OOP_INFO_2("  Owned airport: %1, pos: %2", _x, CALLM0(_x, "getPos"));
			};
		} forEach _airports;

		// Unlock the main thread
		CALLM0(gMessageLoopMain, "unlock");

		OOP_INFO_1("Owned airports: %1", _nAirportsOwned);

		if (((count _airports) == _nAirportsOwned && _nAirportsOwned > 0)) then {
			// I dunno, spam in the chat maybe or make a notification?
			// Just do nothing for now I guess :/
			//"You won the game! Congratulations!" remoteExecCall ["systemChat", 0];
			{
				"winscreen" cutText ["You won! The enemy have no fight left in them.", "PLAIN", 5];
				uisleep 10;
				"winscreen" cutFadeOut 20;
			} remoteExecCall ["spawn", ON_CLIENTS];
		};

		if(_campaignProgress > 0.95) then {
			{
				"winscreen2" cutText ["You won! The people are all with you!", "PLAIN", 5];
				uisleep 10;
				"winscreen2" cutFadeOut 20;
			} remoteExecCall ["spawn", ON_CLIENTS];
		};

	ENDMETHOD;

	// Overrides GameModeBase, we want to spawn missions etc in some locations
	/* protected override */ METHOD(locationSpawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "Location");
		private _activeCities = T_GETV("activeCities");
		if(_location in _activeCities) then {
			private _cityData = GETV(_location, "gameModeData");
			CALLM(_cityData, "spawned", [_location]);
		};
	ENDMETHOD;

	// Overrides GameModeBase, we want to despawn missions etc in some locations
	/* protected override */ METHOD(locationDespawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "Location");
		private _activeCities = T_GETV("activeCities");
		if(_location in _activeCities) then {
			private _cityData = GETV(_location, "gameModeData");
			CALLM(_cityData, "despawned", [_location]);
		};
	ENDMETHOD;

	// Gets called in the main thread!
	/* override */ METHOD(unitDestroyed)
		params [P_THISOBJECT, P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_SIDE("_side"), P_STRING("_faction")];
		pr _valueToAdd = 0;
		if (_catID == T_INF) then {
			if (_side == ENEMY_SIDE) then {
				if (_faction == "police") then {	// We less care for police killed
					_valueToAdd = 0.3;
				} else {
					_valueToAdd = 1;
				};
			} else {
				_valueToAdd = 0.1;
			};
		} else {
			if (_side == ENEMY_SIDE) then {
				_valueToAdd = 0.1;	// Destroyed vehicles contribute less to casualties
			} else {
				_valueToAdd = 0;
			};
		};
		pr _casualties = T_GETV("casualties");
		_casualties = _casualties + _valueToAdd;
		T_SETV("casualties", _casualties);
		PUBLIC_VAR(_thisObject, "casualties");
	ENDMETHOD;

	// Returns the the distance in meters, how far we can recruit units from a location which we own
	METHOD(getRecruitmentRadius)
		params [P_THISOBJECT];
		2000
	ENDMETHOD;

	// Returns an array of cities where we can recruit from
	METHOD(getRecruitCities)
		params [P_THISOBJECT, P_POSITION("_pos")];
		private _radius = T_CALLM0("getRecruitmentRadius");

		// Get nearby cities
		private _cities = ( CALLSM2("Location", "overlappingLocations", _pos, _radius) select {CALLM0(_x, "getType") == LOCATION_TYPE_CITY} ) select {
			private _gmdata = GETV(_x, "gameModeData");
			CALLM0(_gmdata, "getRecruitCount") > 0
		};

		_cities
	ENDMETHOD;

	// Returns how many recruits we can get at a certain place from nearby cities
	METHOD(getRecruitCount)
		params [P_THISOBJECT, P_ARRAY("_cities")];

		private _sum = 0;
		{
			private _gmdata = GETV(_x, "gameModeData");
			_sum = _sum + CALLM0(_gmdata, "getRecruitCount");
		} forEach _cities;

		_sum
	ENDMETHOD;

	/* protected virtual */ METHOD(getCampaignProgress)
		params [P_THISOBJECT];
		#ifdef DEBUG_END_GAME
		0.9
		#else
		T_GETV("campaignProgress");
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	/* public virtual override*/ METHOD(getPlayerSide)
		FRIENDLY_SIDE // from common.hpp
	ENDMETHOD;

	/* public virtual */ METHOD(getEnemySide)
		ENEMY_SIDE
	ENDMETHOD;


	// STORAGE
	/* override */ METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALL_CLASS_METHOD("GameModeBase", _thisObject, "postDeserialize", [_storage]);

		// Broadcast public variables
		PUBLIC_VAR(_thisObject, "casualties");

		T_CALLM0("updateCampaignProgress");

		true
	ENDMETHOD;

ENDCLASS;

/*
Class: CivilWarCityData
City data specific to this game mode.
*/
#define OOP_CLASS_NAME CivilWarCityData
CLASS("CivilWarCityData", "CivilWarLocationData")
	// City state (stable, agitated, in revolt, suppressed, liberated)
	VARIABLE_ATTR("state", [ATTR_SAVE]);
	// Stability value based on local player activity
	VARIABLE_ATTR("instability", [ATTR_SAVE]);
	// Ambient missions, active while location is spawned
	VARIABLE("ambientMissions");
	// Amount of available recruits
	VARIABLE_ATTR("nRecruits", [ATTR_SAVE]);
	// Map UI info
	VARIABLE("mapUIInfo");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("state", CITY_STATE_STABLE);
		T_SETV("instability", 0);
		T_SETV("ambientMissions", []);
		T_SETV("nRecruits", 0);
		T_SETV("mapUIInfo", []);
		if (IS_SERVER) then {	// Makes no sense for client
			T_PUBLIC_VAR("state");
			T_PUBLIC_VAR("instability");
			T_PUBLIC_VAR("nRecruits");
			T_PUBLIC_VAR("mapUIInfo");
		};
	ENDMETHOD;

	METHOD(spawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		OOP_INFO_MSG("Spawning %1", [_city]);

		private _ambientMissions = T_GETV("ambientMissions");
		private _pos = CALLM0(_city, "getPos");
		private _radius = GETV(_city, "boundingRadius");

		// CivPresence civilians are being arrested too, so there is no need for it any more
		//_ambientMissions pushBack (NEW("HarassedCiviliansAmbientMission", [_city ARG [CITY_STATE_STABLE]]));

		_ambientMissions pushBack (NEW("MilitantCiviliansAmbientMission", [_city ARG [CITY_STATE_AGITATED ARG CITY_STATE_IN_REVOLT]]));

		// It's quite confusing so I have disabled it for now, sorry
		_ambientMissions pushBack (NEW("SaboteurCiviliansAmbientMission", [_city ARG [CITY_STATE_AGITATED ARG CITY_STATE_IN_REVOLT]]));
	ENDMETHOD;

	METHOD(despawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		OOP_INFO_MSG("Despawning %1", [_city]);

		private _ambientMissions = T_GETV("ambientMissions");
		{
			DELETE(_x);
		} forEach _ambientMissions;
		T_SETV("ambientMissions", []);
	ENDMETHOD;

	METHOD(update)
		params [P_THISOBJECT, P_OOP_OBJECT("_city"), P_NUMBER("_dt")];
		ASSERT_OBJECT_CLASS(_city, "Location");
		private _state = T_GETV("state");
		private _instability = T_GETV("instability");

		private _cityPos = CALLM0(_city, "getPos");
		private _cityRadius = (300 max GETV(_city, "boundingRadius")) min 700;
		private _cityCivCap = CALLM0(_city, "getCapacityCiv");
		private _oldState = _state;

		// If the location is spawned and there are twice as many friendly as enemy units then it is liberated, otherwise it is suppressed
		private _friendlyCount = 0;
		{ _friendlyCount = _friendlyCount + CALLM0(_x, "countConsciousInfantryUnits") } forEach CALLM1(_city, "getGarrisonsRecursive", FRIENDLY_SIDE);

		private _enemyCount = 0;
		{ _enemyCount = _enemyCount + CALLM0(_x, "countConsciousInfantryUnits") } forEach CALLM1(_city, "getGarrisonsRecursive", ENEMY_SIDE);

		if(_friendlyCount > 0 && _friendlyCount >= _enemyCount * 2) then { 
			_state = CITY_STATE_LIBERATED;
		} else {
			if(_state == CITY_STATE_LIBERATED && _enemyCount > 4) then {
				_state = CITY_STATE_SUPPRESSED;
			};
		};

		// If City is stable or agitated then instability is a factor
		if(_state in [CITY_STATE_STABLE, CITY_STATE_AGITATED]) then {
			private _enemyCmdr = CALL_STATIC_METHOD("AICommander", "getAICommander", [ENEMY_SIDE]);
			private _activity = CALLM(_enemyCmdr, "getActivity", [_cityPos ARG _cityRadius]);

			// For now we will just have instability directly related to activity and inversely related to city radius (activity fades over time just
			// as we want instability to)
			// TODO: add other interesting factors here to the instability rate.
			// This equation makes required instability relative to area, and means you need ~100 activity at radius 300m and ~600 at radius 750m
			_instability = 1 min (_activity * 900 / (_cityRadius * _cityRadius));
			// diag_log [GETV(_city, "name"), _instability, _activity, _cityRadius];

			// TODO: scale the instability limits using settings
			switch true do {
				case (_instability >= 1): { _state = CITY_STATE_IN_REVOLT; };
				case (_instability > 0.2): { _state = CITY_STATE_AGITATED; };
				default { _state = CITY_STATE_STABLE; };
			};
		} else {
			// Instability is only 0 or 1 for liberated/suppressed cities
			_instability = if(_state in [CITY_STATE_LIBERATED, CITY_STATE_IN_REVOLT]) then { 1 } else { 0 };

			// Make sure amount of activity is appropriate for a city that is liberated
			if(_state == CITY_STATE_LIBERATED) then {
				private _enemyCmdr = CALL_STATIC_METHOD("AICommander", "getAICommander", [ENEMY_SIDE]);
				private _activity = CALLM(_enemyCmdr, "getActivity", [_cityPos ARG _cityRadius]);

				// Activity trends upwards in liberated revolting cities until it hits an equilibrium with fade out
				// This will ensure the enemy commander doesn't forget about them even if player isn't active in them
				// https://www.desmos.com/calculator/kiphke1gsj
				private _dActivity = _dt * 10 / (30 * (_activity + 10));
				CALL_STATIC_METHOD("AICommander", "addActivity", [ENEMY_SIDE ARG _cityPos ARG _dActivity]);
			};
		};

		T_SETV_PUBLIC("instability", _instability);
		T_SETV_PUBLIC("state", _state);

		// Send player notifications for changes
		if(_oldState != _state) then {
			// Notify players of what happened
			// private _stateDesc = gCityStateData#_state#0;
			private _stateMsg = CALLM0(_city, "getDisplayName");
			private _args = ["LOCATION STATE CHANGED", _stateMsg, ""];
			REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createLocationNotification", _args, ON_ALL, NO_JIP);
		};

		// Add passive recruits
		private _ratePerHour = T_CALLM1("getRecruitmentRate", _city);
		private _recruitIncome = _dt * _ratePerHour / 3600;
		T_CALLM2("addRecruits", _city, _recruitIncome);

		private _stateData = gCityStateData#_state;
		private _status = ["STATUS", _stateData#0, _stateData#1];
		private _mapUIInfo = [
			["RECRUITS", str floor T_GETV("nRecruits")],
			["  MAX", str floor T_CALLM1("getMaxRecruits", _city)],
			["  PER HOUR", _ratePerHour toFixed 1],
			["INSTABILITY", format["%1%2", (_instability * 100) toFixed 0, "%"]],
			_status
		];
		T_SETV_PUBLIC("mapUIInfo", _mapUIInfo);

#ifdef DEBUG_CIVIL_WAR_GAME_MODE
		private _mrk = GETV(_city, "name") + "_gamemode_data";
		createMarker [_mrk, CALLM0(_city, "getPos") vectorAdd [0, 100, 0]];
		_mrk setMarkerType "mil_marker";
		_mrk setMarkerColor "ColorBlue";
		_mrk setMarkerText (format ["%1 (%2)", gCityStateData#_state#0, T_GETV("instability")]);
		_mrk setMarkerAlpha 1;
#endif
		FIX_LINE_NUMBERS()

		// Update police stations (spawning reinforcements etc)
		private _policeStations = GETV(_city, "children") select { GETV(_x, "type") == LOCATION_TYPE_POLICE_STATION };
		{
			private _policeStation = _x;
			private _data = GETV(_policeStation, "gameModeData");
			CALLM(_data, "update", [_policeStation ARG _state]);
		} forEach _policeStations;

		// Update our ambient missions
		private _ambientMissions = T_GETV("ambientMissions");
		{
			CALLM(_x, "update", [_city]);
		} forEach _ambientMissions;
	ENDMETHOD;
	
	METHOD(getMaxRecruits)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		CALLM0(_city, "getCapacityCiv"); // It gives a quite good estimate for now
	ENDMETHOD;

	// Get the recruitment rate per hour
	METHOD(getRecruitmentRate)
		private _rate = 0;
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_city")];
			ASSERT_OBJECT_CLASS(_city, "Location");
			private _instability = T_GETV("instability");

			private _garrisonedMult = if(count CALLM(_city, "getGarrisons", [FRIENDLY_SIDE]) > 0) then { 1.5 } else { 1 };

			private _nRecruitsMax = T_CALLM1("getMaxRecruits", _city);
			// Recruits is filled up in 2 hours when city is at liberated
			_rate = 0 max (_instability * _nRecruitsMax * _garrisonedMult / 2);
		};
		_rate
	ENDMETHOD;

	// Add/remove recruits
	METHOD(addRecruits)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_city"), P_NUMBER("_amount")];
			private _n = T_GETV("nRecruits");
			private _nRecruitsMax = CALLM0(_city, "getCapacityCiv"); // It gives a quite good estimate for now
			_n = ((_n + _amount) max 0) min _nRecruitsMax;
			T_SETV_PUBLIC("nRecruits", _n);
		};
	ENDMETHOD;

	METHOD(removeRecruits)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_NUMBER("_amount")];

			private _n = T_GETV("nRecruits");
			_n = (_n - _amount) max 0;
			T_SETV_PUBLIC("nRecruits", _n);
		};
	ENDMETHOD;

	METHOD(getRecruitCount)
		private _return = 0;
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			_return = floor T_GETV("nRecruits");
		};
		_return
	ENDMETHOD;

	/* virtual override */ METHOD(updatePlayerRespawn)
		params [P_THISOBJECT];

		// Player respawn is enabled in a city which has non-city locations nearby with enabled player respawn
		pr _loc = T_GETV("location");

		pr _nearLocs = CALLSM2("Location", "overlappingLocations", CALLM0(_loc, "getPos"), CITY_PLAYER_RESPAWN_ACTIVATION_RADIUS) select {CALLM0(_x, "getType") != LOCATION_TYPE_CITY};

		pr _forceEnable = T_GETV("forceEnablePlayerRespawn");
		{
			pr _side = _x;
			pr _index = _nearLocs findIf {CALLM1(_x, "playerRespawnEnabled", _side)};
			pr _enable = (_index != -1) || _forceEnable;
			CALLM2(_loc, "enablePlayerRespawn", _side, _enable);
		} forEach [WEST, EAST, INDEPENDENT];
	ENDMETHOD;

	/* virtual override */ METHOD(getMapInfoEntries)
		private _return = [];
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			private _mapUIInfo = T_GETV("mapUIInfo");
			_return = +_mapUIInfo;
		};
		_return
	ENDMETHOD;

	// Overrides the location name
	/* virtual override */ METHOD(getDisplayName)
		private _return = objNull;
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			pr _loc = T_GETV("location");
			private _stateData = gCityStateData#(T_GETV("state"));
			private _baseName = CALLM0(_loc, "getName");
			// format["%1 [%2]", _baseName, _stateData#1]
			_return = format["%1 (%2)", _baseName, _stateData#0];
		};
		_return
	ENDMETHOD;

	// Overrides the location color
	/* virtual override */ METHOD(getDisplayColor)
		private _return = [1,1,1,1];
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			pr _loc = T_GETV("location");
			private _stateData = gCityStateData#(T_GETV("state"));
			_return = _stateData#1;
		};
		_return
	ENDMETHOD;
	// STORAGE

	METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALL_CLASS_METHOD("CivilWarLocationData", _thisObject, "postDeserialize", [_storage]);

		T_SETV("ambientMissions", []);
		T_SETV("mapUIInfo", []);

		// Broadcast public variables
		T_PUBLIC_VAR("nRecruits");
		T_PUBLIC_VAR("instability");
		T_PUBLIC_VAR("state");
		T_PUBLIC_VAR("mapUIInfo");

		true
	ENDMETHOD;

ENDCLASS;

/*
Class: CivilWarPoliceStationData
Police station data specific to this game mode.
*/
#define OOP_CLASS_NAME CivilWarPoliceStationData
CLASS("CivilWarPoliceStationData", "CivilWarLocationData")
	// If a reinforcement regiment is on the way then it goes here. We ref count it ourselves as well
	// so it doesn't get deleted until we are done with it.
	VARIABLE_ATTR("reinfGarrison", [ATTR_REFCOUNTED]);

	METHOD(new)
		params [P_THISOBJECT];

		T_SETV_REF("reinfGarrison", NULL_OBJECT);
	ENDMETHOD;

	METHOD(update)
		params [P_THISOBJECT, P_OOP_OBJECT("_policeStation"), P_NUMBER("_cityState")];
		ASSERT_OBJECT_CLASS(_policeStation, "Location");

		private _reinfGarrison = T_GETV("reinfGarrison");
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
			private _garrisons = CALLM1(_policeStation, "getGarrisons", ENEMY_SIDE);
			// We only want to reinforce police stations still under our control
			if (  (count _garrisons > 0) and  { CALLM0(_garrisons select 0, "countInfantryUnits") <= 4 } ) then {
				OOP_INFO_MSG("Spawning police reinforcements for %1 as the garrison is dead", [_policeStation]);
				// If we liberated the city then we spawn police on our own side!
				private _side = if(_cityState != CITY_STATE_LIBERATED) then { ENEMY_SIDE } else { FRIENDLY_SIDE };
				// We will use a fixed response size -- police are coming from outside town so town size isn't really relavent
				private _cVehGround = 2;
				private _cInf = _cVehGround * 4;

				// Work out where to start the garrison, we don't want to be near to active players as it will appear out of nowhere
				private _locPos = CALLM0(_policeStation, "getPos");
				private _playerBlacklistAreas = playableUnits apply { [getPos _x, 1000] };
				private _maxDistance = 2500;
				private _spawnInPos = +_locPos;
				while{(_spawnInPos distance2D _locPos <= 900) && _maxDistance <= 4500} do {
					_spawnInPos = [_locPos, 1000, _maxDistance, 0, 0, 1, 0, _playerBlacklistAreas, _locPos] call BIS_fnc_findSafePos;
					// This function returns 2D vector for some reason
					if(count _spawnInPos == 2) then { _spawnInPos pushBack 0; };
					_maxDistance = _maxDistance + 500;
				};

				// Ensure that the found position is far enough from the location which is being reinforced
				if (_spawnInPos distance2D _locPos > 900) then {
					// [P_THISOBJECT, P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry"), P_NUMBER("_cCargoBoxes")];
					private _args = [_side, _cInf, _cVehGround];
					private _newGarrison = CALLM(gGameMode, "createPoliceGarrison", _args);
					T_SETV_REF("reinfGarrison", _newGarrison);

					CALLM2(_newGarrison, "postMethodAsync", "setPos", [_spawnInPos]);
					CALLM0(_newGarrison, "activateOutOfThread");
					private _AI = CALLM0(_newGarrison, "getAI");
					// Send the garrison to join the police station location
					private _args = ["GoalGarrisonJoinLocation", 0, [[TAG_LOCATION, _policeStation], [TAG_MOVE_RADIUS, 100]], _thisObject];
					CALLM2(_AI, "postMethodAsync", "addExternalGoal", _args);
				};
			};
		};
	ENDMETHOD;

	// STORAGE

	METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALL_CLASS_METHOD("CivilWarLocationData", _thisObject, "postDeserialize", [_storage]);

		T_SETV_REF("reinfGarrison", NULL_OBJECT);

		true
	ENDMETHOD;
ENDCLASS;
