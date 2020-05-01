#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"
#include "..\..\Location\Location.hpp"

#define pr private

// Offset between button's bottom and group's edge, also between text's bottom and button
#define VERT_GAP 0.02
#define HORIZONTAL_GAP 0.005
#define BUTTON_HEIGHT 0.04

/*
Class: DialogSingleTabWithButtons

A simple dialog which has a multi line text field and variable amount of buttons at the bottom.
Can be used for simple things like popup messages.

Inherit from DialogOneTabButtons to implement functionality (opposed to typical way of inheriting from DialogTabBase).

Use methods setText, setContentSize, etc..., to configure the dialog appearence.

Call createButtons to create the buttons at the bottom of the text box

Override the onButtonClick method to implement custom button click handling.

You can also use getButtonControl to get the control handle of the button with the required ID (0, 1, 2, ... depending on the amount of created buttons)

Author: Sparker 29 October 2019
*/

#define OOP_CLASS_NAME DialogOneTabButtons
CLASS("DialogOneTabButtons", "DialogBase")

	VARIABLE("buttonTexts");

	METHOD(new)
		params [P_THISOBJECT];

		T_CALLM2("addTab", "TabTextWithButtons", "");

		T_CALLM1("enableMultiTab", false);

		T_SETV("buttonTexts", []);

		T_CALLM1("setCurrentTab", 0); // Will call the tab constructor

	ENDMETHOD;

	// Call this to set text of this dialog
	METHOD(setText)
		params [P_THISOBJECT, P_STRING("_text")];
		pr _tab = T_CALLM0("getCurrentTab");
		CALLM1(_tab, "setText", _text);
	ENDMETHOD;

	METHOD(createButtons)
		params [P_THISOBJECT, P_ARRAY("_buttonTexts")];

		OOP_INFO_1("CREATE BUTTONS: %1", _buttonTexts);

		pr _tab = T_CALLM0("getCurrentTab");
		CALLM1(_tab, "createButtons", _buttonTexts);

		// Resize the UI
		T_CALLM2("resize", T_GETV("contentW"), T_GETV("contentH"));
	ENDMETHOD;

	// Called when user clicks on button
	// Button ID is passed, 0 is leftmost button
	/* virtual */ METHOD(onButtonClick)
		params [P_THISOBJECT, P_NUMBER("_ID")];

		OOP_INFO_1("Button was clicked: %1", _ID);

		//DELETE(_thisObject);
	ENDMETHOD;

	// Returns button control with given ID
	METHOD(getButtonControl)
		params [P_THISOBJECT, P_NUMBER("_ID")];
		pr _tag = format ["TAG_BUTTON_%1", _ID];
		pr _tab = T_CALLM0("getCurrentTab");
		CALLM1(_tab, "findControl", _tag)
	ENDMETHOD;

	// Adds code which will be executed when button with given ID is pushed
	METHOD(addButtonClickHandler)
		params [P_THISOBJECT, P_NUMBER("_ID"), P_CODE("_code")];
		pr _ctrl = T_CALLM1("getButtonControl", _ID);
		if (! (isNull _ctrl)) then {
			_ctrl ctrlAddEventHandler ["buttonClick", _code];
		};
	ENDMETHOD;

ENDCLASS;

