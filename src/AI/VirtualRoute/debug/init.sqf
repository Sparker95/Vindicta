#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING

#include "..\..\..\common.h"

gps_test_fnc_mapDrawLine = COMPILE_COMMON("AI\VirtualRoute\debug\mapDrawLine.sqf");

// Add a map marker.
gps_test_fn_mkr = {
    params ["_pos", ["_prefix", "gps_"], ["_color", "ColorWhite"], ["_icon", "hd_dot"]];
    private _mrk = createMarker [_prefix + str _pos, _pos];
    // define marker
    _mrk setMarkerShape "ICON";
    _mrk setMarkerType _icon;
    _mrk setMarkerColor _color;
    _mrk
};

// Clear all map markers with a certain prefix.
gps_test_fn_clear_markers = {
    params [["_prefix", "gps_"]];
    _allMarkers = allMapMarkers;
    {
        if (toLower _x find (toLower _prefix) >= 0) then
        {
            deleteMarker _x;
        };
    } forEach _allMarkers;
};


gps_test_active_convoys = [];
gps_test_stopped_convoys = [];

// This test function will make a VirtualRoute object between two points and run it as a simulation, with debug drawing.
gps_test_route = {
    params ["_start", "_end", ["_sleep", 10], ["_color", "ColorBlue"]];

    private _args = [_start, _end];
    private _newRoute = NEW("VirtualRoute", _args);
    
    [_newRoute, _sleep, _color] spawn {
        params ["_newRoute", "_sleep", "_color"];

        // Wait for the object to be calculated (it is spawned in the constructor)
        while {!(GETV(_newRoute, "calculated")) and !(GETV(_newRoute, "failed"))} do {
            sleep 1;
        };

        if (!(GETV(_newRoute, "failed"))) then {
            // Draw the route itself on the map
            CALLM1(_newRoute, "debugDraw", _color);

            // Simulate a convoy moving along the route
            private _pos = GETV(_newRoute, "pos");
            private _convoy_mkr = [_pos, "convoy_" + _newRoute, _color, "b_motor_inf"] call gps_test_fn_mkr;

            CALLM0(_newRoute, "start");

            // Make a random convoy composition
            private _vehicleCount = 1 + random(10);
            private _composition = [];
            for "_i" from 0 to _vehicleCount do
            {
                _composition pushBack selectRandom ["O_Truck_02_transport_F", "O_MRAP_02_F", "O_Truck_02_fuel_F"];
            };
            private _routeAndComp = [_newRoute, _composition];
            gps_test_active_convoys pushBack _routeAndComp;

            // Wait for convoy to reach destination
            while {!(GETV(_newRoute, "complete"))} do {
                CALLM0(_newRoute, "process");
                _pos = GETV(_newRoute, "pos");
                _convoy_mkr setMarkerPos _pos;
                sleep _sleep;
            };

            gps_test_active_convoys = gps_test_active_convoys - [_routeAndComp];

            deleteMarker _convoy_mkr;
        } else {
            hint "Route finding failed!";
        };
    };
};

// Records first point clicked on map when placing a test route.
gps_test_start = [];
// Call this function to enable all the debug and testing functions via Player Actions.
gps_test_enable = {

    // Action for placing a single route with defined start and end point. Shift click the map to place start and end points.
    player addAction ["<t color='#FFFF00'>[VirtualRoute] Test Route Finder</t>", {
        openMap true;
        hint "Shift click to place start point, then again to place end point";
        onMapSingleClick {
            if (_shift) then {
                gps_test_start = _pos;
                [gps_test_start, "gpstest_", "ColorWhite", "hd_flag"] call gps_test_fn_mkr;

                onMapSingleClick {
                    if (_shift) then {
                        onMapSingleClick {};

                        ["gpstest_"] call gps_test_fn_clear_markers;
                        [gps_test_start, _pos] call gps_test_route;
                    };
                    _shift
                };
            };
            _shift
        };
    }];

    // Clear all debug info from the map.
    player addAction ["<t color='#FFFF00'>[VirtualRoute] Clear Route Debug</t>", {
        CALLSM0("VirtualRoute", "clearAllDebugDraw");
    }];

    // Stop all in progress convoy simulations and spawn their vehicles onto the road.
    player addAction ["<t color='#FFFF00'>[VirtualRoute] Stop and spawn convoys</t>", {
        {
            _x params ["_route", "_composition"];
            CALLM0(_route, "process");
            CALLM0(_route, "stop");
            private _positions = CALLM1(_route, "getConvoyPositions", count _composition);
            private _vehicles = [];
            for "_i" from 0 to count _composition - 1 do
            {
                (_positions select _i) params ["_pos", "_dir"];
                private _veh = createVehicle [_composition select _i, _pos];
                _veh setDir _dir;
                _vehicles pushBack _veh;
            };
            gps_test_stopped_convoys pushBack [_route, _vehicles];
        } forEach (gps_test_active_convoys select { !(GETV(_x select 0, "stopped")) });
    }];

    // Start all stopped convoy simulations, despawn their vehicles.
    player addAction ["<t color='#FFFF00'>[VirtualRoute] Despawn and start convoys</t>", {
        {
            _x params ["_route", "_vehicles"];
            {
                deleteVehicle _x;
            } forEach _vehicles;
            CALLM0(_route, "start");
        } forEach gps_test_stopped_convoys;

        gps_test_stopped_convoys = [];
    }];

    // Start 20 simulations simultaneously.
    player addAction ["<t color='#FFFF00'>[VirtualRoute] Stress Test</t>", {
        for "_i" from 0 to 20 do {
            private _start = [] call BIS_fnc_randomPos;
            private _end = [] call BIS_fnc_randomPos;
            [_start, _end, 10, selectRandom [
                "ColorBlack", "ColorGrey", "ColorRed", "ColorBrown", 
                "ColorOrange", "ColorYellow", "ColorKhaki", "ColorGreen", 
                "ColorBlue", "ColorPink", "ColorWhite"]
            ] call gps_test_route;
        };
    }];

    // Start 3 simulations with the same start and end points and different update intervals.
    // Used to compare the accuracy for different update intervals.
    player addAction ["<t color='#FFFF00'>[VirtualRoute] Test update accuracy</t>", {
        private _start = [] call BIS_fnc_randomPos;
        private _end = [] call BIS_fnc_randomPos;
        [_start, _end, 0.1, "ColorBlue"] call gps_test_route;
        [_start, _end, 10, "ColorRed"] call gps_test_route;
        [_start, _end, 60, "ColorGreen"] call gps_test_route;
    }];
};

