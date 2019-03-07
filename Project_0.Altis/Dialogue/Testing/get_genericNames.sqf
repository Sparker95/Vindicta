
/*
    By: Jeroen Notenbomer

    Function to find all ingame first and last names.
	Should maybe run on preinit

	Input:
		
    Output: 
		[_firstNames,_lastNames] // array of arrays

*/


private _genericNames = missionNameSpace getVariable ["GenericNames",[]];

if!(_genericNames isequalto [])exitWith{_genericNames};

private _firstNames = [];
private _lastNames = [];

{
	if!(_x isequalto (configfile >> "CfgWorlds" >> "GenericNames" >> "Default"))then{
		{
			_firstNames pushBackUnique  getText _x;
		}forEach (configProperties [_x >> "LastNames"]);
		
		{
			_lastNames pushBackUnique getText _x;
		}forEach (configProperties [_x >> "FirstNames"]);
	};
}forEach configProperties [configfile >> "CfgWorlds" >> "GenericNames"];

missionNameSpace setVariable ["GenericNames",[_firstNames,_lastNames]];