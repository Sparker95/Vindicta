#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\OOP_Light\OOP_Light.h"

#define _setv setVariable
#define _getv getVariable

params ["_ctrlButton", "_checked", "_mouseOver"];

_ctrlButton _setv ["_checked", _checked];
_ctrlButton _setv ["_mouseOver", _mouseOver];

private _ctrlStatic = _ctrlButton getVariable "_static";

private _colorBackground = 0;
private _colorText = 0;

if (_checked) then {
	_colorBackground = [1, 1, 1, 1];
	_colorText = [0, 0, 0, 1];
} else {
	if (_mouseOver) then {
		_colorBackground = [1, 1, 1, 1];
		_colorText = [0, 0, 0, 1];
	} else {
		_colorBackground = [0, 0, 0, 1];
		_colorText = [1, 1, 1, 1];
	};
};

OOP_INFO_2(" Setting BG color: %1, text color: %2", _colorBackground, _colorText);
_ctrlStatic ctrlSetBackgroundColor _colorBackground;
_ctrlStatic ctrlSetTextColor _colorText;