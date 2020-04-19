#include "macros.h"
/**
	@Author : [Utopia] Amaury
	@Creation : 1/02/17
	@Modified : 23/10/17
	@Description :
	@Return : ARRAY - linked crossroads with weight
**/
params [
	 "_crossRoad",
	 "_linkedTo",
	 ["_exceptions",[],[[]]]
];

private _linkedCrossRoads = [];
private _crossRoad_isHighWay = [_crossRoad] call misc_fnc_isHighWay;

{
	private _currRoad = _x;
	private _segmentValue = 0;
	private _previous = _crossRoad;

	// faster than while {true}
	for "_i" from 0 to 1 step 0 do {
		_connected = [_currRoad] call gps_core_fnc_roadsConnectedTo;
		if (isNil "_connected") exitWith {}; // has this error on Tanoa , i don't know why
		_countConnected = count _connected;
		_segmentValue = _segmentValue + (_previous distance2D _currRoad);

		if(_countConnected > 2 || _currRoad in _exceptions || _countConnected isEqualTo 1) exitWith {  
			_currRoad_isHighWay = [_currRoad] call misc_fnc_isHighWay;
			if(_currRoad_isHighWay && _crossRoad_isHighWay) then {
				_segmentValue = (_segmentValue / 3);
			};
			_linkedCrossRoads pushBack [_currRoad,_segmentValue];
		};

		_old = _currRoad;
		_currRoad = (_connected select { !(_x isEqualTo _previous) }) param [0,_old];
		_previous = _old;
		if(_currRoad isEqualTo _old) exitWith {};
	};
	false // it's a count , we need to return a boolean , i use it because it's a little faster than foreach
} count _linkedTo;

[gps_allCrossRoadsWithWeight,str _crossRoad,_linkedCrossRoads] call misc_fnc_hashTable_set;

_linkedCrossRoads