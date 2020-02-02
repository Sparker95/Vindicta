#include "defineCommon.inc"

params [ ["_vehicle",objNull,[objNull]] ];

pr _index = _vehicle call jn_fnc_common_vehicle_getVehicleType;
if (_index == -1) exitWith {nil};

pr _type = typeOf _vehicle;
pr _cfg = (configfile >> "CfgVehicles" >> _type);
pr _displayName = gettext(_cfg >> "displayName");
pr _name = _vehicle getVariable ["JNA_Name",_displayName];



//damage
pr _damage = getAllHitPointsDamage _vehicle;
if(_damage isEqualTo [])then{
	_damage = getDammage _vehicle;
}else{
	_damage = _damage select 2;
};




//Ammo
pr _ammoClassic = [];
{
	//magazinesAllTurrets type
	pr _magazine = _x select 0;
	pr _turret = _x select 1;
	pr _ammo = _x select 2;

	//skip pylon ammo
	if (gettext (configfile >> "CfgMagazines" >> _magazine >> "pylonWeapon") isEqualTo "")then{
		pr _found = false;
		{
			pr _turret2 = _x select 0;
			pr _magazine2 = _x select 1;
			pr _ammo2 = _x select 2;
			if(_turret isEqualTo _turret2 && _magazine2 isEqualTo _magazine)exitWith{
				_found = true;
				_ammoClassic set [_foreachindex,[_turret, _magazine, (_ammo + _ammo2)]];
			};
		} forEach _ammoClassic;

		if(!_found)then{
			_ammoClassic pushback [_turret, _magazine, _ammo];
		};
	};
} forEach magazinesAllTurrets _vehicle;

//pylon ammo
pr _ammoPylon = [];
{
	pr _type = _x;
	pr _amount = _vehicle ammoOnPylon (_foreachindex + 1);
	_ammoPylon pushback [_type,_amount];
} forEach getPylonMagazines _vehicle;

//texture

pr _toPlain = {
	_this = tolower _this;
	//remove first \
	if(_this select [0,1] isEqualTo "\")then{_this = _this select [1,count _this];};
	//remove .paa
	if(_this select [(count _this)-4,count _this] isEqualTo ".paa")then{
		_this = _this select [0,(count _this)-4];
	};
	_this//return
};
pr _texture = "";
pr _currentTexture = getObjectTextures _vehicle;
{
	_currentTexture set [_foreachindex, _x call _toPlain];
} forEach _currentTexture;

{
	pr _configName = configname _x;
	pr _displayName = gettext (_x >> "displayName");
	pr _found = false;
	if (_displayName != "") then {
		_found = true;
		{
			pr _texture = _x call _toPlain;
			if!(_texture in _currentTexture)exitWith{_found = false;};
		} forEach getarray (_x >> "textures");
	};
	if(_found) exitWith{_texture = _configName;};

} foreach (configproperties [_cfg >> "textureSources","isclass _x",true]);

//animations
pr _animations = [];
{
	pr _configName = configname _x;
	if(_vehicle animationPhase _configName == 1)then{
		_animations pushback _configName;
	};
} foreach (configproperties [_cfg >> "animationSources","isclass _x",true]);

//attachtedWeapons
pr _attachItem = [];
{
	pr _typeAndNodeID = _x getVariable ["jnl_cargo",[-1,0]];
	pr _type = _typeAndNodeID select 0;
	pr _nodeID = _typeAndNodeID select 1;
	if(_type == 0)exitWith{
		_attachItem = ((_x call jn_fnc_garage_getVehicleData) select 0);
	};
} forEach attachedObjects _vehicle;

//fuel
pr _fuel = _vehicle call JN_fnc_fuel_get;
pr _fuelCap = _vehicle call JN_fnc_fuel_getCapacity;

//fuel cargo
pr _fuelcargo = _vehicle call JN_fnc_fuel_getCargo;
pr _fuelcargoCap = _vehicle call JN_fnc_fuel_getCargoCapacity;

//fuel cargo
pr _ammocargo = _vehicle call JN_fnc_ammo_getCargo;
pr _ammocargoCap = _vehicle call JN_fnc_ammo_getCargoCapacity;

//fuel cargo
pr _repaircargo = _vehicle call JN_fnc_repair_getCargo;
pr _repaircargoCap = _vehicle call JN_fnc_repair_getCargoCapacity;

//set defaults
pr _beingChanged = "";
pr _locked = getPlayerUID player;
pr _lockedName = name player;

//return
COMPILE_SAVE

_data



