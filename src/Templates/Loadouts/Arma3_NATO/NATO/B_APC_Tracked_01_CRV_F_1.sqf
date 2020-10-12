[
    // Initial vehicle class name
    "B_APC_Tracked_01_CRV_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Sand",1], 
	["showAmmobox",0.75,"showWheels",0.25,"showCamonetHull",0.5,"showBags",0.4]
] call BIS_fnc_initVehicle;
    }
]