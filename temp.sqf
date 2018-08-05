{#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf"







#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\OOP_Light\OOP_Light.h"















































































































































































































































































#line 3 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.hpp"




#line 4 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf"


[] call { scopeName "scopeClass"; private _oop_classNameStr = "Goal"; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "nextID"),  0]; private _oop_memList = []; private _oop_staticMemList = []; private _oop_parents = []; private _oop_methodList = []; if ( "MessageReceiver" != "") then { 	if (!([ "MessageReceiver", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf", 11] call OOP_assert_class)) then {breakOut "scopeClass";}; 	_oop_parents = +( missionNameSpace getVariable ("o_" +  "MessageReceiver" + "_spm_" +   "parents") ); _oop_parents pushBackUnique  "MessageReceiver"; 	_oop_memList = +( missionNameSpace getVariable ("o_" +  "MessageReceiver" + "_spm_" +   "memList") ); 	_oop_staticMemList = +( missionNameSpace getVariable ("o_" +  "MessageReceiver" + "_spm_" +   "staticMemList") ); 	_oop_methodList = +( missionNameSpace getVariable ("o_" +  "MessageReceiver" + "_spm_" +   "methodList") ); 	private _oop_topParent = _oop_parents select ((count _oop_parents) - 1); 	{ private _oop_methodCode = ( missionNameSpace getVariable (_oop_topParent + "_fnc_" +   _x) ); 	missionNameSpace setVariable [("Goal" + "_fnc_" +   _x),  _oop_methodCode]; 	} forEach (_oop_methodList - ["new", "delete", "copy"]); }; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "parents"),  _oop_parents]; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "memList"),  _oop_memList]; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "staticMemList"),  _oop_staticMemList]; missionNameSpace setVariable [("o_" + _oop_classNameStr + "_spm_" +   "methodList"),  _oop_methodList]; _oop_methodList pushBackUnique "new"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "new"), {} ]; _oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "delete"), {} ]; _oop_methodList pushBackUnique "copy"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "copy"), {} ]; _oop_memList pushBackUnique "oop_parent";

_oop_memList pushBackUnique "entity"; 
_oop_memList pushBackUnique "state"; 





_oop_methodList pushBackUnique "new"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "new"), {
params [["_thisObject", "", [""]], ["_entity", "", [""]]];
if([_thisObject,   "entity", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf", 21] call OOP_assert_member) then {missionNameSpace setVariable [(_thisObject + "_" +     "entity"),    _entity]};
} ];





_oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "delete"), {
params [["_thisObject", "", [""]]];
} ];







_oop_methodList pushBackUnique "getMessageLoop"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "getMessageLoop"), {
"GOAL_ERROR_NO_MESSAGE_LOOP"
} ];





_oop_methodList pushBackUnique "activateIfInactive"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "activateIfInactive"), {
params [["_thisObject", "", [""]]];
private _state = ( if([_thisObject,    "state", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf", 48] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "state") )}else{nil} );
if (_state == 		1) then {
([_thisObject] +   []) call ( if([(( missionNameSpace getVariable (_thisObject + "_" +   "oop_parent") )),    "activate", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf", 50] call OOP_assert_method) then {( missionNameSpace getVariable ((( missionNameSpace getVariable (_thisObject + "_" +   "oop_parent") )) + "_fnc_" +      "activate") )}else{nil} );
};
} ];





_oop_methodList pushBackUnique "reactivateIfFailed"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "reactivateIfFailed"), {
params [["_thisObject", "", [""]]];
private _state = ( if([_thisObject,    "state", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf", 60] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "state") )}else{nil} );
if (_state == 		3) then {
([_thisObject] +   []) call ( if([(( missionNameSpace getVariable (_thisObject + "_" +   "oop_parent") )),    "activate", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf", 62] call OOP_assert_method) then {( missionNameSpace getVariable ((( missionNameSpace getVariable (_thisObject + "_" +   "oop_parent") )) + "_fnc_" +      "activate") )}else{nil} );
};
} ];






 _oop_methodList pushBackUnique "activate"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "activate"), {} ];


 _oop_methodList pushBackUnique "process"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "process"), {} ];


 _oop_methodList pushBackUnique "terminate"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "terminate"), {} ]; 




 








_oop_methodList pushBackUnique "isCompleted"; missionNameSpace setVariable [(_oop_classNameStr + "_fnc_" +  "isCompleted"), {
params [ ["_thisObject", "", [""]] ];
private _state = ( if([_thisObject,    "state", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Goal\Goal.sqf", 93] call OOP_assert_member) then {( missionNameSpace getVariable (_thisObject + "_" +      "state") )}else{nil} ); _state == 	2
} ];
















};}