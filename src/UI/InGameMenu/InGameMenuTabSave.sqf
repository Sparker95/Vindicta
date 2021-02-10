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

	// Class name of storage at the server
	VARIABLE("storageClassName");

	// Array with available storage class names
	VARIABLE("storageClassNames");

	METHOD(new)
		params [P_THISOBJECT];

		// Initialize variables
		T_SETV("recordData", []);
		T_SETV("storageClassName", "");
		T_SETV("storageClassNames", []);

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
				_x ctrlSetTooltip localize "STR_ADMIN_ONLY";
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
				
				pr _tooltipText = localize "STR_LOAD_AFTER_RESTART";
				_bnLoadSave ctrlSetTooltip _tooltipText;
			} else {
				_bnNewSave			ctrlEnable false;
				_bnOverwriteSave	ctrlEnable false;
				//_bnLoad				ctrlEnable true;
				
				pr _tooltipText = localize "STR_NOTHING_TO_SAVE";
				_bnOverwriteSave ctrlSetTooltip _tooltipText;
				_bnNewSave ctrlSetTooltip _tooltipText;
			};
		};

		SETSV(__CLASS_NAME, "instance", _thisObject);

		// Temporary:
		// Set hint about FileXT addon
		pr _staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_SAVE_DATA");
		pr _nl = toString [10];
		pr _str = localize "STR_FILEXT_SUGGEST" + _nl;
		_str = _str + localize "STR_FILEXT_SUGGEST_1";
		_staticSaveData ctrlSetText _str;

		// Request save game data from server
		pr _args = [clientOwner, ""];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientRequestAllSavedGames", _args);
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
		params [P_THISOBJECT, P_ARRAY("_recordData"), P_STRING("_storageClassName"), P_ARRAY("_storageClassNames")];

		OOP_INFO_0("RECEIVE RECORD DATA:");
		{
			OOP_INFO_1("  %1", _x);
		} forEach _recordData;
		OOP_INFO_2("Current storage class names: %1, all class names: %2", _storageClassName, _storageClassNames);

		// Unpack serialized data
		pr _recordDataLocal = _recordData apply
		{
			_x params ["_recordName", "_headerSerial", "_errors"];
			pr _header = NEW("SaveGameHeader", []);
			DESERIALIZE_ALL(_header, _headerSerial);
			[_recordName, _header, _errors];
		};
		
		// Sort save games based on their creation time that is stored in the systemTimeUTC save game header
		_recordDataLocal = [_recordDataLocal, [], {
				_x params ["_recordName", "_header", "_errors"];
				GETV(_header, "systemTimeUTC") call misc_fnc_systemTimeToISO8601
			}, "DESCEND"] call BIS_fnc_sortBy;

		T_CALLM0("clearRecordData");

		T_SETV("recordData", _recordDataLocal);
		T_SETV("storageClassName", _storageClassName);
		pr _initCombo = false;
		if ((count T_GETV("storageClassNames")) == 0) then {
			_initCombo = true;
		};
		T_SETV("storageClassNames", +_storageClassNames);
		T_CALLM0("updateListbox");
		if (_initCombo) then {
			T_CALLM0("initStorageCombo");
		};
	ENDMETHOD;

	public STATIC_METHOD(staticReceiveRecordData)
		params [P_THISOBJECT, P_ARRAY("_recordData"), P_STRING("_storageClassName"), P_ARRAY("_storageClassNames")];
		pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
		if (!IS_NULL_OBJECT(_instance)) then {
			CALLM3(_instance, "receiveRecordData", _recordData, _storageClassName, _storageClassNames);
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
			//pr _staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_SAVE_DATA");
			//_staticSaveData ctrlSetText "";
		};

		// savegame count limit
		OOP_INFO_1("Storage class name at server: %1", T_GETV("storageClassName"));
		pr _saveGameLimit = switch (T_GETV("storageClassName")) do {
			case "StorageFilext": {999;}; // Unlimited
			case "StorageProfileNamespace": {4;};
			default {0}; // Error?
		};

		if (call misc_fnc_isAdminLocal && CALLM0(gGameManager, "isGameModeInitialized")) then { // Only admin can save when the game is intialized
			if (count T_GETV("recordData") > _saveGameLimit) then {
				pr _newSaveBtn = T_CALLM1("findControl", "TAB_SAVE_BUTTON_NEW");
				_newSaveBtn ctrlEnable false;
				_newSaveBtn ctrlSetTooltip (localize "STR_NEWSAVE_DISABLED");
			} else {
				pr _newSaveBtn = T_CALLM1("findControl", "TAB_SAVE_BUTTON_NEW");
				_newSaveBtn ctrlEnable true; // We can't enable it here, what if user is not an admin?
				_newSaveBtn ctrlSetTooltip (localize "STR_NEWSAVE_ENABLED");
			};
		};
 
	ENDMETHOD;

	// Updates combo box with storage options
	METHOD(initStorageCombo)
		params [P_THISCLASS];

		OOP_INFO_0("INIT STORAGE COMBO");

		pr _ctrl = T_CALLM1("findControl", "TAB_SAVE_COMBO_STORAGE");
		pr _currentStorageClassName = T_GETV("storageClassName");
		pr _storageClassNames = T_GETV("storageClassNames");
		{
			_x params ["_className", "_displayName"];
			_ctrl lbAdd _displayName;
			_ctrl lbSetData [_forEachIndex, _className];
			if (_className == _currentStorageClassName) then {
				_ctrl lbSetCurSel _forEachIndex;
			};
		} forEach _storageClassNames;

		T_CALLM3("controlAddEventHandler", "TAB_SAVE_COMBO_STORAGE", "LBSelChanged", "onStorageComboSelChanged");
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
		pr _args = [clientOwner, T_GETV("storageClassName")];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientSaveGame", _args);

		// Close in game menu after saving
		CALLM0(gInGameMenu, "close");
	ENDMETHOD;

	public event METHOD(onButtonNewSave)
		params [P_THISOBJECT];

		// Bail if game mode is not initialized (although the button should be disabled, right?)
		if(!CALLM0(gGameManager, "isGameModeInitialized")) exitWith {};

		// Show a confirmation dialog
		pr _args = [format [localize "STR_CREATE_NEW_GAME"],
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
		pr _args = [clientOwner, _recordName, T_GETV("storageClassName")];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientOverwriteSavedGame", _args);

		// Close in game menu after overwriting
		CALLM0(gInGameMenu, "close");
	ENDMETHOD;

	public event METHOD(onButtonOverwriteSavedGame)
		params [P_THISOBJECT];
		pr _index = T_CALLM0("getSelectedSavedGameIndex");
		if (_index == -1) exitWith {};

		pr _selRecordData = T_GETV("recordData") select _index;
		_selRecordData params ["_recordName", "_header", "_errors"];
		
		// Show a confirmation dialog
		pr _args = [format [localize "STR_OVERWRITE_SAVE", _recordName],
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
		pr _args = [clientOwner, _recordName, T_GETV("storageClassName")];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientLoadSavedGame", _args);

		// Close in game menu after loading
		CALLM0(gInGameMenu, "close");
	ENDMETHOD;

	public event METHOD(onButtonLoadSavedGame)
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
			pr _text = format [localize "STR_INCOMPAT_SAVE", _headerVer, _currVer, _saveBreakVersion];
			CALLM1(_dialogObj, "setHintText", _text);
		};

		// Check if maps match
		if ( (toLower GETV(_header,"worldName")) != (toLower worldName)) exitWith {
			pr _dialogObj = T_CALLM0("getDialogObject");
			pr _text = format [localize "STR_INCOMPAT_MAP", GETV(_header,"worldName"), worldName];
			CALLM1(_dialogObj, "setHintText", _text);
		};

		// Show a confirmation dialog
		pr _args = [format [localize "STR_LOAD_CONFIRM", _recordName],
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
		pr _args = [clientOwner, _recordName, T_GETV("storageClassName")];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientDeleteSavedGame", _args);
	ENDMETHOD;

	public event METHOD(onButtonDeleteSavedGame)
		params [P_THISOBJECT];
		pr _index = T_CALLM0("getSelectedSavedGameIndex");
		if (_index == -1) exitWith {};

		pr _selRecordData = T_GETV("recordData") select _index;
		_selRecordData params ["_recordName", "_header", "_errors"];

		// Show a confirmation dialog
		pr _args = [format [localize "STR_DELETE_CONFIRM", _recordName],
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

	public event METHOD(onListboxSelChanged)
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

	METHOD(onStorageComboSelChanged)
		params [P_THISOBJECT];

		pr _ctrl = T_CALLM1("findControl", "TAB_SAVE_COMBO_STORAGE");
		pr _index = lbCurSel _ctrl;
		pr _storageClassName = _ctrl lbData _index;

		OOP_INFO_2("onStorageComboSelChanged: index: %1, new storage: %2", _index, _storageClassName);

		// Request new data with saves from another storage
		pr _args = [clientOwner, _storageClassName];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientRequestAllSavedGames", _args);
	ENDMETHOD;

ENDCLASS;