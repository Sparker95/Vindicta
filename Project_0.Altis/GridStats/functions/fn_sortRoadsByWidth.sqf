/*
Sorts roads based on their width
*/

params ["_roads"];

private _roadBig = [];
private _roadMedium = [];
private _roadSmall = [];
if(count _roads > 0) then
{
	private _width = 0;
	private _roadWidthLimit = 1.1*road_width_big;

	{
		_width = [_x, 0.2, 20] call ws_fnc_getRoadWidth;
		if(road_width_big-1 < _width && _width < road_width_big+1) then
		{
			_roadBig pushBack _x;
		}
		else
		{
			if(road_width_medium-1 < _width && _width < road_width_medium+1) then
			{
				_roadMedium pushback _x;
			}
			else
			{
				if(road_width_small-1 < _width && _width < road_width_small+1) then
				{
					_roadSmall pushback _x;
				};
			};
		};
	} forEach _roads;
};

[_roadBig, _roadMedium, _roadSmall]