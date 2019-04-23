#include "Efficiency.hpp"
/*
Checks two efficiency vectors.
Returns amount of efficiency categories that _e1 can destroy in _e2.
*/

params ["_e1", "_e2"];

private _ret = 0;
private _j = 0;
for "_i" from T_EFF_ANTI_SOFT to T_EFF_ANTI_AIR do {
	if ((_e1 select _i) >= (_e2 select _j)) then {
		_ret = _ret + 1;
	};
	_j = _j + 1;
};

_ret
