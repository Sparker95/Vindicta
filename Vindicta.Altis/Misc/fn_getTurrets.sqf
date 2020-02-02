/*
	Function: misc_fnc_getTurrets

	Author:
		Karel Moricky, optimised by Killzone_Kid
		Modified by Sparker to return different turret types like copilot turret or passenger turrets.

	Description:
		Return vehicle turrets

	Parameter(s): _veh, _isCopilot, _dontCreateAI

	Returns:
		ARRAY of CONFIGs or ARRAYs
*/

params ["_veh", "_isCopilot", "_dontCreateAI"];

if (_veh isEqualType objNull) then {_veh = typeOf _veh};

private _vehConfig = configFile >> "CfgVehicles" >> _veh;

private _vehTurretsPath = [];
private _path = [];

private _fnc_getTurretsPath =
{
	private _index = 0;
	{
		_path append [_index];
		if((getNumber (_x >> "dontCreateAI") == _dontCreateAI) && (getNumber (_x >> "isCopilot") == _isCopilot)) then
		{
			_vehTurretsPath pushBack +_path;
		};
		_index = _index + 1;

		if (isClass (_x >> "Turrets")) then
		{
			_x call _fnc_getTurretsPath;
			_path deleteAt (count _path - 1);
		};
	}
	forEach ("true" configClasses (_this >> "Turrets"));
};

_vehConfig call _fnc_getTurretsPath;
_vehTurretsPath
