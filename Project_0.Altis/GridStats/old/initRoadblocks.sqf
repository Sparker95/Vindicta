//Clear previously spawned roadblocks

if(!isServer) exitWith {};

{
	if (toLower _x find "control" >= 0) then
	{
    	spawner setVariable [_x,Nil,true];
    };
} forEach markers;

markers = markers - controles;
controles = [];

_allMarkers = allMapMarkers;
{
	if (toLower _x find "control" >= 0) then
	{
		deleteMarker _x;
	};
} forEach _allMarkers;

mrkAAF = mrkAAF - (mrkAAF select {toLower _x find "control" >= 0});


//Spawn new roadblocks based on "ws_roadblock_xxx" markers
private _counter = 0;
private _rbpos = [0, 0, 0];
_allMarkers = allMapMarkers;
{
	if (toLower _x find "ws_roadblock" >= 0) then
	{
		//Hide ws_roadblock
		_x setmarkerAlpha 0;
		//Get new roadblock pos
		_rbpos = [_x] call ws_fnc_getRandomPosOnRoad;
		//Create new roadblock marker
		private _rbname = format ["control_%1", _counter];
		private _rbmrk = createMarker [_rbname, _rbpos];
		//_rbmrk setMarkerType "o_installation";
		_rbmrk setMarkerShape "RECTANGLE";
		_rbmrk setMarkerSize [50, 50];
		_rbmrk setMarkerText _rbname;
		_rbmrk setMarkerBrush "SolidFull";
		_rbmrk setMarkerColorLocal "ColorRed";
		_rbmrk setMarkerAlpha 0;
		controles pushBackUnique _rbmrk;
		mrkAAF = mrkAAF + [_rbmrk];
		_counter = _counter + 1;
		spawner setVariable [_rbmrk, false, true];
	};
} forEach _allMarkers;

markers = markers + controles;

publicVariable "markers";
publicVariable "controles";
publicVariable "mrkAAF";