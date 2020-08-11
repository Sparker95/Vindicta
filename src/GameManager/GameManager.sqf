#include "common.hpp"

/*
Class: GameManager

A class which handles saving/loading of game mode or initialization of game mode.
Runs in its own thread, because all other threads are saved and loaded.
It also handles some client requests about saving/loading the game, and initial mission initialization.
*/

#define pr private

// GameManager states
#define STATE_STARTUP				0
#define STATE_GAME_MODE_INITIALIZED	1

#ifdef RELEASE_BUILD
#define DEV_PREFIX ""
#else
#define DEV_PREFIX "[DEV]"
#endif
FIX_LINE_NUMBERS()

#define SAVE_TYPE_DEFAULT			0
#define SAVE_TYPE_RECOVERY			1
#define SAVE_TYPE_AUTO				2

#define OOP_CLASS_NAME GameManager
CLASS("GameManager", "MessageReceiverEx")

	VARIABLE("gameModeInitialized");	// State of the game for this machine

	VARIABLE("campaignName");		// Campaign name
	VARIABLE("saveID");				// saveID property of SaveGameHeader
	VARIABLE("campaignStartDate");	// In-game date when the campaign was started
	VARIABLE("templates");			// Array of templates currently used
	VARIABLE("gameModeClassName");
	VARIABLE("lastAutoSave");
	VARIABLE("lastAutoSaveCheck");
	VARIABLE("storageClassName"); // Primary class name of Storage (profile namespace, filext, etc...)
	VARIABLE("storageClassNames"); // Array with data to send to client about available class names

	METHOD(new)
		params [P_THISOBJECT];

		T_SETV("gameModeInitialized", false);
		T_SETV("saveID", 0);
		T_SETV("campaignName", "_noname_");
		T_SETV("templates", []);
		T_SETV("campaignStartDate", date);
		T_SETV("gameModeClassName", "_noname_");
		T_SETV("lastAutoSave", TIME_NOW);
		T_SETV("lastAutoSaveCheck", TIME_NOW);

		#ifndef RELEASE_BUILD
		if(HAS_INTERFACE) then {
			[] call vin_fnc_initDebugMenu;
		};
		#endif
		FIX_LINE_NUMBERS()

		// Choose proper storage class name
		// If FileXT addon is loaded, we use it
		// Otherwise we use profile namespace for storage
		pr _storageClassNamePrimary = "StorageProfileNamespace";
		pr _storageClassNames = [ ["StorageProfileNamespace", "Profile"] ];
		if (isClass (configFile >> "cfgPatches" >> "filext")) then {
			_storageClassNamePrimary = "StorageFilext";
			_storageClassNames pushBack ["StorageFilext", "FileXT"];
		} else {
			//
		};
		T_SETV("storageClassName", _storageClassNamePrimary);
		T_SETV("storageClassNames", _storageClassNames);

		// Create a message loop for ourselves
		gMessageLoopGameManager = NEW("MessageLoop", ["Game Mode Manager Thread" ARG 10 ARG 0.2]); // 0.2s sleep interval, this thread doesn't need to run fast anyway
	ENDMETHOD;

	// This method is called at preinit (see https://community.bistudio.com/wiki/Initialization_Order)
	public METHOD(preInit)
		params [P_THISOBJECT];

		// Create various objects not related to a particular mission
		T_CALLM0("initSettings");

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
				CALL_COMPILE_COMMON("UI\initPlayerUI.sqf");

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
	ENDMETHOD;

	// This method is called from init.sqf (see https://community.bistudio.com/wiki/Initialization_Order)
	public METHOD(init)
		params [P_THISOBJECT];

		// This must be done after modules are initialized at least, preferably as late as possible in init order.
		if(IS_SERVER) then {
			T_CALLM0("autoLoad");
		};

		// Init standard BI revive if ACE medical is disabled
		if (IS_MULTIPLAYER) then {
			if (! (isClass (configfile >> "CfgPatches" >> "ace_medical"))) then {
				diag_log "[Vindicta] Ace medican system is disabled, initializing standard Arma revive system";
				[1] call BIS_fnc_paramReviveMode; // Enabled
				[10]  call BIS_fnc_paramReviveDuration;
				[0] call BIS_fnc_paramReviveRequiredTrait; // 0 - no trait required
				[1.5] call BIS_fnc_paramReviveMedicSpeedMultiplier;
				[2] call BIS_fnc_paramReviveRequiredItems; // 2 - medkit or FAK
				[0] call BIS_fnc_paramReviveUnconsciousStateMode;
				[200] call BIS_fnc_paramReviveBleedOutDuration;
				[3] call BIS_fnc_paramReviveForceRespawnDuration;

				// Initialize BIS revive
				call BIS_fnc_reviveInit;
			};
		};
	ENDMETHOD;
	
	// - - - - - Getters for game state - - - - -

	public METHOD(isGameModeInitialized)
		params [P_THISOBJECT];
		T_GETV("gameModeInitialized")
	ENDMETHOD;

	// - - - - - Saved game management - - - - -

	// Reads all headers of saved games from storage
	// Returns an array of [record name(string), header(ref)]
	// !!! Note: headers must be deleted from RAM afterwards !!!
	METHOD(readAllSavedGameHeaders)
		params [P_THISOBJECT, P_STRING("_storageClassName")];
		pr _storage = NEW(_storageClassName, []);

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
					OOP_ERROR_1("Save game header not found for %1, removing invalid record", _recordName);
					CALLM1(_storage, "eraseRecord", _recordName);
				};
			} else {
				OOP_ERROR_1("Can't open record %1", _recordName);
			};
			CALLM0(_storage, "close");
		} forEach _allRecords;

		DELETE(_storage);

		// Return
		_allRecordNamesAndHeaders
	ENDMETHOD;

	// Checks all headers if they can be loaded
	// Parameters: _recordNamesAndHeaders - see readAllSavedGameHeaders output
	// Returns an array of [record name(string), header(ref), errors(array)]
	METHOD(checkAllHeadersForLoading)
		params [P_THISOBJECT, P_ARRAY("_recordNamesAndHeaders")];
		// Process all headers and check if these files can be loaded
		pr _return = []; // Array with server's response
		OOP_INFO_1("Checking %1 headers:", count _recordNamesAndHeaders);
		pr _saveVersion = parseNumber (call misc_fnc_getSaveVersion);
		pr _saveBreakVersion = parseNumber (call misc_fnc_getSaveBreakVersion);
		{
			_x params ["_recordName", "_header"];
			OOP_INFO_2("  checking header: %1 of record: %2", _header, _recordName);

			pr _errors = [];
			pr _headerSaveVersion = parseNumber GETV(_header, "saveVersion");
			if (_headerSaveVersion > _saveVersion || _headerSaveVersion < _saveBreakVersion) then {
				_errors pushBack INCOMPATIBLE_SAVE_VERSION;
				OOP_INFO_3("  incompatible save version: %1, current: %2, last compatible: %3", _headerSaveVersion, _saveVersion, _headerSaveVersion);
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
	ENDMETHOD;

	METHOD(saveGame)
		params [P_THISOBJECT, P_NUMBER("_type"), P_STRING("_storageClassName")];

		// Bail if we are not server
		if (!isServer) exitWith {
			OOP_ERROR_0("saveGame must be executed only on server!");
			false
		};

		ASSERT_MSG(_storageClassName != "", "Storage class name is empty!");

		// Bail if game mode is not initialized (although the button should be disabled, right?)
		if(!CALLM0(gGameManager, "isGameModeInitialized")) exitWith { false };

		diag_log "[GameManager] - - - - - - - - - - - - - - - - - - - - - - - - - - -";
		diag_log format ["[GameManager]			GAME SAVE STARTED to: %1", _storageClassName];
		OOP_INFO_0("GAME SAVE STARTED");

		// Start loading screen
		["saving", ["<t size='4' color='#FF7733'>PLEASE WAIT</t><br/><t size='6' color='#FFFFFF'>SAVING NOW</t>", "PLAIN", -1, true, true]] remoteExec ["cutText", ON_ALL, false];
		["saving", 20000] remoteExec ["cutFadeOut", ON_ALL, false];

		pr _storage = NEW(_storageClassName, []);

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

		pr _typePrefix = switch _type do {
			case SAVE_TYPE_DEFAULT: 	{ "" };
			case SAVE_TYPE_RECOVERY: 	{ "[RECOVERY]" };
			case SAVE_TYPE_AUTO: 		{ "[AUTO]" };
		};

		pr _recordNameFinal = DEV_PREFIX + _typePrefix + _recordNameBase;

		// We only keep one recovery and auto save for each campaign name, delete any others
		if(_type in [SAVE_TYPE_RECOVERY, SAVE_TYPE_AUTO]) then {
			pr _recordsToDelete = CALLM0(_storage, "getAllRecords") select { 
				tolower _typePrefix in tolower _x && tolower T_GETV("campaignName") in tolower _x
			};
			{
				CALLM1(_storage, "eraseRecord", _x);
			} forEach _recordsToDelete;
		} else {
			// Find a unique name for the save
			pr _i = 1;
			while {CALLM1(_storage, "recordExists", _recordNameFinal)} do {
				_recordNameFinal = format ["%1 %2", _recordNameBase, _i];
				_i = _i + 1;
			};
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
			//CRITICAL_SECTION {
			CALLM2(_storage, "save", "gameMode", gGameMode);	// Ref to game mode object
			//};
			
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
	ENDMETHOD;

	vin_fnc_loadGameMsg = {
		params ["_header", "_message", "_delay"];
		diag_log _this;
		["loading", [format ["<t size='5' color='#FF7733'>%1</t><br/><t size='3' color='#FFFFFF'>%2</t>", _header, _message], "PLAIN", -1, true, true]] remoteExec ["cutText", ON_ALL, false];
		["loading", _delay] remoteExec ["cutFadeOut", ON_ALL, false];
	};

	// Loads game, returns true on success
	METHOD(loadGame)
		params [P_THISOBJECT, P_STRING("_recordName"), P_STRING("_storageClassName")];

		ASSERT_MSG(_storageClassName != "", "Storage class name is empty!");

		OOP_INFO_1("LOAD GAME: %1", _this);

		diag_log 			"[GameManager] - - - - - - - - - - - - - - - - - - - - - - - - - - -";
		diag_log format	[	"[GameManager]			LOAD GAME: %1 from %2", _recordName, _storageClassName];
		OOP_INFO_0("GAME SAVE STARTED");

		// Bail if we are not server
		if (!isServer) exitWith {
			OOP_ERROR_0("loadGame must be executed only on server!");
			false
		};

		// Bail if game mode is already initialized (although the button should be disabled, right?)
		if(CALLM0(gGameManager, "isGameModeInitialized")) exitWith { false };

		// Start loading screen
		[LOCS("Vindicta_GameManager", "Load_Loading"), _recordName, 20000] call vin_fnc_loadGameMsg;

		pr _storage = NEW(_storageClassName, []);

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
						pr _timeStart = diag_tickTime;
						//CRITICAL_SECTION {
						CALLM3(_storage, "load", _gameModeRef, false, _headerVer);
						//};
						diag_log format ["[GameManager] Game loaded in %1 seconds", diag_tickTime - _timeStart];
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
		if(_success) then {
			[LOCS("Vindicta_GameManager", "Load_Failed"), _recordName, 10] call vin_fnc_loadGameMsg;
		} else {
			[LOCS("Vindicta_GameManager", "Load_Complete"), _recordName, 10] call vin_fnc_loadGameMsg;
		};

		OOP_INFO_0("GAME LOAD ENDED");
		diag_log "[GameManager] GAME LOAD ENDED";
		diag_log "[GameManager] - - - - - - - - - - - - - - - - - - - - - - - - - - -";

		_success
	ENDMETHOD;

	METHOD(deleteSavedGame)
		params [P_THISOBJECT, P_STRING("_recordName"), P_STRING("_storageClassName")];
		
		OOP_INFO_1("DELETE SAVED GAME: %1", _this);

		ASSERT_MSG(_storageClassName != "", "Storage class name is empty!");

		pr _storage = NEW(_storageClassName, []);
		CALLM1(_storage, "eraseRecord", _recordName);
		DELETE(_storage);
	ENDMETHOD;

	vin_fnc_autoLoadMsg = {
		diag_log ("[Vindicta Autoload] " + _this);
		["autoloadwarning", [format ["<t size='4' color='#FF7733'>%1</t><br/><t size='2' color='#FFFFFF'>%2</t>", LOCS("Vindicta_GameManager", "Autoload"), _this], "PLAIN", -1, true, true]] remoteExec ["cutText", ON_ALL, false];
		["autoloadwarning", 10] remoteExec ["cutFadeOut", ON_ALL, false];
	};

	METHOD(autoLoad)
		params [P_THISOBJECT];

		#define LOC_SCOPE "Vindicta_GameManager"
		if(!vin_autoLoad_enabled) exitWith {
			LOC("Autoload_Disabled") call vin_fnc_autoLoadMsg;
		};

		// Read headers of all records
		pr _recordNamesAndHeaders = T_CALLM1("readAllSavedGameHeaders", T_GETV("storageClassName"));

		if(count _recordNamesAndHeaders == 0) exitWith {
			LOC("Autoload_NoSaves") call vin_fnc_autoLoadMsg;
		};

		// log
		diag_log "[Vindicta Autoload] All saved games:";
		{
			diag_log format ["    %1", _x];
		} forEach _recordNamesAndHeaders;

		// Check all headers for loadability
		pr _checkResult = T_CALLM1("checkAllHeadersForLoading", _recordNamesAndHeaders);

		pr _dataForLoad = _checkResult apply {
			_x params ["_recordName", "_header", "_errors"];
			DELETE(_header);
			[_recordName, _errors]
		} select {
			!(INCOMPATIBLE_WORLD_NAME in _x#1)
		};

		// Log
		diag_log "[Vindicta Autoload] Saved games compatible for load:";
		{
			diag_log format ["    %1", _x];
		} forEach _dataForLoad;

		if(count _dataForLoad == 0) exitWith {
			LOC("Autoload_NoSavesForMap") call vin_fnc_autoLoadMsg;
		};

		reverse _dataForLoad;

		_dataForLoad#0 params ["_recordName", "_errors"];

		diag_log format ["[Vindicta Autoload] Selected saved game: %1", _recordName];

		if(INCOMPATIBLE_SAVE_VERSION in _errors) exitWith {
			LOC("Autoload_Version") call vin_fnc_autoLoadMsg;
		};

		if(INCOMPATIBLE_FACTION_TEMPLATES in _errors) exitWith {
			LOC("Autoload_Factions") call vin_fnc_autoLoadMsg;
		};

		// Now we wait for players/admins if we are on dedicated server
		if(IS_DEDICATED) then {
			[_thisObject, _recordName] spawn {
				params ["_thisObject", "_recordName"];

				// Wait for players to connect
				waitUntil {
					sleep 1;
					count HUMAN_PLAYERS > 0
				};

				private _autoLoadTime = PROCESS_TIME + 30;
				while { !IS_ADMIN_ON_DEDI && _autoLoadTime > PROCESS_TIME } do {
					sleep 0.5;
					format [LOC("Autoload_CountDown"), ceil (_autoLoadTime - PROCESS_TIME)] call vin_fnc_autoLoadMsg;
				};

				if(!IS_ADMIN_ON_DEDI) then {
					pr _args = [_recordName, T_GETV("storageClassName")];
					T_CALLM2("postMethodAsync", "loadGame", _args);
				} else {
					LOC("Autoload_AdminAbort") call vin_fnc_autoLoadMsg;
				};
			};
		} else {
			pr _args = [_recordName, T_GETV("storageClassName")];
			T_CALLM2("postMethodAsync", "loadGame", _args);
		};

		#undef LOC_SCOPE
	ENDMETHOD;
	
	// FUNCTIONS CALLED BY CLIENT

	// Called by client when he needs to get data on all the saved games
	public server METHOD(clientRequestAllSavedGames)
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_STRING("_storageClassName")];

		OOP_INFO_1("clientRequestAllSavedGames: %1", _this);

		// When client first opens the dialog, he doesn't know which storage to ask data from
		// Therefore we use our preferred storage
		if (_storageClassName == "") then {
			_storageClassName = T_GETV("storageClassName");
		};

		// Read headers of all records
		pr _recordNamesAndHeaders = T_CALLM1("readAllSavedGameHeaders", _storageClassName);

		// Check all headers for loadability
		pr _checkResult = T_CALLM1("checkAllHeadersForLoading", _recordNamesAndHeaders);

		pr _dataForClient = _checkResult apply {
			_x params ["_recordName", "_header", "_errors"];
			[_recordName, SERIALIZE_ALL(_header), _errors]
		};

		// Send data to client
		pr _args = [_dataForClient, _storageClassName, +T_GETV("storageClassNames")];
		REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabSave", "staticReceiveRecordData", _args, _clientOwner, false);

		// Cleanup
		{
			// We are deleting the local copies of saved game headers from RAM
			_x params ["_recordName", "_header"];
			DELETE(_header);
		} forEach _recordNamesAndHeaders;
	ENDMETHOD;

	public server METHOD(clientSaveGame)
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_STRING("_storageClassName")];

		if (_storageClassName == "") then {
			_storageClassName = T_GETV("storageClassName");
		};

		T_CALLM2("saveGame", SAVE_TYPE_DEFAULT, _storageClassName);
		T_CALLM2("clientRequestAllSavedGames", _clientOwner, _storageClassName);	// Send updated saved game list to client
	ENDMETHOD;

	public server METHOD(serverSaveGameRecovery)
		params [P_THISOBJECT];
		T_CALLM2("saveGame", SAVE_TYPE_RECOVERY, T_GETV("storageClassName"));
	ENDMETHOD;

	public server METHOD(clientOverwriteSavedGame)
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_STRING("_recordName"), P_STRING("_storageClassName")];

		OOP_INFO_1("CLIENT OVERWRITE SAVED GAME: %1", _this);

		if (_storageClassName == "") then {
			_storageClassName = T_GETV("storageClassName");
		};

		T_CALLM2("deleteSavedGame", _recordName, _storageClassName);
		T_CALLM2("saveGame", SAVE_TYPE_DEFAULT, _storageClassName);
		T_CALLM2("clientRequestAllSavedGames", _clientOwner, _storageClassName);	// Send updated saved game list to client
	ENDMETHOD;

	public server METHOD(clientDeleteSavedGame)
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_STRING("_recordName"), P_STRING("_storageClassName")];

		if (_storageClassName == "") then {
			_storageClassName = T_GETV("storageClassName");
		};

		T_CALLM2("deleteSavedGame", _recordName, _storageClassName);
		T_CALLM2("clientRequestAllSavedGames", _clientOwner, _storageClassName);	// Send updated saved game list to client
	ENDMETHOD;

	public server METHOD(clientLoadSavedGame)
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_STRING("_recordName"), P_STRING("_storageClassName")];

		OOP_INFO_1("CLIENT LOAD SAVED GAME: %1", _recordName);

		if (_storageClassName == "") then {
			_storageClassName = T_GETV("storageClassName");
		};

		T_CALLM2("loadGame", _recordName, _storageClassName);
	ENDMETHOD;


	// - - - - Game Mode Initialization - - - -

	// Initializes a new campaign and a new game mode on server (does NOT load a saved game, but creates a new one!)
	// todo: initialization parameters
	public METHOD(initCampaignServer)
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
		//CRITICAL_SECTION {
		CALLM0(gGameMode, "init");
		//};
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
	ENDMETHOD;

	// Must be run on client to initialize the game mode
	public client METHOD(initGameModeClient)
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
	ENDMETHOD;

	public client METHOD(staticInitGameModeClient)
		params [P_THISCLASS, P_STRING("_className")];
		pr _instance = CALLSM0("GameManager", "getInstance");
		CALLM2(_instance, "postMethodAsync", "initGameModeClient", [_className]);
	ENDMETHOD;

	// Fix for SQF-VM
	#ifdef _SQF_VM
	vin_diff_aggressionBoost = 0;
	vin_diff_lootAmount = 1.0;
	vin_diff_global = 1.0;
	#endif

	// - - - - - Settings - - - - -
	METHOD(initSettings)
		params [P_THISOBJECT];
		#define LOC_SCOPE "Vindicta_Settings"

		private _section = LOC("Section");
		// TODO format this better. Maybe push/pop sections like START_SECTION(sec) if(isNil "_currSection") then { _currSection = sec; _sections = []; } else { _sections pushBack _currSection; _currSection = _currSection + "_" + sec; }
		// Spawn distance
		["vin_spawnDist_garrisonToPlayer",		"SLIDER",
			[LOC("Perf_Spawn_Garrison_Player"), LOC("Perf_Spawn_Garrison_Player_Tooltip")],
			[_section, LOC("Perf")],
			[300, 5000, 1300, 0],
			true] call CBA_fnc_addSetting;
		["vin_spawnDist_garrisonToAI",		"SLIDER",
			[LOC("Perf_Spawn_Garrison_AI"), LOC("Perf_Spawn_Garrison_AI_Tooltip")],
			[_section, LOC("Perf")],
			[300, 3000, 500, 0],
			true] call CBA_fnc_addSetting;
		["vin_CivPresence_multiplierUser",		"SLIDER",
			[LOC("Ambient_Civ_Multiplier"), LOC("Ambient_Civ_Multiplier_Tooltip")],
			[_section, LOC("Perf")],
			[0, 5, 1, 2],
			true] call CBA_fnc_addSetting;

		// Difficulty
		["vin_diff_global",				"SLIDER",	[LOC("Diff_Global"),		LOC("Diff_Global_Tooltip")],	[_section, LOC("Diff")],[0, 1, 0.5, 2],	true] call CBA_fnc_addSetting;

		["vin_diff_aggressionBoost",	"SLIDER",	[LOC("Diff_Aggression"),	LOC("Diff_Aggression_Tooltip")],[_section, LOC("Diff")],[0, 100, 0, 0],	true] call CBA_fnc_addSetting;

		["vin_diff_lootAmount",	"SLIDER",	[LOC("Diff_LootAmount"),	LOC("Diff_LootAmount")],[_section, LOC("Diff")],[0.5, 5, 1.0, 1],	true] call CBA_fnc_addSetting;

		// Disabled for now until we work out how best to combine global and individual settings
		// Difficulty - Cmdr
		// ["vin_diff_cmdrGlobal",			"SLIDER",	[LOC("Diff_Cmdr_Global"),	LOC("Diff_Cmdr_Global_Tooltip")],			[_section, LOC("Diff")],[0, 2, 1, 2],	true] call CBA_fnc_addSetting;
		// ["vin_diff_cmdrReinforcement",	"SLIDER",	[LOC("Diff_Cmdr_Reinforcement_Rate"), LOC("Diff_Cmdr_Reinforcement_Rate_Tooltip")],	[_section, LOC("Diff")],[0, 1, 0.5, 2],	true] call CBA_fnc_addSetting;
		// ["vin_diff_cmdrEscalation",		"SLIDER",	[LOC("Diff_Cmdr_Escalation_Rate"), LOC("Diff_Cmdr_Escalation_Rate_Tooltip")],	[_section, LOC("Diff")],[0, 1, 0.5, 2],	true] call CBA_fnc_addSetting;
		// ["vin_diff_cmdrPersistence",	"SLIDER",	[LOC("Diff_Cmdr_Persistence"), LOC("Diff_Cmdr_Persistence_Tooltip")],	[_section, LOC("Diff")],[0, 1, 0.5, 2],	true] call CBA_fnc_addSetting;

		// AI
		pr _tooltip = LOC("AI_Tooltip_Note");
		["vin_aiskill_aimingAccuracy",	"SLIDER",	[LOC("AI_Accuracy"),			_tooltip],								[_section, LOC("AI")],[0, 1, 0.5, 2],	true] call CBA_fnc_addSetting;
		["vin_aiskill_aimingShake",		"SLIDER",	[LOC("AI_Shake"),				_tooltip],								[_section, LOC("AI")],[0, 1, 0.5, 2],	true] call CBA_fnc_addSetting;
		["vin_aiskill_aimingSpeed",		"SLIDER",	[LOC("AI_Speed"),				_tooltip],								[_section, LOC("AI")],[0, 1, 0.5, 2],	true] call CBA_fnc_addSetting;
		["vin_aiskill_spotDistance",	"SLIDER",	[LOC("AI_Spotting_Distance"), 	_tooltip],								[_section, LOC("AI")],[0, 1, 0.5, 2],	true] call CBA_fnc_addSetting;
		["vin_aiskill_spotTime",		"SLIDER",	[LOC("AI_Spotting_Time"), 		_tooltip],								[_section, LOC("AI")],[0, 1, 0.5, 2],	true] call CBA_fnc_addSetting;

		// Auto load
		["vin_autoLoad_enabled",		"CHECKBOX",	[LOC("Autoload_Enabled"),		LOC("Autoload_Enabled_Tooltip")],		[_section, LOC("Autoload")],	false,			true] call CBA_fnc_addSetting;

		// Auto save
		["vin_autoSave_enabled",		"CHECKBOX",	[LOC("Autosave_Enabled"),		LOC("Autosave_Enabled_Tooltip")],		[_section, LOC("Autosave")],	false,			true] call CBA_fnc_addSetting;
		["vin_autoSave_onEmpty",		"CHECKBOX",	[LOC("Autosave_On_Empty"),		LOC("Autosave_On_Empty_Tooltip")],		[_section, LOC("Autosave")],	false,			true] call CBA_fnc_addSetting;
		["vin_autoSave_interval",		"SLIDER",	[LOC("Autosave_Interval"),		LOC("Autosave_Interval_Tooltip")],		[_section, LOC("Autosave")],	[0, 24, 0, 0],	true] call CBA_fnc_addSetting;
		["vin_autoSave_inCombat",		"CHECKBOX",	[LOC("Autosave_In_Combat"),		LOC("Autosave_In_Combat_Tooltip")],		[_section, LOC("Autosave")],	false,			true] call CBA_fnc_addSetting;

		// Server
		["vin_server_suspendWhenEmpty",	"CHECKBOX",	[LOC("Server_Suspend"),			LOC("Server_Suspend_Tooltip")],			[_section, LOC("Server")],	true,			true] call CBA_fnc_addSetting;

		// Game
		["vin_server_gameSpeed",		"SLIDER",	[LOC("Game_Speed"),				LOC("Game_Speed_Tooltip")],				[_section, LOC("Game")],		[0.1, 5, 1, 1],	true] call CBA_fnc_addSetting;

		#undef LOC_SCOPE
	ENDMETHOD;

	// - - - - - Auto Save - - - - -
	METHOD(_playersInCombat)
		params [P_THISOBJECT];

		if(vin_autoSave_inCombat) exitWith { false };
		if(isNil "gGameMode") exitWith { false };

		private _enemySide = CALLM0(gGameMode, "getEnemySide");

		HUMAN_PLAYERS findIf {
			// Find nearby enemies
			(_x nearEntities ["Man", 250] - HUMAN_PLAYERS) findIf { side _x == _enemySide } != NOT_FOUND
		} != NOT_FOUND;
	ENDMETHOD;

	vin_fnc_autoSaveMsg = {
		["autosavewarning", [_this, "PLAIN DOWN", -1, true, true]] remoteExec ["cutText", ON_ALL, false];
		["autosavewarning", 10] remoteExec ["cutFadeOut", ON_ALL, false];
	};

	public METHOD(checkPeriodicAutoSave)
		params [P_THISOBJECT];

		if(!vin_autoSave_enabled || vin_autoSave_interval == 0) exitWith { 
			// disabled
		};

		private _playersInCombat = T_CALLM0("_playersInCombat");
		private _nextAutoSaveTime = T_GETV("lastAutoSave") + vin_autoSave_interval * 60 * 60;

		if(_nextAutoSaveTime > TIME_NOW || {_playersInCombat && _nextAutoSaveTime + 30 * 60 > TIME_NOW}) exitWith {
			// not time yet
			private _lastAutoSaveCheck = T_GETV("lastAutoSaveCheck");
			T_SETV("lastAutoSaveCheck", TIME_NOW);
			private _delayMessage = if(_playersInCombat) then {
				"<br/><t size='2' color='#FFFFFF'>(delayed due to enemies within 250m of players)</t>"
			} else {
				""
			};
			switch true do {
				// 5m warning
				case (_nextAutoSaveTime - 300 <= TIME_NOW && _nextAutoSaveTime - 300 > _lastAutoSaveCheck): {
					("<t size='2' color='#FFFF33'>Auto saving in 5 minutes</t>" + _delayMessage) call vin_fnc_autoSaveMsg;
				};
				// 30s  warning
				case (_nextAutoSaveTime - 30 <= TIME_NOW && _nextAutoSaveTime - 30 > _lastAutoSaveCheck): {
					("<t size='4' color='#FFFF33'>Auto saving in 30 seconds</t>" + _delayMessage) call vin_fnc_autoSaveMsg;
				};
				// Forced warning
				case (_playersInCombat && _nextAutoSaveTime + 30 * 60 <= TIME_NOW && _nextAutoSaveTime + 30 * 60 - 30 > _lastAutoSaveCheck): {
					("<t size='4' color='#FFFF33'>Auto saving in 30 seconds</t><br/><t size='1' color='#FFFFFF'>(was delayed by 30 minutes due to enemies within 250m of players)</t>" + _delayMessage) call vin_fnc_autoSaveMsg;
				};
			};
		};

		T_CALLM2("saveGame", SAVE_TYPE_AUTO, T_GETV("storageClassName"));
		T_SETV("lastAutoSave", TIME_NOW);
	ENDMETHOD;

	public METHOD(checkEmptyAutoSave)
		params [P_THISOBJECT];
		if(!vin_autoSave_enabled || !vin_autoSave_onEmpty) exitWith { };
		T_CALLM2("saveGame", SAVE_TYPE_AUTO, T_GETV("storageClassName"));
		T_SETV("lastAutoSave", TIME_NOW);
	ENDMETHOD;

	// - - - - Misc methods - - - -

	public override METHOD(getMessageLoop)
		gMessageLoopGameManager
	ENDMETHOD;

	public STATIC_METHOD(getInstance)
		gGameManager
	ENDMETHOD;

ENDCLASS;