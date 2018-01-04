/*
Sets the border type of location as circle with defined radius.
*/

params ["_loc", "_radius"];

_loc setVariable ["l_borderType", 0, true];
_loc setVariable ["l_borderData", _radius, true];

_loc setVariable ["l_boundingRadius", _radius, true];

//==== Add patrol waypoints ====
/*
Patrol waypoints are around the base. If the found position is on water, it is moved iteratively towards the center of location.
*/
private _wp = [];
private _i = 0;
private _d  = 0;
private _pos = 0;
while {_i < 8} do
{
	_d = _radius;
	_pos = _loc getPos [_radius, 45*_i]; //Points around the location
	while {(surfaceIsWater _pos) && (_d > 0)} do
	{
		_d = _d - 10;
		_pos = _loc getPos [_d, 45*_i];
	};
	if(_d > 0) then
	{
		_wp pushback _pos;
	};
	_i = _i + 1;

	//Test
	"Sign_Arrow_Large_Pink_F" createVehicle (_pos);
	//
};
_loc setVariable ["l_patrol_wp", _wp, false]; //An array with points between which patrols should walk