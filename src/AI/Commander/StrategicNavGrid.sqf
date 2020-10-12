#define OOP_DEBUG
//#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING

#define OFSTREAM_FILE "Commander.rpt"
#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\..\Location\Location.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\defineCommon.inc"
#include "..\..\Cluster\Cluster.hpp"
#include "..\..\Templates\Efficiency.hpp"
#include "..\Action\Action.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\parameterTags.hpp"
#include "..\..\Group\Group.hpp"
#include "..\..\Garrison\Garrison.hpp"
#include "..\..\Unit\Unit.hpp"
#include "..\targetStruct.hpp"
#include "..\Garrison\garrisonWorldStateProperties.hpp"
#include "..\Group\groupWorldStateProperties.hpp"
#include "LocationData.hpp"
#include "AICommander.hpp"
#include "..\..\MessageReceiver\MessageReceiver.hpp"
#include "..\..\Mutex\Mutex.hpp"
#include "..\..\Intel\Intel.hpp"

#define PROFILER_COUNTERS_ENABLE

#include "CmdrAction\CmdrActionStates.hpp"


/*
Low resolution navigation grid to estimate travel distance for commander.
Used primarity for distance estimation during action scoring.
*/

//#define DEBUG_STRATEGIC_NAV_GRID

#define _NODE_ID_LINKS      0
#define _NODE_ID_G          1
#define _NODE_ID_F          2
#define _NODE_ID_CAME_FROM  3
#define _NODE_NEW() [[], 0, 0, []]

// Distance cache size, we want to have it high to help commander with planning
#define _CACHE_SIZE (1024*20)

