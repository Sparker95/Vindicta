/*
Deploys roadblocks along the frontline
Author: Sparker

Parameters:
[_zc, _zcCheck, _dir, _keepoutMarkers, _keepoutRadius]
_zc - a grid array of elements where the roadblocks should be put. Non zero value rezult in roadblock generation.
_zcCheck - a grid array used to check if the roadblock is still at the frontline. Should be like _zc but a bit smoother to account for roadblocks spawned outside of initial square.
_dir = a grid array with directions
_keeputMarkers - array of markers where doadblock shoudln'tbe placed
_keepoutRadius - the radius at which to avoid previously placed roadblock markers and keepout markers

Return value: total ammount of added roadblocks
*/

params ["_zc", "_zcCheck", "_dir", "_keepoutMarkers", "_keepoutRadius", ["_debug", false]];

//Initialize the global roadblock counter
if(isNil "controlesCounter") then
{
	diag_log "fn_putRoadblockMarkerAtFrontline.sqf: controlesCounter not initialized! Removing previous roadblock markers.";
	controlesCounter = 0;
	mrkFIA = mrkFIA - controles;
	controles = [];
	publicVariable "mrkFIA";
	//call compile preprocessFileLineNumbers "WarStatistics\initRoadblocks2.sqf"; //Clear previously spawned roadblocks
};

//Remove old markers
if(_debug) then
{
	_allMarkers = allMapMarkers;
	{
		if (toLower _x find "rb_fr" >= 0) then
		{
			deleteMarkerLocal _x;
		};
	} forEach _allMarkers;
};

private _road = objNull;
private _frontlineDir = 0;
private _roadDir = 0;
private _angle = 0;
private _value = 0;
private _gridPos = [0, 0, 0];
private _halfSize = 0.5*ws_squareSize;
private _newRbCounter = 0;
private _newRbMarkers = [];
private _rb = [];
private _priority = 0;
private _numAttempts = 0;

private _wsm = "";
private _wsmname = "";
private _roadCity = [];
private _roadCountry = [];
private _roadCitySorted = [];
private _roadCountrySorted = [];
private _roadsToCheck = [];
private _roadsAtGoodDistance = [];
private _roadGood = true;
private _mrkPos = [0, 0, 0];
private _rbData = [];

private _connectedRoads = [];

private _rbname = "";
private _rbmrk = "";

private _rbCompositions = [
"Compositions\cmp_roadblock_enemy_big_city.sqf",
"Compositions\cmp_roadblock_enemy_big_country.sqf",
"Compositions\cmp_roadblock_enemy_medium_city.sqf",
"Compositions\cmp_roadblock_enemy_medium_country.sqf",
"Compositions\cmp_roadblock_enemy_medium_city.sqf", //Don't have compositions for tiny roads yet
"Compositions\cmp_roadblock_enemy_medium_country.sqf"
];

