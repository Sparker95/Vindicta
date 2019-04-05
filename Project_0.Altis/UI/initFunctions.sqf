#define COMPILEFUNC(path) compile preprocessFileLineNumbers path
ui_fnc_createControlsFromConfig = COMPILEFUNC("UI\fn_createControlsFromConfig.sqf");
fnc_UIUndercoverDebug = compile preprocessFileLineNumbers "UI\UndercoverUIDebug\UndercoverUIDebug.sqf";