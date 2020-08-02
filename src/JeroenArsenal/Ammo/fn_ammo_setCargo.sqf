#include "defineCommon.inc"

params [["_vehicle",objNull,[objNull]],["_amount",0,[0]]];

pr _cap = [_vehicle] call JN_fnc_ammo_getCargoCapacity;
if(_cap==0 || {_amount > _cap} || {_amount < 0})exitWith{false};

_vehicle setVariable ["jn_ammo_cargo",_amount];

//update vehicle mass
pr _mass = _vehicle getVariable ["jn_mass", getmass _vehicle];//save default mass
_vehicle setVariable ["jn_mass", _mass];
_vehicle setMass (_mass * (1+((FLOAT_MASSMULTIPLIER-1)*_amount/_cap)));

pr _id = _vehicle getVariable "rearmAction_id";
if(!isNil "_id")then{
	ACTION_SET_ICON_AND_TEXT(_vehicle, _id, STR_ACTION_TEXT_REARM(_amount,_cap), STR_ACTION_ICON_REARM);
};

true;