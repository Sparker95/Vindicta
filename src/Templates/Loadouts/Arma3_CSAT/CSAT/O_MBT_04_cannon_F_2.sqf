[
    // Initial vehicle class name
    "O_MBT_04_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Hex",1], 
	["showCamonetHull",1,"showCamonetTurret",1]
] call BIS_fnc_initVehicle;

    }
]