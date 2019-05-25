/*
Function: misc_fnc_getRoadWidth
Measures the width of a road object with given precision

Parameters: _road, _precision, _maxWidth

_road - road object
_precision - the precision with which to find the width
_maxWidth - the maximum width. If the road is wider, the return value will max at _maxWidth

return value: number, road width or 0 if wrong road object was given

Author: Sparker
Date: 16.08.2017
*/

params [["_road", objNull, [objNull]], "_precision", "_maxWidth"];

if(isNull _road) exitWith {0}; //Wrong data was given

private _direction = [_road] call misc_fnc_getRoadDirection;

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