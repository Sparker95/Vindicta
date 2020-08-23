[
    // Initial vehicle class name
    "B_W_APC_Tracked_01_CRV_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Olive",1], 
	["showAmmobox",0.25,"showWheels",0.15,"showCamonetHull",0.5,"showBags",0.4]
] call BIS_fnc_initVehicle;
    }
]