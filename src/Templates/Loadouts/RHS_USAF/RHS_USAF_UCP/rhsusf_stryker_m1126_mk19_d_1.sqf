[
    // Initial vehicle class name
    "rhsusf_stryker_m1126_mk19_d",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Tan",1], 
	["Hatch_Commander",0,"Hatch_Front",0,"Hatch_Left",0,"Hatch_Right",0,"Ramp",0,"Hide_Antenna_1",0.5,"Hide_Antenna_2",0.5,"Hide_Antenna_3",0.5,"Hide_CIP",0.5,"Hide_DEK",0.5,"Hide_DUKE",0.5,"Hide_ExDiff",0.5,"Hide_FCans",0.5,"Hide_WCans",0.5,"Hide_GPS",0.5,"Hide_PioKit",0.5,"Hide_StgBar",0.5,"Hide_STORM",0.5,"Hide_SuspCov",0,"Hide_Towbar",0,"Extend_Mirrors",0.5,"Hatch_Driver",0]
] call BIS_fnc_initVehicle;


    }
]