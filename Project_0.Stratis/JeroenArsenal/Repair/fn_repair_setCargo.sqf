#include "defineCommon.inc"

params [["_object",objNull,[objNull]],["_amount",0,[0]],["_global",false]];

pr _isUnit = _object isKindOf "Man";

pr _cap = [_object] call JN_fnc_repair_getCargoCapacity;
if(_amount > _cap || {_amount < 0} || {!_isUnit && _cap==0 })exitWith{false};

_object setVariable ["jn_repair_cargo",_amount];

//update vehicle mass
if(!_isUnit)then{
	pr _mass = _object getVariable ["jn_mass", getmass _object];//save default mass
	_object setVariable ["jn_mass", _mass];
	_object setMass (_mass * (1+((FLOAT_MASSMULTIPLIER-1)*_amount/_cap)));

	pr _id = _object getVariable ["repairAction_id",nil];//error here? you need to initilise action first
	if(!isNil "_id")then{
		_object setUserActionText [_id, STR_ACTION_REPAIR(_amount,_cap)];
	};
};

true;