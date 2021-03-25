#include "..\common.h"

private _animSetNames = ["STAND","STAND1","STAND_IA","STAND2","STAND_U1","STAND_U2","STAND_U3","WATCH","WATCH1","WATCH2","GUARD","LISTEN_BRIEFING","LEAN_ON_TABLE","LEAN","SIT_AT_TABLE","SIT1","SIT","SIT2","SIT3","SIT_U1","SIT_U2","SIT_U3","SIT_HIGH1","SIT_HIGH","SIT_HIGH2","SIT_LOW","SIT_LOW_U","SIT_SAD1","SIT_SAD2","KNEEL","REPAIR_VEH_PRONE","REPAIR_VEH_KNEEL","REPAIR_VEH_STAND","PRONE_INJURED_U1","PRONE_INJURED_U2","PRONE_INJURED","KNEEL_TREAT","KNEEL_TREAT2","BRIEFING","BRIEFING_POINT_LEFT","BRIEFING_POINT_RIGHT","BRIEFING_POINT_TABLE"];
gAmbientAnimSets = _animSetNames apply { [ _x, ((_x call BIS_fnc_ambientAnimGetParams) select 0) apply { toLower _x } ] };
private _animMarkers = CALL_COMPILE_COMMON("Location\objectAnimMarkers.sqf");
gShootingTargetTypes = ["TargetP_Inf_F", "TargetP_Inf_Acc2_F", "TargetP_Inf_Acc1_F", "TargetP_Inf2_F", "TargetP_Inf2_Acc2_F", "TargetP_Inf2_Acc1_F", "TargetP_Inf3_F", "TargetP_Inf3_Acc2_F", "TargetP_Inf3_Acc1_F", "TargetP_Inf4_F", "TargetP_Inf4_Acc2_F", "TargetP_Inf4_Acc1_F", "TargetP_HVT1_F", "TargetP_HVT2_F", "Target_F", "Land_Target_Oval_F", "Land_Target_Concrete_01_v2_F", "Land_Target_Concrete_01_v1_F", "Land_Target_Line_PaperTargets_01_F", "Land_Target_Single_01_F", "Land_Target_Pistol_01_F", "Land_Target_Line_01_F"];
//gObjectMakeSimple = CALL_COMPILE_COMMON("Location\objectMakeSimple.sqf");

gObjectAnimMarkers = [false] call CBA_fnc_createNamespace;
// Add animation markers to hashmap
{
	private _modelPath = getText (configFile >> "cfgVehicles" >> (_x#0) >> "model");
	private _modelPathSplit = _modelPath splitString "\";
	private _modelName = _modelPathSplit select (count _modelPathSplit - 1);
	gObjectAnimMarkers setVariable [_modelName, _x];
} forEach _animMarkers;

