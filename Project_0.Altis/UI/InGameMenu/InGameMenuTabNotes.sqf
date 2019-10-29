#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Location\Location.hpp"

#define pr private

CLASS("InGameMenuTabNotes", "DialogTabBase")

	STATIC_VARIABLE("text");
	STATIC_VARIABLE("instance");

	METHOD("new") {
		params [P_THISOBJECT];
		
		SETSV("InGameMenuTabNotes", "instance", _thisObject);


		// Create the controls
		pr _displayParent = T_CALLM0("getDisplay");
		pr _group = _displayParent ctrlCreate ["TAB_NOTES", -1];
		T_CALLM1("setControl", _group);

		// Set previous text
		pr _text = GETSV("InGameMenuTabNotes", "text");
		pr _ctrl = T_CALLM1("findControl", "TAB_NOTES_EDIT");
		_ctrl ctrlSetText _text;

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		SETSV("InGameMenuTabNotes", "instance", nil);
	} ENDMETHOD;

	/*
	STATIC_METHOD("showServerResponse") {
		params [P_THISCLASS, P_STRING("_text")];
		// If this tab is already closed, just throw text into system chat
		if (isNil "gTabCommander") then {
			systemChat _text;
		} else {
			pr _thisObject = gTabCommander;
			pr _dialogObj = T_CALLM0("getDialogObject");
			CALLM1(_dialogObj, "setHintText", _text);
		};
	} ENDMETHOD;
	*/

	// Called before this tab is deleted but when controls still exist
	// Override for custom functionality
	/* virtual */ METHOD("beforeDelete") {
		params [P_THISOBJECT];

		// We want to save the text to restore it next time this tab is open
		pr _ctrl = T_CALLM1("findControl", "TAB_NOTES_EDIT");
		if (!isNull _ctrl) then {
			pr _text = ctrlText _ctrl;
			SETSV("InGameMenuTabNotes", "text", _text);
		};
	} ENDMETHOD;

	// Appends text to the currently open tab or to the static variable
	STATIC_METHOD("staticAppendText") {
		params [P_THISCLASS, P_STRING("_text")];

		pr _instance = GETSV("InGameMenuTabNotes", "instance");
		if (isNil "_instance") then {
			pr _textCurrent = GETSV("InGameMenuTabNotes", "text");
			SETSV("InGameMenuTabNotes", "text", _textCurrent + _text);
		} else {
			pr _thisObject = _instance;
			pr _ctrl = T_CALLM1("findControl", "TAB_NOTES_EDIT");
			pr _currentText = ctrlText _ctrl;
			_ctrl ctrlSetText (_currentText + _text);
		};
	} ENDMETHOD;

ENDCLASS;

if (isNil {GETSV("InGameMenuTabNotes", "text")}) then {
	SETSV("InGameMenuTabNotes", "text", "Here I will write notes... (Use Shift+Enter for a new line)");
};