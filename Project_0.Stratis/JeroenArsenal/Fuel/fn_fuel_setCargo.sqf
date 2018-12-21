#include "defineCommon.inc"

params [["_vehicle",objNull,[objNull]],["_amount",0,[0]],["_global",false]];

pr _cap = [_vehicle] call JN_fnc_fuel_getCargoCapacity;
if(_cap==0 || {_amount > _cap} || {_amount < 0})exitWith{};

_vehicle setVariable ["jn_fuel_cargo",_amount,_global];

//update vehicle mass
if(_global)then{
	pr _mass = _vehicle getVariable ["jn_mass", getmass _vehicle];//save default mass
	_vehicle setVariable ["jn_mass", _mass];
	_vehicle setMass (_mass * (1+((FLOAT_MASSMULTIPLIER-1)*_amount/_cap)));
};

pr _id = _vehicle getVariable "refuelAction_id";
if(!isNil "_id")then{
	_vehicle setUserActionText [_id, STR_ACTION_REFUEL(_amount,_cap)];
};