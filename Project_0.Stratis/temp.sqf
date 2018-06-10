{#line 1 "C:\Users\Admin\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0.Stratis\Unit\Unit.sqf"




#line 1 "C:\Users\Admin\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0.Stratis\Unit\Unit.hpp"
















#line 3 "C:\Users\Admin\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0.Stratis\Unit\Unit.sqf"

#line 1 "C:\Users\Admin\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0.Stratis\OOP_Light\OOP_Light.h"






























































































































































































































































#line 4 "C:\Users\Admin\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0.Stratis\Unit\Unit.sqf"

#line 1 "C:\Users\Admin\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0.Stratis\Mutex\Mutex.hpp"
















#line 5 "C:\Users\Admin\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0.Stratis\Unit\Unit.sqf"




[] call { scopeName "scopeClass"; private _oop_classNameStr = "Unit"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "nextID"),  0]; private _oop_memList = []; private _oop_staticMemList = []; private _oop_parents = []; private _oop_methodList = []; if ( "" != "") then { 	if (!([ "", "C:\Users\Admin\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0.Stratis\Unit\Unit.sqf", 11] call OOP_assert_class)) then {breakOut "scopeClass";}; 	_oop_parents = +( missionNameSpace getVariable ("o_" +  "" + "_spm_" +   "parents") ); _oop_parents pushBackUnique  ""; 	_oop_memList = +( missionNameSpace getVariable ("o_" +  "" + "_spm_" +   "memList") ); 	_oop_staticMemList = +( missionNameSpace getVariable ("o_" +  "" + "_spm_" +   "staticMemList") ); 	_oop_methodList = +( missionNameSpace getVariable ("o_" +  "" + "_spm_" +   "methodList") ); 	private _oop_topParent = _oop_parents select ((count _oop_parents) - 1); 	{ private _oop_methodCode = ( missionNameSpace getVariable ("o_" + _oop_topParent + "_fnc_" +   _x) ); 	missionNameSpace setVariable [("o_" + "Unit" + "_fnc_" +   _x),  _oop_methodCode]; 	} forEach (_oop_methodList - ["new", "delete", "copy"]); }; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "parents"),  _oop_parents]; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "memList"),  _oop_memList]; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "staticMemList"),  _oop_staticMemList]; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "methodList"),  _oop_methodList]; _oop_methodList pushBackUnique "new"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "new"), {} ]; _oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "delete"), {} ]; _oop_methodList pushBackUnique "copy"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "copy"), {} ]; _oop_memList pushBackUnique "oop_parent";
_oop_memList pushBackUnique "data";
_oop_staticMemList pushBackUnique "all";





_oop_methodList pushBackUnique "new"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "new"), {
params [["_thisObject", "", [""]], ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]]];


private _valid = false;

if(_classID == -1) then	{
if(([_template, _catID, _subcatID, 0] call t_fnc_isValid)) then	{
_valid = true;
};
}
else {
if(([_template, _catID, _subcatID, _classID] call t_fnc_isValid)) then {
_valid = true;
};
};
if (!_valid) exitWith { missionNameSpace setVariable [(_thisObject + "_" +    "data"),   []]; };

if(_group == "" && _catID == T_INF) exitWith { diag_log "[Unit] Error: men must be added with a group!";};


private _class = "";
if(_classID == -1) then {
private _classData = [_template, _catID, _subcatID] call t_fnc_selectRandom;
_class = _classData select 0;
} else {
_class = [_template, _catID, _subcatID, _classID] call t_fnc_select;
};


private _data = 		[0, 0, "", objNull, "", 2, "", []];
_data set [				0, _catID];
_data set [			1, _subcatID];
_data set [		2, _class];
_data set [			7, []];
missionNameSpace setVariable [(_thisObject + "_" +    "data"),   _data];


private _allArray = ( missionNameSpace getVariable ("o_" + "Unit" + "_stm_" +    "all") );
_allArray pushBack _thisObject;
} ];





_oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "delete"), {
params["_thisObject"];
private _data = ( missionNameSpace getVariable (_thisObject + "_" +    "data") );
private _mutex = _data select 			7;
waitUntil { (_mutex pushBackUnique 0) == 0;};

private _objectHandle = _data select 	3;
if (!(isNull _objectHandle)) then {
deleteVehicle _objectHandle;
};


private _allArray = ( missionNameSpace getVariable ("o_" + "Unit" + "_stm_" +    "all") );
_allArray = _allArray - [_thisObject];
_mutex deleteAt 0;
missionNameSpace setVariable [(_thisObject + "_" +    "data"),   nil];
} ];







_oop_methodList pushBackUnique "isValid"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "isValid"), {
params ["_thisObject"];
private _data = ( missionNameSpace getVariable (_thisObject + "_" +    "data") );

( (count _data) == 				8)
} ];






_oop_methodList pushBackUnique "isSpawned"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "isSpawned"), {
params ["_thisObject"];
private _mutex = _data select 			7;
waitUntil { (_mutex pushBackUnique 0) == 0;};
private _return = !( isNull (_data select 	3));
_mutex deleteAt 0;
_return
} ];





_oop_methodList pushBackUnique "spawn"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "spawn"), {
params ["_thisObject", "_pos", "_dir"];

private _data = ( missionNameSpace getVariable (_thisObject + "_" +    "data") );
private _mutex = _data select 			7;


waitUntil { (_mutex pushBackUnique 0) == 0;};


private _objectHandle = _data select 	3;
if (isNull _objectHandle) then { 
private _className = _data select 		2;
private _group = _data select 			6;


switch(_catID) do {
case T_INF: {
private _groupHandle = ([_group] +  []) call ( missionNameSpace getVariable ("o_" + (( missionNameSpace getVariable (_group + "_" +   "oop_parent") )) + "_fnc_" +     "getSpawnedGroupHandle") );
_objectHandle = _groupHandle createUnit [_class, _pos, [], 10, "FORM"];
[_objectHandle] joinSilent _groupHandle; 
};
case T_VEH: {
};
case T_DRONE: {
};
};
if (_group != "") then {  };
_data set [	3, _objectHandle];
_objectHandle setDir _dir;
_objectHandle setPos _pos;
};		

_mutex deleteAt 0;
} ];





_oop_methodList pushBackUnique "despawn"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "despawn"), {
params ["_thisObject"];

private _data = ( missionNameSpace getVariable (_thisObject + "_" +    "data") );
private _mutex = _data select 			7;


waitUntil { (_mutex pushBackUnique 0) == 0;};


private _objectHandle = _data select 	3;
if (!(isNull _objectHandle)) then { 
deleteVehicle _objectHandle;
private _group = _data select 			6;
if (_group != "") then {  };
_data set [	3, objNull];
_objectHandle setDir _dir;
_objectHandle setPos _pos;
};		

_mutex deleteAt 0;
} ];






_oop_methodList pushBackUnique "handleKilled"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_fnc_" +  "handleKilled"), {
params ["_thisObject"];

} ];


};

missionNameSpace setVariable [("o_" + "Unit" + "_stm_" +    "all"),   []];}