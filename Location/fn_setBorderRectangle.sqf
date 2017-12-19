/*
Sets the border type of location as rectangle with a, b, direction, like in markers.
*/

params ["_loc", "_a", "_b", "_dir"];

_loc setVariable ["l_borderType", 1, false];
_loc setVariable ["l_borderData", [_a, _b, _dir], false];
private _radius = sqrt(_a*_a + _b*_b);
_loc setVariable ["l_boundingRadius", _radius, false];

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
private _pos = [0, 0, 0];

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

private _distWP = //DIstances to waypoints relative to center
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
while {_i < 8} do
{
	_dir = _dirWP select _i;
	_dist = _distWP select _i;
	_pos = _loc getPos [_dist, _dir]; //Get position
	//diag_log format ["==== _dir: %1   _dist: %2   _center: %3   _pos: %4", _dir, _dist, (getpos _loc), _pos];
	while {(surfaceIsWater _pos) && (_dist > 0)} do //If it's on water, move it to the center
	{
		_dist = _dist - 10;
		_pos = _loc getPos [_dist, _dir];
	};
	if(_dist > 0) then
	{
		_wp pushback _pos;
	};
	_i = _i + 1;

	//Test
	"Sign_Arrow_Large_Pink_F" createVehicle (_pos);
	//
};

_loc setVariable ["l_patrol_wp", _wp]; //An array with points between which patrols should walk