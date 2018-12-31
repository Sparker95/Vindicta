// Class: Location
/*
Method: calculateInfantryCapacity
Calculates infantry capacity based on buildings in this location.

Returns: Number - amount of infantry soldeirs that can stay here

Author: Sparker 03.08.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"

params [ ["_thisObject", "", [""]] ];

private _radius = GET_VAR(_thisObject, "boundingRadius");
private _locPos = GET_VAR(_thisObject, "pos");
private _no = _locPos nearObjects _radius;

private _capacity = 0;
{
	if (_x isKindOf "House") then {
		if(CALL_METHOD(_thisObject, "isInBorder", [_x])) then {
			private _class = typeOf _x;
			//Infantry capacities of buildings
			_bc = location_b_capacity select { _class in (_x select 0)};
			if(count _bc > 0 && ((getDammage _x) < 0.99999)) then { //If the building isn't destroyed yet
				_capacity = _capacity + ((_bc select 0) select 1); //Increase the infantry capacity of this location
			};
		};
	};
} forEach _no;

SET_VAR(_thisObject, "capacityInf", _capacity);