/*
Calculates the score(suitability) of a garrison to do a specific mission.

Parameters:
	_mo - mission object
	_gar - garrison
	
Return value:
 	score - number
*/

//#define DEBUG

params ["_mo", "_gar"];

//Read mission parameters
private _mParams = _mo getVariable "AI_m_params";
_mParams params ["_target"];

private _d = _target distance _gar;
private _mType = _mo getVariable "AI_m_type";
private _mRequirements = _mo getVariable "AI_m_requirements";

//Check if the garrison has any transport
private _nTransport = 0;
private _allVehicles = [_gar, T_VEH, -1] call gar_fnc_findUnits;
private _allVehicleClassnames = [];
{
	_allVehicleClassnames pushback ([_gar, _x] call gar_fnc_getUnitClassname);
} forEach _allVehicles;
private _cargoCapacity = _allVehicleClassnames call misc_fnc_getCargoInfantryCapacity; //Calculate amount of troops they all can transport

//Check if the garrison has any troops
private _nTroops = 0;
_nTroops = _nTroops + ([_gar, [[T_INF, -1]], G_GT_idle] call gar_fnc_countUnits);
_nTroops = _nTroops + ([_gar, [[T_INF, -1]], G_GT_patrol] call gar_fnc_countUnits);

//diag_log format ["===== _nTroops: %1, _mRequirements: %2, _cargoCapacity: %3", _nTroops, _mRequirements, _cargoCapacity];

//Calculate score
private _score = 0;
if (_nTroops > _mRequirements && _cargoCapacity > _mRequirements) then
{
	_score = (10000 - _d); //Now just make a simple calculation based on distance
};

#ifdef DEBUG
diag_log format ["INFO: fn_calculateEfficiency: garrison: %1, efficiency: %2", _gar call gar_fnc_getName, _score];
#endif

_score