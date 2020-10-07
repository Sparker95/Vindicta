[
    // Initial vehicle class name
    "O_T_MBT_02_cannon_ghex_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["GreenHex",1], 
	["showCamonetHull",0,"showCamonetTurret",0,"showLog",0.4]
] call BIS_fnc_initVehicle;
    }
]