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