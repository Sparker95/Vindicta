#include "defineCommon.inc"

// Must be executed on the server to prevent all the duplication exploits!

if (!isServer) exitWith {
	diag_log "arsenal_cargoToArsenal: error: must be executed on the server";
};

params["_objectFrom","_objectTo"];

pr _array = _objectFrom call jn_fnc_arsenal_cargoToArray;

if(_objectFrom in allPlayers) exitWith {
	[format["PLAYERINVBUG: cargoToArsenal _this:%1", _this]] remoteExecCall ["diag_log", 0, false];
	pr _msg = format["%1 just avoided the inventory clear bug (cargoToArsenal), please send your server .rpt to the developers so we can fix it!", name _objectFrom];
	[_msg] remoteExecCall ["hint", 0, false];
};

//clear cargo
clearMagazineCargoGlobal _objectFrom;
clearItemCargoGlobal _objectFrom;
clearweaponCargoGlobal _objectFrom;
clearbackpackCargoGlobal _objectFrom;

OOP_INFO_1("Adding array of items: %1", _array);

[_objectTo,_array] call jn_fnc_arsenal_arrayToArsenal;