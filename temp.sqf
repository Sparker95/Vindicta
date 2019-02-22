{#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf"




#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.hpp"



































#line 5 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\OOP_Light\OOP_Light.h"













































































































































































































































































































































































































































































































#line 6 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Mutex\Mutex.hpp"





























#line 7 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Message\Message.hpp"































































#line 8 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageTypes.hpp"
































#line 9 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\CriticalSection\CriticalSection.hpp"


























#line 10 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Group\Group.hpp"


































#line 11 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf"












Unit_fnc_EH_Killed = compile preprocessFileLineNumbers "Unit\EH_Killed.sqf";
Unit_fnc_EH_handleDamageInfantry = compile preprocessFileLineNumbers "Unit\EH_handleDamageInfantry.sqf";
Unit_fnc_EH_GetIn = compile preprocessFileLineNumbers "Unit\EH_GetIn.sqf";


scopeName "scopeClass"; private _oop_classNameStr = "Unit"; missionNamespace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "nextID")),  0]; private _oop_memList = []; private _oop_staticMemList = []; private _oop_parents = []; private _oop_methodList = []; private _oop_extMethodList = []; if ( "" != "") then { 	if (!([ "", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 28] call OOP_assert_class)) then {breakOut "scopeClass";}; 	_oop_parents = +( missionNamespace getVariable ("o_" + ( "") + "_spm_" + (  "parents")) ); _oop_parents pushBackUnique  ""; 	_oop_memList = +( missionNamespace getVariable ("o_" + ( "") + "_spm_" + (  "memList")) ); 	_oop_staticMemList = +( missionNamespace getVariable ("o_" + ( "") + "_spm_" + (  "staticMemList")) ); 	_oop_methodList = +( missionNamespace getVariable ("o_" + ( "") + "_spm_" + (  "methodList")) ); 	_oop_extMethodList = +_oop_methodList; 	private _oop_topParent = _oop_parents select ((count _oop_parents) - 1); 	{ private _oop_methodCode = ( missionNameSpace getVariable ((_oop_topParent) + "_fnc_" + (  _x)) ); 	missionNamespace setVariable [(("Unit") + "_fnc_" + (  _x)),  _oop_methodCode]; 	} forEach (_oop_methodList - ["new", "delete", "copy"]); }; missionNamespace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "parents")),  _oop_parents]; missionNamespace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "memList")),  _oop_memList]; missionNamespace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "staticMemList")),  _oop_staticMemList]; missionNamespace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "methodList")),  _oop_methodList]; _oop_methodList pushBackUnique "new"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "new")), {} ]; _oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "delete")), {} ]; _oop_methodList pushBackUnique "copy"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "copy")), {} ]; _oop_memList pushBackUnique "oop_parent"; _oop_memList pushBackUnique "oop_public";
_oop_memList pushBackUnique "data";
_oop_staticMemList pushBackUnique "all";














_oop_methodList pushBackUnique "new"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "new")), {
params [["_thisObject", "", [""]], ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]], ["_hO", objNull]];


private _valid = false;
if (isNull _ho) then {

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
} else {
_valid = true;
};

if (!_valid) exitWith { if([_thisObject,  "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 65] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +    "data"),   []]};  diag_log format ["[Unit::new] Error: created invalid unit: %1", _this] };

if(_group == "" && _catID == T_INF && isNull _hO) exitWith { diag_log "[Unit] Error: men must be added with a group!";};


private _class = "";
if (isNull _hO) then {
if(_classID == -1) then {
private _classData = [_template, _catID, _subcatID] call t_fnc_selectRandom;
_class = _classData select 0;
} else {
_class = [_template, _catID, _subcatID, _classID] call t_fnc_select;
};
} else {
_class = typeOf _hO;
};


private _data = 		[0, 0, "", objNull, "", 2, "", [], ""];
_data set [			0, _catID];
_data set [			1, _subcatID];
_data set [		2, _class];
_data set [			7, []];
_data set [			6, _group];
if (!isNull _hO) then {
_data set [	3, _hO];
};
if([_thisObject,  "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 92] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +    "data"),   _data]};


private _allArray = ( if(["Unit",  "all", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 95] call OOP_assert_staticMember) then {( missionNameSpace getVariable (("o_") + ("Unit") + "_stm_" + (   "all")) )}else{nil} );
_allArray pushBack _thisObject;


if(_group != "") then {
(([_group] +  [_thisObject]) call ( if([(( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") )),   "addUnit", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 100] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") ))) + "_fnc_" + (    "addUnit")) )}else{nil} ));
};


if (!isNull _hO) then {
(([_thisObject]) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "initObjectVariables", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 105] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "initObjectVariables")) )}else{nil} ));
(([_thisObject]) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "initObjectEventHandlers", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 106] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "initObjectEventHandlers")) )}else{nil} ));
};
} ];








_oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "delete")), {
params[["_thisObject", "", [""]]];
private _data = ( if([_thisObject,  "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 119] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +    "data") )}else{nil} );


(([_thisObject] +   []) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "despawn", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 122] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "despawn")) )}else{nil} ));


private _group = _data select 			6;
(([_group] +  [_thisObject]) call ( if([(( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") )),   "removeUnit", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 126] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") ))) + "_fnc_" + (    "removeUnit")) )}else{nil} ));


private _allArray = ( if(["Unit",  "all", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 129] call OOP_assert_staticMember) then {( missionNameSpace getVariable (("o_") + ("Unit") + "_stm_" + (   "all")) )}else{nil} );
_allArray deleteAt (_allArray find _thisObject);
if([_thisObject,  "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 131] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +    "data"),   nil]};
} ];











_oop_methodList pushBackUnique "isValid"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "isValid")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,  "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 146] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +    "data") )}else{nil} );
if (isNil "_data") exitWith {false};

( (count _data) == 				9)
} ];
















_oop_methodList pushBackUnique "createAI"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "createAI")), {
params [["_thisObject", "", [""]], ["_AIClassName", "", [""]]];




private _data = ( if([_thisObject,    "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 173] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +      "data") )}else{nil} );
private _AI = [] call { if (!([_AIClassName, "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 174] call OOP_assert_class)) exitWith {format ["ERROR_NO_CLASS_%1", _AIClassName]}; private _oop_nextID = -1; _oop_nul = isNil { _oop_nextID = ( missionNamespace getVariable ("o_" + (_AIClassName) + "_spm_" + (  "nextID")) ); if (isNil "_oop_nextID") then { missionNamespace setVariable [("o_" + (_AIClassName) + "_spm_" + (  "nextID")),  0];	_oop_nextID = 0;}; missionNamespace setVariable [("o_" + (_AIClassName) + "_spm_" + (  "nextID")),  _oop_nextID+1]; }; private _objNameStr = ("o_" + (_AIClassName) + "_N_" + (format ["%1",  _oop_nextID])); missionNameSpace setVariable [((_objNameStr) + "_" +   "oop_parent"),  _AIClassName]; private _oop_parents = ( missionNamespace getVariable ("o_" + (_AIClassName) + "_spm_" + (  "parents")) ); private _oop_i = 0; private _oop_parentCount = count _oop_parents; while {_oop_i < _oop_parentCount} do { 	([_objNameStr] +  [_thisObject]) call ( if([(_oop_parents select _oop_i),  "new", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 174] call OOP_assert_method) then {( missionNameSpace getVariable (((_oop_parents select _oop_i)) + "_fnc_" + (   "new")) )}else{nil} ); 	_oop_i = _oop_i + 1; }; (([_objNameStr] +   [_thisObject]) call ( if([(( missionNameSpace getVariable ((_objNameStr) + "_" +   "oop_parent") )),   "new", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 174] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_objNameStr) + "_" +   "oop_parent") ))) + "_fnc_" + (    "new")) )}else{nil} )); _objNameStr };
_data set [				8, _AI];


_AI
} ];















_oop_methodList pushBackUnique "spawn"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "spawn")), {
params [["_thisObject", "", [""]], "_pos", "_dir"];

private _o_str = format ["[%1.%2] INFO: %3", if(isNil "_thisClass") then {(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))} else {_thisClass}, if(isNil "_thisClass") then {_thisObject} else {"static"}, "SPAWN"]; ((ofstream_new "Main.rpt") ofstream_write( _o_str));


private _data = ( if([_thisObject,  "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 201] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +    "data") )}else{nil} );





private _null = isNil {


private _objectHandle = _data select 	3;
if (isNull _objectHandle) then { 
private _className = _data select 		2;
private _group = _data select 			6;


private _catID = _data select 			0;
switch(_catID) do {
case T_INF: {
private _groupHandle = (([_group] +  []) call ( if([(( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") )),   "getGroupHandle", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 219] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") ))) + "_fnc_" + (    "getGroupHandle")) )}else{nil} ));

_objectHandle = _groupHandle createUnit [_className, _pos, [], 10, "FORM"];
[_objectHandle] joinSilent _groupHandle; 

_data set [	3, _objectHandle];




private _AI = (([_thisObject,   "AIUnitInfantry"]) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "createAI", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 229] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "createAI")) )}else{nil} ));

private _groupType = (([_group]) call ( if([(( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") )),    "getType", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 231] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") ))) + "_fnc_" + (     "getType")) )}else{nil} ));
if (_groupType == 	3) then {	
(([_AI,   _pos]) call ( if([(( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") )),    "setSentryPos", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 233] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") ))) + "_fnc_" + (     "setSentryPos")) )}else{nil} ));
};
};
case T_VEH: {
_objectHandle = createVehicle [_className, _pos, [], 0, "can_collide"];

_data set [	3, _objectHandle];

(([_thisObject,   "AIUnitVehicle"]) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "createAI", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 241] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "createAI")) )}else{nil} ));
};
case T_DRONE: {
};
};



