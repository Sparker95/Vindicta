#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\common.h"

// Code which does processing of events of our custom checkbox-like button
params ["_ctrlButton", "_event"];

OOP_INFO_2("CHECKBOX: EVENT: %1", ctrlClassName _ctrlButton, _event);

#define _setv setVariable
#define _getv getVariable

private _checked = _ctrlButton _getv ["_checked", false];
private _mouseOver = _ctrlButton _getv ["_mouseOver", false];

switch (_event) do {
	
	case "enter": {
		OOP_INFO_0("  CHECKBOX: ENTER");
		[_ctrlButton, _checked, true] call ui_fnc_buttonCheckboxSetState;
	};

	case "exit": {
		OOP_INFO_0("  CHECKBOX: EXIT");
		[_ctrlButton, _checked, false] call ui_fnc_buttonCheckboxSetState;
	};

	case "buttonClick": {
		OOP_INFO_0("  CHECKBOX: CLICK");
		[_ctrlButton, !_checked, _mouseOver] call ui_fnc_buttonCheckboxSetState;
	};

	default {
		OOP_INFO_1("  CHECKBOX: ERROR: UNKNOWN EVENT: %1", _event);
		diag_log format ["buttonCheckboxEvent: Error: unknown event: %1", _event];
	};
};