/* 
	
	Global variables for checking if certain mods are loaded

*/

#define activeACE bActiveACE
#define activeCBA bActiveCBA

activeACE = false;
activeCBA = false;

// check if mod is active and set variable
if (isClass (configFile >> "CfgPatches" >> "ace_main")) then { activeACE = true; };
if (isClass (configfile >> "CfgVehicles" >> "CBA_main_require")) then { activeCBA = true; };

