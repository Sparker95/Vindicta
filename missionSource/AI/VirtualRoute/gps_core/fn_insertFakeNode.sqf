#include "macros.h"
/**
  @Author : [Utopia] Amaury
  @Creation : ??
  @Modified : 23/10/17
  @Description : insert fake node on the path
  TODO : delete fake nodes later
  @Return : NOTHING
**/
params [
	["_road",objNull,[objNull]]
];

if (count ([_road] call gps_core_fnc_roadsConnectedTo) > 2) exitWith {}; //already a node

[gps_fakeNodes,str _road,_road] call misc_fnc_hashTable_set;

_nodes = (allVariables gps_fakeNodes) apply {gps_fakeNodes getVariable _x};

_res = [_road,[_road] call gps_core_fnc_roadsConnectedTo,_nodes] call gps_core_fnc_mapNodeValues;

{
	[_x select 0,[_x select 0] call gps_core_fnc_roadsConnectedTo,_nodes] call gps_core_fnc_mapNodeValues;
}foreach _res;