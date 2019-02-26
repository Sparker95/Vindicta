/*
This function stops the AI_fnc_manageSpottedEnemies.sqf script.
*/

params ["_lo"];

private _hScript = _lo getVariable ["g_enemiesThreadHandle", scriptNull];
if(! isNull _hScript) then
{
	terminate _hScript;
};
