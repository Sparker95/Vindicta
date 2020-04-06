if (!hasInterface) exitWith {};

//diag_log [">>> testLoadDisplay %1", _this];

params ["_display"];

{
	ctrlDelete _x;
} forEach (allControls _display);

_display ctrlCreate ["LoadingScreenGroup", -1];

 // version number
 private _ctrl = _display displayCtrl 64599;
 if (isNil "misc_fnc_getVersion") then { // Compile the function if it's not there yet
	 misc_fnc_getVersion = compile preprocessFileLineNumbers "Misc\fn_getVersion.sqf";
 };
 private _versionStr = 0 call misc_fnc_getVersion;
 if (! isNil "_versionStr") then {
	private _text = format ["v%1", _versionStr];
	_ctrl ctrlSetText _text;
 };
 

 