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

//Check if the garrison has any transport
private _nTransport = 0;


//Check if the garrison has any troops
private _nTroops = 0;

private _score = 10000 - _d; //Now just make a simple calculation based on distance

_score