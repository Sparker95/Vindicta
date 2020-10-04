[
    // Initial vehicle class name
    "B_AFV_Wheeled_01_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Sand",1], 
	["showCamonetHull",0,"showCamonetTurret",0,"showSLATHull",0.25]
] call BIS_fnc_initVehicle;

    }
]