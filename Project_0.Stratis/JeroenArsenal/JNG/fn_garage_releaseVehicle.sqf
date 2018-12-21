#include "defineCommon.inc"

if(!isserver)exitWith{};

params["_data","_index","_object"];

pr _vehicleLists = _object getVariable "jng_vehicleLists";
pr _vehicleList = (_vehicleLists select _index);

pr _name = _data select 0;
_data set [1,""];//set beingChanged to non so others can edit it

{
	pr _name2 = _x select 0;
	if(_name2 isEqualTo _name)exitWith{
		_vehicleList set [_foreachindex,_data];
	};
} forEach _vehicleList;

_vehicleLists set [_index,_vehicleList];
_object setVariable ["jng_vehicleLists", _vehicleLists];

//update all clients that are looking in the garage
["updateVehicle",[_data,_index]] remoteExecCall ["jn_fnc_garage",missionnamespace getVariable ["jng_playersInGarage",[]]];
