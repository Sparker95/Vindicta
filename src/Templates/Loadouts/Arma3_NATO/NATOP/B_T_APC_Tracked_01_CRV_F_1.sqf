[
    // Initial vehicle class name
    "B_T_APC_Tracked_01_CRV_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Olive",1], 
	["showAmmobox",0.75,"showWheels",0.40,"showCamonetHull",0.5,"showBags",0.3]
] call BIS_fnc_initVehicle;

    }
]