/*
Gets the amount of spawn positions suitable for specified unit type
*/

params ["_o", "_catID", "_subcatID", "_groupType"];

private _stAll = _o getVariable ["l_st", []];
private _type = [_catID, _subcatID];
//private _ignoreGT = (_catID == T_VEH); //Ignore the group type check for this kind of unit
//private _stSuitable = _stAll select {((_type in (_x select 0))) && ((_x select 3) == _groupType || _ignoreGT)};
private _stSuitable = _stAll select {((_type in (_x select 0))) && (_groupType in (_x select 3))};

private _capacity = 0;
{
	_capacity = _capacity + (count (_x select 1));
} forEach _stSuitable;

_capacity