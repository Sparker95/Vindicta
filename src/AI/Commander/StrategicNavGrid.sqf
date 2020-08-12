#include "common.hpp"

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

    // Resolution - amount of meters between nodes
    METHOD(new)
        params [P_THISOBJECT, P_NUMBER("_resolution")];

        OOP_INFO_1("NEW %1", _this);

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

                #ifndef _SQF_VM
                _fMap setVariable [str [_xl, _yl], 0];
                _gMap setVariable [str [_xl, _yl], 0];
                #endif

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
    public METHOD(getNearestNode)
        params [P_THISOBJECT, P_ARRAY("_posWorld")];
        _posWorld params ["_xWorld", "_yWorld"];
        pr _res = T_GETV("resolution");
        [round (_xWorld / _res), round (_yWorld / _res)];
    ENDMETHOD;

    // _pos0, _pos1 - are logical positions!
    // Returns [path (array of nodes), distance (number)]
    // On failure, returns []
    public METHOD(findPath)
        params [P_THISOBJECT, P_ARRAY("_pos0"), P_ARRAY("_pos1")];

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
        pr _return = [];

        while {count _openSet > 0} do {
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

        _return;

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
};
#endif