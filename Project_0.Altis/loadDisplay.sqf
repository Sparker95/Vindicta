if (!hasInterface) exitWith {};

//diag_log [">>> testLoadDisplay %1", _this];

params ["_display"];

/*
// Old loading screen code which resizes everything
 _ctrl = _display ctrlCreate ["RscText", -1]; // 52, 63 
 _ctrl ctrlSetPosition [0.2 + random 0.3, 0.2 + random 0.3, 0.8, 0.3]; 
 _ctrl ctrlSetText (format ["Display IDD: %1 %2", ctrlIDD _display, diag_ticktime]);
 _ctrl ctrlSetFontHeight 0.1 + random 0.5;
 private _symbols = ["!", "=", "-", "$", "@", "!", "&", "/", "\", "*", ".", ",", ".", "%"];
 private _vindicta = "VINDICTA";
 private _str = "";
 for "_j" from 0 to 2 do {
 	private _i = 0;
	while {_i < (count _vindicta)} do {
		if (random 10 < 3) then {
			_str = _str + (selectrandom _symbols);
		} else {
			_str = _str + (_vindicta select [_i, 1]);
			_i = _i + 1;
		};
	};
	_str = _str + " ";
 };
 _ctrl ctrlSetBackgroundColor [0, 0, 0, 0.8];
 _ctrl ctrlSetTextColor [0.9, 0.1, 0, 1];
 _ctrl ctrlSetText _str;
 _ctrl ctrlCommit 0;
 

 {
	 //ctrlDelete _x;
	 //_x ctrlSetBackgroundColor [0, 0.5, 0, 0.5];
	 private _pos = ctrlPosition _x;
	 _pos params ["_xpos", "_ypos", "_w", "_h"];
	 _x ctrlSetPosition [_xpos + (random 0.1) - (random 0.5), _ypos + (random 0.1) - (random 0.5), _w + (random 0.05), _h + (random 0.05)];
	 if ((random 10 < 5)) then {
		 private _t = ctrlText _x;
		 //if ((_t find "png") == -1 && (_t find "jpg") == -1 && (_t find "paa") == -1 && (_t find "\") == -1) then {
		 	//_x ctrlSetText "< VINDICTA >";
			_x ctrlSetTextColor [1, 1, 1, 1];
			_x ctrlSetBackgroundColor [0.4, 0, 0, 0.6];
		 //};
	 };
	 _x ctrlCommit 0;
 } forEach (allControls _display);
 */

{
	ctrlDelete _x;
} forEach (allControls _display);

_display ctrlCreate ["LoadingScreenGroup", -1];

// Author list
private _ctrl = _display displayCtrl 12366;
private _names = ["Sparker", "BillW", "Jeroen Not", "Marvis", "Sen", "Dusty", "Sebastian"];
private _text = "By ";
{
	_text = _text + _x;
	if (_foreachindex < ((count _names) - 1)) then {
		_text = _text + ", ";
	};
} forEach (_names call BIS_fnc_arrayShuffle);
_ctrl ctrlSetText _text;

// Special msg for Marvis
 if (profileName == "Marvis") then {
	private _ctrl = _display displayCtrl 6654;
	_ctrl ctrlSetText "Marvis, make a nice loading screen for us some day plz :3";
 };

 // Game title and version
 private _ctrl = _display displayCtrl 6644;
 private _versionStr = call misc_fnc_getVersion;
 private _text = format ["Vindicta v%1", _versionStr];