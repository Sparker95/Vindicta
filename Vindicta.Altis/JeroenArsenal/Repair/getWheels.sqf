#include "defineCommon.inc"

params["_type"];

//if object was past change it to type
if!(_type isEqualType "")then{_type = typeof __type};

pr _wheels = ("true" configClasses (configfile >> "CfgVehicles" >> _type >> "Wheels"));
if (count _wheels == 0 )exitWith{-1};

//return
getNumber((_wheels select 1) >> "width");






configfile >> "CfgVehicles" >> "Offroad_01_armed_base_F" >> "HitPoints" >> "HitRMWheel" >> "name"
configfile >> "CfgVehicles" >> "Offroad_01_armed_base_F" >> "Wheels" >> "LF" >> "center"
///////////////////////////////


_vehicle = cursorObject;
_info = getAllHitPointsDamage _vehicle;
_info params["_hitpoints","_selections","_damages"];

{
	pr _hitpoint = _hitpoints select _forEachIndex;
	pr _selection = _selections select _forEachIndex;
	pr _damage = _x;
	
	if(_selection find  "wheel_")then{
		pr _name = [_selection,0,9] call BIS_fnc_trimString;
		[_name, "axis"] joinString "";
		
		
	}else{
	
	}
}forEach _damages;





[
	["hithull","hitengine","hitltrack","hitrtrack","hitfuel","hitslat_left_1","hitslat_left_2","hitslat_left_3","hitslat_right_1","hitslat_right_2","hitslat_right_3","hitslat_back","hitslat_front","hitturret","hitgun","#l svetlo","#p svetlo","#cabin_light","#cargo_light_1"],
	
	["telo","motor","pas_l","pas_p","palivo","","","","","","","","","vez","zbran","l svetlo","p svetlo","",""],
	
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]
	
	[["hitlfwheel","hitlf2wheel","hitrfwheel","hitrf2wheel","hitrglass","hitlglass","hitglass1","hitglass2","hitglass3","hitglass4","hitglass5","hitglass6","hitbody","hitfuel","hitlbwheel","hitlmwheel","hitrbwheel","hitrmwheel","hitengine","hithull","#light_l","#light_l","#light_r","#light_l"],
	
	["wheel_1_1_steering","wheel_1_2_steering","wheel_2_1_steering","wheel_2_2_steering","","","glass1","glass2","glass3","glass4","","","karoserie","","","","","","","","light_l","light_l","light_r","light_l"],
	
	[2.62749e-006,0.000113217,0.530813,0.33082,0,0,0,0.0419672,0,0,0,0,0.258914,0,0,0,0,0,0,0,0,0,0.596068,0]]