#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"
#include "..\..\Location\Location.hpp"

#define pr private

#define OOP_CLASS_NAME InGameMenuTabNotes
CLASS("InGameMenuTabNotes", "DialogTabBase")

	STATIC_VARIABLE("text");

	METHOD(new)
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

	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		SETSV("InGameMenuTabNotes", "instance", nil);
	ENDMETHOD;

	// Called before this tab is deleted but when controls still exist
	// Override for custom functionality
	public override METHOD(beforeDelete)
		params [P_THISOBJECT];

		// We want to save the text to restore it next time this tab is open
		pr _ctrl = T_CALLM1("findControl", "TAB_NOTES_EDIT");
		if (!isNull _ctrl) then {
			pr _text = ctrlText _ctrl;
			SETSV("InGameMenuTabNotes", "text", _text);
			profileNamespace setVariable ["vin_notes", _text];
		};
	ENDMETHOD;

	// Appends text to the currently open tab or to the static variable
	public STATIC_METHOD(staticAppendText)
		params [P_THISCLASS, P_STRING("_text")];

		pr _instance = GETSV("InGameMenuTabNotes", "instance");
		if (isNil "_instance") then {
			pr _textCurrent = GETSV("InGameMenuTabNotes", "text");
			pr _textNew = _textCurrent + _text;
			SETSV("InGameMenuTabNotes", "text", _textNew);
			profileNamespace setVariable ["vin_notes", _textNew];
		} else {
			pr _thisObject = _instance;
			pr _ctrl = T_CALLM1("findControl", "TAB_NOTES_EDIT");
			pr _currentText = ctrlText _ctrl;
			_ctrl ctrlSetText (_currentText + _text);
		};
	ENDMETHOD;

ENDCLASS;

if (isNil {GETSV("InGameMenuTabNotes", "text")}) then {
	pr _textFromProfile = profileNamespace getVariable ["vin_notes", ""];
	if (_textFromProfile ==  "") then {
		_textFromProfile = "Here I will write notes... (Use Shift+Enter for a new line, Ctrl+C and Ctrl+V for copying text)";
	};
	SETSV("InGameMenuTabNotes", "text", _textFromProfile);
};