#include "defineCommon.inc"

if(!isserver)exitWith{};

params["_name","_index","_namePlayer","_uid","_id","_object"];

pr _vehicleLists = _object getVariable "jng_vehicleLists";
pr _vehicleList = (_vehicleLists select _index);
diag_log "test1";
diag_log _vehicleList;

pr _activePlayers = [];
{
	_activePlayers pushBack (name _x); false;
} count (allPlayers - entities "HeadlessClient_F");


pr _message = false;
{//forEach _array
	pr _data = _x;
	_data params ["_name2", "_beingChanged2"];
	
	if(_name2 isEqualTo _name)exitWith{
		if(!(_beingChanged2 in _activePlayers) || _beingChanged2 isEqualTo _namePlayer)then{//check if someone is already changing this vehicle
			_locked = _data select 2;
			if(_locked isEqualTo "" || {_locked isEqualTo _uid} || {getPlayerUID slowhand isEqualTo _uid})then{//check if vehicle is unlocked or locked by requesting person
				_message = true;

				//update datalist
				_data set [1,_namePlayer];
				_vehicleList set [_foreachindex,_data];
				_vehicleLists set [_index,_vehicleList];
				_object setVariable ["jng_vehicleLists",_vehicleLists];
				//update all clients that are looking in the garage
				["updateVehicleSingleData",[_name,_index,_namePlayer,nil]] remoteExecCall ["jn_fnc_garage",missionnamespace getVariable ["jng_playersInGarage",[]]];
			};
		};
		
		
	};
} forEach _vehicleList;

//tell client he can or cant take vehicle
[_message] remoteExecCall ["jn_fnc_garage_requestVehicleMessage",[_id]];

