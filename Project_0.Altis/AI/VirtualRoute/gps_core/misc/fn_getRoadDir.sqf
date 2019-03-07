#include "..\macros.h"
/**
	@Author : [Utopia] Amaury
	@Creation : ??/10/17
	@Modified : --
	@Description : get the road direction
	@Return : SCALAR
**/

params [
	["_road",objNull,[objNull]],
	["_otherRoad",objNull,[objNull]]
];

if !(isNull _otherRoad) exitWith {
	_road getDir _otherRoad
};

private _connectedRoads = roadsConnectedTo _road;

if(count _connectedRoads == 0) exitWith {0};
if(count _connectedRoads >= 1) then 
{
	_roadID = parseNumber str _road;
	_friendlyRoads = _connectedRoads select {(parseNumber str _x) in [_roadID + 1,_roadID - 1]};
	if (_friendlyRoads isEqualTo []) then {
		_friendlyRoads = _connectedRoads;
	};
	_road getDir (_friendlyRoads select 0);
};
