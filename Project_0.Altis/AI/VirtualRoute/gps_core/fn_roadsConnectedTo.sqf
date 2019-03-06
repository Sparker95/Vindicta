#include "macros.h"
/**
  @Author : [Utopia] Amaury
  @Creation : 1/02/17
  @Modified : 5/02/17
  @Description : get connected roads to a road
  @Return : OBJECT - road
**/

params [
	["_road",objNull,[objNull]]
];

[gps_roadsWithConnected,str _road] call misc_fnc_hashTable_find;