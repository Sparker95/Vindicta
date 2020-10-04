[
    // Initial vehicle class name
    "B_GEN_Offroad_01_comms_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Gendarmerie",1], 
	["hidePolice",0.55,"HideServices",1,"HideCover",0.25,"StartBeaconLight",0,"HideRoofRack",0.25,"HideLoudSpeakers",0.5,"HideAntennas",0.5,"HideBeacon",0.5,"HideSpotlight",0.5,"HideDoor3",0,"OpenDoor3",0,"HideDoor1",0,"HideDoor2",0,"HideBackpacks",0.4,"HideBumper1",1,"HideBumper2",0.15,"HideConstruction",0.2,"BeaconsStart",0]
] call BIS_fnc_initVehicle;
    }
]