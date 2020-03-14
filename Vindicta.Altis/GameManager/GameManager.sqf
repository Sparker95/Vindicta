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

	VARIABLE("campaignName");		// Campaign name
	VARIABLE("saveID");				// saveID property of SaveGameHeader
	VARIABLE("campaignStartDate");	// In-game date when the campaign was started
	VARIABLE("templates");			// Array of templates currently used
	VARIABLE("gameModeClassName");	// 

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("gameModeInitialized", false);
		T_SETV("saveID", 0);
		T_SETV("campaignName", "_noname_");
		T_SETV("templates", []);
		T_SETV("campaignStartDate", date);
		T_SETV("gameModeClassName", "_noname_");

		#ifndef RELEASE_BUILD
		if(HAS_INTERFACE) then {
			[] call pr0_fnc_initDebugMenu;
		};
		#endif

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

			// Main initialization sequence
			0 spawn {
				// Wait until we have UI
				waitUntil {!(isNull (finddisplay 12)) && !(isNull (findDisplay 46))};
				call compile preprocessfilelinenumbers "UI\initPlayerUI.sqf";

				// Show notification
				CALLSM1("NotificationFactory", "createSystem", "Press [U] to setup the mission or load a saved game");

				// Exception for SP, we must wait till player spawns, then do more init, because onPlayerRespawn.sqf does not work there
				if (!isMultiplayer) then {
					waitUntil {!(isNull player) && (count allUnits > 1)}; // We are waiting till player and all the other units for MP slots are there

					// Destroy other MP playable units
					{deleteVehicle _x} forEach (allUnits) - [player];
				};
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

	// Reads all headers of saved games from storage
	// Returns an array of [record name(string), header(ref)]
	// !!! Note: headers must be deleted from RAM afterwards !!!
	METHOD("readAllSavedGameHeaders") {
		params [P_THISOBJECT];
		pr _storage = NEW(__STORAGE_CLASS, []);

		pr _allRecords = CALLM0(_storage, "getAllRecords");

		OOP_INFO_1("All records: %1", _allRecords);

		// Read headers of all records
		pr _allRecordNamesAndHeaders = [];
		{
			pr _recordName = _x;
			CALLM1(_storage, "open", _recordName);
			OOP_INFO_1("Reading record: %1", _recordName);
			if (CALLM0(_storage, "isOpen")) then {
				pr _headerRef = CALLM1(_storage, "load", "header");
				if (!isNil "_headerRef") then {
					pr _newHeader = CALLM2(_storage, "load", _headerRef, true); // Create a new object
					_allRecordNamesAndHeaders pushBack [_recordName, _newHeader];
				} else {
					OOP_ERROR_1("Save game header not found for %1", _recordName);
				};
			} else {
				OOP_ERROR_1("Can't open record %1", _recordName);
			};
			CALLM0(_storage, "close");
		} forEach _allRecords;

		DELETE(_storage);

		// Return
		_allRecordNamesAndHeaders
	} ENDMETHOD;

	// Checks all headers if they can be loaded
	// Parameters: _recordNamesAndHeaders - see readAllSavedGameHeaders output
	// Returns an array of [record name(string), header(ref), errors(array)]
	METHOD("checkAllHeadersForLoading") {
		params [P_THISOBJECT, P_ARRAY("_recordNamesAndHeaders")];
		// Process all headers and check if these files can be loaded
		pr _return = []; // Array with server's response
		OOP_INFO_1("Checking %1 headers:", count _recordNamesAndHeaders);
		pr _saveVersion = parseNumber (call misc_fnc_getSaveVersion);
		{
			_x params ["_recordName", "_header"];
			OOP_INFO_2("  checking header: %1 of record: %2", _header, _recordName);

			pr _errors = [];
			pr _headerSaveVersion = parseNumber GETV(_header, "saveVersion");
			if (_headerSaveVersion > _saveVersion) then {
				_errors pushBack INCOMPATIBLE_SAVE_VERSION;
				OOP_INFO_2("  incompatible save version: %1, current: %2", _headerSaveVersion, _saveVersion);
				// No point checking further
			} else {
				if ((toLower GETV(_header, "worldName")) != (tolower worldName)) then {
					_errors pushBack INCOMPATIBLE_WORLD_NAME;
					OOP_INFO_2("  incompatible world name: %1, current: %2", GETV(_header, "worldName"), worldName);
				};

				// Check templates
				{
					if (([_x] call t_fnc_getTemplate) isEqualTo []) then {
						_errors pushBack INCOMPATIBLE_FACTION_TEMPLATES;
						OOP_ERROR_1("  incompatible template: %1", _x);
					};
				} forEach GETV(_header, "templates");
			};

			_return pushBack [_recordName, _header, _errors];
		} forEach _recordNamesAndHeaders;

		_return
	} ENDMETHOD;

	METHOD("saveGame") {
		params [P_THISOBJECT, P_BOOL("_recovery")];

		// Bail if we are not server
		if (!isServer) exitWith {
			OOP_ERROR_0("saveGame must be executed only on server!");
			false
		};

		// Bail if game mode is not initialized (although the button should be disabled, right?)
		if(!CALLM0(gGameManager, "isGameModeInitialized")) exitWith { false };

		diag_log "[GameManager] - - - - - - - - - - - - - - - - - - - - - - - - - - -";
		diag_log "[GameManager]			GAME SAVE STARTED";
		OOP_INFO_0("GAME SAVE STARTED");

		// Start loading screen
		["saving", ["<t size='4' color='#FF7733'>PLEASE WAIT</t><br/><t size='6' color='#FFFFFF'>SAVING NOW</t>", "PLAIN", -1, true, true]] remoteExec ["cutText", ON_ALL, false];
		["saving", 20000] remoteExec ["cutFadeOut", ON_ALL, false];

		pr _storage = NEW(__STORAGE_CLASS, []);

		// Create save game header
		pr _header = NEW("SaveGameHeader", []);
		CALLM0(_header, "initNew");
		SETV(_header, "campaignName", T_GETV("campaignName"));
		SETV(_header, "saveID", T_GETV("saveID"));
		SETV(_header, "gameModeClassName", T_GETV("gameModeClassName"));
		SETV(_header, "campaignStartDate", T_GETV("campaignStartDate"));
		SETV(_header, "templates", []); // todo NYI

		// Generate a unique record name
		pr _recordNameBase =
			format ["%1 %2%3 #%4",
				T_GETV("campaignName"),
				floor (100 * CALLM0(gGameMode, "getCampaignProgress")), 
				"%",
				T_GETV("saveID")
			];

		if (_recovery) then {
			_recordNameBase = format["[RECOVERY] %1", _recordNameBase];
		};
#ifdef RELEASE_BUILD
		pr _recordNameFinal = _recordNameBase;
#else
		pr _recordNameFinal = format["[DEV] %1", _recordNameBase];
#endif
		pr _i = 1;
		while {CALLM1(_storage, "recordExists", _recordNameFinal)} do {
			_recordNameFinal = format ["%1 %2", _recordNameBase, _i];
			_i = _i + 1;
		};
		diag_log format ["[GameManager] Opening record: %1", _recordNameFinal];
		CALLM1(_storage, "open", _recordNameFinal);

		_success = false;
		if (CALLM0(_storage, "isOpen")) then {
			// Send notification to everyone
			pr _text = "Game state save is in progress...";
			REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createSystem", [_text], ON_CLIENTS, NO_JIP);

			diag_log format ["[GameManager] Saving game mode: %1", gGameMode];
			CALLM1(_storage, "save", gGameMode);
			CRITICAL_SECTION {
				CALLM2(_storage, "save", "gameMode", gGameMode);	// Ref to game mode object
			};
			
			diag_log format ["[GameManager] Saving save game header..."];
			[_header] call OOP_dumpAllVariables;
			OOP_INFO_0("Saving header...");
			CALLM1(_storage, "save", _header);
			CALLM2(_storage, "save", "header", _header);		// Ref to header object

			diag_log format ["[GameManager] Finished saving!"];
			OOP_INFO_0("Done!");

			CALLM0(_storage, "close");

			// Increase our save ID
			T_SETV("saveID", T_GETV("saveID") + 1);

			// Send notification to everyone
			pr _text = "Game state has been saved!";
			REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createSystem", [_text], ON_CLIENTS, NO_JIP);
			_success = true;
		} else {
			OOP_ERROR_1("Cant open storage record: %1", _recordNameFinal);
			_success = false;
		};


		// End loading screen
		["saving", ["<t size='4' color='#77FF77'>SAVE COMPLETE</t><br/><t size='6' color='#FFFFFF'>CARRY ON...</t>", "PLAIN", -1, true, true]] remoteExec ["cutText", ON_ALL, false];
		["saving", 10] remoteExec ["cutFadeOut", ON_ALL, false];

		OOP_INFO_0("GAME SAVE ENDED");
		diag_log "[GameManager] GAME SAVE ENDED";
		diag_log "[GameManager] - - - - - - - - - - - - - - - - - - - - - - - - - - -";

		DELETE(_header);
		DELETE(_storage);

		_success
	} ENDMETHOD;

	// Loads game, returns true on success
	METHOD("loadGame") {
		params [P_THISOBJECT, P_STRING("_recordName")];

		OOP_INFO_1("LOAD GAME: %1", _recordName);

		diag_log 			"[GameManager] - - - - - - - - - - - - - - - - - - - - - - - - - - -";
		diag_log format	[	"[GameManager]			LOAD GAME: %1", _recordName];
		OOP_INFO_0("GAME SAVE STARTED");

		// Bail if we are not server
		if (!isServer) exitWith {
			OOP_ERROR_0("loadGame must be executed only on server!");
			false
		};


		// Start loading screen
		["loading", ["<t size='4' color='#FF7733'>PLEASE WAIT</t><br/><t size='6' color='#FFFFFF'>LOADING NOW</t>", "PLAIN", -1, true, true]] remoteExec ["cutText", ON_ALL, false];
		["loading", 20000] remoteExec ["cutFadeOut", ON_ALL, false];

		// Bail if game mode is already initialized (although the button should be disabled, right?)
		if(CALLM0(gGameManager, "isGameModeInitialized")) exitWith { false };

		pr _storage = NEW(__STORAGE_CLASS, []);

		pr _success = false;
		if (CALLM1(_storage, "recordExists", _recordName)) then {
			diag_log "[GameManager] Record exists";
			CALLM1(_storage, "open", _recordName);
			if (CALLM0(_storage, "isOpen")) then {
				diag_log "[GameManager] Record can be opened";

				// Read header
				pr _headerRef = CALLM1(_storage, "load", "header");
				if (!isNil "_headerRef") then {
					pr _header = CALLM2(_storage, "load", _headerRef, true); // Create a new object
					
					// Check if save version is compatible
					pr _headerVer = parseNumber GETV(_header,"saveVersion");
					pr _currVer = parseNumber (call misc_fnc_getSaveVersion);
					if (_headerVer <= _currVer) then {
						// Read other data from the header
						T_SETV("campaignName", GETV(_header, "campaignName"));
						T_SETV("saveID", GETV(_header, "saveID") + 1);
						T_SETV("gameModeClassName", GETV(_header, "gameModeClassName"));
						T_SETV("campaignStartDate", GETV(_header, "campaignStartDate"));
						T_SETV("templates", []); // todo NYI
						// Increase the OOP session counter
						[GETV(_header, "OOPSessionCounter")+1] call OOP_setSessionCounter;

						// Load game mode...
						diag_log "[GameManager] Starting loading the game mode object";

						// Send notification to everyone
						pr _text = "Game load is in progress...";
						REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createSystem", [_text], ON_CLIENTS, NO_JIP);

						pr _gameModeRef = CALLM3(_storage, "load", "gameMode", false, _headerVer);
						CRITICAL_SECTION {
							CALLM3(_storage, "load", _gameModeRef, false, _headerVer);
						};
						gGameMode = _gameModeRef;
						gGameModeServer = _gameModeRef;
						PUBLIC_VARIABLE "gGameModeServer";

						// Restore date
						pr _date = GETV(_header, "date");
						[_date] remoteExec ["setDate"];

						// todo
						// restore weather, smth else?

						// Add data to the JIP queue so that clients can also initialize
						// Execute everywhere but not on server
						REMOTE_EXEC_CALL_STATIC_METHOD("GameManager", "staticInitGameModeClient", [T_GETV("gameModeClassName")], ON_ALL, "GameManager_initGameModeClient");

						// Make sure to initialize client UI stuff if we are running combined client/server or single player
						if(HAS_INTERFACE) then {
							CALLM0(gGameMode, "initClientOnly");
						};

						// Set flag
						T_SETV("gameModeInitialized", true);

						// Send notification to everyone
						pr _text = "Game has been loaded. You should respawn now.";
						REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createSystem", [_text], ON_CLIENTS, NO_JIP);

						diag_log "[GameManager] Finished loading the game mode object";
					} else {
						OOP_ERROR_1("Saved game versions mismatch, it can't be loaded", _recordName);
						diag_log "[GameManager] Saved game version does not match the mission version, it can't be loaded";
						_success = false;
					};
				} else {
					OOP_ERROR_1("Save game header not found for %1", _recordName);
					diag_log "[GameManager] Error: Can't read header of the record";
				};
			} else {
				OOP_ERROR_1("Cant open record: %1", _recordName);
				diag_log "[GameManager] Error: Can't open record";
				_success = false;
			};
		} else {
			_success = false;
		};

		DELETE(_storage);


		// End loading screen
		["loading", ["<t size='4' color='#77FF77'>LOAD COMPLETE</t><br/><t size='6' color='#FFFFFF'>CARRY ON...</t>", "PLAIN", -1, true, true]] remoteExec ["cutText", ON_ALL, false];
		["loading", 10] remoteExec ["cutFadeOut", ON_ALL, false];

		OOP_INFO_0("GAME LOAD ENDED");
		diag_log "[GameManager] GAME LOAD ENDED";
		diag_log "[GameManager] - - - - - - - - - - - - - - - - - - - - - - - - - - -";

		_success
	} ENDMETHOD;

	METHOD("deleteSavedGame") {
		params [P_THISOBJECT, P_STRING("_recordName")];
		
		OOP_INFO_1("DELETE SAVED GAME: %1", _recordName);

		pr _storage = NEW(__STORAGE_CLASS, []);
		CALLM1(_storage, "eraseRecord", _recordName);
		DELETE(_storage);
	} ENDMETHOD;

	// FUNCTIONS CALLED BY CLIENT

	// Called by client when he needs to get data on all the saved games
	METHOD("clientRequestAllSavedGames") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner")];

		// Read headers of all records
		pr _recordNamesAndHeaders = T_CALLM0("readAllSavedGameHeaders");

		// Check all headers for loadability
		pr _checkResult = T_CALLM1("checkAllHeadersForLoading", _recordNamesAndHeaders);

		pr _dataForClient = _checkResult apply {
			_x params ["_recordName", "_header", "_errors"];
			[_recordName, SERIALIZE_ALL(_header), _errors]
		};

		// Send data to client
		pr _args = [_dataForClient];
		REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabSave", "staticReceiveRecordData", _args, _clientOwner, false);

		// Cleanup
		{
			// We are deleting the local copies of saved game headers from RAM
			_x params ["_recordName", "_header"];
			DELETE(_header);
		} forEach _recordNamesAndHeaders;
	} ENDMETHOD;

	METHOD("clientSaveGame") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner")];
		T_CALLM0("saveGame");
		T_CALLM1("clientRequestAllSavedGames", _clientOwner);	// Send updated saved game list to client
	} ENDMETHOD;

	METHOD("serverSaveGameRecovery") {
		params [P_THISOBJECT];
		T_CALLM1("saveGame", true);
	} ENDMETHOD;

	METHOD("clientOverwriteSavedGame") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_STRING("_recordName")];

		OOP_INFO_1("CLIENT OVERWRITE SAVED GAME: %1", _recordName);

		T_CALLM1("deleteSavedGame", _recordName);
		T_CALLM0("saveGame");
		T_CALLM1("clientRequestAllSavedGames", _clientOwner);	// Send updated saved game list to client
	} ENDMETHOD;

	METHOD("clientDeleteSavedGame") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_STRING("_recordName")];
		T_CALLM1("deleteSavedGame", _recordName);
		T_CALLM1("clientRequestAllSavedGames", _clientOwner);	// Send updated saved game list to client
	} ENDMETHOD;

	METHOD("clientLoadSavedGame") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_STRING("_recordName")];

		OOP_INFO_1("CLIENT LOAD SAVED GAME: %1", _recordName);

		T_CALLM1("loadGame", _recordName);
	} ENDMETHOD;


	// - - - - Game Mode Initialization - - - -

	// Initializes a new campaign and a new game mode on server (does NOT load a saved game, but creates a new one!)
	// todo: initialization parameters
	METHOD("initCampaignServer") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_STRING("_className"),
				P_ARRAY("_gameModeParameters"), P_STRING("_campaignName"),
				P_ARRAY("_templatesVerify")];

		if (!isServer) exitWith {};

		OOP_INFO_1("INIT CAMPAIGN SERVER: %1", _this);

		// Bail if already initialized
		if (T_CALLM0("isGameModeInitialized")) exitWith {
			OOP_ERROR_0("Game mode is already initialized!");
		};

		// Verify templates
		pr _templatesGood = true;
		pr _failedTemplates = [];
		{
			if (([_x] call t_fnc_getTemplate) isEqualTo []) then {
				_templatesGood = false;
				_failedTemplates pushBack _x;
			};
		} forEach _templatesVerify;
		if (!_templatesGood) exitWith {
			pr _text = format ["Error: factions are not loaded on server: %1", _failedTemplates];
			REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabGameModeinit", "showServerResponse", [_text], _clientOwner, false);
		};

		OOP_INFO_1("Initializing game mode on server: %1", _className);

		// Send notifications...
		pr _text = "Game is being initialized. It can take up to several minutes.";
		REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createSystem", [_text], ON_CLIENTS, NO_JIP);

		uisleep 0.05; // Let it send the messages

		// Setup variables
		T_SETV("saveID", 0);
		T_SETV("campaignName", _campaignName);
		T_SETV("templates", []); // todo NYI, need to get that from game mode
		T_SETV("campaignStartDate", date);
		T_SETV("gameModeClassName", _className);

		// Run the initialization
		gGameMode = NEW_PUBLIC(_className, _gameModeParameters);
		CRITICAL_SECTION {
			CALLM0(gGameMode, "init");
		};
		gGameModeServer = gGameMode;
		PUBLIC_VARIABLE "gGameModeServer";
		OOP_INFO_0("Finished initializing game mode");

		// Send notifications...
		pr _text = "Game mode initialization is complete. You should respawn now.";
		REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createSystem", [_text], ON_CLIENTS, NO_JIP);

		// Set flag
		T_SETV("gameModeInitialized", true);

		// Add data to the JIP queue so that clients can also initialize
		REMOTE_EXEC_CALL_STATIC_METHOD("GameManager", "staticInitGameModeClient", [_className], 0, "GameManager_initGameModeClient");
	} ENDMETHOD;

	// Must be run on client to initialize the game mode
	METHOD("initGameModeClient") {
		params [P_THISOBJECT, P_STRING("_className")];

		if (!T_GETV("gameModeInitialized")) then {
			OOP_INFO_1("Initializing game mode on client: %1", _className);
			gGameMode = NEW(_className, []);
			CALLM0(gGameMode, "init");
			OOP_INFO_0("Finished initializing game mode");

			// Set flag
			T_SETV("gameModeInitialized", true);
		};

		// Tell server that we are done
		if (HAS_INTERFACE) then {
			0 spawn {
				waitUntil {count (getPlayerUID player) > 1}; // Sometimes it might be ""
				private _uid = profileNamespace getVariable ["p0_uid", getPlayerUID player]; // Alternative UID for testing purposes
				[_uid, profileName, clientOwner, playerSide] remoteExecCall ["fnc_onPlayerInitializedServer", 2];
			};
		};
	} ENDMETHOD;

	METHOD("staticInitGameModeClient") {
		params [P_THISCLASS, P_STRING("_className")];
		pr _instance = CALLSM0("GameManager", "getInstance");
		CALLM2(_instance, "postMethodAsync", "initGameModeClient", [_className]);
	} ENDMETHOD;


	// - - - - Misc methods - - - -

	METHOD("getMessageLoop") {
		gMessageLoopGameManager
	} ENDMETHOD;

	STATIC_METHOD("getInstance") {
		gGameManager
	} ENDMETHOD;

ENDCLASS;