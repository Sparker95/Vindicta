/* 
	
	Global variables for checking if certain mods are loaded

*/

activeACE = false;
activeCBA = false;
activeRHSAFRF = false;
activeRHSUSAF = false;
active3CBFactions = false;

// check if mod is active and set variable
if (isClass (configFile >> "CfgPatches" >> "ace_main")) then { activeACE = true; };
if (isClass (configfile >> "CfgVehicles" >> "CBA_main_require")) then { activeCBA = true; };
if (isClass (configFile >> "CfgPatches" >> "rhsusf_c_f22")) then { activeRHSUSAF = true; };
if (isClass (configFile >> "CfgPatches" >> "rhs_btr70")) then { activeRHSAFRF = true; };
if (isClass (configFile >> "CfgPatches" >> "UK3CB_Factions_Common")) then { active3CBFactions = true; };