params [ ["_vehicle",objNull,[objNull]] ];

if (isNull _vehicle) exitWith {"You are not looking at a vehicle"};
if !(alive _vehicle) exitWith {"You cannot add destroyed vehicles to your garage"};
if ({isPlayer _x} count crew _vehicle > 0) exitWith {"In order to store vehicle, its crew must disembark."};

//check if its a vehicle
private _index = _vehicle call jn_fnc_garage_getVehicleIndex;
if (_index == -1) exitWith {"You are not looking at a vehicle"};

//check if vehicle is locked. If not, current player is considered as the valid user to store
_uid = getPlayerUID player; private _owner = _vehicle getVariable["vehOwner", _uid];
if!(_owner isEqualTo _uid)exitWith{"This is not my vehicle, I need to ask the owner to unlock it first"};

//max distance
if (_vehicle distance getMarkerPos guer_respawn > 50) exitWith {"Vehicle must be within 50m of the flag"};

//return
"";
