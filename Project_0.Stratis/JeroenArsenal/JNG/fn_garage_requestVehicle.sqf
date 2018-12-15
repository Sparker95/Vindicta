//#define DEBUG_SYNCHRONOUS
//#define DEBUG_MODE_FULL
#include "script_component.hpp"
if(!isserver)exitWith{};

params["_name","_index","_namePlayer","_uid","_id"];

with missionNamespace do{
	_array = jng_vehicleList select _index;

	private _activePlayers = [];
	{
	    TRACE_3("activePlayers", _activePlayers, _x, name _x);
	    _activePlayers pushBack (name _x); false;
	} count (allPlayers - entities "HeadlessClient_F");

	{
		_data = _x;
		_data params ["_name2", "_beingChanged2"];
		_message = false;
        TRACE_2("Is that vehicle", _name2, _name);
		if(_name2 isEqualTo _name)exitWith{
    	    TRACE_3("Is used by other players", _beingChanged2, _activePlayers, _namePlayer);
			if(!(_beingChanged2 in _activePlayers) || _beingChanged2 isEqualTo _namePlayer)then{//check if someone is already changing this vehicle
				_locked = _data select 2;
    	        TRACE_3("lock check", _locked, _uid, getPlayerUID slowhand );
				if(_locked isEqualTo "" || {_locked isEqualTo _uid} || {getPlayerUID slowhand isEqualTo _uid})then{//check if vehicle is unlocked or locked by requesting person
					_message = true;

					//update datalist
					_data set [1,_namePlayer];
					_array set [_foreachindex,_data];
					jng_vehicleList set [_index,_array];
					//update all clients that are looking in the garage
					LOG_2("Vehicle [%1] is viewed by [%2]",_name,_namePlayer);
					["updateVehicleSingleData",[_name,_index,_namePlayer,nil]] remoteExecCall ["jn_fnc_garage",server getVariable ["jng_playersInGarage",[]]];
				};
			};
			//tell client he can take vehicle
			LOG_1("Vehicle request to approve: %1",_message);
			[_message] remoteExecCall ["jn_fnc_garage_requestVehicleMessage",[_id]];
		};
	} forEach _array;
};