#define OOP_CLASS_NAME TabTextWithButtons
CLASS("TabTextWithButtons", "DialogTabBase")

	VARIABLE("nButtons");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_dialogObj")];

		pr _display = T_CALLM0("getDisplay");

		// Create group
		pr _group = _display ctrlCreate ["MUI_GROUP_ABS", -1];
		T_CALLM1("setControl", _group);

		// Create text
		pr _args = ["MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS", -1, _group, "TAG_TEXT"]; // "MUI_BG_TRANSPARENT_MULTILINE_ABS"
		pr _text = T_CALLM("createControl", _args);

		T_SETV("nButtons", 0);

	ENDMETHOD;

	METHOD(createButtons)
		params [P_THISOBJECT, P_ARRAY("_buttonTexts")];

		OOP_INFO_1("CREATE BUTTONS: %1", _buttonTexts);

		// Create buttons
		pr _nbuttons = count _buttonTexts;
		T_SETV("nButtons", _nbuttons);
		pr _group = T_CALLM0("getControl");
		OOP_INFO_1("  Group: %1", _group);
		{
			pr _tag = format ["TAG_BUTTON_%1", _foreachindex];
			pr _args = ["MUI_BUTTON_TXT_ABS", -1, _group, _tag];
			_button = T_CALLM("createControl", _args);
			OOP_INFO_1("  Created button: %1", _button);
			_button ctrlSetText _x;
			_button setVariable ["__buttonID", _foreachindex]; // We will get the ID at event handlers
			T_CALLM3("controlAddEventHandler", _tag, "buttonClick", "_onButton");
		} forEach _buttonTexts;

		// Buttons will be resized separately
	ENDMETHOD;

	METHOD(setText)
		params [P_THISOBJECT, P_STRING("_text"), P_BOOL_DEFAULT_TRUE("_fitTextHeight")];

		pr _ctrl = T_CALLM1("findControl", "TAG_TEXT");
		_ctrl ctrlSetText _text;

		if (_fitTextHeight) then {
			pr _textHeight = ctrlTextHeight _ctrl;
			pr _dlgobj = T_CALLM0("getDialogObject");
			CALLM0(_dlgobj, "getContentSize") params ["_width", "_height"];

			// Calculate height
			_height = _textHeight + 2*VERT_GAP + BUTTON_HEIGHT;
			CALLM2(_dlgobj, "setContentSize", _width, _height);
		};

	ENDMETHOD;

	/* override */ METHOD(resize)
		params [P_THISOBJECT, P_NUMBER("_width"), P_NUMBER("_height")];

		OOP_INFO_0("RESIZE");

		pr _buttonHeight = BUTTON_HEIGHT;

		pr _display = T_CALLM0("getDisplay");

		// Resize text
		pr _ctrl = T_CALLM1("findControl", "TAG_TEXT");
		pr _textHeight = _height - _buttonHeight - 2*VERT_GAP;
		_ctrl ctrlSetPosition [0, 0, _width, _textHeight];
		_ctrl ctrlCommit 0;

		// Resize buttons
		pr _nButtons = T_GETV("nButtons");
		for "_i" from 0 to (_nButtons - 1) do {
			pr _tag = format ["TAG_BUTTON_%1", _i];
			pr _ctrl = T_CALLM1("findControl", _tag);

			// simply fill window width with buttons
			pr _bwidth = (_width/_nButtons);
			pr _bheight = _buttonHeight;
			pr _bposy = _height - _bheight;
			pr _bposx = 0;
			if (_i > 0) then { _bposx = (_bwidth * _i); };
			if (_i == _nButtons - 1) then { _bposx = (_bwidth * _i) - 0.001; }; // - 0.001 for last button to hopefully fix protruding button

			/*
			// Calculate positions of buttons
			
			pr _bposxcenter = (_i+1) * (_width/(_nbuttons+1)); // Center of button
			#ifndef _SQF_VM
			// WTF we can't get text width for a button?? Ok we will create a static control instead :/
			// We will set its text, get its text width, then delete it
			// todo replace with https://community.bistudio.com/wiki/getTextWidth in 1.97
			pr _tempctrl = _display ctrlCreate ["MUI_BASE_ABS", -1];
			_tempctrl ctrlSetText (ctrlText _ctrl);
			OOP_INFO_2("  btn text: %1, width: %2", ctrlText _ctrl, ctrlTextWidth _tempctrl);
			pr _bwidth = 0.04 + ctrlTextWidth _tempctrl;
			ctrlDelete _tempctrl;
			#endif
			pr _bposx = _bposxcenter - 0.5*_bwidth;
			
			*/
			
			pr _posarray = [_bposx, _bposy, _bwidth, _bheight];
			OOP_INFO_2("Setting button %1 pos: %2", _i, _posarray);
			_ctrl ctrlSetPosition _posarray;
			_ctrl ctrlCommit 0;
		};

	ENDMETHOD;

	// private function, don't touch it
	// use dialog's onButtonClick instead
	METHOD(_onButton)
		params [P_THISOBJECT, "_ctrl"];

		// Get ID of the button
		pr _ID = _ctrl getVariable "__buttonID";

		// Call the dialog's function
		pr _dlgobj = T_CALLM0("getDialogObject");
		CALLM1(_dlgobj, "onButtonClick", _ID);
	ENDMETHOD;

ENDCLASS;