#include "common.hpp"

/*
Inherits basic flee action, but in case of civilians it provides its own flee pos
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitCivilianFlee
CLASS("ActionUnitCivilianFlee", "ActionUnitFlee")

	METHOD(new)
		params [P_THISOBJECT];

		pr _cp = GETV(T_GETV("AI"), "cpModule");
		pr _fleepos = [_this,1] call bis_fnc_cp_getSafespot;
		T_SETV("fleePos", _fleePos);
	ENDMETHOD;

ENDCLASS;
