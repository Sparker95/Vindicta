/*
Checks if given position is in area of given location.
_pos - position or object
*/

params ["_loc", "_pos"];

private _bt = _loc getVariable ["l_borderType", 0];
private _bd = _loc getVariable ["l_borderData", 0];
private _return = false;
//diag_log format ["bt: %1, bd: %2", _bt, _bd];
switch (_bt) do
{
	case 0:	//Circle
	{
		_return = (_loc distance _pos) < _bd;
		//diag_log format ["distance: %1 bd: %2", _loc distance _pos, _bd];
	};

	case 1: //Rectangle
	{
		_return = (_pos inArea [_loc, _bd select 0, _bd select 1, _bd select 2, true]);
	};
};

_return
