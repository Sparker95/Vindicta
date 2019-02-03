{#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf"



#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\OOP_Light\OOP_Light.h"








































































































































































































































































































































































#line 4 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf"











[] call { scopeName "scopeClass"; private _oop_classNameStr = "MapMarkerLocation"; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "nextID")),  0]; private _oop_memList = []; private _oop_staticMemList = []; private _oop_parents = []; private _oop_methodList = []; if ( "MapMarker" != "") then { 	if (!([ "MapMarker", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 15] call OOP_assert_class)) then {breakOut "scopeClass";}; 	_oop_parents = +( missionNameSpace getVariable ("o_" + ( "MapMarker") + "_spm_" + (  "parents")) ); _oop_parents pushBackUnique  "MapMarker"; 	_oop_memList = +( missionNameSpace getVariable ("o_" + ( "MapMarker") + "_spm_" + (  "memList")) ); 	_oop_staticMemList = +( missionNameSpace getVariable ("o_" + ( "MapMarker") + "_spm_" + (  "staticMemList")) ); 	_oop_methodList = +( missionNameSpace getVariable ("o_" + ( "MapMarker") + "_spm_" + (  "methodList")) ); 	private _oop_topParent = _oop_parents select ((count _oop_parents) - 1); 	{ private _oop_methodCode = ( missionNameSpace getVariable ((_oop_topParent) + "_fnc_" + (  _x)) ); 	missionNameSpace setVariable [(("MapMarkerLocation") + "_fnc_" + (  _x)),  _oop_methodCode]; 	} forEach (_oop_methodList - ["new", "delete", "copy"]); }; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "parents")),  _oop_parents]; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "memList")),  _oop_memList]; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "staticMemList")),  _oop_staticMemList]; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "methodList")),  _oop_methodList]; _oop_methodList pushBackUnique "new"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "new")), {} ]; _oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "delete")), {} ]; _oop_methodList pushBackUnique "copy"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "copy")), {} ]; _oop_memList pushBackUnique "oop_parent";

_oop_memList pushBackUnique "angle";
_oop_memList pushBackUnique "selected";
_oop_staticMemList pushBackUnique "selectedLocationMarker";

_oop_methodList pushBackUnique "new"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "new")), {
params ["_thisObject"];
;
if([_thisObject,   "angle", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 23] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +     "angle"),     0]};
if([_thisObject,   "selected", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 24] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +     "selected"),     false]};
} ];

_oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "delete")), {
params ["_thisObject"];

} ];


_oop_methodList pushBackUnique "onDraw"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "onDraw")), {
params ["_thisObject", "_control"];

private _pos = ( if([_thisObject,   "pos", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 36] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "pos") )}else{nil} );



_control drawIcon 
[
"\A3\ui_f\data\map\markers\military\circle_CA.paa",

[0.8,0,0,1], 
_pos, 
20, 
20, 
0, 
"   " + "Enemy base" 
];

if (( if([_thisObject,   "selected", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 52] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "selected") )}else{nil} )) then {
private _angle = ( if([_thisObject,   "angle", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 53] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +     "angle") )}else{nil} );















_control drawIcon 
[
"\A3\ui_f\data\map\groupicons\selector_selectable_ca.paa",
[1,0,0,1], 
_pos, 
29, 
29, 
-_angle, 
"" 
];


if([_thisObject,   "angle", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 81] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +     "angle"),     _angle + 10/diag_FPS]};
};

} ];








_oop_methodList pushBackUnique "onMouseEnter"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "onMouseEnter")), {
params ["_thisObject"];
diag_log format ["[%1.%2] INFO: %3", (( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )), _thisObject, "ENTER"];

} ];







_oop_methodList pushBackUnique "onMouseLeave"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "onMouseLeave")), {
params ["_thisObject"];
diag_log format ["[%1.%2] INFO: %3", (( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )), _thisObject, "LEAVE"];

} ];












_oop_methodList pushBackUnique "onMouseButtonDown"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "onMouseButtonDown")), {
params ["_thisObject", "_button", "_shift", "_ctrl", "_alt"];
diag_log format ["[%1.%2] INFO: %3", (( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )), _thisObject, format ["DOWN Button: %1 Shift: %2 Ctrl: %3 Alt: %4",  _button,  _shift,  _ctrl,  _alt]];
} ];












_oop_methodList pushBackUnique "onMouseButtonUp"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "onMouseButtonUp")), {
params ["_thisObject", "_button", "_shift", "_ctrl", "_alt"];
diag_log format ["[%1.%2] INFO: %3", (( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )), _thisObject, format ["UP Button: %1 Shift: %2 Ctrl: %3 Alt: %4",  _button,  _shift,  _ctrl,  _alt]];
} ];











_oop_methodList pushBackUnique "onMouseButtonClick"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "onMouseButtonClick")), {
params ["_thisObject", "_shift", "_ctrl", "_alt"];
diag_log format ["[%1.%2] INFO: %3", (( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )), _thisObject, format ["CLICK Shift: %1 Ctrl: %2 Alt: %3",  _shift,  _ctrl,  _alt]];

;

if([_thisObject,   "selected", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 159] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +     "selected"),     true]};
if(["MapMarkerLocation",   "selectedLocationMarker", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 160] call OOP_assert_staticMember) then {missionNameSpace setVariable [(("o_") + ("MapMarkerLocation") + "_stm_" + (    "selectedLocationMarker")),    _thisObject]};
} ];


