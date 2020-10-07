[
    // Initial vehicle class name
    "O_T_MBT_04_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["GreenHex",1], 
	["showCamonetHull",1,"showCamonetTurret",1]
] call BIS_fnc_initVehicle;
    }
]