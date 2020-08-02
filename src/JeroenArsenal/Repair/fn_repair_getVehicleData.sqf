#include "defineCommon.inc"

params [["_vehicle",objNull,[objNull]]];

if(isnull _vehicle)exitWith{};

pr _cfg = (configfile >> "CfgVehicles" >> typeof _vehicle);

pr _displayName = getText(_cfg >>"displayname");

diag_log _displayName;

pr _type = _vehicle call JN_fnc_common_vehicle_getVehicleType;

pr _size = getNumber(_cfg >> "mapsize");

pr _armor = getNumber(_cfg >> "armor");


pr _AllHitPointsDamage = getAllHitPointsDamage _vehicle;
pr _hitpoints = [];
pr _selections = [];
pr _hitTypes = [];

{
	pr _hitpoint = _x;
	pr _selection = (_AllHitPointsDamage select 1) select _forEachIndex;
	if(!(_hitpoint in _hitpoints) && !((_vehicle selectionPosition [_selection,"HitPoints"]) isEqualTo [0,0,0]))then{
		pr _hitType = ([_hitpoint,_selection] call {
			params ["_hitpoint","_selection"];
				if(_selection find "wheel"    != -1)exitWith{TYPE_WHEEL};
				if(_hitpoint find "hitfuel"   != -1)exitWith{TYPE_FUEL};
				if(_hitpoint find "hithull"   != -1)exitWith{TYPE_HULL};
				if(_hitpoint find "hitbody"   != -1)exitWith{TYPE_BODY};
				if(_hitpoint find "hitglass"  != -1)exitWith{TYPE_GLASS};
				if(_hitpoint find "hitengine" != -1)exitWith{TYPE_ENGINE};
				if(_hitpoint find "hitrtrack" != -1)exitWith{TYPE_TRACK};
				if(_hitpoint find "hitltrack" != -1)exitWith{TYPE_TRACK};
				if(_hitpoint find "#" 		  ==  0)exitWith{TYPE_LIGHT};
				-1;
		});
		
		if!(_hitType in [-1, TYPE_LIGHT])then{//we add lights later
			_hitpoints pushBack _hitpoint;
			_selections pushBack _selection;
			_hitTypes pushBack _hitType;
		};
	};
}forEach (_AllHitPointsDamage select 0);

pr _reflectorsCfgs = configProperties [_cfg >> "Reflectors", "isClass _x", true];
pr _lights = [];
{
	pr _reflectorsCfg = _x;

	pr _hitpoint = ("#" + getText(_reflectorsCfg >> "hitpoint"));
	pr _selection = getText(_reflectorsCfg >> "position");
	pr _pos = _vehicle selectionPosition _selection;
	pr _distance = _pos distance [0,0,0];
	pr _found = false;
	{
		_x params ["_hitpoint1","_selection1","_distance1"];
		if(_hitpoint isEqualTo _hitpoint1)then{
			_found = true;
			if(_distance < _distance1)then{
				_lights set [_forEachIndex, [_hitpoint,_selection,_distance]];
			};
		}
	}forEach _lights;
	
	if(!_found)then{_lights pushBack [_hitpoint,_selection,_distance]};
	
}forEach _reflectorsCfgs;

{
	_x params ["_hitpoint","_selection"];
	_hitpoints pushBack _hitpoint;
	_selections pushBack _selection;
	_hitTypes pushBack TYPE_LIGHT;
	diag_log [_hitpoint,_selection];
}forEach _lights;


pr _wheelSize = -1;
pr _wheelCfgs = configProperties [_cfg >> "Wheels", "isClass _x", true];
if(count _wheelCfgs > 0)then{_wheelSize = getNumber(_wheelCfgs select 0 >> "width")};


[_displayName,_type,_size,_armor,_wheelSize,_hitpoints,_selections,_hitTypes]

