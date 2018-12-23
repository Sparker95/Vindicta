#include "defineCommon.inc"

params[["_name","",[""]],["_index",-1,[1]],["_locked",-1,[1]],"_object"];

pr _vehicleLists = _object getVariable "jng_vehicleLists";
pr _vehicleList = (_vehicleLists select _index);

{
	pr _data  = _x;
	pr _name2 = _x select 0;
	if(_name2 isEqualTo _name)exitWith{
		_data set [2,_locked];
		_vehicleList set [_foreachindex,_data];
	};
} forEach _vehicleList;

_vehicleLists set [_index,_vehicleList];
_object setVariable ["jng_vehicleLists", _vehicleLists];

//update all clients that are looking in the garage
["updateVehicleSingleData",[_name,_index,nil,_locked]] remoteExecCall ["jn_fnc_garage",missionnamespace getVariable ["jng_playersInGarage",[]]];
