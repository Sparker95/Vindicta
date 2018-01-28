/*
Calculates the score(suitability) of a garrison to do a specific mission.

Parameters:
	_mo - mission object
	_gar - garrison
	
Return value:
 	score - number
*/

params ["_mo", "_gar"];

private _d = _mo distance _gar;
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
_nTroops = _nTroops + [_gar, [[T_INF, -1]], G_GT_idle] call gar_fnc_countUnits;
_nTroops = _nTroops + [_gar, [[T_INF, -1]], G_GT_patrol] call gar_fnc_countUnits;

//Calculate score
private _score = 0; 
if (_nTroops > _mRequirements && _cargoCapacity > _mRequirements) then
{
	_score = (_nTroops/_mRequirements)*(10000 - _d); //Now just make a simple calculation based on distance
};

_score