#include "defineCommon.inc"
_vehicle = cursorObject;
pr _cfg = (configfile >> "CfgVehicles" >> typeof _vehicle);

pr _hitpoints = [];
pr _selections = [];
pr _hitType = [];
pr _loopTurrets = {
	diag_log configName _this;
	pr _hitpointCfgs = configProperties [_this >> "HitPoints", "isClass _x", true];
	{	
		pr _selection = getText(_x >> "name");
		if(_selection != "")then{
			if((_vehicle selectionPosition [_selection,"HitPoints"]) isEqualTo [0,0,0])exitWith{};
			pr _hitpoint = configName _x;
			_hitpoints pushBack _hitpoint;
			_selections pushBack getText(_x >> "name");
			_hitType pushBack (_hitpoint call {
				if(_this find "hitfuel"   != -1)exitWith{1};
				if(_this find "hitengine" != -1)exitWith{2};
				if(_this find "hitrtrack" != -1)exitWith{3};
				if(_this find "hitltrack" != -1)exitWith{4};
			});
		};
		
	}forEach _hitpointCfgs;
	
	pr _turretCfgs = configProperties [_this >> "Turrets", "isClass _x", true];
	{
		_x call _loopTurrets;
	}forEach _turretCfgs;
};
_cfg call _loopTurrets;

[_hitpoints,_selections,_hitType]

pr _reflectorsCfgs = configProperties [_cfg >> "Reflectors", "isClass _x", true];
{
	pr _reflectorsCfg = _x;
	_hitpoints pushBack ("#" + getText(_reflectorsCfg >> "hitpoint"));
	_selections pushBack getText(_reflectorsCfg >> "selection");
	_hitType pushBack "light";
	
}forEach _reflectorsCfgs;