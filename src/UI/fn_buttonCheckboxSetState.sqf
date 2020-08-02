#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#define OFSTREAM_FILE "UI.rpt"
#include "..\common.h"
#include "Resources\UIProfileColors.h"

#define _setv setVariable
#define _getv getVariable

params ["_ctrlButton", "_checked", "_mouseOver"];

_ctrlButton _setv ["_checked", _checked];
_ctrlButton _setv ["_mouseOver", _mouseOver];

OOP_INFO_3("BUTTON CHECKBOX SET STATE: %1, checked: %2, mouseOver: %3", ctrlClassName _ctrlButton, _checked, _mouseOver);

private _ctrlStatic = _ctrlButton getVariable "_static";

private _colorBackground = 0;
private _colorText = 0;
private _font = "PuristaLight";

if (_checked) then {
	if (_mouseOver) then {
		_colorBackground = MUIC_COLOR_MISSION_HOVER;
		_colorText = MUIC_COLOR_BLACK;
		_font = "PuristaSemibold";
	} else {
		_colorBackground = MUIC_COLOR_MISSION;
		_colorText = MUIC_COLOR_BLACK;
		_font = "PuristaSemibold";
	};
} else {
	if (_mouseOver) then {
		_colorBackground = MUIC_COLOR_WHITE;
		_colorText = MUIC_COLOR_BLACK;
	} else {
		_colorBackground = MUIC_COLOR_BLACK;
		_colorText = MUIC_COLOR_WHITE;
	};
};

OOP_INFO_2(" Setting BG color: %1, text color: %2", _colorBackground, _colorText);
_ctrlStatic ctrlSetBackgroundColor _colorBackground;
_ctrlStatic ctrlSetTextColor _colorText;
_ctrlStatic ctrlSetFont _font;