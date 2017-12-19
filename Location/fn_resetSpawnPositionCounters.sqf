params ["_loc"];

private _stAll = _loc getVariable ["l_st", []];

{
	_x set [2, 0];
} forEach _stAll;