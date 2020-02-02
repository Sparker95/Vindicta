#include "common.hpp"

//Slowly starts to spawn in civilians in the area

params [["_module",objnull,[objnull]]];

//check if module is valide
if(isnull _module)exitWith{};

_module setVariable ["#active",true];

//block sub-sequent executions
if (_module getVariable ["#running",false]) exitWith {};
_module setVariable ["#running",true];


_spawnPoints = _module getVariable ["#modulesUnit",[]];

_module spawn{

	scriptName "Civilian Presence";

	private _module = _this;

	private _units = _module getVariable ["#units",[]];
	private _maxUnits = _module getVariable ["#unitCount",0];
	private _active = false;

	
	while{
		_active = _module getVariable ["#active",false];
		_units = _units select {!isNull _x && {alive _x}};
		(_active && _maxUnits > 0) || (!_active && count _units > 0)
	}do{
		// Let's do it unscheduled
		isNil {
			if (_active) then{
				//spawn in units when module is active and total number is not reached.
				if (count _units < _maxUnits) then{
					private _unit = _module call CivPresence_fnc_createUnit;
					if (!isNull _unit) then {_units pushBack _unit};
				};
			}else{
				//slowly removes units that are not in view of players
				private _unit = selectRandom _units;
				private _deleted = ["deleteUnit",[_module,_unit]] call bis_fnc_moduleCivilianPresence;
				if (_deleted) then
				{
					_units = _units - [_unit];
				};
			};
			//compact & store units array
			_units = _units select {!isNull _x && {alive _x}};
			_module setVariable ["#units",_units];
		};

		sleep 1;
	};
};


//release module so it can be used again
_module setVariable ["#running",false];

//run in console to see the waypoints and plans of AI
/*
	private _paramsDraw3D = missionNamespace getVariable ["bis_fnc_moduleCivilianPresence_paramsDraw3D",[]];
	private _handle = addMissionEventHandler ["Draw3D",{["debug"] call bis_fnc_cp_debug;}];
	_paramsDraw3D set [_handle,_module];
	bis_fnc_moduleCivilianPresence_paramsDraw3D = _paramsDraw3D;
*/