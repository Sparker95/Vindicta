/*
Finds the length of the road specified by a road segment.
parameters: [_road, _maxLength]

It works bad! Bacause at crossroads and T-shaped junctions it might switch to another road and continue calculating its length.

Author: Sparker
*/

params ["_road", ["_maxLength", 1000]];

private _length0 = 0;
private _length1 = 0;

private _rct = roadsConnectedTo _road;
private _road0 = _road;
private _road1 = _road;
private _roadNext = objNull;
private _road0Prev = objNull;
private _road1Prev = objNull;
private _roadcon = [objNull, objNull];
private _arrow = objNull;
private _count = 0;
private _dist = 0;
private _roadFarthest = objNull;
private _distMax = 0;
while {(_length0 + _length1) < _maxLength} do
{
	if(! isNull _road0) then
	{
		_roadcon = roadsConnectedTo _road0;
		_count = count _roadcon;

		if(_count == 2) then //it's a good piece of road somewhere in the middle
		{
			_roadNext = _roadcon select 0;
			_length0 = _length0 + (_road0 distance _roadNext);

			//Put an arrow for debug
			private _dir = (_road0 getDir _roadNext) + 180;
			_arrow = "Sign_Arrow_Blue_F" createVehicle (getPos _road0);
			_arrow setVectorDirAndUp [[0, 0, 1], [sin _dir, cos _dir, 0]];

			_road0Prev = _road0;
			_road0 = _roadNext;
		}
		else
		{
			if(_count > 2) then //It's probably an intersection
			{
				//Choose the farthest piece of road
				_roadcon = _roadcon - [_road0Prev];
				_roadFarthest = objNull;
				_distMax = 0;
				{
					_dist = (_x distance _road0);
					if(_dist > _distMax) then
					{
						_distMax = _dist;
						_roadFarthest = _x;
					};
				} forEach _roadcon;

				_length0 = _length0 + _distMax;

				_road0Prev = _road0;
				_road0 = _roadFarthest;
			}
			else //That's the end of the road!
			{
				//Put an arrow for debug
				_arrow = "Sign_Arrow_F" createVehicle (getPos _road0);

				_road0 = objNull;
			};
		};
	};

	if(! isNull _road1) then
	{
		_roadcon = roadsConnectedTo _road1;
		_count = count _roadcon;

		if(_count == 2) then //it's a good piece of road somewhere in the middle
		{
			_roadNext = _roadcon select 1;
			_length1 = _length1 + (_road1 distance _roadNext);

			//Put an arrow for debug
			private _dir = (_road1 getDir _roadNext) + 180;
			_arrow = "Sign_Arrow_Green_F" createVehicle (getPos _road1);
			_arrow setVectorDirAndUp [[0, 0, 1], [sin _dir, cos _dir, 0]];

			_road1Prev = _road1;
			_road1 = _roadNext;
		}
		else
		{
			if(_count > 2) then //It's probably an intersection
			{
				//Choose the farthest piece of road
				_roadcon = _roadcon - [_road1Prev];
				_roadFarthest = objNull;
				_distMax = 0;
				{
					_dist = (_x distance _road0);
					if(_dist > _distMax) then
					{
						_distMax = _dist;
						_roadFarthest = _x;
					};
				} forEach _roadcon;

				_length1 = _length1 + _distMax;

				_road1Prev = _road1;
				_road1 = _roadFarthest;
			}
			else //That's the end of the road!
			{
				//Put an arrow for debug
				_arrow = "Sign_Arrow_F" createVehicle (getPos _road1);

				_road1 = objNull;
			};
		};
	};

	if(isNull _road0 && isNull _road1) exitWith {}; //Scanned through all the length of the road
};

(_length0 + _length1)