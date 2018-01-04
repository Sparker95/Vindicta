/*
Adds a spawn position to to the spawn types array.

Each element in the spawn types array is:
[_typesArray, _posAndDirArray, _nextFreePosID, _groupType]
_typesArray - an array of [_catID, _subcatID]

_posAndDir - array [x, y, z, direction, _isInBuilding]
	_isInBuilding - false/true. If it's in building, it's added to a special array which can be refreshed in-game in case building gets destroyed. Otherwise it's added to non-refreshable array.
*/
params ["_o", "_typesArray", "_posAndDir", "_groupTypes", "_isInBuilding"];
private _stAll = [];

_stAll = _o getVariable ["l_st", []]; //All spawn positions of this location

private _stCurrent = [];
if(count _stAll > 0) then
{
	_stCurrent = _stAll select {((_x select 0) isEqualTo _typesArray) && ((_x select 3) isEqualTo _groupTypes)};
};

if (count _stCurrent == 0) then
{
	_stAll pushBack [_typesArray, [_posAndDir + [_isInBuilding]], 0, _groupTypes];
}
else
{
	//diag_log format ["%1", _stCurrent];
	private _positions = (_stCurrent select 0) select 1;
	_positions pushBack (_posAndDir + [_isInBuilding]);
};