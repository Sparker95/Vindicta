#include "common.hpp"

/*
Class: GameManager

A class which handles saving/loading of game mode or initialization of game mode.
Runs in its own thread, because all other threads are saved and loaded.
It also handles some client requests about saving/loading the game, and initial mission initialization.
*/

#define __STORAGE_CLASS "StorageProfileNamespace"

#define pr private

// GameManager states
#define STATE_STARTUP				0
#define STATE_GAME_MODE_INITIALIZED	1

CLASS("GameManager", "MessageReceiverEx")

	VARIABLE("gameModeInitialized");	// State of the game for this machine

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("gameModeInitialized", false);

		// Create a message loop for ourselves
		gMessageLoopGameManager = NEW("MessageLoop", ["Game Mode Manager Thread" ARG 10 ARG 0.2]); // 0.2s sleep interval, this thread doesn't need to run fast anyway
	} ENDMETHOD;

	// This method is called at preinit
	METHOD("init") {
		params [P_THISOBJECT];

		// Create various objects not related to a particular mission

		if(IS_SERVER || IS_HEADLESSCLIENT) then {
		};

		if(IS_SERVER) then {
			// Initialize player database
			gPlayerDatabaseServer = NEW("PlayerDatabaseServer", []);
		};

		if (HAS_INTERFACE || IS_HEADLESSCLIENT) then {
		};

		if (IS_HEADLESSCLIENT) then {
		};

		if(HAS_INTERFACE) then {
			// Lots of client-side UI initialization is here

			// Create GarrisonDatabaseClient
			gGarrisonDBClient = NEW("GarrisonDatabaseClient", []);

			// Create IntelDatabaseClient
			gIntelDatabaseClient = NEW("IntelDatabaseClient", [playerSide]);

			// Create PlayerDatabaseClient
			gPlayerDatabaseClient = NEW("PlayerDatabaseClient", []);

			// Initialize notification system
			CALLSM0("Notification", "staticInit");

			// Main UI initialization sequence
			// But we must wait until UI exists on client
			0 spawn {
				waitUntil {!(isNull (finddisplay 12)) && !(isNull (findDisplay 46))};
				call compile preprocessfilelinenumbers "UI\initPlayerUI.sqf";
			};


			/*
			// Code to add some dummy intel for UI tests
				private _serial = ["IntelCommanderActionAttack","o_intelcommanderactionattack_n_0_12",[2035,6,24,12,6],nil,[21281.7,7212.84,0],nil,nil,"o_IntelCommanderActionAttack_N_0_10",playerSide,[17430,13161,0],[21082,7324,0],"o_Garrison_N_0_27",[21281.7,7212.84,0],nil,nil,[2035,6,24,12,8.93733],[0,0,0,0,0,0,0,0],"o_Garrison_N_0_9","Reinforce garrison","o_Garrison_N_0_10",nil,nil];
				private _dummyIntel = ["IntelCommanderActionAttack", []] call OOP_new;
				[_dummyIntel, _serial] call OOP_deserialize;
				CALLM1(gIntelDatabaseClient, "addIntel", _dummyIntel);
			*/
		};
	} ENDMETHOD;

	// - - - - - Getters for game state - - - - -

	METHOD("isGameModeInitialized") {
		params [P_THISOBJECT];
		T_GETV("gameModeInitialized")
	} ENDMETHOD;

	// - - - - - Saved game management - - - - -

	METHOD("getAllSavedGames") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner")];
		pr _storage = NEW(__STORAGE_CLASS, []);

		pr _allRecords = CALLM0(_storage, "getAllRecords");

		OOP_INFO_1("All records: %1", _allRecords);

		// Read headers of all records
		pr _allHeaders = [];
		{
			pr _recordName = _x;
			CALLM1(_storage, "open", _recordName);
			OOP_INFO_1("Reading record: %1", _recordName);
			if (CALLM0(_storage, "isOpen")) then {
				pr _headerRef = CALLM1(_storage, "load", "header");
				if (!isNil "_headerRef") then {
					pr _newHeader = CALLM2(_storage, "load", _headerRef, true); // Create a new object
					_allHeaders pushBack _newHeader;
				} else {
					OOP_ERROR_1("Save game header not found for %1", _recordName);
				};
			} else {
				OOP_ERROR_1("Can't open record %1", _recordName);
			};
			CALLM0(_storage, "close");
		} forEach _allRecords;

		// Process all headers and check if these files can be loaded
		pr _response = []; // Array with server's response
		OOP_INFO_1("Checking %1 headers:", count _allRecords);
		pr _saveVersion = call mist_fnc_getSaveVersion;
		{
			OOP_INFO_1("  checking header: %1", _x);

			pr _errors = [];

			if (GETV(_x, "saveVersion") != _saveVersion) then {
				_errors pushBack [INCOMPATIBLE_SAVE_VERSION];
				OOP_INFO_2("  incompatible save version: %1, current: %2", GETV(_x, "saveVersion"), _saveVersion);
				// No point checking further
			} else {
				if ((toLower GETV(_x, "worldName")) != (tolower worldName)) then {
					_errors pushBack INCOMPATIBLE_WORLD_NAME;
					OOP_INFO_2("  incompatible world name: %1, current: %2", GETV(_x, "worldName"), worldName);
				};

				// Check templates
				{
					if (([_x] call t_fnc_getTemplate) isEqualTo []) then {
						_errors pushBack INCOMPATIBLE_FACTION_TEMPLATES;
						OOP_ERROR_1("  incompatible template: %1", _x);
					};
				} forEach GETV(_x, "templates");
			};

			_response pushBack [SERIALIZE_ALL(_x), _errors];
		} forEach _allHeaders;

		// Send data back to client
		OOP_INFO_0("Response:");
		{
			OOP_INFO_1("  %1", _x);
		} forEach _response;

		// Clearup
		{ DELETE(_x); } forEach _allHeaders;
		DELETE(_storage);
	} ENDMETHOD;

	METHOD("saveGame") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner")];

	} ENDMETHOD;


	// - - - - Game Mode Initialization - - - -

	// Initializes a new game mode on server (does NOT load a saved game, but creates a new one!)
	// todo: initialization parameters
	METHOD("initGameModeServer") {
		params [P_THISOBJECT, P_STRING("_className")];
		OOP_INFO_1("Initializing game mode on server: %1", _className);
		gGameMode = NEW(_className, []);
		CALLM0(gGameMode, "init");
		OOP_INFO_0("Finished initializing game mode");

		// Add data to the JIP queue so that clients can also initialize
		// Execute everywhere but not on server
		REMOTE_EXEC_CALL_STATIC_METHOD("GameMode", "staticInitGameModeClient", [_className], -2, "GameManager_initGameModeClient");

		// Set flag
		T_SETV("gameModeInitialized", true);
	} ENDMETHOD;

	// Must be run on client to initialize the game mode
	METHOD("initGameModeClient") {
		params [P_THISOBJECT, P_STRING("_className")];
		OOP_INFO_1("Initializing game mode on client: %1", _className);
		gGameModeClient = NEW(_className, []);
		CALLM0(gGameModeClient, "init");
		OOP_INFO_0("Finished initializing game mode");

		// Set flag
		T_SETV("gameModeInitialized", true);
	} ENDMETHOD;

	METHOD("staticInitGameModeClient") {
		params [P_THISCLASS, P_STRING("_className")];
		pr _instance = CALLSM0("GameManager", "getInstance");
		CALLM2(_instance, "postMethodAsync", "initGameModeClient", _className);
	} ENDMETHOD;


	// - - - - Misc methods - - - -

	METHOD("getMessageLoop") {
		gMessageLoopGameManager
	} ENDMETHOD;

	STATIC_METHOD("getInstance") {
		gGameManager
	} ENDMETHOD;

ENDCLASS;