for [{private _i = 0}, {_i < ws_gridSizeX}, {_i = _i + 1}] do //_i is x-pos
{
	for [{private _j = 0}, {_j < ws_gridSizeY}, {_j = _j + 1}] do //_j is y-pos
	{
		_value = [_zc, _i, _j] call ws_fnc_getValueID;
		if(_value != 0) then //Try to put a roadblock here
		{
			_gridPos = [ws_squareSize*_i + _halfSize + ws_gridStartX, ws_squareSize*_j + _halfSize + ws_gridStartY, 0];
			_frontlineDir = [_dir, _i, _j] call ws_fnc_getValueID; //Desired direction of the roadblock

			//Try to find a new position for a roadblock
			_rb = [_gridPos, 1.4*_halfSize, 10, _frontlineDir, 60, _newRbMarkers + _keepoutMarkers + ["FIA_HQ"], _keepoutRadius, _debug] call ws_fnc_findRoadblockRoads;
			_roadCitySorted = [_rb select 0] call ws_fnc_sortRoadsByWidth; //Sort roads by width
			_roadCountrySorted = [_rb select 1] call ws_fnc_sortRoadsByWidth;
			_roadsToCheck = [_roadCitySorted select 0, _roadCountrySorted select 0, _roadCitySorted select 1, _roadCountrySorted select 1, _roadCitySorted select 2, _roadCountrySorted select 2]; //Bigger roads in cities have highest priority
			_priority = 0;
			/*
			_priority:
			0 - big city road
			1 - big country road
			2 - medium city road
			3 - medium country road
			4 - small city road
			5 - small country road
			*/
			while {_priority < 6} do
			{
				if(count (_roadsToCheck select _priority) > 0) exitWith
				{
					//Good position found! Put a roadblock marker here.
					_road = selectRandom (_roadsToCheck select _priority);
					_connectedRoads = roadsConnectedTo _road;
					_rbpos = getPos _road;

					//Create a marker for controles array
					_rbname = format ["ws_control_%1", controlesCounter];
					_rbmrk = createMarker [_rbname, _rbpos];
					_rbmrk setMarkerShape "RECTANGLE";
					_rbmrk setMarkerSize [50, 50];
					_rbmrk setMarkerBrush "SolidFull";
					_rbmrk setMarkerColor "ColorGreen";
					if(_debug) then
					{
						_rbmrk setMarkerAlpha 0.8;
					}
					else
					{
						_rbmrk setMarkerAlpha 0.0;
					};
					_newRbMarkers pushBack _rbmrk;
					controles pushBackUnique _rbmrk;
					publicVariable "controles";

					controlesCounter = controlesCounter + 1;
					_newRbCounter = _newRbCounter + 1;

					//Set the composition data
					//Detect which way the roadblock should be facing
					if(count _connectedRoads == 1) then //If it's the end of the road
					{
						_roadDir = _road getDir (_connectedRoads select 0);
						diag_log "fn_putRoadblockMarkersAtFrontline.sqf: Error: the roadblock road has only one connected road!";
					}
					else //Else approximate the direction by the direction between two nearest segments
					{
						_roadDir = (_connectedRoads select 0) getDir (_connectedRoads select 1);
					};
					_angle = abs (_roadDir - _frontlineDir);
					//Make the angle in the range -180 ... +180
					while {abs (_angle) > 180} do	{
						if(_angle < 0) then {_angle = _angle + 360;}
						else {_angle = _angle - 360;};
					};
					if((abs _angle) < 90) then {_roadDir = _roadDir + 180;}; //Rotate it around if it's not facing the FIA territory
					_rbData = [call compile preprocessFileLineNumbers (_rbCompositions select _priority), _roadDir];
					roadblocksEnemy setVariable [_rbmrk, _rbData];


					diag_log format ["fn_putRoadblockMarkerAtFrontline.sqf: adding a new roadblock at %1. Roadblock priority: %2 Marker name: %3. Suspending thread.", _rbpos, _priority, _rbmrk];

					//Start a new thread for the new roadblock marker
					[_rbpos, _rbmrk, _zcCheck] spawn
					{
						private _sleepInterval = 1;
						private _rbpos = _this select 0;
						private _rbname = _this select 1;
						private _check = _this select 2;
						private _a = 0;
						while{true} do
						{
							sleep _sleepInterval;
							//Check if the place is still at frontline
							if(([_check, _rbpos select 0, _rbpos select 1] call ws_fnc_getValue) == 0) exitWith //This location is no longer at frontline, remove it
							{
								diag_log format ["fn_putRoadblockMarkerAtFrontline.sqf: roadblock was not spawned and is no longer at frontline. Marker name: %1", _rbname];
								controles = controles - [_rbname];
								publicVariable "controles";
								deleteMarker _rbname;
								roadblocksEnemy setVariable [_rbname, nil];
							};
							//Check if there are no players around
							if(({_x distance _rbpos < 2*distanciaSPWN} count allPlayers) == 0) exitWith //There are no players around, put a roadblock here
							{
								_rbname setMarkerColor "ColorRed";
								mrkAAF pushBackUnique _rbname;
								spawner setVariable [_rbname, false, true];
								markers pushBackUnique _rbname;
								publicVariable "markers";
								publicVariable "mrkAAF";
								diag_log format ["fn_putRoadblockMarkerAtFrontline.sqf: added a new roadblock marker. Marker name: %1", _rbname];
								_a = 2;
							};
						};
						if(_a == 2) then //The roadblock has been put on the map. Now wait till it gets destroyed or till it's not at frontline any more
						{
							_a = 0;
							while {true} do //Wait until it gets destroyed or it's no longer at the frontline
							{
								sleep _sleepInterval;
								if(!(_rbname in controles)) exitWith {_a = 1;}; //It was killed
								if((([_check, _rbpos select 0, _rbpos select 1] call ws_fnc_getValue) == 0)) exitWith {_a = 2;}; //Roadblock is no longer at frontline
							};
							if(_a == 1) then
							{
								diag_log format ["fn_putRoadblockMarkerAtFrontline.sqf: roadblock has been destroyed. Terminating thread. Marker name: %1", _rbname];
							};
							if(_a == 2) then
							{
								waitUntil {sleep _sleepInterval; !(spawner getVariable _rbname)};
								//Now delete the marker
								mrkAAF = mrkAAF - [_rbname];
								markers = markers - [_rbname];
								controles = controles - [_rbname];
								publicVariable "mrkAAF";
								publicVariable "markers";
								publicVariable "controles";
								spawner setVariable [_rbname, nil, true];
								deleteMarker _rbname;
								roadblocksEnemy setVariable [_rbname, nil];
								diag_log format ["fn_putRoadblockMarkerAtFrontline.sqf: roadblock is no longer at the frontline and has been removed. Marker name: %1", _rbname];
							};
						};
					};

				};
				_priority = _priority + 1;
			};
		};
	};
};

_newRbCounter