/*
Get the group with specified __groupID.

Parameters:
_returnType:
	0 - return only the group array
	1 - return only the group's index in the group array
	2 - return [_groupArray, _groupIndex]
	_groupIndex = -1 if group not found
*/

params ["_lo", "_groupID", ["_returnType", 0]];

private _groups = _lo getVariable ["g_groups", []];

private _group = [];
private _foundGroup = [];
private _count = count _groups;
private _i = 0;
while{_i < _count} do
{
	_group = _groups select _i;
	//diag_log format ["current group: %1", _group];
	if(_group select 2 == _groupID) exitWith {_foundGroup = _group};
	_i = _i + 1;
};

if(_foundGroup isEqualTo []) then
{
	_i = -1;
};

switch (_returnType) do
{
	case 0:
	{
		_foundGroup
	};
	case 1:
	{
		_i
	};
	case 2:
	{
		[_foundGroup, _i]
	};
};
