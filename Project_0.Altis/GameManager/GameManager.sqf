#include "common.hpp"

/*
Class: GameManager

A class which handles saving/loading of game mode or initialization of game mode.
Runs in its own thread, because all other threads are saved and loaded.
It also handles some client requests about saving/loading the game, and initial mission initialization.
*/

#define __STORAGE_CLASS "StorageProfileNamespace"

#define pr private

CLASS("GameManager", "MessageReceiverEx")

	METHOD("new") {
		params [P_THISOBJECT];

		// Create a message loop for ourselves
		gMessageLoopGameManager = NEW("MessageLoop", ["Game Mode Manager Thread" ARG 10 ARG 0.2]); // 0.2s sleep interval, this thread doesn't need to run fast anyway

		// Create various objects not related to a particular mission

	} ENDMETHOD;

	METHOD("getMessageLoop") {
		gMessageLoopGameManager
	} ENDMETHOD;

	METHOD("getAllSaves") {
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

ENDCLASS;