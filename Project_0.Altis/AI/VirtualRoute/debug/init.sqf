#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING

#include "..\..\..\OOP_Light\OOP_Light.h"

gps_test_fnc_mapDrawLine = compile preprocessFileLineNumbers "AI\VirtualRoute\debug\mapDrawLine.sqf";

// danger_markers = [];

// activity_grid = [] call ws_fnc_newGridArray;

// fn_randomize_danger_zones = {
//     [] execVM "gen_activity.sqf";
// };
// [] call fn_randomize_danger_zones;

gps_test_fn_mkr = {
    params ["_pos", ["_prefix", "gps_"], ["_color", "ColorWhite"], ["_icon", "hd_dot"]];
    private _mrk = createMarker [_prefix + str _pos, _pos];
    // define marker
    _mrk setMarkerShape "ICON";
    _mrk setMarkerType _icon;
    _mrk setMarkerColor _color;
    _mrk
};

gps_test_fn_clear_markers = {
    params [["_prefix", "gps_"]];
    _allMarkers = allMapMarkers;
    {
        if (toLower _x find _prefix >= 0) then
        {
            deleteMarkerLocal _x;
        };
    } forEach _allMarkers;
};

gps_test_start = [];

VirtualRoute_debug = true;

//test_routes = [];

if(!(isNil "VirtualRoute_debug")) then {
    player addAction ["Test Route Finder", {
        openMap true;

        onMapSingleClick {
            if (_shift) then {
                gps_test_start = _pos;
                [gps_test_start, "gpstest_", "ColorWhite", "hd_flag"] call gps_test_fn_mkr;

                onMapSingleClick {
                    if (_shift) then {
                        onMapSingleClick {};

                        ["gpstest_"] call gps_test_fn_clear_markers;

                        private _args = [gps_test_start, _pos];
                        private _newRoute = NEW("VirtualRoute", _args);

                        [_newRoute] spawn {
                            params ["_newRoute"];

                            while {!(GETV(_newRoute, "calculated")) and !(GETV(_newRoute, "failed"))} do {
                                sleep 1;
                            };

                            if (!(GETV(_newRoute, "failed"))) then {
                                CALLM0(_newRoute, "debugDraw");
                            } else {
                                hint "Route finding failed!";
                            };

                            private _pos = GETV(_newRoute, "pos");
                            private _convoy_mkr = [_pos, "convoy_" + _newRoute, "ColorBlue", "b_motor_inf"] call gps_test_fn_mkr;

                            CALLM0(_newRoute, "start");

                            while {!(GETV(_newRoute, "complete"))} do {
                                CALLM0(_newRoute, "process");
                                _pos = GETV(_newRoute, "pos");
                                _convoy_mkr setMarkerPos _pos;
                            };

                            deleteMarker _convoy_mkr;
                        };
                    };
                    _shift
                };
            };
            _shift
        };
    }];

    player addAction ["Clear Route Debug", {
        CALL_STATIC_METHOD_0("VirtualRoute", "clearAllDebugDraw");
    }];
};

