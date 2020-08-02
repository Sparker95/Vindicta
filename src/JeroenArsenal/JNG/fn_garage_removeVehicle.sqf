#include "defineCommon.inc"
if(!isserver)exitWith{};

params ["_name","_index","_object"];

pr _vehicleLists = _object getVariable "jng_vehicleLists";
pr _vehicleList = (_vehicleLists select _index);

{
	pr _data = _x;
	pr _name2 = _data select 0;
	if(_name isEqualTo _name2)exitWith{
		_vehicleList deleteAt _foreachindex;
	};
} forEach _vehicleList;


//update all clients that are looking in the garage
pr _clients = missionnamespace getVariable ["jng_playersInGarage",[]];
if!(_clients isEqualTo [])then{
	["removeVehicle",[_data,_index]] remoteExecCall ["jn_fnc_garage",_clients];
};


