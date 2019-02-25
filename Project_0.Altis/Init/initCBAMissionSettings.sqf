#include "..\modCompatBools.sqf"

// CHECKBOX --- extra argument: default value
["Test_Setting_1", "CHECKBOX", ["-test checkbox-", "-tooltip-"], "My Category", true] call cba_settings_fnc_init;

// LIST --- extra arguments: [_values, _valueTitles, _defaultIndex]
["Test_Setting_2", "LIST",     ["-test list-",     "-tooltip-"], "My Category", [[1,0], ["enabled","disabled"], 1]] call cba_settings_fnc_init;

// SLIDER --- extra arguments: [_min, _max, _default, _trailingDecimals]
["Test_Setting_3", "SLIDER",   ["-test slider-",   "-tooltip-"], "My Category", [0, 10, 5, 0]] call cba_settings_fnc_init;

// COLOR PICKER --- extra argument: _color
["Test_Setting_4", "COLOR",    ["-test color-",    "-tooltip-"], "My Category", [1,1,0]] call cba_settings_fnc_init;

// EDITBOX --- extra argument: default value
["Test_Setting_5", "EDITBOX", ["-test editbox-", "-tooltip-"], "My Category", "defaultValue"] call cba_settings_fnc_init;
