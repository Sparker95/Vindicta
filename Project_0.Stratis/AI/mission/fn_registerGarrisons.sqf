/*
This function checks all _garrisons and registers then to _missions they can take.
*/

#define DEBUG

params ["_missions", "_garrisons"];

for "_i" from 0 to ((count _garrisons) - 1) do
{
	private _gar = _garrisons select _i;
	//Check if the garrison is not doing any missions now and is located at its base
	if((isNull (_gar call gar_fnc_getAssignedMission)) && (_gar call gar_fnc_isStatic)) then
	{
		for "_j" from 0 to ((count _missions) - 1) do
		{
			private _m = _missions select _j;
			//Check if the mission is not started yet
			if ((_m call AI_fnc_mission_getState) == "IDLE") then {
				//Calculate efficiency
				private _eAndUnits = [_m, _gar] call AI_fnc_mission_calculateEfficiency;
				_eAndUnits params ["_e", "_units"];
				if (_e > 0) then { //If the garrison can do the mission
					[_m, _gar, _e, [_units]] call AI_fnc_mission_registerGarrison;
				};
			};
		};
	};
};