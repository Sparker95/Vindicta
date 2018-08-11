{#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf"














#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\OOP_Light\OOP_Light.h"















































































































































































































































































#line 3 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Message\Message.hpp"






















#line 4 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageTypes.hpp"















#line 5 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf"


[] call { scopeName "scopeClass"; private _oop_classNameStr = "AnimObject"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "nextID"),  0]; private _oop_memList = []; private _oop_staticMemList = []; private _oop_parents = []; private _oop_methodList = []; if ( "MessageReceiver" != "") then { 	if (!([ "MessageReceiver", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 19] call OOP_assert_class)) then {breakOut "scopeClass";}; 	_oop_parents = +( missionNameSpace getVariable ("o_" +  "MessageReceiver" + "_spm_" +   "parents") ); _oop_parents pushBackUnique  "MessageReceiver"; 	_oop_memList = +( missionNameSpace getVariable ("o_" +  "MessageReceiver" + "_spm_" +   "memList") ); 	_oop_staticMemList = +( missionNameSpace getVariable ("o_" +  "MessageReceiver" + "_spm_" +   "staticMemList") ); 	_oop_methodList = +( missionNameSpace getVariable ("o_" +  "MessageReceiver" + "_spm_" +   "methodList") ); 	private _oop_topParent = _oop_parents select ((count _oop_parents) - 1); 	{ private _oop_methodCode = ( missionNameSpace getVariable (_oop_topParent + "_fnc_" +   _x) ); 	missionNameSpace setVariable [("AnimObject" + "_fnc_" +   _x),  _oop_methodCode]; 	} forEach (_oop_methodList - ["new", "delete", "copy"]); }; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "parents"),  _oop_parents]; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "memList"),  _oop_memList]; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "staticMemList"),  _oop_staticMemList]; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "methodList"),  _oop_methodList]; _oop_methodList pushBackUnique "new"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "new"), {} ]; _oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "delete"), {} ]; _oop_methodList pushBackUnique "copy"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "copy"), {} ]; _oop_memList pushBackUnique "oop_parent";

_oop_memList pushBackUnique "object"; 


_oop_memList pushBackUnique "points"; 
_oop_memList pushBackUnique "units"; 
_oop_memList pushBackUnique "pointCount"; 
_oop_memList pushBackUnique "animations"; 





_oop_methodList pushBackUnique "new"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "new"), {
params [["_thisObject", "", [""]], ["_object", objNull, [objNull]]];
if (isNil "gMessageLoopGoal") exitWith { diag_log "[AnimObject] Error: global goal message loop doesn't exist!"; };
if([_thisObject,    "object", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 35] call OOP_assert_member) then {missionNameSpace setVariable [(_thisObject + "_" +      "object"),     _object]};
} ];






_oop_methodList pushBackUnique "isFree"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "isFree"), {
params [["_thisObject", "", [""]]];
private _pointCount = ( if([_thisObject,    "pointCount", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 45] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "pointCount") )}else{nil} );
private _units = ( if([_thisObject,    "units", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 46] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "units") )}else{nil} );
private _pointFreeCount = {_x == ""} count _units;
private _return = _pointFreeCount > 0;
_return
} ];







_oop_methodList pushBackUnique "getFreePoint"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "getFreePoint"), {
params [ ["_thisObject", "", [""]] ];
private _units = ( if([_thisObject,    "units", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 60] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "units") )}else{nil} );
private _pointCountM1 = ( if([_thisObject,    "pointCount", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 61] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "pointCount") )}else{nil} ) - 1;
private _freePointIDs = [];
for "_i" from 0 to _pointCountM1 do {

if (_units select _i == "") then {_freePointIDs pushBack _i; };
};


if (count _freePointIDs == 0) exitWith { [] };


private _pointID = selectRandom _freePointIDs;


private _object = ( if([_thisObject,    "object", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 75] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "object") )}else{nil} );
private _movePosOffset = ([_thisObject] +   [_pointID]) call ( if([(( missionNameSpace getVariable (_thisObject + "_" +   "oop_parent") )),    "getPointMovePosOffset", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 76] call OOP_assert_method) then {( missionNameSpace getVariable ((( missionNameSpace getVariable (_thisObject + "_" +   "oop_parent") )) + "_fnc_" +      "getPointMovePosOffset") )}else{nil} );
private _posWorld = _object modelToWorld _movePosOffset;
private _return = [_pointID, _posWorld];

_return
} ];








_oop_methodList pushBackUnique "getPointMovePosOffset"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "getPointMovePosOffset"), {
params [ ["_thisObject", "", [""]], ["_pointID", 0, [0]] ];
private _points = ( if([_thisObject,    "points", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 92] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "points") )}else{nil} );
private _pointOffset = _points select _pointID;
} ];






_oop_methodList pushBackUnique "isPointFree"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "isPointFree"), {
params [["_thisObject", "", [""]], ["_pointID", 0, [0]]];
private _units = ( if([_thisObject,    "units", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 103] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "units") )}else{nil} );
private _return = ( (_units select _pointID) == "");
_return
} ];







_oop_methodList pushBackUnique "getPointData"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "getPointData"), {
params [["_thisObject", "", [""]], ["_unit", "", [""]], ["_pointID", 0, [0]]];
private _units = ( if([_thisObject,    "units", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 116] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "units") )}else{nil} );


if (_units select _pointID == "") then { 
_units set [_pointID, _unit];
private _return = ([_thisObject] +   [_pointID]) call ( if([(( missionNameSpace getVariable (_thisObject + "_" +   "oop_parent") )),    "getPointDataInternal", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 121] call OOP_assert_method) then {( missionNameSpace getVariable ((( missionNameSpace getVariable (_thisObject + "_" +   "oop_parent") )) + "_fnc_" +      "getPointDataInternal") )}else{nil} );
_return
} else {
[]
};
} ];






_oop_methodList pushBackUnique "getPointDataInternal"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "getPointDataInternal"), {
params [["_thisObject", "", [""]], ["_pointID", 0, [0]]];
private _animations = ( if([_thisObject,    "animations", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 135] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "animations") )}else{nil} );
private _points = ( if([_thisObject,    "points", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 136] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "points") )}else{nil} );
[_points select _pointID, selectRandom _animations]
} ];






_oop_methodList pushBackUnique "handleMessage"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "handleMessage"), {
params [["_thisObject", "", [""]], ["_msg", [], [[]]] ];
private _msgType = _msg select 2;
if (_msgType == 	100) then {
private _unit = _msg select 1; 
private _units = ( if([_thisObject,    "units", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 150] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "units") )}else{nil} );
private _unitID = _units find _unit;
if (_unitID != -1) then { 
_units set [_unitID, ""];
};
true 
} else {
false 
};
} ];


_oop_methodList pushBackUnique "getObject"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "getObject"), {
params [["_thisObject", "", [""]] ];
( if([_thisObject,    "object", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\AnimObject\AnimObject.sqf", 165] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "object") )}else{nil} )
} ];

};}