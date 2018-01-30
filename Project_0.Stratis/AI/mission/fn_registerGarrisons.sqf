/*
This function checks all _garrisons and registers then to _missions they can take.
*/

#define DEBUG

params ["_missions", "_garrisons"];

for "_i" from 0 to ((count _garrisons) - 1) do
{
	private _gar = _garrisons select _i;
	//Check if the garrison is not doing any missions now
	if(isNull (_gar call gar_fnc_getAssignedMission)) then
	{
		for "_j" from 0 to ((count _missions) - 1) do
		{
			private _m = _missions select _j;	
			//Calculate efficiency
			private _e = [_m, _gar] call AI_fnc_mission_calculateEfficiency;
			if (_e > 0) then //If the garrison can do the mission
			{
				[_m, _gar, _e] call AI_fnc_mission_registerGarrison;
			};
		};
	};
};