#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\common.h"

#define _setv setVariable
#define _getv getVariable

// Must be called on a control of class derived from MUI_BUTTON_TXT_CHECKBOX_LIKE
// In fact it calls it itself in its onload event

params ["_ctrlStatic"];

OOP_INFO_1("CHECKBOX: INIT: %1", ctrlClassName _ctrlStatic);

// Create a dummy button right over it
private _ctrlButton = (ctrlParent _ctrlStatic) ctrlCreate ["MUI_BUTTON_DUMMY", -1];
_ctrlButton ctrlSetPosition (ctrlPosition _ctrlStatic);
_ctrlButton ctrlCommit 0;

// Set tag so that we can find it with findControl
private _buttonClassName = (ctrlClassName _ctrlStatic) + "_DUMMY_BUTTON";
_ctrlButton setVariable ["__tag", _buttonClassName];
OOP_INFO_2("Created dummy button: %1 %2", _ctrlButton, _buttonClassName);

[_ctrlButton, false, false] call _fnc_setState;

// test
_ctrlButton ctrlSetBackgroundColor [1, 0, 0, 0.4];

// Link the controls together
_ctrlButton _setv ["_static", _ctrlStatic];
_ctrlStatic _setv ["_button", _ctrlButton];

// Add event handlers
_ctrlButton ctrlAddEventHandler ["MouseEnter", {
	[_this select 0, 'enter'] call ui_fnc_buttonCheckboxEvent;
}];
_ctrlButton ctrlAddEventHandler ["MouseExit", {
	[_this select 0, 'exit'] call ui_fnc_buttonCheckboxEvent;
}];
_ctrlButton ctrlAddEventHandler ["ButtonDown", {
	[_this select 0, 'buttonClick'] call ui_fnc_buttonCheckboxEvent;
}];