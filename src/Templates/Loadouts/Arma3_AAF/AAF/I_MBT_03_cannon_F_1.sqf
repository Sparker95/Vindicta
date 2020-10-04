[
    // Initial vehicle class name
    "I_MBT_03_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Indep_01",1], 
	["HideTurret",0,"HideHull",0,"showCamonetHull",0,"showCamonetTurret",0]
] call BIS_fnc_initVehicle;
    }
]