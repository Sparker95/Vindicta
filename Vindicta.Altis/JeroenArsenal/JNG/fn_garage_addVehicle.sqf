#include "defineCommon.inc"

if(!isserver)exitWith{};

params ["_data","_index","_object"];

pr _name = _data select 0;
pr _vehicleLists = _object getVariable "jng_vehicleLists";
pr _vehicleList = _vehicleLists select _index;

pr _nr = 1;
pr _newName = (_name + " nr:"+ str _nr);

//check if name is already in the list
pr _nameExist = {
	_return = false;
	{
		_nameCheck = _x select 0;
		if(_newName isEqualTo _nameCheck)exitWith{
			_return = true;
		};
	} forEach _vehicleList;
	_return
};

//find a name that doesnt exist yet
while {call _nameExist} do {
	 _nr = _nr + 1;
	 _newName = (_name + " nr:" + str _nr);
};

//update name and save
_data set [0, _newName];

_vehicleList pushback _data;
_vehicleLists set [_index,_vehicleList];
_object setVariable ["jng_vehicleLists",_vehicleLists];


//update all clients that are looking in the garage
pr _clients = missionnamespace getVariable ["jng_playersInGarage",[]];
if!(_clients isEqualTo [])then{
	["addVehicle",[_data,_index]] remoteExecCall ["jn_fnc_garage",_clients];
};
