#include "defineCommon.hpp"

/*
	Author: Jeroen Notenbomer

	Description:
	Start a loop that constanly checks if the player is looking at a valid target

	Parameter(s):
	none

	Returns:
	none
	
*/

#define UPDATE_INTERVAL 0.5; // seconds

if(!hasinterface)exitWith{};

//add loop that checks if you are looking at something
private _spawnID = missionNamespace getVariable ["p0_interact_spawnID",scriptNull];
terminate _spawnID;
_spawnID = [] spawn {
	while{true}do{
		private _obj = cursorTarget;
		if(!isnull _obj)then{
			private  _type = _obj getVariable ["p0_cursorTarget",CURSORTARGET_INVALID];
			if(_type == CURSORTARGET_INVALID)exitWith{hint "wrong obj"};
			if(_type == CURSORTARGET_CIVILIAN)exitWith{
				_obj call Dialog_fnc_interact_civilian;
			};

		}else{

		};
		sleep UPDATE_INTERVAL;
	};
};
missionNamespace setVariable ["p0_interact_spawnID", _spawnID];


