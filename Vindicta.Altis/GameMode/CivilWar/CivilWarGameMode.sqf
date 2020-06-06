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

	protected override METHOD(startCommanders)
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
	protected override METHOD(initLocationGameModeData)
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
	protected override METHOD(getLocationOwner)
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

	// Overrides GameModeBase, we do a bunch of custom setup here for this game mode
	protected override METHOD(initServerOnly)
		params [P_THISOBJECT];

		// Call base
		T_CALLCM0("GameModeBase", "initServerOnly");
	
		// Select the cities we will consider for civil war activities
		private _activeCities = GETSV("Location", "all") select { 
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
		} forEach (GETSV("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_POLICE_STATION });


		// Create LocationGameModeData objects for all locations
		{
			private _loc = _x;
			T_CALLM1("initLocationGameModeData", _loc);
		} forEach GETSV("Location", "all");

		// Select a city as a spawn point for players
		private _spawnPoints = [];
		private _cities = (GETSV("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_CITY });
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
	protected override client METHOD(initClientOnly)
		params [P_THISOBJECT];

		CALLCM("GameModeBase", _thisObject, "initClientOnly", []);
		
		["Game Mode", "Add 10 activity here", {
			// Call to server to add the activity
			[[getPos player], {
				params ["_playerPos"];
				CALLSM("AICommander", "addActivity", [ENEMY_SIDE ARG _playerPos ARG 10]);
			}] remoteExec ["call", ON_SERVER];
		}] call pr0_fnc_addDebugMenuItem;

		["Game Mode", "Add 50 activity here", {
			// Call to server to add the activity
			[[getPos player], {
				params ["_playerPos"];
				CALLSM("AICommander", "addActivity", [ENEMY_SIDE ARG _playerPos ARG 50]);
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
	protected override METHOD(playerSpawn)
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
		pr _restored = CALLCM("GameModeBase", _thisObject, "playerSpawn", [_newUnit ARG _oldUnit ARG _respawn ARG _respawnDelay ARG _restoreData ARG _restorePosition]);
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

	protected override METHOD(update)
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
				CALLSM("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);
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
					CALLSM("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);

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
					CALLSM("AICommander", "setCmdrStrategyForSide", [ENEMY_SIDE ARG _strategy]);

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
	protected override METHOD(locationSpawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "Location");
		private _activeCities = T_GETV("activeCities");
		if(_location in _activeCities) then {
			private _cityData = GETV(_location, "gameModeData");
			CALLM(_cityData, "spawned", [_location]);
		};
	ENDMETHOD;

	// Overrides GameModeBase, we want to despawn missions etc in some locations
	protected override METHOD(locationDespawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "Location");
		private _activeCities = T_GETV("activeCities");
		if(_location in _activeCities) then {
			private _cityData = GETV(_location, "gameModeData");
			CALLM(_cityData, "despawned", [_location]);
		};
	ENDMETHOD;

	// Gets called in the main thread!
	protected override METHOD(unitDestroyed)
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
	protected override METHOD(getRecruitmentRadius)
		params [P_THISOBJECT];
		2000
	ENDMETHOD;

	// Returns an array of cities where we can recruit from
	protected override METHOD(getRecruitCities)
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
	protected override METHOD(getRecruitCount)
		params [P_THISOBJECT, P_ARRAY("_cities")];

		private _sum = 0;
		{
			private _gmdata = GETV(_x, "gameModeData");
			_sum = _sum + CALLM0(_gmdata, "getRecruitCount");
		} forEach _cities;

		_sum
	ENDMETHOD;

	protected override METHOD(getCampaignProgress)
		params [P_THISOBJECT];
		#ifdef DEBUG_END_GAME
		0.9
		#else
		T_GETV("campaignProgress");
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	public override METHOD(getPlayerSide)
		FRIENDLY_SIDE // from common.hpp
	ENDMETHOD;

	public override METHOD(getEnemySide)
		ENEMY_SIDE
	ENDMETHOD;


	// STORAGE
	 public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALLCM("GameModeBase", _thisObject, "postDeserialize", [_storage]);

		// Broadcast public variables
		PUBLIC_VAR(_thisObject, "casualties");

		T_CALLM0("updateCampaignProgress");

		true
	ENDMETHOD;

ENDCLASS;
