params ["_startPos", "_endPos"];

[_startPos, _endPos] spawn {
    params ["_startPos", "_endPos"];

    while {!gps_core_init_done} do { sleep 1; };

    [] call gps_test_fn_clear_markers;

    // private _normal = ["ColorBlue", { 
    //     params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute"];
    //     _base_cost
    // }];
    // private _danger = ["ColorRed", { 
    //     params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute"];
    //     private _danger_rating = 0;
    //     private _pos = getPos _next;
    //     private _activity = [activity_grid, _pos select 0, _pos select 1] call ws_fnc_getValue; 
    //     // {
    //     //     private _rating_cost = 0 max (((markerSize _x) select 0) - ((markerPos _x) distance _next));
    //     //     _danger_rating = _danger_rating + _rating_cost * _rating_cost * _rating_cost;
    //     // } forEach danger_markers;
    //     _base_cost + _activity * _activity * _activity
    // }];
    
    // private _height = ["ColorGreen", { 
    //     params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute"];
    //     private _height = ((getPosASL _next) select 2);
    //     _base_cost + _height * _height * _height
    // }];

    //private _runs = [_normal, _danger, _height];
    
    private _startRoute = [_startPos, 1000, gps_blacklistRoads] call bis_fnc_nearestRoad;
    private _endRoute = [_endPos, 1000, gps_blacklistRoads] call bis_fnc_nearestRoad;

    if (isNull _endRoute) exitWith {hintSilent "end invalid"};
    if (isNull _startRoute) exitWith {hintSilent "start invalid"};

    [_startRoute] call gps_core_fnc_insertFakeNode;
    [_endRoute] call gps_core_fnc_insertFakeNode;

    try {
        // private _routes = [];
        // {
            //_x params ["_color", "_weight_fn"];

            private _path = [_startRoute, _endRoute] call gps_core_fnc_generateNodePath;
            private _fullPath = [_path] call gps_core_fnc_generatePathHelpers;

            private _last_junction = 0;
            for "_i" from 0 to count _fullPath - 1 do {
                private _current = _fullPath select _i;
                if(count ([gps_allCrossRoadsWithWeight, str _current] call misc_fnc_hashTable_find) > 1) then
                {
                    [getPos (_fullPath select floor((_i + _last_junction)/2))] call gps_test_fn_mkr;
                    _last_junction = _i;
                };
            };

            private _path_pos = _fullPath apply { getPos _x };

            private _seg_positions = [_path_pos, 20] call gps_core_fnc_RDP;

            for "_i" from 0 to (count _seg_positions - 2) do
            {
                private _size = if((_i == 0) or (_i == count _seg_positions - 2)) then { 10 } else { 20 };
                private _start = _seg_positions select _i;
                private _end = _seg_positions select (_i + 1);
                [
                    ["start", _start],
                    ["end", _end],
                    ["color", "ColorGreen"],
                    ["size", _size],
                    ["id", "gps_" + str _start + str _end]
                ] call gps_test_fnc_mapDrawLine; 
            };

            //_routes pushBack [_fullPath, _color];
        //} forEach _runs;

        //{
            //_x params ["_fullPath", "_color"];

            // [_fullPath, _color] spawn {
            //     params ["_fullPath", "_color"];
            //     if (count _fullPath <= 1) exitWith {};

            //     private _pos = getPos (_fullPath select 0);
            //     private _next_idx = 1;
            //     private _next_pos = getPos (_fullPath select 1);

            //     private _convoy_mkr = [_pos, "convoy_" + _color, _color, "b_motor_inf"] call fn_mkr;


            //     fn_get_road_speed = {
            //         params ["_road"];
            //         if([_road] call misc_fnc_isHighWay) exitWith {
            //             60 * 0.277778 * 10
            //         };
            //         40 * 0.277778 * 10
            //     };

            //     private _speed_ms = [_fullPath select 0] call fn_get_road_speed;

                
            //     // This algorithm isn't actually perfectly accurate. However as long as
            //     // distance moved per iteration is significantly less than gaps between nodes
            //     // (and it should be!) error will be trivial.
            //     // If you are going to increase the sleep time significantly (i.e. many seconds)
            //     // then it might be worth revisiting how this works.
            //     while { _next_idx < count _fullPath - 1 } do {
            //         sleep(0.1);

            //         // How far will we travel this iteration?
            //         private _dist = _speed_ms * 0.1;
            //         // How far to the next node?
            //         private _next_dist = _pos distance _next_pos;
            //         // If we will reach the next node then...
            //         if(_dist >= _next_dist) then {
            //             // Just set our position to the next node itself. We lose a bit of accuracy here but it 
            //             // should be trivial.
            //             _pos = _next_pos;

            //             _next_idx = _next_idx + 1;
            //             if(_next_idx < count _fullPath - 1) then {
            //                 _next_pos = getPos (_fullPath select _next_idx);
            //                 _speed_ms = [_fullPath select _next_idx] call fn_get_road_speed;
            //             };
            //         } else {
            //             _pos = _pos vectorAdd (vectorNormalized (_next_pos vectorDiff _pos) vectorMultiply _dist);
            //         };
                    
            //         _convoy_mkr setMarkerPos _pos;
            //     };
            //     deleteMarker _convoy_mkr;
            // };
        //} forEach _routes;

    } catch {
        hint "No path";
        diag_log str _exception;
    };
};