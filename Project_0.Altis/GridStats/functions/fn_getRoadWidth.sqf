/*
Measures the width of a road object with given precision
paramerets: [_road, _precision, _maxWidth]
	_road - road object
	_precision - the precision with which to find the width
	_maxWidth - the maximum width. If the road is wider, the return value will max at _maxWidth
return value: number, road width or 0 if wrong road object was given
Author: Sparker
Date: 16.08.2017
*/

params [["_road", objNull, [objNull]], "_precision", "_maxWidth"];

if(isNull _road) exitWith {0}; //Wrong data was given

private _connectedRoads = roadsConnectedTo _road;

private _numConnectedRoads = count _connectedRoads;
if (_numConnectedRoads == 0) exitWith {0}; //Connected road not found, can't calculate direction

private _direction = 0;
if(_numConnectedRoads == 1) then //If it's the end of the road
{
	_direction = _road getDir (_connectedRoads select 0);
	//diag_log "Detected one connected road";
}
else //Else approximate the direction by the direction between two nearest segments
{
	_direction = (_connectedRoads select 0) getDir (_connectedRoads select 1);
	//diag_log "Detected two connected roads";
};

//Spawn an arrow facing the road
private _roadPos = getPos _road;
//Create arrow for debug
//_arrow = "Sign_Arrow_Blue_F" createVehicle _roadPos;
//_arrow setVectorDirAndUp [[0, 0, 1], [sin _direction, cos _direction, 0]];

//Get orthogonal direction
private _cos = cos (_direction+90);
private _sin = sin (_direction+90);
private _vectorDir = [_sin, _cos, 0];

//Find road width in one direction
private _checkPos = _roadPos;
private _testWidth = 0;
private _width = 0;
while {(_width <= _maxWidth) && (isOnRoad _checkPos)} do
{
	_width = _width + _precision;
	_testWidth = _testWidth + _precision;
	_checkPos = _roadPos vectorAdd (_vectorDir vectorMultiply _testWidth);

	//Create arrow for debug
	//"Sign_Arrow_Pink_F" createVehicle _checkPos;
};


//Find road width in another direction
_testWidth = 0;
_vectorDir = [-_sin, -_cos, 0]; //Rotate the vector 180 degrees
_checkPos = _roadPos;
while {(_width <= _maxWidth) && (isOnRoad _checkPos)} do
{
	_width = _width + _precision;
	_testWidth = _testWidth + _precision;
	_checkPos = _roadPos vectorAdd (_vectorDir vectorMultiply _testWidth);

	//Create arrow for debug
	//"Sign_Arrow_Pink_F" createVehicle _checkPos;
};

_width