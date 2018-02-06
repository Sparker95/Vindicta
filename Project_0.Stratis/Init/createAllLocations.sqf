/*
Scans the whole map, creates all locations and initializes their spawn positions.
*/
private _allLocations = []; //An array with all locations

private _mrkPos = [0, 0, 0];
private _mrkSize = [0, 0];
private _ab = [0, 0];
private _radius = 0;
private _loc = objNull;
{
	_mrkPos = getMarkerPos _x;
	_loc = objNull;
	_ab = markerSize _x;
	call
	{
		if(_x find "base" == 0) exitWith
		{
			_loc = [_mrkPos, _x, LOC_TYPE_base] call loc_fnc_createLocation;
		};
		if(_x find "outpost" == 0) exitWith
		{
			_loc = [_mrkPos, _x, LOC_TYPE_outpost] call loc_fnc_createLocation;
		};
	};
	if(!(_loc isEqualTo objNull)) then
	{
		private _side = WEST;
		private _template = tNATO;
		if(_x find "_ind" > 0) then
		{
			_side = INDEPENDENT;
			_template = tAAF;
		}
		else
		{
			if(_x find "_east" > 0) then
			{
				_side = EAST;
				_template = tCSAT;
			};
		};

		_allLocations pushBack _loc;

		//Set the border type for this location
		_mrkSize = getMarkerSize _x;
		if(_mrkSize select 0 == _mrkSize select 1) then //if width==height, make it a circle
		{
			[_loc, _mrkSize select 0] call loc_fnc_setBorderCircle;
		}
		else //If width!=height, make border a rectangle
		{
			private _dir = markerDir _x;
			[_loc, _mrkSize select 0, _mrkSize select 1, _dir] call loc_fnc_setBorderRectangle;
		};

		_radius = vectorMagnitude [_ab select 0, _ab select 1, 0];
		//Initialize spawn positions
		[_loc] call loc_fnc_initSpawnPositions;

		//Add the main garrison to this location
		private _gar = [_loc] call loc_fnc_getMainGarrison;
		[_gar, _side] call gar_fnc_setSide;
		[_loc, _template] call loc_fnc_setMainTemplate;

		//Start the thread for this location
		[_loc] call loc_fnc_startThread;

		//Add marker
		//todo redo markers
		[_loc, _x] call loc_fnc_setMarker;
		[_loc] call loc_fnc_updateMarker;

	};
} forEach allMapMarkers;

//Delete all the markers
/*
{
	deleteMarker _x;
} forEach allMapMarkers;
*/

_allLocations