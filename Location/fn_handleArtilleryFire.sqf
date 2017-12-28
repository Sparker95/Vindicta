/*
This function is called at the server when artillery shells are landing at the location.
*/

params ["_loc", "_posLaunch", "_reportFire"];

[_loc, 120] call loc_fnc_setForceSpawnTimer;

if(_reportFire) then
{
	//todo check if the location actually has the artillery radar or not
	//todo report to the artillery radar of this faction!
	[globalArtilleryRadar, _posLaunch, getPos _loc] call sense_fnc_reportArtilleryFire;
};