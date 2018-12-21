#include "defineCommon.inc"

params ["_item","_array"];

pr _return = 0;
{
	if((_x select 0) isEqualTo _item)exitWith{_return = (_x select 1)};
}forEach _array;

_return;
