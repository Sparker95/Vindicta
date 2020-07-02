#include "defineCommon.inc"

/*
	Author: Jeroen Notenbomer

	Description:
	Gets array of seats with there index and a propper name 

	Parameter(s):
		Object - vehicle with seats

	Returns:
		Array - array of turretId and names [[-1],["Driver"]]
		
	Usage: object call JN_fnc_common_vehicle_getSeatNames;
	
*/

params["_vehicle"];
pr _turretsArrayName = [typeof _vehicle, true] call BIS_fnc_allTurrets;
pr _turretCfgs = ([_vehicle] call BIS_fnc_getTurrets);
if(count _turretsArrayName != count _turretCfgs)then{	_turretsArrayName = [[-1]] + _turretsArrayName;};
pr _turrets = [];
pr _names = [];
{
	_x params ["_cfgTurret"];
	pr _arrayName = (_turretsArrayName select _forEachIndex);
	pr "_name";
	if(_arrayName isEqualTo [-1])then{
		_name = ["Driver","Pilot"] select(_vehicle isKindOf "Helicopter");
	}else{
		_name = getText(_cfgTurret >>  "gunnerName");
	};
	pr _magazineArray = getArray (_cfgTurret >> "magazines");
	
	_turrets pushBack _arrayName;
	_names pushBack _name;
} forEach _turretCfgs;

[_turrets,_names];