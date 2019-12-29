#include "defineCommon.inc"
/*
	Author: Jeroen Notenbomer

	Description:
	Adds vehicle to garage with checking distance

	Parameter(s):
	Object

	Returns:
	
	Usage: object call jn_fnc_garage_garageVehicle;
	
*/

#include "defineCommon.inc"

params [ ["_vehicle",objNull,[objNull]] ,["_object",objNull,[objNull]]];

//incase you are looking to attached item
if !(isnull (attachedto _vehicle))then{_vehicle = attachedto _vehicle};

//close if it couldnt save
_message = [_vehicle,_object] call jn_fnc_garage_canGarageVehicle;
if!(_message isEqualTo "")exitWith {hint _message};

//save it on server
pr _data = _vehicle call jn_fnc_garage_getVehicleData;
pr _index = _vehicle call jn_fnc_common_vehicle_getVehicleType;
[_data,_index,_object] remoteExecCall ["jn_fnc_garage_addVehicle",2];

//delete attach weapon
pr _attachItems = [];
{
	pr _type = (_x getVariable ["jnl_cargo",[-1,0]]) select 0;
	if(_type == 0)then{
		_x hideObject true;
		detach _x;
		deleteVehicle _x;
	};
} forEach attachedObjects _vehicle;

deleteVehicle _vehicle;

//set message it was saved
SPLIT_SAVE
hint (_name + " stored in garage");
