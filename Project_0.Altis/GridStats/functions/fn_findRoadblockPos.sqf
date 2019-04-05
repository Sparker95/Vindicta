/*
Finds best position for a roadblock around given position inside defined radius
Most priority is given to wider roads and to roads inside cities

Return value:
[_roadObject, _priority]
_roadObject - the selected road object
_priority - number from 0(no suitable roads found) to 6(big road in a city)

*/

params ["_position", "_radius", "_direction", "_angleRange", ["_debug", false]];

_roads = [_position, _radius, 10, _direction, _angleRange, _debug] call ws_fnc_findRoadblockRoads;
_roadCity = _roads select 0;
_roadCountry = _roads select 1;

//Find the widest road inside city
private _roadCityBig = [];
private _roadCityMedium = [];
private _roadCitySmall = [];
if(count _roadCity > 0) then
{
	private _roadCityWidth = [];
	private _roadCityWidthMax = 0;
	private _roadCityMax = objNull;
	private _width = 0;
	private _roadWidthLimit = 1.1*road_width_big;

	{
		_width = [_x, 0.2, 20] call ws_fnc_getRoadWidth;
		/*
		if(_width > _roadCityWidthMax && _width < _roadWidthLimit) then
		{
			_roadCityWidth pushBackUnique _width;
			_roadCityWidthMax = _width;
			_roadCityMax = _x;
		};
		*/
		if(road_width_big-1 < _width && _width < road_width_big+1) then
		{
			_roadCityBig pushBack _x;
		}
		else
		{
			if(road_width_medium-1 < _width && _width < road_width_medium+1) then
			{
				_roadCityMedium pushback _x;
			}
			else
			{
				if(road_width_small-1 < _width && _width < road_width_small+1) then
				{
					_roadCitySmall pushback _x;
				};
			};
		};
	} forEach _roadCity;
};

private _roadCountryBig = [];
private _roadCountryMedium = [];
private _roadCountrySmall = [];
if(count _roadCountry > 0) then
{
	//Find the widest road inside country
	private _roadCountryWidth = [];
	private _roadCountryWidthMax = 0;
	private _roadCountryMax = objNull;
	_width = 0;
	{
		_width = [_x, 0.2, 20] call ws_fnc_getRoadWidth;
		/*
		if(_width > _roadCountryWidthMax && _width < _roadWidthLimit) then
		{
			_roadCountryWidth pushBackUnique _width;
			_roadCountryWidthMax = _width;
			_roadCountryMax = _x;
		};*/
		if(road_width_big-1 < _width && _width < road_width_big+1) then
		{
			_roadCountryBig pushBack _x;
		}
		else
		{
			if(road_width_medium-1 < _width && _width < road_width_medium+1) then
			{
				_roadCountryMedium pushback _x;
			}
			else
			{
				if(road_width_small-1 < _width && _width < road_width_small+1) then
				{
					_roadCountrySmall pushback _x;
				};
			};
		};
	} forEach _roadCountry;
};



//Choose the best position
private _roadArrays = [_roadCityBig, _roadCountryBig, _roadCityMedium, _roadCountryMedium, _roadCitySmall, _roadCountrySmall]; //Cities and big roads go first
private _i = 0;
while {((_roadArrays select _i) isEqualTo []) && (_i < 6)} do
{
	_i = _i + 1;
};

_return = [objNull, 6];
private _roadArray = [];
if(_i < 6) then
{
	_roadArray = _roadArrays select _i;
	_return = [selectRandom _roadArray, 6-_i];
};

//Plot a marker on the map
if(_debug) then
{

};

//[_roadCityWidthMax, _roadCountryWidthMax]
//[_roadCityMax, _roadCountryMax]
//[_roadCityWidth, _roadCountryWidth]
/*
[[_roadCityBig, _roadCityMedium, _roadCitySmall], [_roadCountryBig, _roadCountryMedium, _roadCountrySmall]]
*/

_return