_oop_methodList pushBackUnique "deselectAllMarkers"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "deselectAllMarkers")), {
params ["_thisClass"];

private _prevMarker = ( if(["MapMarkerLocation",   "selectedLocationMarker", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 167] call OOP_assert_staticMember) then {( missionNameSpace getVariable (("o_") + ("MapMarkerLocation") + "_stm_" + (    "selectedLocationMarker")) )}else{nil} );
if (_prevMarker != "") then {
if([_prevMarker,    "selected", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 169] call OOP_assert_member) then {missionNameSpace setVariable [((_prevMarker) + "_" +      "selected"),     false]};
};
};

_oop_methodList pushBackUnique "onMouseClickElsewhere"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "onMouseClickElsewhere")), {
params ["_thisClass"];

(["MapMarkerLocation"] +  []) call ( if(["MapMarkerLocation",   "deselectAllMarkers", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 176] call OOP_assert_method) then {( missionNameSpace getVariable (("MapMarkerLocation") + "_fnc_" + (    "deselectAllMarkers")) )}else{nil} );
} ];

};

if(["MapMarkerLocation",   "selectedLocationMarker", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 181] call OOP_assert_staticMember) then {missionNameSpace setVariable [(("o_") + ("MapMarkerLocation") + "_stm_" + (    "selectedLocationMarker")),    ""]};

[missionNamespace, "MapMarker_MouseButtonDown_none", {
;
}] call BIS_fnc_addScriptedEventHandler;

[missionNamespace, "MapMarker_MouseButtonClick_none", {
;
}] call BIS_fnc_addScriptedEventHandler;


private _testMarker = [] call { if (!(["MapMarkerLocation", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 192] call OOP_assert_class)) exitWith {format ["ERROR_NO_CLASS_%1", "MapMarkerLocation"]}; private _oop_nextID = ( missionNameSpace getVariable ("o_" + ("MapMarkerLocation") + "_spm_" + (  "nextID")) ); if (isNil "_oop_nextID") then { missionNameSpace setVariable [("o_" + ("MapMarkerLocation") + "_spm_" + (  "nextID")),  0];	_oop_nextID = 0;}; missionNameSpace setVariable [("o_" + ("MapMarkerLocation") + "_spm_" + (  "nextID")),  _oop_nextID+1]; private _objNameStr = ("o_" + ("MapMarkerLocation") + "_N_" + (format ["%1",  _oop_nextID])); missionNameSpace setVariable [((_objNameStr) + "_" +   "oop_parent"),  "MapMarkerLocation"]; private _oop_parents = ( missionNameSpace getVariable ("o_" + ("MapMarkerLocation") + "_spm_" + (  "parents")) ); private _oop_i = 0; private _oop_parentCount = count _oop_parents; while {_oop_i < _oop_parentCount} do { 	([_objNameStr] +  []) call ( if([(_oop_parents select _oop_i),  "new", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 192] call OOP_assert_method) then {( missionNameSpace getVariable (((_oop_parents select _oop_i)) + "_fnc_" + (   "new")) )}else{nil} ); 	_oop_i = _oop_i + 1; }; ([_objNameStr] +   []) call ( if([(( missionNameSpace getVariable ((_objNameStr) + "_" +   "oop_parent") )),   "new", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 192] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_objNameStr) + "_" +   "oop_parent") ))) + "_fnc_" + (    "new")) )}else{nil} ); _objNameStr };
private _pos = [4123, 5123];
([_testMarker,   _pos]) call ( if([(( missionNameSpace getVariable ((_testMarker) + "_" +   "oop_parent") )),    "setPos", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 194] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_testMarker) + "_" +   "oop_parent") ))) + "_fnc_" + (     "setPos")) )}else{nil} );

private _testMarker = [] call { if (!(["MapMarkerLocation", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 196] call OOP_assert_class)) exitWith {format ["ERROR_NO_CLASS_%1", "MapMarkerLocation"]}; private _oop_nextID = ( missionNameSpace getVariable ("o_" + ("MapMarkerLocation") + "_spm_" + (  "nextID")) ); if (isNil "_oop_nextID") then { missionNameSpace setVariable [("o_" + ("MapMarkerLocation") + "_spm_" + (  "nextID")),  0];	_oop_nextID = 0;}; missionNameSpace setVariable [("o_" + ("MapMarkerLocation") + "_spm_" + (  "nextID")),  _oop_nextID+1]; private _objNameStr = ("o_" + ("MapMarkerLocation") + "_N_" + (format ["%1",  _oop_nextID])); missionNameSpace setVariable [((_objNameStr) + "_" +   "oop_parent"),  "MapMarkerLocation"]; private _oop_parents = ( missionNameSpace getVariable ("o_" + ("MapMarkerLocation") + "_spm_" + (  "parents")) ); private _oop_i = 0; private _oop_parentCount = count _oop_parents; while {_oop_i < _oop_parentCount} do { 	([_objNameStr] +  []) call ( if([(_oop_parents select _oop_i),  "new", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 196] call OOP_assert_method) then {( missionNameSpace getVariable (((_oop_parents select _oop_i)) + "_fnc_" + (   "new")) )}else{nil} ); 	_oop_i = _oop_i + 1; }; ([_objNameStr] +   []) call ( if([(( missionNameSpace getVariable ((_objNameStr) + "_" +   "oop_parent") )),   "new", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 196] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_objNameStr) + "_" +   "oop_parent") ))) + "_fnc_" + (    "new")) )}else{nil} ); _objNameStr };
private _pos = [5123, 5123];
([_testMarker,   _pos]) call ( if([(( missionNameSpace getVariable ((_testMarker) + "_" +   "oop_parent") )),    "setPos", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\UI\MapMarkerLocation\MapMarkerLocation.sqf", 198] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_testMarker) + "_" +   "oop_parent") ))) + "_fnc_" + (     "setPos")) )}else{nil} );}