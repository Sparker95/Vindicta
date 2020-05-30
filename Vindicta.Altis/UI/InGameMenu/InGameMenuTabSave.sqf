#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"

#include "..\..\GameManager\GameManager.hpp"

#define __CLASS_NAME "InGameMenuTabSave"

#define pr private
#define OOP_CLASS_NAME InGameMenuTabSave
CLASS("InGameMenuTabSave", "DialogTabBase")

	// Array with record header data received from server
	// Structure: [record name, record header(ref), errors(array)]
	VARIABLE("recordData");

	METHOD(new)
		params [P_THISOBJECT];

		// Initialize variables
		T_SETV("recordData", []);

		// Create controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["TAB_SAVE", -1];
		T_CALLM1("setControl", _group);

		// Resolve controls
		pr _bnNewSave = T_CALLM1("findControl", "TAB_SAVE_BUTTON_NEW");
		pr _bnOverwriteSave = T_CALLM1("findControl", "TAB_SAVE_BUTTON_OVERWRITE");
		pr _bnLoadSave = T_CALLM1("findControl", "TAB_SAVE_BUTTON_LOAD");
		pr _bnDeleteSave = T_CALLM1("findControl", "TAB_SAVE_BUTTON_DELETE");
		pr _lnbSavedGames = T_CALLM1("findControl", "TAB_SAVE_LISTNBOX_SAVES");

		// Add event handlers
		T_CALLM3("controlAddEventHandler", "TAB_SAVE_BUTTON_NEW", "buttonClick", "onButtonNewSave");
		T_CALLM3("controlAddEventHandler", "TAB_SAVE_BUTTON_OVERWRITE", "buttonClick", "onButtonOverwriteSavedGame");
		T_CALLM3("controlAddEventHandler", "TAB_SAVE_BUTTON_LOAD", "buttonClick", "onButtonLoadSavedGame");
		T_CALLM3("controlAddEventHandler", "TAB_SAVE_BUTTON_DELETE", "buttonClick", "onButtonDeleteSavedGame");
		T_CALLM3("controlAddEventHandler", "TAB_SAVE_LISTNBOX_SAVES", "LBSelChanged", "onListboxSelChanged");

		// Check user's permissions
		// todo integrate our own permissions thing... which is not done yet
		// instead check if player is admin
		pr _isAdmin = call misc_fnc_isAdminLocal;

		// Enable/disable some buttons permanently
		if (!_isAdmin) then {
			{
				_x ctrlEnable false;
				_x ctrlSetTooltip "Only for admins";
			} forEach [
				_bnNewSave,
				_bnOverwriteSave,
				_bnLoadSave,
				_bnDeleteSave
			];
		} else {
			// Setup tooltips for disabled buttons
			if(CALLM0(gGameManager, "isGameModeInitialized")) then {
				//_bnNewSave			ctrlEnable true;
				//_bnOverwriteSave	ctrlEnable true;
				_bnLoadSave			ctrlEnable false;
				
				pr _tooltipText = "Game can be loaded only after a mission restart";
				_bnLoadSave ctrlSetTooltip _tooltipText;
			} else {
				_bnNewSave			ctrlEnable false;
				_bnOverwriteSave	ctrlEnable false;
				//_bnLoad				ctrlEnable true;
				
				pr _tooltipText = "There is nothing to save yet";
				_bnOverwriteSave ctrlSetTooltip _tooltipText;
				_bnNewSave ctrlSetTooltip _tooltipText;
			};
		};

		SETSV(__CLASS_NAME, "instance", _thisObject);

		// Request save game data from server
		CALLM2(gGameManagerServer, "postMethodAsync", "clientRequestAllSavedGames", []);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", nil);
		T_CALLM0("clearRecordData"); // Must delete the save game header objects we have created
	ENDMETHOD;

	// Deletes all local record header objects
	METHOD(clearRecordData)
		params [P_THISOBJECT];
		{
			_x params ["_recordName", "_header", "_errors"];
			DELETE(_header);
		} forEach T_GETV("recordData");
		T_SETV("recordData", []);
	ENDMETHOD;

	// - - - - - Comms with server - - - - - -

	METHOD(receiveRecordData)
		params [P_THISOBJECT, P_ARRAY("_recordData")];

		OOP_INFO_0("RECEIVE RECORD DATA:");
		{
			OOP_INFO_1("  %1", _x);
		} forEach _recordData;

		// Unpack serialized data
		pr _recordDataLocal = _recordData apply
		{
			_x params ["_recordName", "_headerSerial", "_errors"];
			pr _header = NEW("SaveGameHeader", []);
			DESERIALIZE_ALL(_header, _headerSerial);
			[_recordName, _header, _errors];
		};
		// They are in order of when they were created so reverse them so we get newest at the top
		reverse _recordDataLocal;

		T_CALLM0("clearRecordData");
		T_SETV("recordData", _recordDataLocal);
		T_CALLM0("updateListbox");
	ENDMETHOD;

	STATIC_METHOD(staticReceiveRecordData)
		params [P_THISOBJECT, P_ARRAY("_recordData")];
		pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
		if (!IS_NULL_OBJECT(_instance)) then {
			CALLM1(_instance, "receiveRecordData", _recordData);
		};
	ENDMETHOD;

	// - - - - UI update event handlers - - - -
	// Updates listbox from the local record data
	METHOD(updateListbox)
		params [P_THISOBJECT];

		pr _lnbSavedGames = T_CALLM1("findControl", "TAB_SAVE_LISTNBOX_SAVES");
		lnbClear _lnbSavedGames;

		{
			pr _row = _forEachIndex;
			_x params ["_recordName", "_header", "_errors"];
			_lnbSavedGames lnbAddRow [_recordName];
			_lnbSavedGames lnbSetValue [[_row, 0], GETV(_header, "saveID")];
			_lnbSavedGames lnbSetData [[_row, 0], str _row]; // Set data to index of this record
		} forEach T_GETV("recordData");

		// Select something
		if (count T_GETV("recordData") > 0) then {
			_lnbSavedGames lnbSetCurSelRow 0; // It will cause a static box update too
		} else {
			pr _staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_SAVE_DATA");
			_staticSaveData ctrlSetText "";
		};

		// savegame count limit
		if (count T_GETV("recordData") > 4) then {
			pr _newSaveBtn = T_CALLM1("findControl", "TAB_SAVE_BUTTON_NEW");
			_newSaveBtn ctrlEnable false;
			_newSaveBtn ctrlSetTooltip (localize "STR_NEWSAVE_DISABLED");
		} else {
			pr _newSaveBtn = T_CALLM1("findControl", "TAB_SAVE_BUTTON_NEW");
			_newSaveBtn ctrlEnable true;
			_newSaveBtn ctrlSetTooltip (localize "STR_NEWSAVE_ENABLED");
		};
 
	ENDMETHOD;

	// Returns index of the currently selected saved game in the recordData array
	// Or -1 if nothing is selected
	METHOD(getSelectedSavedGameIndex)
		params [P_THISOBJECT];
		pr _lnbSavedGames = T_CALLM1("findControl", "TAB_SAVE_LISTNBOX_SAVES");
		pr _row = lnbCurSelRow _lnbSavedGames;
		if (_row == -1) exitWith {-1};
		if (_row >= (count T_GETV("recordData"))) exitWith {-1};
		pr _indexStr = _lnbSavedGames lnbData [_row, 0];
		parseNumber _indexStr
	ENDMETHOD;

	// - - - - Button and listbox event handlers - - - -

	METHOD(_saveGame)
		params [P_THISOBJECT];

		// Send request to server
		CALLM2(gGameManagerServer, "postMethodAsync", "clientSaveGame", [clientOwner]);

		// Close in game menu after saving
		CALLM0(gInGameMenu, "close");
	ENDMETHOD;

	METHOD(onButtonNewSave)
		params [P_THISOBJECT];

		// Bail if game mode is not initialized (although the button should be disabled, right?)
		if(!CALLM0(gGameManager, "isGameModeInitialized")) exitWith {};

		// Show a confirmation dialog
		pr _args = [format ["Create a new game save?\n"],
			[],
			{
				pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
				if (!IS_NULL_OBJECT(_instance)) then {
					CALLM0(_instance, "_saveGame");
				};
			},
			[], {}];
		NEW("DialogConfirmAction", _args);
	ENDMETHOD;

	METHOD(_overwriteSavedGame)
		params [P_THISOBJECT, P_STRING("_recordName")];

		OOP_INFO_1("Sending request to overwrite saved game: %1", _recordName);
		pr _args = [clientOwner, _recordName];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientOverwriteSavedGame", _args);

		// Close in game menu after overwriting
		CALLM0(gInGameMenu, "close");
	ENDMETHOD;

	METHOD(onButtonOverwriteSavedGame)
		params [P_THISOBJECT];
		pr _index = T_CALLM0("getSelectedSavedGameIndex");
		if (_index == -1) exitWith {};

		pr _selRecordData = T_GETV("recordData") select _index;
		_selRecordData params ["_recordName", "_header", "_errors"];
		
		// Show a confirmation dialog
		pr _args = [format ["Overwrite this saved game?\n%1", _recordName],
			[_recordName],
			{
				pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
				if (!IS_NULL_OBJECT(_instance)) then {
					CALLM1(_instance, "_overwriteSavedGame", _this#0);
				};
			},
			[], {}];
		NEW("DialogConfirmAction", _args);
	ENDMETHOD;

	METHOD(_loadSavedGame)
		params [P_THISOBJECT, P_STRING("_recordName")];

		OOP_INFO_1("Sending request to load saved game: %1", _recordName);
		pr _args = [clientOwner, _recordName];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientLoadSavedGame", _args);

		// Close in game menu after loading
		CALLM0(gInGameMenu, "close");
	ENDMETHOD;

	METHOD(onButtonLoadSavedGame)
		params [P_THISOBJECT];

		OOP_INFO_0("ON BUTTON LOAD SAVED GAME");

		pr _index = T_CALLM0("getSelectedSavedGameIndex");
		if (_index == -1) exitWith {};

		pr _selRecordData = T_GETV("recordData") select _index;
		_selRecordData params ["_recordName", "_header", "_errors"];

		// Check if versions match
		OOP_INFO_1(" checking record data: %1", _selRecordData);
		pr _headerVer = parseNumber GETV(_header,"saveVersion");
		pr _currVer = parseNumber (call misc_fnc_getSaveVersion);
		pr _saveBreakVersion = parseNumber (call misc_fnc_getSaveBreakVersion);
		// Last save break is at save version 19, we cannot load older games
		if (_headerVer < _saveBreakVersion || _headerVer > _currVer) exitWith {
			pr _dialogObj = T_CALLM0("getDialogObject");
			pr _text = format ["Error: version is incompatible: save: %1, current: %2, last compatible: %3", _headerVer, _currVer, _saveBreakVersion];
			CALLM1(_dialogObj, "setHintText", _text);
		};

		// Check if maps match
		if ( (toLower GETV(_header,"worldName")) != (toLower worldName)) exitWith {
			pr _dialogObj = T_CALLM0("getDialogObject");
			pr _text = format ["Error: maps are incompatible: save: %1, current: %2", GETV(_header,"worldName"), worldName];
			CALLM1(_dialogObj, "setHintText", _text);
		};

		// Show a confirmation dialog
		pr _args = [format ["Load this saved game?\n%1", _recordName],
			[_recordName],
			{
				pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
				if (!IS_NULL_OBJECT(_instance)) then {
					CALLM1(_instance, "_loadSavedGame", _this#0);
				};
			},
			[], {}];
		NEW("DialogConfirmAction", _args);
	ENDMETHOD;



	METHOD(_deleteSavedGame)
		params [P_THISOBJECT, P_STRING("_recordName")];
		OOP_INFO_1("Sending request to delete saved game: %1", _recordName);
		pr _args = [clientOwner, _recordName];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientDeleteSavedGame", _args);
	ENDMETHOD;

	METHOD(onButtonDeleteSavedGame)
		params [P_THISOBJECT];
		pr _index = T_CALLM0("getSelectedSavedGameIndex");
		if (_index == -1) exitWith {};

		pr _selRecordData = T_GETV("recordData") select _index;
		_selRecordData params ["_recordName", "_header", "_errors"];

		// Show a confirmation dialog
		pr _args = [format ["Delete this saved game?\n%1", _recordName],
			[_recordName],
			{
				pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
				if (!IS_NULL_OBJECT(_instance)) then {
					CALLM1(_instance, "_deleteSavedGame", _this#0);
				};
			},
			[], {}];
		NEW("DialogConfirmAction", _args);

	ENDMETHOD;



	METHOD(onListboxSelChanged)
		params [P_THISOBJECT];
		pr _index = T_CALLM0("getSelectedSavedGameIndex");

		if (_index == -1) exitWith {};
		pr _selRecordData = T_GETV("recordData") select _index;
		_selRecordData params ["_recordName", "_header", "_errors"];

		// Format text
		//pr _endl = toString [13, 10];
		pr _text = "";
		/*
		_text = _text + (format ["Campaign name: %1", GETV(_header, "campaignName")]);
		_text = _text + (format [", Map: %1", GETV(_header, "worldName")]);
		_text = _text + _endl;
		_text = _text + (format ["Version: %1", GETV(_header, "missionVersion")]);
		_text = _text + (format [", Save count: %1", GETV(_header, "saveID") + 1]);
		
		pr _staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_SAVE_DATA");
		*/

		_text = GETV(_header, "campaignName");
		pr _staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_NAME");
		_staticSaveData ctrlSetText _text;

		_text = GETV(_header, "worldName");
		_staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_MAP");
		_staticSaveData ctrlSetText _text;

		_text = GETV(_header, "missionVersion");
		_staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_VER");
		_staticSaveData ctrlSetText _text;

		_text = (format ["%1", GETV(_header, "saveID") + 1]);
		_staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_COUNT");
		_staticSaveData ctrlSetText _text;
	ENDMETHOD;

ENDCLASS;