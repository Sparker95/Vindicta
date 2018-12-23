#include "defineCommon.inc"

params["_objectTo", "_objectFrom","_data","_hitpointIndex"];

pr _displayName = _data select  VEHICLE_DATA_DISPLAYNAME;
pr _type = _data select  VEHICLE_DATA_TYPE;
pr _wheelSize = _data select  VEHICLE_DATA_WHEELSIZE;
pr _hitpoint = _data select  VEHICLE_DATA_HITPOINTS select _hitpointIndex;
pr _hitType = _data select VEHICLE_DATA_HITTYPES select _hitpointIndex;

pr _amountFrom = _objectFrom call JN_fnc_repair_getCargo;
pr _typeName = TYPE_VEHICLES select _type;

pr _skill = _objectFrom getVariable ["jn_repair_skill",1];
_repair = 0.5 max _skill;//can only repair with high skill


pr _cost = 100;
_cost = _cost * (switch (_hitType) do {
    case TYPE_WHEEL: {_repair = 1; _wheelSize/10};//always repair wheels 100%
    case TYPE_TRACK: {10};
    case TYPE_ENGINE: {10};
	case TYPE_FUEL: {5};
	case TYPE_BODY: {5};
	case TYPE_HULL: {5};
	case TYPE_GLASS: {2};
	case TYPE_LIGHT: {1};
});
_cost = _cost * (switch (_type) do {
	case TYPE_CAR:{1};
	case TYPE_ARMOR:{10};
	case TYPE_HELI:{20};
	case TYPE_PLANE:{20};
	case TYPE_NAVAL:{5};
	case TYPE_STATIC:{0.5};
});
_cost = round _cost;

_damage = _vehicle getHitPointDamage _hitpoint;

if(1-_repair >= _damage)exitWith{hint "cant repair part furter"};
if(_cost > _amountFrom)exitWith{hint "To less points"};


_vehicle setHitPointDamage [_hitpoint,1-_repair];

[_objectFrom,_amountFrom - _cost] call JN_fnc_repair_setCargo;

hint "repaired";




//add cancel action