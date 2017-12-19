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

LOC_TYPE_base = 0;
LOC_TYPE_outpost = 1;
LOC_TYPE_roadblock = 2;