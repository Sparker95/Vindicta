//call compile preprocessFileLineNumbers "Garrison\initVariablesServer.sqf";
if(isNil "groupLogic") then
{
	groupLogic = createGroup sideLogic;
}
else
{
	deleteGroup groupLogic;
	groupLogic = createGroup sideLogic;
};

//Group types are global because they are als accessed by other modules
G_GT_idle = 0; //Group which is doing nothing specific at the location now. Probably a reserve non-structured infantry squad or a vehicle without assigned crew.
G_GT_veh_static = 1; //Static vehicle(s) and its/their crew
G_GT_veh_non_static = 2; //Non-static vehicles and their crew
G_GT_building_sentry = 3; //Infantry inside buildings in firing positions like snipers/marksmen/sharpshooters
G_GT_patrol = 4; //Patrols that are walking around

//Alert states
G_AS_none = 0; //AIs are handled by non-garrison AI script, like when they are on combat mission.
G_AS_safe = 1;
G_AS_aware = 2;
G_AS_combat = 3;

//Vehicle roles
G_VR_driver = 0;
G_VR_turret = 1;
G_VR_cargo_turret = 2;
G_VR_cargo = 3;