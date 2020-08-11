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
        pr _sizeNodes = ceil (_ws / _resolution);
        T_SETV("sizeNodes", _sizeNodes);

        pr _grid = []; _grid resize _sizeNodes;
        pr _i = 0;
        while {_i < _sizeNodes} do {
            pr _col = []; _col resize _sizeNodes;
            _col = _col apply {[]};
            _grid set [_i, _col];
        };

        // Checks if neighbour node with given ID is valid
        pr _isNodeValid = {
            params ["_x", "_y"];
            pr _valid = (_x >= 0) && {_y >= 0} && {_x < _sizeNodes} && {_y < _sizeNodes};
            _valid;
        };

        // Populate the grid
        pr _xl = 0;
        while {_xl < _sizeNodes} do {
            pr _yl = 0;
            while {_yl < _sizeNodes} do {
                pr _posWorld = [_xl * _resolution, _yl * _resolution, 0];
                pr _isWater = surfaceIsWater _posWorld;
                if (!_isWater) then {
                    {
                        _x params ["_xn", "_yn"];
                        // If that neighbour node is valid
                        if (_x call _isNodeValid) then {

                        };
                    } forEach [[_xl + 1, _yl], [_xl - 1, _yl], [_xl, _yl + 1], [_xl, _yl - 1]];
                };
                _yl = _yl + 1;
            };
            _xl = _xl + 1;
        };
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