(([_thisObject]) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "initObjectVariables", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 249] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "initObjectVariables")) )}else{nil} ));


(([_thisObject]) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "initObjectEventHandlers", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 252] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "initObjectEventHandlers")) )}else{nil} ));

_objectHandle setDir _dir;
_objectHandle setPos _pos;
} else {
private _o_str = format ["[%1.%2] WARNING: %3", if(isNil "_thisClass") then {(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))} else {_thisClass}, if(isNil "_thisClass") then {_thisObject} else {"static"}, "Already spawned"]; ((ofstream_new "Main.rpt") ofstream_write( _o_str));
};

};


} ];







_oop_methodList pushBackUnique "initObjectVariables"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "initObjectVariables")), {
params [["_thisObject", "", [""]]];

private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 274] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
private _hO = _data select 	3;


if (!isNull _hO) then {
_hO setVariable ["unit", _thisObject];

};

} ];








_oop_methodList pushBackUnique "initObjectEventHandlers"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "initObjectEventHandlers")), {
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 293] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
private _hO = _data select 	3;
private _catID = _data select 			0;


_hO addEventHandler ["Killed", Unit_fnc_EH_Killed];
_hO addEventHandler ["handleDamage", Unit_fnc_EH_handleDamageInfantry];


if (_catID == T_VEH) then {
_hO addEventHandler ["GetIn", Unit_fnc_EH_GetIn];
};
} ];














_oop_methodList pushBackUnique "despawn"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "despawn")), {
params [["_thisObject", "", [""]]];

private _o_str = format ["[%1.%2] INFO: %3", if(isNil "_thisClass") then {(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))} else {_thisClass}, if(isNil "_thisClass") then {_thisObject} else {"static"}, "DESPAWN"]; ((ofstream_new "Main.rpt") ofstream_write( _o_str));


private _data = ( if([_thisObject,  "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 326] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +    "data") )}else{nil} );
private _mutex = _data select 			7;





private _objectHandle = _data select 	3;
if (!(isNull _objectHandle)) then { 

private _AI = _data select 				8;

if (_AI != "") then {
private _msg = ["", "", clientOwner, -666, 0, 0];
_msg set [4,  501];			
private _msgID = (([_AI,   _msg,   true]) call ( if([(( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") )),    "postMessage", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 341] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") ))) + "_fnc_" + (     "postMessage")) )}else{nil} ));
(([_AI] +   [_msgID]) call ( if([(( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") )),    "waitUntilMessageDone", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 342] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") ))) + "_fnc_" + (     "waitUntilMessageDone")) )}else{nil} ));
_data set [				8, ""];
};


deleteVehicle _objectHandle;
private _group = _data select 			6;

_data set [	3, objNull];
} else {
private _o_str = format ["[%1.%2] WARNING: %3", if(isNil "_thisClass") then {(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))} else {_thisClass}, if(isNil "_thisClass") then {_thisObject} else {"static"}, "Already despawned"]; ((ofstream_new "Main.rpt") ofstream_write( _o_str));
};


} ];










_oop_methodList pushBackUnique "setVehicleRole"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "setVehicleRole")), {
params [["_thisObject", "", [""]], "_vehicle", "_vehicleRole"];
} ];















_oop_methodList pushBackUnique "setGarrison"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "setGarrison")), {
params [["_thisObject", "", [""]], ["_garrison", "", [""]] ];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 387] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
_data set [		4, _garrison];
} ];














_oop_methodList pushBackUnique "setGroup"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "setGroup")), {
params [["_thisObject", "", [""]], ["_group", "", [""]] ];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 406] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
_data set [			6, _group];
} ];














_oop_methodList pushBackUnique "getGarrison"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getGarrison")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 425] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );


