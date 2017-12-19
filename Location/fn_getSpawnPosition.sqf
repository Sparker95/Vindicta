/*
Gets a spawn position for a unit of specified category and subcategory.

Return value:
[x, y, z, direction]
*/

params ["_o", "_catID", "_subcatID", "_class", "_groupType"];

//First try to find it in building spawn positions
private _stAll = _o getVariable ["l_st", []]; //All spawn positions inside buildings of this location

//Local variables
private _stCurrent = [];
private _stFound = []; //The return value
private _types = [];
private _type = [];
//Find spawn position which has specified unit type
private _count = count _stAll;
private _count1 = 0;
private _i = 0;
private _j = 0;
private _found = false;
private _ignoreGT = (_catID == T_VEH); //Ignore the group type check for this unit
private _posAndDir = [];


if(_catID == T_INF) then //For infantry we use the counter to check for free position, because inf can be spawned everywhere without blowing up
{
	while {_i < _count && !_found} do
	{
		_stCurrent = _stAll select _i;
		_types = _stCurrent select 0;
		_count1 = count _types;
		_j = 0;
		if([_catID, _subcatID] in _types &&
		   ( _groupType in (_stCurrent select 3)) &&
		   ((count (_stCurrent select 1)) != (_stCurrent select 2))) then //If maximum amount hasn't been reached
		{
			private _spawnPositions = _stCurrent select 1;
			private _nextFreePosID = _stCurrent select 2;
			_posAndDIr = (_spawnPositions select _nextFreePosID) select [0, 4]; //Because the last element is _isInBuilding, which we don't need to return
			_stCurrent set [2, _nextFreePosID + 1]; //Increment the counter
			_found = true;
		};
		_i = _i + 1;
	};
}
else //For vehicles we use a special loc_fnc_isPosSafe function that checks if this place is occupied by something else
{
	while {_i < _count && !_found} do
	{
		_stCurrent = _stAll select _i;
		_types = _stCurrent select 0;
		_j = 0;
		if([_catID, _subcatID] in _types &&
			( _groupType in (_stCurrent select 3))) then
		{
			_type = _types select _j;
			//Find the first free spawn position
			{
				private _posFree = [_x, _class] call loc_fnc_isPosSafe;
				if(_posFree) exitWith
				{
					_posAndDir = _x select [0, 4];
					_found = true;
					private _nextFreePosID = _stCurrent select 2;
					_stCurrent set [2, _nextFreePosID + 1]; //Increment the counter, although it doesn't matter here
				};
			} forEach (_stCurrent select 1);
		};
		_i = _i + 1;
	};
};

private _return = [0, 0, 0, 0];
//diag_log format ["123: %1", _stCurrent];
/*
Old code that finds spawn positions based on counter.
//todo delete it
if(_found) then //If the category has been found
{
	private _spawnPositions = _stCurrent select 1;
	private _nextFreePosID = _stCurrent select 2;
	_return = (_spawnPositions select _nextFreePosID) select [0, 4]; //Because the last element is _isInBuilding, which we don't need to return
	_stCurrent set [2, _nextFreePosID + 1]; //Increment the counter
}
else
{
	//Provide default spawn position
	private _r = 15; //0.5 * (_o getVariable ["l_radius", 0]);
	_return = ((getPos _o) vectorAdd [-_r + (random (2*_r)), -_r + (random (2*_r)), 0]) + [0];
	diag_log format ["fn_getSpawnPosition.sqf: warning: spawn position not defined for this type or maximum amount was reached: %1. Returning default position.", [_catID, _subcatID, _groupType]];
};

*/
if(_found) then //If the spawn position has been found
{
		_return = _posAndDir;
}
else
{
	//Provide default spawn position
	private _r = 15; //0.5 * (_o getVariable ["l_radius", 0]);
	_return = ((getPos _o) vectorAdd [-_r + (random (2*_r)), -_r + (random (2*_r)), 0]) + [0];
	diag_log format ["fn_getSpawnPosition.sqf: warning: spawn position not defined for this type or maximum amount was reached: %1. Returning default position.", [_catID, _subcatID, _groupType]];
};

_return