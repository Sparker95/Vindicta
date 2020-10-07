[
    // Initial vehicle class name
    "O_T_MBT_04_command_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["GreenHex",1], 
	["showCamonetHull",0,"showCamonetTurret",0]
] call BIS_fnc_initVehicle;
    }
]