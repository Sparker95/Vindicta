#include "common.h"

if (!hasInterface) exitWith {};

diag_log format [">>> testLoadDisplay %1", _this];

params ["_display"];

{
	ctrlDelete _x;
} forEach (allControls _display);

uiNamespace setVariable ['vin_loadingScreen', _display];

_display ctrlCreate ["LoadingScreenGroup", -1];

// version number
private _ctrl = _display displayCtrl 64599;
if (isNil "misc_fnc_getVersion") then { // Compile the function if it's not there yet
	 misc_fnc_getVersion = COMPILE_COMMON("Misc\fn_getVersion.sqf");
};

private _versionStr = 0 call misc_fnc_getVersion;
if (! isNil "_versionStr") then {
	private _text = format ["v%1", _versionStr];
	_ctrl ctrlSetText _text;
	_ctrl ctrlCommit 0;
};

private _title = uiNamespace getVariable ['vin_loadingScreenTitle', ''];
(_display displayCtrl 666) ctrlSetText _title;
(_display displayCtrl 666) ctrlCommit 0;

private _subtitle = uiNamespace getVariable ['vin_loadingScreenSubtitle', ''];
(_display displayCtrl 667) ctrlSetText _subtitle;
(_display displayCtrl 667) ctrlCommit 0;

private _subprogress = uiNamespace getVariable ['vin_loadingScreenSubprogress', 0];
(_display displayCtrl 668) progressSetPosition _subprogress;
(_display displayCtrl 668) ctrlCommit 0;