private _group = _data select 			6;
if (_group != "") then {
(([_group]) call ( if([(( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") )),    "getGarrison", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 431] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_group) + "_" +   "oop_parent") ))) + "_fnc_" + (     "getGarrison")) )}else{nil} ))
} else {

_data select 		4
};
} ];









_oop_methodList pushBackUnique "getObjectHandle"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getObjectHandle")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 447] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
_data select 	3
} ];







_oop_methodList pushBackUnique "getClassName"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getClassName")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 459] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
_data select 		2
} ];










_oop_methodList pushBackUnique "getGroup"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getGroup")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 474] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
_data select 			6
} ];










_oop_methodList pushBackUnique "getAI"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getAI")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 489] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
_data select 				8
} ];










_oop_methodList pushBackUnique "getMainData"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getMainData")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 504] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
[_data select 			0, _data select 			1, _data select 		2]
} ];	









_oop_methodList pushBackUnique "getData"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getData")), {
params [["_thisObject", "", [""]]];
( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 519] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} )
} ];









_oop_methodList pushBackUnique "getPos"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getPos")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 531] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
private _oh = _data select 	3;
getPos _oh
} ];






	
_oop_methodList pushBackUnique "handleKilled"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "handleKilled")), {
params [["_thisObject", "", [""]]];


private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 546] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
private _AI = _data select 				8;
if (_AI != "") then {
private _msg = ["", "", clientOwner, -666, 0, 0];
_msg set [4,  501];			
private _msgID = (([_AI,   _msg,   true]) call ( if([(( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") )),    "postMessage", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 551] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") ))) + "_fnc_" + (     "postMessage")) )}else{nil} ));
(([_AI,   _msgID]) call ( if([(( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") )),    "waitUntilMessageDone", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 552] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_AI) + "_" +   "oop_parent") ))) + "_fnc_" + (     "waitUntilMessageDone")) )}else{nil} ));

_data set [				8, ""];
};


_data set [			6, ""];
} ];

















_oop_methodList pushBackUnique "getUnitFromObjectHandle"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getUnitFromObjectHandle")), {
params [ ["_thisClass", "", [""]], ["_objectHandle", objNull, [objNull]] ];
_objectHandle getVariable ["unit", ""]
} ];








_oop_methodList pushBackUnique "createUnitFromObjectHandle"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "createUnitFromObjectHandle")), {
} ];













_oop_methodList pushBackUnique "getBehaviour"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getBehaviour")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,    "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 606] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +      "data") )}else{nil} );
private _object = _data select 	3;
behaviour _object
} ];









_oop_methodList pushBackUnique "isAlive"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "isAlive")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,    "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 621] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +      "data") )}else{nil} );
private _object = _data select 	3;
if (_object isEqualTo objNull) then {

true
} else {	
alive _object
};
} ];








_oop_methodList pushBackUnique "isSpawned"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "isSpawned")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 640] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
private _return = !( isNull (_data select 	3));
_return
} ];













_oop_methodList pushBackUnique "isInfantry"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "isInfantry")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 659] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
_data select 			0 == T_INF
} ];








_oop_methodList pushBackUnique "isVehicle"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "isVehicle")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 672] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
_data select 			0 == T_VEH
} ];








_oop_methodList pushBackUnique "isDrone"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "isDrone")), {
params [["_thisObject", "", [""]]];
private _data = ( if([_thisObject,   "data", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 685] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "data") )}else{nil} );
_data select 			0 == T_DRONE
} ];















_oop_methodList pushBackUnique "getSubagents"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getSubagents")), {
[] 
} ];










_oop_methodList pushBackUnique "getPossibleGoals"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getPossibleGoals")), {
["GoalUnitSalute","GoalUnitScareAway"]
} ];









	
_oop_methodList pushBackUnique "getPossibleActions"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getPossibleActions")), {
["ActionUnitSalute","ActionUnitScareAway"]
} ];







_oop_methodList pushBackUnique "createDefaultCrew"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "createDefaultCrew")), compile preprocessFileLineNumbers  "Unit\createDefaultCrew.sqf"];









{ if (! (_x in _oop_extMethodList)) then { private _fnc = missionNamespace getVariable ((_oop_classNameStr) + "_fnc_" + ( _x)); private _fnc_array = toArray str _fnc; _fnc_array deleteAt 0; _fnc_array deleteAt ((count _fnc_array) - 1); private _fnc_str = (format ["_fnc_scriptName = %1;", _x]) + (toString myFnc_array); missionNamespace setVariable [((_oop_classNameStr) + "_fnc_" + ( _x)), compile _fnc_str]; }; } forEach _oop_methodList;;

if(["Unit",  "all", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Unit\Unit.sqf", 751] call OOP_assert_staticMember) then {missionNamespace setVariable [(("o_") + ("Unit") + "_stm_" + (   "all")),   []]};}