#define OOP_CLASS_NAME StrategicNavGrid
CLASS("StrategicNavGrid", "")

    /*
    Each element is an array of format:
    [neighbours, G, F, cameFrom]
        neighbours - neighbours this cell is conencted with:
            Each neighbour is an array:
            [x, y, distance]
            where x, y are index of neighbour cell, distance is distance of this link
        G - number
        F - number
        cameFrom - [x, y, distance] of the node we came from
    */
    VARIABLE("grid");

    // Each element is a bool, true if surfaceIsWater
    VARIABLE("gridWater");

    VARIABLE("resolution"); // In meters

    VARIABLE("sizeNodes");  // Amount of nodes in width or height

    // Arrays pre-filled with big number for A*
    VARIABLE("gridF");
    VARIABLE("gridG");
    VARIABLE("gridCameFrom");

    // Cache for calculated distances
    VARIABLE("distanceCache");

    // Resolution - amount of meters between nodes
    METHOD(new)
        params [P_THISOBJECT, P_NUMBER("_resolution")];

        OOP_INFO_1("NEW %1", _this);

        // Don't do anything in tests
        #ifdef _SQF_VM
        if (true) exitWith {};
        #endif

        T_SETV("resolution", _resolution);

        pr _ws = WORLD_SIZE;
        pr _sizeNodes = ceil (_ws / _resolution);
        T_SETV("sizeNodes", _sizeNodes);

        pr _grid = []; _grid resize _sizeNodes;
        pr _gridWater = []; _gridWater resize _sizeNodes;
        T_SETV("gridWater", _gridWater);
        T_SETV("grid", _grid);
        pr _i = 0;
        while {_i < _sizeNodes} do {
            pr _col = []; _col resize _sizeNodes;
            _col = _col apply {_NODE_NEW()};
            pr _colWater = []; _colWater resize _sizeNodes;
            _colWater = _col apply {false};
            _grid set [_i, _col];
            _gridWater set [_i, _colWater];
            _i = _i + 1;
        };

        // Checks if neighbour node with given ID is valid
        pr _isNodeValid = {
            params ["_x", "_y"];
            pr _valid = (_x >= 0) && {_y >= 0} && {_x < _sizeNodes} && {_y < _sizeNodes};
            _valid;
        };

        // Prepare water grid
        pr _xl = 0;
        while {_xl < _sizeNodes} do {
            pr _yl = 0;
            while {_yl < _sizeNodes} do {
                pr _posWorld = [_xl * _resolution, _yl * _resolution, 0];
                pr _isWater = surfaceIsWater _posWorld;
                (_gridWater#_xl) set [_yl, _isWater];
                _yl = _yl + 1;
            };
            _xl = _xl + 1;
        };

        // Process bridge modules
        pr _modules = entities "Vindicta_BridgeConnection";
        OOP_INFO_2("Processing %1 bridge modules: %2", count _modules, _modules);
        pr _processedModules = [];
        {
            OOP_INFO_1("Processing module: %1", _x);
            pr _linkedModules = synchronizedObjects _x;
            if (count _linkedModules != 1) then {
                OOP_ERROR_2("Vindicta_BridgeConnection at %1 has %2 connections, must have only one connection", getPosWorld _x, count _linkedModules);
            } else {
                pr _thisModule = _x;
                pr _thatModule = _linkedModules#0;
                OOP_INFO_2("  Processing module pair: %1 %2", _thisModule, _thatModule);
                if ((!(_thisModule in _processedModules)) && (!(_thatModule in _processedModules))) then {
                    OOP_INFO_0("    Pair is not processed yet");

                    pr _pos0 = T_CALLM1("getNearestNode", getPosWorld _thisModule);
                    pr _pos1 = T_CALLM1("getNearestNode", getPosWorld _thatModule);

                    // Ensure nodes are not on water
                    pr _isWater0 = _gridWater#(_pos0#0)#(_pos0#1);
                    pr _isWater1 = _gridWater#(_pos1#0)#(_pos1#1);
                    OOP_INFO_2("    Is water: %1 %2", _isWater0, _isWater1);
                    if (_isWater0 || _isWater1) then {
                        OOP_ERROR_2("Vindicta_BridgeConnection is on water or close to water at %1 %2", getPosWorld _thisModule, getPosWorld _thatModule);
                    } else {
                        // Add links between the nodes
                        pr _pos0World = [(_pos0#0)*_resolution, (_pos0#1)*_resolution, 0];
                        pr _pos1World = [(_pos1#0)*_resolution, (_pos1#1)*_resolution, 0];
                        pr _distance = _pos0World distance2D _pos1World;
                        
                        pr _node0Links = _grid#(_pos0#0)#(_pos0#1)#_NODE_ID_LINKS;
                        _node0Links pushBackUnique [_pos1#0, _pos1#1, _distance];

                        pr _node1Links = _grid#(_pos1#0)#(_pos1#1)#_NODE_ID_LINKS;
                        _node1Links pushBackUnique [_pos0#0, _pos0#1, _distance];
                        OOP_INFO_5("Added connection between nodes %1 -> %2, world pos: %3 -> %4, distance: %5", _pos0, _pos1, _pos0World, _pos1World, _distance);

                        #ifdef DEBUG_STRATEGIC_NAV_GRID
                        [_pos0World, _pos1World, "ColorRed", 50, format ["StrategicGrid_bridge_%1_%2", _pos0, _pos1]] call misc_fnc_mapDrawLineLocal;
                        #endif
                    };

                    // Add pair to array so we don't process it again
                    _processedModules pushBack _thisModule;
                    _processedModules pushBack _thatModule;
                } else {
                    OOP_INFO_0("    Already processed");
                };
            };
        } forEach _modules;

        // Populate the grid
        pr _xl = 0;
        while {_xl < _sizeNodes} do {
            pr _yl = 0;
            while {_yl < _sizeNodes} do {
                pr _posWorld = [_xl * _resolution, _yl * _resolution, 0];
                // Check if this node is water
                pr _thisNodeIsWater = _gridWater#_xl#_yl;
                if (!_thisNodeIsWater) then {
                    pr _thisNode = _grid#_xl#_yl;
                    pr _thisNodeLinks = _thisNode#_NODE_ID_LINKS;
                    {
                        _x params ["_xn", "_yn"];
                        // If that neighbour node is valid
                        if (_x call _isNodeValid) then {
                            // Check if another node is water
                            pr _neighbourNodeIsWater = _gridWater#_xn#_yn;
                            if (!_neighbourNodeIsWater) then {
                                // Add link from this node to neighbour nodes
                                _thisNodeLinks pushBack [_xn, _yn, _resolution];
                            };
                        };
                    } forEach [[_xl + 1, _yl], [_xl - 1, _yl], [_xl, _yl + 1], [_xl, _yl - 1]];

                    #ifdef DEBUG_STRATEGIC_NAV_GRID
                    OOP_INFO_4("Node: %1 %2 %3 %4", _xl, _yl, _posWorld, _thisNode);
                    if ( (count _thisNodeLinks) > 0) then {
                        _mrkName = format ["StrategicGrid_debugNode_%1_%2", _xl, _yl];
                        deleteMarkerLocal _mrkName;
                        pr _mrk = createMarkerLocal [_mrkName, _posWorld];
                        _mrk setMarkerShapeLocal "ICON";
                        _mrk setMarkerBrushLocal "SolidFull";
                        _mrk setMarkerColorLocal "ColorRed";
                        _mrk setMarkerAlphaLocal 1.0;
                        _mrk setMarkerTypeLocal "mil_dot";
                        _mrk setMarkerSizeLocal [1, 1];
                        _mrk setMarkerTextLocal (format ["%1 : %2", [_xl, _yl], (count _thisNodeLinks)]);
                    };
                    #endif
                };
                _yl = _yl + 1;
            };
            _xl = _xl + 1;
        };

        // Prepare arrays for G,F, cameFrom
        _i = 0;
        pr _fg = []; _fg resize _sizeNodes;
        pr _cameFrom = []; _cameFrom resize _sizeNodes;
        while {_i < _sizeNodes} do {
            pr _col = []; _col resize _sizeNodes;
            _col = _col apply {999999};
            pr _colCameFrom = []; _colCameFrom resize _sizeNodes;

            _fg set [_i, _col];
            _cameFrom set [_i, _colCameFrom];
            _i = _i + 1;
        };
        T_SETV("gridF", +_fg);
        T_SETV("gridG", +_fg);
        T_SETV("gridCameFrom", _cameFrom);

        // Initialize cache
        pr _cache = NEW("CacheStringToValue", [_CACHE_SIZE]);
        T_SETV("distanceCache", _cache);
    ENDMETHOD;

    // Returns true if given logical node position is within range of this grid 
    public METHOD(isNodeValid)
        params [P_THISOBJECT, "_posLogical"];
        _posLogical params ["_x", "_y"];
        pr _n = T_GETV("sizeNodes");
        pr _valid = (_x >= 0) && {_y >= 0} && {_x < _n} && {_y < _n};
        _valid;
    ENDMETHOD;

    // Returns logical node position [_x, _y] nearest to _posWorld
    // Might return invalid node position (outside of the map)
    public METHOD(getNearestNode)
        params [P_THISOBJECT, P_ARRAY("_posWorld")];
        _posWorld params ["_xWorld", "_yWorld"];
        pr _res = T_GETV("resolution");
        [round (_xWorld / _res), round (_yWorld / _res)];
    ENDMETHOD;

    // _pos0, _pos1 - are logical positions!
    // Returns [path (array of nodes), distance (number)]
    // On failure, returns [[], -1]
    public METHOD(findPath)
        params [P_THISOBJECT, P_ARRAY("_pos0"), P_ARRAY("_pos1")];

        OOP_INFO_1("findPath: %1", _this);

        // Bail if nodes are not valid
        if (!T_CALLM1("isNodeValid", _pos0)) exitWith {
            [[], -1];
        };
        if (!T_CALLM1("isNodeValid", _pos1)) exitWith {
            [[], -1];
        };

        // In case they had 3rd element
        _pos0 = +_pos0;
        _pos0 resize 2;
        _pos1 = +_pos1;
        _pos1 resize 2;


        // Handy functions to set/get values
        pr _gridSet = {
            params ["_grid", "_pos", "_value"];
            (_grid#(_pos#0)) set [_pos#1, _value];
        };

        // Heuristic function - manhattan distance
        pr _resolution = T_GETV("resolution");
        pr _hFunc = {
            params ["_pos0", "_pos1"];
            _resolution * (   ( abs ((_pos0#0) - (_pos1#0)) ) + ( abs ((_pos0#1) - (_pos1#1)))   );
        };

        pr _grid = T_GETV("grid");

        // Array of [_x, _y]
        pr _openSet = [_pos0];

        // Array of [_x, _y, _distance]
        pr _cameFrom = +T_GETV("gridCameFrom");

        pr _gScore = +T_GETV("gridG");
        [_gScore, _pos0, 0] call _gridSet;
        
        pr _fScore = +T_GETV("gridF");
        [_fScore, _pos0, [_pos0, _pos1] call _hFunc] call _gridSet;

        scopeName "scope0";
        pr _return = [[], -1]; // Value will be returned if nothing is found

        while {count _openSet > 0} do {
            //OOP_INFO_1("Open set size: %1", count _openSet);
            // Select node in open set with lowest F score
            pr _openSetF = _openSet apply {
                [_fScore#(_x#0)#(_x#1), _x];
            };
            _openSetF sort ASCENDING;
            pr _current = _openSetF#0#1;

            // Return if we have found destination
            if (_current isEqualTo _pos1) then {
                #ifdef DEBUG_STRATEGIC_NAV_GRID
                diag_log format ["Open set size: %1", count _openSet];
                diag_log format ["Open set:"];
                {
                    diag_log format ["  %1", _x];
                } forEach _openSet;
                #endif
                // Reconstruct path and return it
                pr _path = [];
                pr _distance = 0;
                pr _next = _current;
                while {! (_next isEqualTo _pos0)} do {
                    _path pushBack [_next#0, _next#1];
                    _nodeCameFrom = _cameFrom#(_next#0)#(_next#1);
                    _distance = _distance + (_nodeCameFrom#2);
                    _next = [_nodeCameFrom#0, _nodeCameFrom#1];
                };
                _path pushBack _next;
                _return = [_path, _distance];
                breakTo "scope0";
            };

            _openSet deleteAt (_openSet find _current);
            pr _neighbors = _grid#(_current#0)#(_current#1)#_NODE_ID_LINKS;
            {
                _x params ["_xn", "_yn", "_distance"];
                pr _tentativeGScore = _gScore#(_current#0)#(_current#1) + _distance;
                pr _gScoreNeighbor = _gScore#_xn#_yn;
                if (_tentativeGScore < _gScoreNeighbor) then {
                    // This path to neighbor is better, record it
                    (_cameFrom#_xn) set [_yn, [_current#0, _current#1, _distance]];
                    [_gScore, _x, _tentativeGScore] call _gridSet;
                    pr _fScoreValue = _gScoreNeighbor + ([_x, _pos1] call _hFunc);
                    [_fScore, _x, _fScoreValue] call _gridSet;

                    // If neighbor not in open set, add it there
                    pr _neighbourPos = [_xn, _yn];
                    pr _index = _openSet find _neighbourPos;
                    if (_index == -1) then {
                        _openSet pushBack _neighbourPos;
                    };
                };
            } forEach _neighbors;
        };

        OOP_INFO_1("findPath: return value: %1", _return);

        _return;

    ENDMETHOD;


    // Returns nearest non-water node to given world position
    // Returns [] if it couldn't find anything
    public METHOD(findNearestGroundNode)
        params [P_THISOBJECT, P_ARRAY("_posWorld")];

        OOP_INFO_1("findNearestGroundNode: %1", _posWorld);

        // Get nearest node as first estimate
        pr _nearestNode = T_CALLM1("getNearestNode", _posWorld);

        OOP_INFO_1("Nearest node: %1", _nearestNode);

        // Ensure that node is valid, this might be at edge of the map
        pr _size = T_GETV("sizeNodes");
        _nearestNode params ["_x", "_y"];
        _nearestNode set [0, CLAMP(_x, 0, _size-1)];
        _nearestNode set [1, CLAMP(_y, 0, _size-1)];

        // Common path should be fast
        // Check if it's not water and bail
        pr _gridWater = T_GETV("gridWater");
        if (!(_gridWater#(_nearestNode#0)#(_nearestNode#1))) exitWith {
            OOP_INFO_1("Node %1 is already at ground", _nearestNode);
            +_nearestNode;
        };

        pr _resolution = T_GETV("resolution");
        pr _grid = T_GETV("grid");

        // Array of [_distance, [_x, _y]]
        pr _nodesToCheck = [[0, _nearestNode]];
        // Array of [_x, _y] logical positions of nodes we have checked
        pr _nodesChecked = [];
        
        pr _isNodeValid = {
            params ["_x", "_y"];
            pr _valid = (_x >= 0) && {_y >= 0} && {_x < _size} && {_y < _size};
            _valid;
        };

        pr _return = [];
        while {count _nodesToCheck > 0} do {
            // Sort _nodesToCheck by their distance to _posWorld
            _nodesToCheck sort ASCENDING;
            OOP_INFO_2("Nodes to check: %1: %2", count _nodesToCheck, _nodesToCheck);
            OOP_INFO_1("Checked nodes: %1", _nodesChecked);
            pr _a = _nodesToCheck#0;
            pr _node = _a#1;
            _node params ["_x", "_y"];

            // Return if this node is on the ground
            if (! (_gridWater#(_node#0)#(_node#1)) ) exitWith {
                _return = [_node#0, _node#1];
                OOP_INFO_1("Found ground node: %1", _return);
            };

            // Mark this node as checked
            _nodesToCheck deleteAt 0;
            _nodesChecked pushBack [_node#0, _node#1];

            // Expand this node - add its neighbour nodes to _nodesToCheck
            pr _neighbors = _grid#(_node#0)#(_node#1)#_NODE_ID_LINKS;
            {
                if (_x call _isNodeValid) then {
                    if (!(_x in _nodesChecked)) then {
                        _nodesToCheck pushBack [_x distance2D _nearestNode, _x];
                    };
                };
            } forEach [[_x-1, _y], [_x+1, _y], [_x, _y-1], [_x, _y+1]];
        };

        if (count _return == 0) then {
            OOP_ERROR_1("Failed to find ground node for position: %1", _posWorld);
        };

        _return;
    ENDMETHOD;

    // Estimate ground travel distance between two points
    // Returns -1 if there is no route (islands are not connected)
    public METHOD(calculateGroundDistance)
        params [P_THISOBJECT, P_POSITION("_posWorldFrom"), P_POSITION("_posWorldTo")];

        OOP_INFO_1("calculateGroundDistance: %1", _this);

        // Bypass in tests
        #ifdef _SQF_VM
        if (true) exitWith { _posWorldFrom distance _posWorldTo };
        #endif

        // We need these values for cache key
        pr _posFromUnsafe = T_CALLM1("getNearestNode", _posWorldFrom);
        pr _posToUnsafe = T_CALLM1("getNearestNode", _posWorldTo);

        // Lookup result in cache
        pr _key = format ["%1_%2", _posFromUnsafe, _posToUnsafe];
        pr _cache = T_GETV("distanceCache");
        pr _value = CALLM1(_cache, "getValue", _key);
        if (!isNil "_value") exitWith {
            OOP_INFO_1("calculateGroundDistance: return value: %1", _value);
            _value;
        };

        // Here we get safe grid positions which are within the grid and are on ground
        // Because path finder needs proper positions
        pr _posFrom = T_CALLM1("findNearestGroundNode", _posWorldFrom);
        pr _posTo = T_CALLM1("findNearestGroundNode", _posWorldTo);

        if ((count _posFrom == 0) || (count _posTo == 0)) exitWith {
            CALLM2(_cache, "addValue", _key, -1);
            -1;
        };
        
        pr _return = T_CALLM2("findPath", _posFrom, _posTo);
        _return params ["_path", "_distance"];
        
        // Add value to cache
        // Add reverse path to cache too
        CALLM2(_cache, "addValue", _key, _distance);
        pr _keyReverse = format ["%1_%2", _posToUnsafe, _posFromUnsafe];
        CALLM2(_cache, "addValue", _keyReverse, _distance);

        OOP_INFO_1("calculateGroundDistance: return value: %1", _distance);

        _distance;

    ENDMETHOD;

ENDCLASS;

// Cache with limited size which maps string to anything
// Same cache is used in GarrisonModel
#define OOP_CLASS_NAME CacheStringToValue
CLASS("CacheStringToValue", "")

    VARIABLE("cache");      // Hashmap
    VARIABLE("allKeys");    // Array of all keys
	VARIABLE("counter");	// Counter for all keys, we increase and overflow it at each addition to cache
	VARIABLE("nMiss");	    // Amount of misses in the cache
	VARIABLE("nHit");	    // Amount of hits in the cache
    

    METHOD(new)
        params [P_THISOBJECT, P_NUMBER("_size")];

        #ifdef _SQF_VM
        pr _hm = "dummy" createVehicle [1, 2, 3];
        #else
        pr _hm = [false] call CBA_fnc_createNamespace;
        #endif
        T_SETV("cache", _hm);

        T_SETV("nHit", 0);
        T_SETV("nMiss", 0);
        T_SETV("counter", 0);
        pr _allKeys = [];
        _allKeys resize _size;
        _allkeys = _allKeys apply {""};
        T_SETV("allKeys", _allKeys);
    ENDMETHOD;

    // Gets value from cache, returns nil if value wasn't found
    METHOD(getValue)
        params [P_THISOBJECT, P_STRING("_key")];
        #ifdef RELEASE_BUILD
        T_GETV("cache") getVariable _key;
        #else
        pr _value = T_GETV("cache") getVariable [_key, nil];
        if (isNil "_value") exitWith {
            OOP_INFO_1("Cache miss: %1", _key);
            pr _a = T_GETV("nMiss");
            T_SETV("nMiss", _a+1);
            OOP_INFO_3("  nHit/nMiss/ttl: %1 / %2 / %3", T_GETV("nHit"), T_GETV("nMiss"), T_GETV("nHit") + T_GETV("nMiss"));
            nil;
        };
        OOP_INFO_2("Cache hit: %1 : %2", _key, _value);
        pr _a = T_GETV("nHit");
        T_SETV("nHit", _a+1);
        OOP_INFO_3("  nHit/nMiss/ttl: %1 / %2 / %3", T_GETV("nHit"), T_GETV("nMiss"), T_GETV("nHit") + T_GETV("nMiss"));
        _value;
        #endif
    ENDMETHOD;

    // Adds value to cache
    // If cache exceeds size, previous values are deleted
    METHOD(addValue)
        CRITICAL_SECTION {
        params [P_THISOBJECT, P_STRING("_key"), P_DYNAMIC("_value")];
            pr _allKeys = T_GETV("allKeys");
            pr _counter = T_GETV("counter");
            pr _hashMap = T_GETV("cache");
            pr _existingKey = _allKeys#_counter;
            if (count _existingKey > 0) then { // If it's not ""
                // There is an existing entry here, need to delete it from the cache
				// Because we want to limit the cache size
                _hashMap setVariable [_existingKey, nil];
            };
            _allKeys set [_counter, _key];
            _hashMap setVariable [_key, _value];
            _counter = (_counter + 1) % (count _allKeys); // Overflow over cache size
            T_SETV("counter", _counter);
        };
        0; // Return 0... just in case
    ENDMETHOD;

ENDCLASS;

#ifndef RELEASE_BUILD
StrategicNavGrid_fnc_test = {

    gStrategicNavGrid = NEW("StrategicNavGrid", [500]);

    pr _pos0 = [9, 11];
    pr _pos1 = [12, 15];
    pr _return = CALLM2(gStrategicNavGrid, "findPath", _pos0, _pos1);
    diag_log _return;
    diag_log "Distance:";
    diag_log (_return #1);

    0 spawn {
        pr _posWorld = [3000, 6000, 0];
        pr _nearestGroundNode = CALLM1(gStrategicNavGrid, "findNearestGroundNode", _posWorld);
        diag_log "Nearest ground node:";
        diag_log _nearestGroundNode;

        pr _posWorld0 = [3000, 6000, 0];
        pr _posWorld1 = [7000, 11000, 0];
        _calcGroundDistanceResult = CALLM2(gStrategicNavGrid, "calculateGroundDistance", _posWorld0, _posWorld1);
        diag_log "_calcGroundDistanceResult:";
        diag_log _calcGroundDistanceResult;
    };
};
#endif