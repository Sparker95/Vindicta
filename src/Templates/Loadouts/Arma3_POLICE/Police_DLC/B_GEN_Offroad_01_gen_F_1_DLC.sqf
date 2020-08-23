[
    // Initial vehicle class name
    "B_GEN_Offroad_01_gen_F",

    // This code will be called upon vehicle construction
    {
        params ["_veh"];
[
	_veh,
	["Gendarmerie",1], 
	["HideDoor1",0,"HideDoor2",0,"HideDoor3",0.45,"HideBackpacks",0.75,"HideBumper1",1,"HideBumper2",0.3,"HideConstruction",0.4,"hidePolice",0,"HideServices",1,"BeaconsStart",0,"BeaconsServicesStart",0]
] call BIS_fnc_initVehicle;
    }
]