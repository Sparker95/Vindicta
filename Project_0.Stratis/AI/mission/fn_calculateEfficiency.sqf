/*
Calculates the score(suitability) of a garrison to do a specific mission and tries to allocate units for the mission.

Parameters:
	_mo - mission object
	_gar - garrison
	
Return value:
 	score - number
*/

#define DEBUG

params ["_mo", "_gar"];

//Read mission parameters
private _mParams = _mo getVariable "AI_m_params";
_mParams params ["_target"];

private _d = _target distance _gar;
private _mType = _mo getVariable "AI_m_type";
private _mRequirements = _mo getVariable "AI_m_requirements";
private _score = 0;
private _unitsAllocated = [];

switch (_mType) do
{
	case "SAD": {
		_mRequirements params ["_effReq", "_clusterStruct"];
		
		//Check if this garrison already sees the target
		private _garsReportTarget = _clusterStruct select 3; //Check the structure of this in Sense/enemyMonitor.sqf
		private _canSeeTarget = _gar in _garsReportTarget;
		//Check alert state
		private _loc = _gar call gar_fnc_getLocation;
		private _as = _loc call loc_fnc_getAlertState;
		
		if (_as == LOC_AS_safe || _as == LOC_AS_aware || _canSeeTarget) then {
			//Calculate the total efficiency of the garrison
			private _eff = T_EFF_null;
			{
				private _ut = [_x select 0, _x select 1]; //[catId, subcatID] of the unit
				if (! (_ut in T_static)) then { //Exclude static units (turrets)
					_eff = [_eff, _x call T_fnc_getEfficiency] call BIS_fnc_vectorAdd;
				};
			} forEach (_gar call gar_fnc_getAllUnits);
			
			//Check if the garrison can destroy the target
			/*
			T_EFF_soft =	0;
			T_EFF_medium =	1;
			T_EFF_armor =	2;
			T_EFF_air =		3;
			T_EFF_aSoft =	4;
			T_EFF_aMedium =	5;
			T_EFF_aArmor =	6;
			T_EFF_aAir =	7;
			*/
			private _canDestroy = false;
			if ((_eff select T_EFF_aSoft) >= (_effReq select T_EFF_soft) &&
				(_eff select T_EFF_aMedium) >= (_effReq select T_EFF_medium) &&
				(_eff select T_EFF_aArmor) >= (_effReq select T_EFF_armor) &&
				(_eff select T_EFF_aAir) >= (_effReq select T_EFF_air)) then {
					_canDestroy = true;
			};
			
			if (_canDestroy) then {				
				//Try to plan the mission (preallocate units)
				_unitsAllocated = [_mo, _gar] call AI_fnc_mission_allocateUnits;
				
				//Calculate score
				if (count _unitsAllocated != 0) then {
					if (_d < 10000) then {
						_score = (10000 - _d); //Now just make a simple calculation based on distance
					};
				};
				#ifdef DEBUG
				diag_log format ["INFO: fn_calculateEfficiency: garrison: %1, _eff: %2, _effReq: %3, _canDestroy: %4, _d: %5, _canSeeTarget: %6",
					_gar call gar_fnc_getName, _eff, _effReq, _canDestroy, _d, _canSeeTarget];
				diag_log format ["INFO: fn_calculateEfficiency: _score: %1, _unitsAllocated: %2",
					_score, _unitsAllocated];
				
				diag_log "";
				#endif
			};
		};
	};
};

[_score, _unitsAllocated]