#include "common.hpp"

/*
Low resolution navigation grid to estimate travel distance for commander.
Used primarity for distance estimation during action scoring.
*/

#define OOP_CLASS_NAME StrategicNavGrid
CLASS("StrategicNavGrid", "")

    /*
    Each element is an array of neighbours this cell is conencted with:
    [ neighbour 0, neighbour 1, neighbour 2, ... ]
    Each neighbour is an array [x, y], where x, y are index of neighbour cell
    */
    VARIABLE("grid");

    VARIABLE("resolution"); // In meters

    VARIABLE("sizeNodes");  // Amount of nodes in width or height

    // Resolution - amount of meters between nodes
    METHOD(new)
        params [P_THISOBJECT, P_NUMBER("_resolution")];

        T_SETV("resolution", _resolution);

        pr _ws = WORLD_SIZE;
        pr _nNodesWidthHeight = ceil (_ws / _resolution);
        T_SETV("sizeNodes", _nNodesWidthHeight);

        pr _grid = []; _grid resize _nNodesWidthHeight;
        pr _i = 0;
        while {_i < _nNodesWidthHeight} do {
            pr _col = []; _col resize _nNodesWidthHeight;
            _col = _col apply {[]};
            _grid set [_i, _col];
        };

        // Checks if neighbour node with given ID is valid
        pr _isNodeValid = {
            params ["_x", "_y", "_nNodesWidthHeight"];
            pr _valid = (_x >= 0) && {_y >= 0} && {_x < _nNodesWidthHeight} && {_y < _nNodesWidthHeight};
            _valid;
        };

        // Populate the grid

    ENDMETHOD;

    // Returns true if given logical node position is within range of this grid 
    public METHOD(isNodeValid)
        params [P_THISOBJECT, "_posLogical"];
        _pos params ["_x", "_y"];
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
ENDCLASS;