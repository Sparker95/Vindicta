/*
Calculates the score(suitability) of a garrison to do a specific mission.

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

switch (_mType) do
{
	case "SAD": {
		_mRequirements params ["_effReq"];
		//Calculate the total efficiency of the garrison
		private _eff = T_EFF_null;
		{
			_eff = [_eff, _x call T_fnc_getEfficiency] call BIS_fnc_vectorAdd;
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
		
		//Check if the garrison has any transport
		private _nTransport = 0;
		private _allVehicles = [_gar, T_VEH, -1] call gar_fnc_findUnits;
		private _allVehicleClassnames = [];
		{
			_allVehicleClassnames pushback ([_gar, _x] call gar_fnc_getUnitClassname);
		} forEach _allVehicles;
		private _cargoCapacity = _allVehicleClassnames call misc_fnc_getCargoInfantryCapacity; //Calculate amount of troops they all can transport
		
		//Check if the garrison has any troops
		/*
		private _nTroops = 0;
		_nTroops = _nTroops + ([_gar, [[T_INF, -1]], G_GT_idle] call gar_fnc_countUnits);
		_nTroops = _nTroops + ([_gar, [[T_INF, -1]], G_GT_patrol] call gar_fnc_countUnits);
		*/
		
		//diag_log format ["===== _nTroops: %1, _mRequirements: %2, _cargoCapacity: %3", _nTroops, _mRequirements, _cargoCapacity];
		
		#ifdef DEBUG
		diag_log format ["INFO: fn_calculateEfficiency: garrison: %1, _eff: %2, _effReq: %3, _canDestroy: %4, _cargoCapacity: %5, _d: %6",
			_gar call gar_fnc_getName, _eff, _effReq, _canDestroy, _cargoCapacity, _d];
		#endif
		
		//Calculate score
		if (_canDestroy && (_cargoCapacity > (_effReq select T_EFF_soft)) ) then
		{
			if (_d < 10000) then {
				_score = (10000 - _d); //Now just make a simple calculation based on distance
			};
		};
	};
};

#ifdef DEBUG
diag_log format ["INFO: fn_calculateEfficiency: garrison: %1, efficiency: %2", _gar call gar_fnc_getName, _score];
#endif

_score