/*
if(isNil "groupLogic") then
{
	groupLogic = createGroup sideLogic;
}
else
{
	deleteGroup groupLogic;
	groupLogic = createGroup sideLogic;
};
*/

call compile preprocessFileLineNumbers "Location\buildings.sqf";

//Location types
LOC_TYPE_base = 0;
LOC_TYPE_outpost = 1;
LOC_TYPE_roadblock = 2;

//Alert states
LOC_AS_none = 0;
LOC_AS_safe = 1;
LOC_AS_aware = 2;
LOC_AS_combat = 3;

allLocations = [];