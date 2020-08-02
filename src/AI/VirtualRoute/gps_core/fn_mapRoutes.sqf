#include "macros.h"
/**
  @Author : [Utopia] Amaury
  @Creation : 1/02/17
  @Modified : 22/10/17
  @Description : generate the road graph and assign connections to roads.
  @Return : Nothing
**/
scriptName "gps_virtual_mapping";

["<<< MapRoutes init >>>"] call gps_core_fnc_log;
_start = diag_tickTime;

["getting roads ..."] call gps_core_fnc_log;
gps_allRoads = [] call gps_core_fnc_getAllRoads;
["done in " + str round (diag_tickTime - _start)] call gps_core_fnc_log;

private _gps_allRoadsWithInter = [];

gps_allCrossRoadsWithWeight = ["gps_allCrossRoadsWithWeight"] call misc_fnc_hashTable_create;
gps_roadsWithConnected =  ["gps_roadsWithConnected"] call misc_fnc_hashTable_create;


["mapping road intersect ..."] call gps_core_fnc_log;
_ri_start = diag_tickTime;

// TODO: road networks for disconnected islands, add port and air nodes?
gps_blacklistRoads = gps_allRoads select { count (roadsConnectedTo _x) == 0 };

// Still searching an efficient way to detect overlapping roads connection
_gps_allRoadsWithInter = gps_allRoads apply {
    private _road = _x;
    // Some values returned from roadsConnectedTo are not actually roads for some reason (e.g. mounds)
    private _connected = roadsConnectedTo _road;

    if (count _connected > 1) then 
    {
        private _near = getPosATL _road nearRoads 15;
        {
            private _otherConnected = count roadsConnectedTo _x;
            if(_otherConnected > 0 && _otherConnected < 3) then 
            {
                _rID = str _x;
                _connected pushBackUnique _x;
                if([gps_roadsWithConnected, _rID] call misc_fnc_hashTable_exists) then {
                    ([gps_roadsWithConnected, _rID] call misc_fnc_hashTable_find) pushBack _road;
                } else {
                    [gps_roadsWithConnected, _rID, [_road]] call misc_fnc_hashTable_set;
                };
            };
        } foreach ((_near - _connected) - [_road]);
    };

    _currentConnected = [gps_roadsWithConnected, str _road] call misc_fnc_hashTable_find;
    if(isNil "_currentConnected") then {
        [gps_roadsWithConnected, str _road, _connected] call misc_fnc_hashTable_set;
    } else {
        _currentConnected append _connected;
    };
    [_road, _connected]
};

["done in " + str round (diag_tickTime - _ri_start)] call gps_core_fnc_log;
["mapping node values ..."] call gps_core_fnc_log;
_nv_start = diag_tickTime;

{
    _connected = [gps_roadsWithConnected,str (_x select 0)] call misc_fnc_hashTable_find;
    if (count _connected > 2) then {
        _x call gps_core_fnc_mapNodeValues;
    };
    false
} count _gps_allRoadsWithInter;

["done in " + str round (diag_tickTime - _nv_start)] call gps_core_fnc_log;
[format ["Maproutes init done in %1s",round (diag_tickTime - _start)]] call gps_core_fnc_log;

gps_core_init_done = true;
[missionNameSpace,"gps_core_loaded",[]] call BIS_fnc_callScriptedEventHandler;