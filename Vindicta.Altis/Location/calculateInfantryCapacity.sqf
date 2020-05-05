// Class: Location
/*
Method: calculateInfantryCapacity
Calculates infantry capacity based on buildings in this location.

Returns: Number - amount of infantry soldeirs that can stay here

Author: Sparker 03.08.2018
*/

#include "..\common.h"
#include "..\Group\Group.hpp"
#include "..\Garrison\Garrison.hpp"

params [P_THISOBJECT];

private _radius = T_GETV("boundingRadius");
private _locPos = T_GETV("pos");
private _no = _locPos nearObjects _radius;

private _capacity = 0;
{
	if (_x isKindOf "House") then {
		if(T_CALLM("isInBorder", [_x])) then {
			private _class = typeOf _x;
			//Infantry capacities of buildings
			_bc = location_b_capacity select { _class in (_x select 0)};
			if(count _bc > 0 && ((getDammage _x) < 0.99999)) then { //If the building isn't destroyed yet
				_capacity = _capacity + ((_bc select 0) select 1); //Increase the infantry capacity of this location
			};
		};
	};
} forEach _no;

T_SETV("capacityInf", _capacity);