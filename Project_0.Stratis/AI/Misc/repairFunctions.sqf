#define pr private

// What happens to a vehicle when a non-engineer AI repairs it
AI_misc_fnc_repairWithoutEngineer = {
	params [["_veh", objNull, [objNull]]];
	
	(getAllHitPointsDamage _veh) params ["_names", "_selections", "_damages"];
	pr _repairNames = ["wheel", "engine", "track", "fuel"];
	for "_i" from 0 to ((count _names) - 1) do
	{
		pr _name = _names select _i;
		// Repair wheels
		pr _needToRepair = (_repairNames findIf {_name find _x > 0}) != -1;
		if (_needToRepair) then {
			if (_damages select _i > 0.6) then {
				_veh setHit [_selections select _i, 0.6, true];
			};
		};
	};
	
	// Also refuel the car
	_veh setFuel 0.8;
};

// Returns true if any wheel or track is damaged on vehicle
AI_misc_fnc_isAnyWheelDamaged = {
	params [["_veh", objNull, [objNull]]];
	
	(getAllHitPointsDamage _veh) params ["_names", "_selections", "_damages"];
	pr _repairNames = ["wheel", "track"];
	pr _return = false;
	scopeName "s0";
	for "_i" from 0 to ((count _names) - 1) do
	{
		pr _name = _names select _i;
		// Repair wheels
		pr _isWheelOrTrack = (_repairNames findIf {_name find _x > 0}) != -1;
		if (_isWheelOrTrack) then {
			if (_damages select _i > 0.89) then {
				_return = true;
				breakTo "s0";
			};
		};
	};
	
	_return
};

