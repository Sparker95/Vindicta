/*
Function: ui_fnc_createControlsFromConfig
Creates controls fron config

Parameters: _cfg, _idd

_cfg - Config entry that has Controls class
_idd - display ID to which controls will be added

Returns: nil

Author: Sparker 04.02.2019
*/

#define pr private

params [["_cfg", configNull, [configNull]], ["_idd", 0, [0]]];

// Gets number from config but can also return nil if it doesn't exist
_getNumber = {
	params [["_cfg", configNull, [configNull]]];
	//diag_log format ["Getting number: %1", _cfg];
	// If it doesn't exist return nil
	if (! (isNumber _cfg) && !(isText _cfg)) exitWith {
		//diag_log "Number doesn't exist!";
		nil
	};
	//diag_log format ["Retrieved number: %1", getNumber _cfg];
	// Otherwise return value
	getNumber _cfg
};

// Creates a single control from config
_createControlFromConfig = {
	params [["_cfg", configNull, [configNull]], ["_idd", 0, [0]]];

	// Get parent class
	_cfgParent = inheritsFrom (_cfg);
	if (isNull _cfgParent) exitWith {
		diag_log format ["[ui_fnc_createControlsFromConfig] Error: %1 has no parent class", _cfg];
	};

	// Create new control
	pr _parentName = configName _cfgParent;
	pr _idc = getNumber (_cfg >> "idc");
	pr _ctrl = (findDisplay _idd) ctrlCreate [_parentName, _idc];
	_ctrl setVariable ["__tag", configName _cfg];
	diag_log format ["[ui_fnc_createControlsFromConfig] Created control: %1", _ctrl];

	// Apply properties

	// Report unsupported properties
	pr _supportedProps = ["idc", "x", "y", "w", "h", "text", "enableSimulation", "sizeEx", "show", "colorBackground", "enable"];
	pr _props = (configProperties [_cfg, "true", false]) apply {configName _x};
	{
		if (! (_x in _supportedProps)) then {
			diag_log format ["[ui_fnc_createControlsFromConfig] Error: property %1 is not supported in %2", _x, _cfg];
		} else {
			switch (_x) do {
				case "text" : {
					_val = getText (_cfg >> _x);
					_ctrl ctrlSetText _val;
				};
				case "enableSimulation" : {
					_val = getText (_cfg >> _x);
					if (_val == "") exitWith {};
					_ctrl ctrlEnable _val;
				};
				case "sizeEx" : {
					_val = getNumber (_cfg >> _x);
					if (_val == 0) exitWith {};
					_ctrl ctrlSetFontHeight _val;
				};
				case "colorBackground" : {
					_val = getArray (_cfg >> _x);
					_ctrl ctrlSetBackgroundColor _val;
				};
				case "enable" : {
					_val = getNumber (_cfg >> _x);
					if (_val == 0) then { _ctrl ctrlEnable false; } else { _ctrl ctrlEnable true; }
				};
				case "show" : {
					_val = getNumber (_cfg >> _x);
					if (_val == 0) then { _ctrl ctrlShow false; } else { _ctrl ctrlShow true; }
				};

			};
		};
	} forEach _props;

	// x, y, w, h
	pr _xywh = ["x", "y", "w", "h"] apply {[_cfg >> _x] call _getNumber};
	if (({isNil "_x"} count _xywh) > 0) then {
		diag_log format ["[ui_fnc_createControlsFromConfig] Error: x,y,w,h is not defined for %1. Value: %2", _cfg, _xywh];
	} else {
		diag_log format ["[ui_fnc_createControlsFromConfig] Setting control position: %1", _xywh];
		_ctrl ctrlSetPosition _xywh;
	};

	// Commit control
	_ctrl ctrlCommit 0;
};

if (! isClass (_cfg >> "Controls")) then {
	diag_log format ["Creating control without subcontrols %1", _cfg];
	[_cfg, _idd] call _createControlFromConfig;
} else {
	// It might be a group box which must be created as well
	if (isNumber (_cfg >> "type")) then {
		diag_log format ["Creating control that has subcontrols %1", _cfg];
		[_cfg, _idd] call _createControlFromConfig;
	};

	// Call this function for all subcontrols
	// Todo actually group subcontrols must be created sifferently
	// Just do it later, we don't use group boxes now anyway :p
	{
		[_x, _idd] call ui_fnc_createControlsFromConfig;
	} forEach ("isClass _x" configClasses (_cfg >> "Controls"));
};

