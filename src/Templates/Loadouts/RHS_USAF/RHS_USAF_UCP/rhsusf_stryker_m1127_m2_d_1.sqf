[
    // Initial vehicle class name
    "rhsusf_stryker_m1127_m2_d",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Tan",1], 
	["Hide_DUKE",0,"Hatch_Commander",0,"Hatch_Left",0,"Hatch_Right",0,"Ramp",0,"Hide_Antenna_1",0,"Hide_Antenna_2",0,"Hide_Antenna_3",0,"Hide_CIP",0,"Hide_DEK",0,"Hide_ExDiff",0,"Hide_FCans",0,"Hide_WCans",0,"Hide_GPS",0,"Hide_PioKit",0,"Hide_StgBar",0,"Hide_SuspCov",0,"Hide_Towbar",0,"Extend_Mirrors",0,"Hatch_Driver",0]
] call BIS_fnc_initVehicle;
    }
]