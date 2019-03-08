#include "..\OOP_Light\OOP_Light.h"

// Class: Location
/*
Method: setBorder
Sets border parameters for this location

Arguments:
_type - "circle" or "rectange"
_data	- for "circle":
	_radius
		- for "rectangle":
	[_a, _b, _dir] - rectangle dimensions and direction

*/

params [["_thisObject", "", [""]], ["_type", "", [""]], ["_data", 50, [0, []]] ];

switch (_type) do {
	case "circle" : {
		_data params [ ["_radius", 0, [0] ] ];
		SET_VAR_PUBLIC(_thisObject, "boundingRadius", _radius);
		SET_VAR_PUBLIC(_thisObject, "border", _radius);
		
		// Update the patrol waypoints
		private _wp = [];
		private _i = 0;
		private _d  = 0;
		private _locPos = GET_VAR(_thisObject, "pos");
		private _pos = 0;
		while {_i < 8} do
		{
			_d = _radius;
			_pos = _locPos getPos [_radius, 45*_i]; //Points around the location
			while {(surfaceIsWater _pos) && (_d > 0)} do {
				_d = _d - 10;
				_pos = _locPos getPos [_d, 45*_i];
			};
			if(_d > 0) then	{
				_wp pushback _pos;
			};
			_i = _i + 1;

			//Test
			//createVehicle ["Sign_Arrow_Large_Pink_F", _pos, [], 0, "can_collide"];
		};
		SET_VAR(_thisObject, "borderPatrolWaypoints", _wp);
	};
	
	case "rectangle" : {
		_data params ["_a", "_b", "_dir"];
		private _radius = sqrt(_a*_a + _b*_b);
		SET_VAR_PUBLIC(_thisObject, "border", _data);
		SET_VAR_PUBLIC(_thisObject, "boundingRadius", _radius);
		
		// Add patrol waypoints
		/*
		For a rectangular border the waypoints are located like this:
		
		  a   a
		7---0---1
		|	|* /|  * is the _alpha angle
		|	| /	| b
		|	|/	|
		6---+---2
		|	|	|
		|	|	| b
		|	|	|
		5---4---3
		
		If the found position is on water, it is moved iteratively towards the center of location.
		*/
		
		private _alpha = _a atan2 _b;
		private _pos = [];
		
		private _dirWP = //Directions towards the waypoint
		[
			_dir,			//0
			_dir+_alpha, 	//1
			_dir+90, 		//2
			_dir+180-_alpha,//3
			_dir+180,		//4
			_dir+180+_alpha,//5
			_dir-90,		//6
			_dir-_alpha		//7
		];
		
		//diag_log format ["==== _dirWP: %1", _dirWP];
		
		private _distWP = //Distances to waypoints relative to center
		[
			_b,			//0
			_radius,	//1
			_a,			//2
			_radius,	//3
			_b,			//4
			_radius,	//5
			_a,			//6
			_radius		//7
		];
		
		private _i = 0;
		private _dist = 0;
		private _wp = [];
		private _locPos = GET_VAR(_thisObject, "pos");
		while {_i < 8} do {
			_dir = _dirWP select _i;
			_dist = _distWP select _i;
			_pos = _locPos getPos [_dist, _dir]; //Get position
			//diag_log format ["==== _dir: %1   _dist: %2   _center: %3   _pos: %4", _dir, _dist, (getpos _loc), _pos];
			while {(surfaceIsWater _pos) && (_dist > 0)} do { //If it's on water, move it to the center
				_dist = _dist - 10;
				_pos = _locPos getPos [_dist, _dir];
			};
			if(_dist > 0) then {
				_wp pushback _pos;
			};
			_i = _i + 1;
		
			//Test
			//createVehicle ["Sign_Arrow_Large_Pink_F", _pos, [], 0, "can_collide"];

		};
		SET_VAR(_thisObject, "borderPatrolWaypoints", _wp);
	};
	
	default {
		diag_log format ["[Location::setBorder] Error: wrong border type: %1, location: %2", _type, GET_VAR(_thisObject, "debugName")];
	};
};