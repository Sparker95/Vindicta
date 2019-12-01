#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

#define __CLASS_NAME "InGameMenuTabSave"

#define pr private

CLASS(__CLASS_NAME, "DialogTabBase")

	// Array with record header data received from server
	// Structure: [record name, record header(ref), errors(array)]
	VARIABLE("recordData");

	METHOD("new") {
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
		T_CALLM3("controlAddEventHandler", "TAB_SAVE_BUTTON_LOAD", "buttonClick", "onButtonLoadSave");
		T_CALLM3("controlAddEventHandler", "TAB_SAVE_BUTTON_DELETE", "buttonClick", "onButtonDeleteSavedGame");
		T_CALLM3("controlAddEventHandler", "TAB_SAVE_LISTNBOX_SAVES", "LBSelChanged", "onListboxSelChanged");

		// Enable/disable some buttons permanently
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

		SETSV(__CLASS_NAME, "instance", _thisObject);

		// Request save game data from server
		CALLM2(gGameManagerServer, "postMethodAsync", "clientRequestAllSavedGames", []);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		SETSV(__CLASS_NAME, "instance", nil);
		T_CALLM0("clearRecordData"); // Must delete the save game header objects we have created
	} ENDMETHOD;

	// Deletes all local record header objects
	METHOD("clearRecordData") {
		params [P_THISOBJECT];
		{
			_x params ["_recordName", "_header", "_errors"];
			DELETE(_header);
		} forEach T_GETV("recordData");
		T_SETV("recordData", []);
	} ENDMETHOD;

	// - - - - - Comms with server - - - - - -

	METHOD("receiveRecordData") {
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

		T_CALLM0("clearRecordData");
		T_SETV("recordData", _recordDataLocal);
		T_CALLM0("updateListbox");
	} ENDMETHOD;

	STATIC_METHOD("staticReceiveRecordData") {
		params [P_THISOBJECT, P_ARRAY("_recordData")];
		pr _instance = CALLSM0(__CLASS_NAME, "getInstance");
		if (!IS_NULL_OBJECT(_instance)) then {
			CALLM1(_instance, "receiveRecordData", _recordData);
		};
	} ENDMETHOD;

	// - - - - UI update event handlers - - - -
	// Updates listbox from the local record data
	METHOD("updateListbox") {
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

		// Sort by save ID
		_lnbSavedGames lnbSortByValue [0, true];

		// Select something
		if (count T_GETV("recordData") > 0) then {
			_lnbSavedGames lnbSetCurSelRow 0; // It will cause a static box update too
		} else {
			pr _staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_SAVE_DATA");
			_staticSaveData ctrlSetText "";
		};
	} ENDMETHOD;

	// Returns index of the currently selected saved game in the recordData array
	// Or -1 if nothing is selected
	METHOD("getSelectedSavedGameIndex") {
		params [P_THISOBJECT];
		pr _lnbSavedGames = T_CALLM1("findControl", "TAB_SAVE_LISTNBOX_SAVES");
		pr _row = lnbCurSelRow _lnbSavedGames;
		if (_row == -1) exitWith {-1};
		if (_row >= (count T_GETV("recordData"))) exitWith {-1};
		pr _indexStr = _lnbSavedGames lnbData [_row, 0];
		parseNumber _indexStr
	} ENDMETHOD;

	// - - - - Button and listbox event handlers - - - -

	METHOD("onButtonNewSave") {
		params [P_THISOBJECT];

		// Bail if game mode is not initialized (although the button should be disabled, right?)
		if(!CALLM0(gGameManager, "isGameModeInitialized")) exitWith {};

		// Send request to server
		CALLM2(gGameManagerServer, "postMethodAsync", "clientSaveGame", [clientOwner]);
	} ENDMETHOD;

	METHOD("onButtonOverwriteSavedGame") {
		params [P_THISOBJECT];
		pr _index = T_CALLM0("getSelectedSavedGameIndex");
		if (_index == -1) exitWith {};

		pr _selRecordData = T_GETV("recordData") select _index;
		_selRecordData params ["_recordName", "_header", "_errors"];
		OOP_INFO_1("Sending request to overwrite saved game: %1", _recordName);
		pr _args = [clientOwner, _recordName];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientOverwriteSavedGame", _args);
	} ENDMETHOD;

	METHOD("onButtonLoadSave") {
		params [P_THISOBJECT];
		pr _args = ["Load this saved game?",
			111, {systemChat "You clicked yes"},
			222, {systemChat "You clicked no"}];
		NEW("DialogConfirmAction", _args);
	} ENDMETHOD;

	METHOD("onButtonDeleteSavedGame") {
		params [P_THISOBJECT];
		pr _index = T_CALLM0("getSelectedSavedGameIndex");
		if (_index == -1) exitWith {};

		pr _selRecordData = T_GETV("recordData") select _index;
		_selRecordData params ["_recordName", "_header", "_errors"];
		OOP_INFO_1("Sending request to delete saved game: %1", _recordName);
		pr _args = [clientOwner, _recordName];
		CALLM2(gGameManagerServer, "postMethodAsync", "clientDeleteSavedGame", _args);
	} ENDMETHOD;

	METHOD("onListboxSelChanged") {
		params [P_THISOBJECT];
		pr _index = T_CALLM0("getSelectedSavedGameIndex");

		if (_index == -1) exitWith {};
		pr _selRecordData = T_GETV("recordData") select _index;
		_selRecordData params ["_recordName", "_header", "_errors"];

		// Format text
		pr _endl = toString [13, 10];
		pr _text = "";
		_text = _text + (format ["Campaign name: %1", GETV(_header, "campaignName")]);
		_text = _text + (format [", Map: %1", GETV(_header, "worldName")]);
		_text = _text + _endl;
		_text = _text + (format ["Version: %1", GETV(_header, "missionVersion")]);
		_text = _text + (format [", Save count: %1", GETV(_header, "saveID") + 1]);

		pr _staticSaveData = T_CALLM1("findControl", "TAB_SAVE_STATIC_SAVE_DATA");
		_staticSaveData ctrlSetText _text;
	} ENDMETHOD;

ENDCLASS;