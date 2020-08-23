[
    // Initial vehicle class name
    "B_W_MBT_01_cannon_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
        private _Camonet = selectRandom[0,1];
[
	_veh,
	["Olive",1], 
	["showBags",0.4,"showCamonetTurret",_Camonet,"showCamonetHull",_Camonet]
] call BIS_fnc_initVehicle;

    }
]