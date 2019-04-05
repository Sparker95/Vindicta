/*
Searches for a position suitable for a roadblock. The function doesn't check for the road width.

Parameters:
[_position, _radius, _width, _direction, _angleRange, _debug]
_position -
_radius - the radius of search
_direction - the desired direction the road must be facing
_angleRande - the maximum difference between road direction and the _direction. Set to 180 to disable the angle criteria.
_debug - plot the found positions on the map

Return value:
[_roadCity, _roadCountry] - array:
_roadCity - array of road objects that are good for city-type roadblocks
_roadCountry - array of road objects that are good for country-type roadblocks

Author: Sparker
Possible usage: [getpos player, 400, 10, 0, 180, [], 10000, true] call ws_fnc_findRoadblockRoads;
*/
params ["_position", "_radius", "_width", ["_direction", 0], ["_angleRange", 180], ["_keepoutMarkers", []], ["_keepoutRadius", 666666], ["_debug", false]];


//Remove previous markers

if(!_debug) then
{
	_allMarkers = allMapMarkers;
	{
		if (toLower _x find "rd_mrk" >= 0) then
		{
			deleteMarkerLocal _x;
		};
	} forEach _allMarkers;
};

private _nr = _position nearRoads _radius;

if(count _nr == 0) exitWith {[[], []]};

//Plot markers
if(isNil "findRoadblockRoadsCounter") then
{
	findRoadblockRoadsCounter = 0;
};
private _wsm = "";
if(_debug) then
{
	private _wsmname = "";
	{
		_wsmname = format ["rd_mrk_%1", findRoadblockRoadsCounter];
		_wsm = createMarkerLocal [_wsmName, getPos _x];
		_wsm setMarkerTypeLocal "mil_dot";
		_wsm setMarkerColorLocal "ColorRed";
		_wsm setMarkerAlphaLocal 1;
		findRoadblockRoadsCounter = findRoadblockRoadsCounter + 1;
	} forEach _nr;
};

//diag_log format ["Initial road count: %1", count _nr];
private _no = [];
private _roadPos = [0, 0, 0];
private _roadIndex = 0;
private _bb = [[0, 0, 0], [0, 0, 0]];
private _count = 0;
private _i = 0;
private _size = 0;
private _obj = objNull;
private _road = objNull;
private _nrDelete = [];

private _roadCity = [];
private _roadCountry = [];
private _roadIntercection = [];
private _connectedRoads = [];
private _roadDirection = 0;
private _num = 0;
private _mrkPos = [0, 0, 0];
private _distanceGood = true;

{
	_road = _x;
	_roadPos = getPos _road;
	_roadIndex = _forEachIndex;
	//_no = nearestTerrainObjects [_roadPos, ["BUILDING", "HOUSE", "FENCE", "WALL", "FUELSTATION"], _width + 50, false, true];

	//Check if the road is not the end and not an intercection
	_connectedRoads = roadsConnectedTo _road;
	if (count _connectedRoads == 2) then
	{
		//Check if the road is far enough from keepout markers
		_distanceGood = true;
		if(count (_keepoutMarkers) > 0) then
		{
			{ //Check all the keepout markers
				_mrkPos = getMarkerPos _x;
				if((_road distance _mrkPos) < _keepoutRadius) exitWith {_distanceGood = false;};
			}forEach _keepoutMarkers;
		};

		if(_distanceGood) then //If the road is far from keepout markers
		{
			//Approximate the direction by the direction between two nearest segments
			_roadDirection = (_connectedRoads select 0) getDir (_connectedRoads select 1); // 0 ... 360 degrees
			_roadDirection = abs (_roadDirection - _direction);
			//Make the angle in range 0 ... 90
			while {_roadDirection > 180} do	{_roadDirection = _roadDirection - 180;};
			if(_roadDirection > 90) then {_roadDirection = 180 - _roadDirection;};
			//Check if the road is heading where we need it
			if (_roadDirection <= _angleRange) then
			{
				//Check how many houses the road has nearby
				_no = nearestTerrainObjects [_roadPos, ["BUILDING", "HOUSE"], _width + 50, false, true];
				_count = count _no;
				_i = 0;
				_num = 0;
				//diag_log format ["Checking road: %1  objects count: %2", _roadIndex, _count];
				while {_i < _count} do
				{
					//diag_log format ["Checking object: %1", _i];
					_obj = _no select _i;
					_bb = boundingBoxReal _obj;
					_size = 1.5*vectorMagnitude [_bb select 0 select 0, _bb select 0 select 1, 0];
					if((_obj distance _road) < (_size + _width)) then
					{
						_num = _num + 1;
					};
					_i = _i + 1;
				};
				if(_num == 0) then //No houses around, check for fences and walls
				{
					_no = nearestTerrainObjects [_roadPos, ["FENCE", "WALL", "ROCK", "ROCKS", "HIDE"], _width + 50, false, true];
					_count = count _no;
					_i = 0;
					_num = 0;
					//diag_log format ["Checking road: %1  objects count: %2", _roadIndex, _count];
					while {_i < _count} do
					{
						//diag_log format ["Checking object: %1", _i];
						_obj = _no select _i;
						_bb = boundingBoxReal _obj;
						_size = 1.5*vectorMagnitude [_bb select 0 select 0, _bb select 0 select 1, 0];
						if((_obj distance _road) < (_size + _width)) exitWith { _num = 1;};
						_i = _i + 1;
					};
					if(_num == 0) then //No objects around, its a good country roadblock
					{
						if(count (_road nearRoads (2*_width)) < 4) then //Don't put it at crossroads to avoid clusterfuck
						{
							_roadCountry pushBack _road;
						};
					};
				}
				else
				{
					if( _num > 1) then //There are some houses around, it's a good place to put a city roadblock
					{
						if(count (_road nearRoads (2*_width)) < 4) then //Don't put it at crossroads to avoid clusterfuck
						{
							_roadCity pushBack _road;
						};
					};
				};
			};
		};
	};
} forEach _nr;

_nr = _nr - _nrDelete;


//Plot markers
if(_debug) then
{
	{
		_wsmname = format ["rd_mrk_%1", findRoadblockRoadsCounter];
		_wsm = createMarkerLocal [_wsmName, getPos _x];
		//_wsm setMarkerTypeLocal "mil_box";
		_wsm setMarkerTypeLocal "b_maint";
		_wsm setMarkerColorLocal "ColorBlue";
		_wsm setMarkerAlphaLocal 1;
		findRoadblockRoadsCounter = findRoadblockRoadsCounter + 1;
	} forEach _roadCity;

	{
		_wsmname = format ["rd_mrk_%1", findRoadblockRoadsCounter];
		_wsm = createMarkerLocal [_wsmName, getPos _x];
		//_wsm setMarkerTypeLocal "mil_box";
		_wsm setMarkerTypeLocal "n_hq";
		_wsm setMarkerColorLocal "ColorGreen";
		_wsm setMarkerAlphaLocal 1;
		findRoadblockRoadsCounter = findRoadblockRoadsCounter + 1;
	} forEach _roadCountry;
};

//diag_log format ["Road count in the end: %1", count _nr];

[_roadCity, _roadCountry]