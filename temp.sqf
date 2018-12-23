{#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf"
#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\OOP_Light\OOP_Light.h"



























































































































































































































































































































#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Message\Message.hpp"





































#line 2 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\CriticalSection\CriticalSection.hpp"










#line 3 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf"

#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.hpp"





#line 4 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf"














g_ownerRqNextID = 0;

g_rqArray = [0];



MsgRcvr_fnc_setMsgDone = {
params ["_msgID", ["_result", 0]];
private _rqArrayElement = g_rqArray select _msgID; 
_rqArrayElement set [0, 1]; 
_rqArrayElement set [1, _result];
};

[] call { scopeName "scopeClass"; private _oop_classNameStr = "MessageReceiver"; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "nextID")),  0]; private _oop_memList = []; private _oop_staticMemList = []; private _oop_parents = []; private _oop_methodList = []; if ( "" != "") then { 	if (!([ "", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 31] call OOP_assert_class)) then {breakOut "scopeClass";}; 	_oop_parents = +( missionNameSpace getVariable ("o_" + ( "") + "_spm_" + (  "parents")) ); _oop_parents pushBackUnique  ""; 	_oop_memList = +( missionNameSpace getVariable ("o_" + ( "") + "_spm_" + (  "memList")) ); 	_oop_staticMemList = +( missionNameSpace getVariable ("o_" + ( "") + "_spm_" + (  "staticMemList")) ); 	_oop_methodList = +( missionNameSpace getVariable ("o_" + ( "") + "_spm_" + (  "methodList")) ); 	private _oop_topParent = _oop_parents select ((count _oop_parents) - 1); 	{ private _oop_methodCode = ( missionNameSpace getVariable ((_oop_topParent) + "_fnc_" + (  _x)) ); 	missionNameSpace setVariable [(("MessageReceiver") + "_fnc_" + (  _x)),  _oop_methodCode]; 	} forEach (_oop_methodList - ["new", "delete", "copy"]); }; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "parents")),  _oop_parents]; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "memList")),  _oop_memList]; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "staticMemList")),  _oop_staticMemList]; missionNameSpace setVariable [("o_" + (_oop_classNameStr) + "_spm_" + (  "methodList")),  _oop_methodList]; _oop_methodList pushBackUnique "new"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "new")), {} ]; _oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "delete")), {} ]; _oop_methodList pushBackUnique "copy"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "copy")), {} ]; _oop_memList pushBackUnique "oop_parent";

_oop_memList pushBackUnique "owner";


_oop_methodList pushBackUnique "getMessageLoop"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "getMessageLoop")), {
""
} ];


_oop_methodList pushBackUnique "new"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "new")), {
params [ ["_thisObject", "", [""]] ];
if([_thisObject,    "owner", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 42] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +      "owner"),     clientOwner]};
} ];


_oop_methodList pushBackUnique "delete"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "delete")), {
params [ ["_thisObject", "", [""]] ];
private _msgLoop = ([_thisObject] +   []) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "getMessageLoop", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 48] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "getMessageLoop")) )}else{nil} );
diag_log format ["[MessageReceiver:delete] Info: deleting object %1, its message loop: %2", _thisObject, ([_thisObject]) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "getMessageLoop", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 49] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "getMessageLoop")) )}else{nil} )];

([_msgLoop] +   [_thisObject]) call ( if([(( missionNameSpace getVariable ((_msgLoop) + "_" +   "oop_parent") )),    "deleteReceiverMessages", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 51] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_msgLoop) + "_" +   "oop_parent") ))) + "_fnc_" + (     "deleteReceiverMessages")) )}else{nil} );
} ];









_oop_methodList pushBackUnique "handleMessage"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "handleMessage")), { 
params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];

diag_log format ["[MessageReceiver] handleMessage: %1", _msg];
false 
} ];




_oop_methodList pushBackUnique "postMessage"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "postMessage")), {
params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]], ["_returnMsgID", false] ];


private _owner = ( if([_thisObject,    "owner", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 76] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +      "owner") )}else{nil} );

if (_owner == clientOwner) then {
private _messageLoop = ([_thisObject] +  []) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),   "getMessageLoop", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 79] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (    "getMessageLoop")) )}else{nil} );
if (_messageLoop == "") exitWith { diag_log format ["[MessageReceiver:postMessage] Error: %1 is not assigned to a message loop", _thisObject];};
_msg set [0, _thisObject]; 


if (_returnMsgID) then {

private _msgID = 0;
private _null = isNil {
_msgID = g_rqArray find 0;
if (_msgID == -1) then {
_msgID = g_rqArray pushback [0, 0, _thisObject]; 
} else {
g_rqArray set [_msgID, [0, 0, _thisObject]];
};
};


_msg set [3, _msg];


([_messageLoop,   _msg]) call ( if([(( missionNameSpace getVariable ((_messageLoop) + "_" +   "oop_parent") )),    "postMessage", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 100] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_messageLoop) + "_" +   "oop_parent") ))) + "_fnc_" + (     "postMessage")) )}else{nil} );


_msgID
} else {

([_messageLoop,   _msg]) call ( if([(( missionNameSpace getVariable ((_messageLoop) + "_" +   "oop_parent") )),    "postMessage", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 106] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_messageLoop) + "_" +   "oop_parent") ))) + "_fnc_" + (     "postMessage")) )}else{nil} );


-66.6
};
} else {

diag_log "Sending msg to a remote machine";
if (_returnMsgID) then {

private _null = isNil {
_msgID = g_rqArray find 0;
if (_msgID == -1) then {
_msgID = g_rqArray pushback [0, 0, _thisObject]; 
} else {
g_rqArray set [_msgID, [0, 0, _thisObject]];
};
};


_msg set [3, _msg];



[_thisObject,  "postMessage",  [_msg]] remoteExecCall("OOP_callFromRemote",  _owner, false);


_msgID
} else {



[_thisObject,  "postMessage",  [_msg]] remoteExecCall("OOP_callFromRemote",  _owner, false);


-66.6
};
};
} ];





_oop_methodList pushBackUnique "messageDone"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "messageDone")), {
params ["_thisClass", "_msgID"];


if (_msgID < 0) exitWith {
if (_msgID == -66.6) then {
diag_log format ["[MessageReceiver:messageDone] Error: provided message ID that was not requested. You must request a valid message ID first."];
};
true
};


if ((g_rqArray select _msgID) isEqualTo 0) exitWith {
diag_log format ["[MessageReceiver::messageDone] Error: message with ID %1 has already been processed!", _msgID];
};

private _rqArray = g_rqArray;
if ((g_rqArray select _msgID select 0) == 1) then {

g_rqArray set [_msgID, 0];
true
} else {
false
}
} ];



_oop_methodList pushBackUnique "waitUntilMessageDone"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "waitUntilMessageDone")), {
params [ ["_thisObject", "", [""]], ["_msgID", 0, [0]] ];


if (_msgID < 0) exitWith {
if (_msgID == -66.6) then {
diag_log format ["[MessageReceiver:waitUntilMessageDone] Error: Object: %1, provided message ID that was not requested. You must request a valid message ID first.", _thisObject];
};
true
};


if ((g_rqArray select _msgID) isEqualTo 0) exitWith {
diag_log format ["[MessageReceiver::waitUntilMessageDone] Error: message with ID %1 has already been processed!", _msgID];
};


private _return = 0;
waitUntil {

(g_rqArray select _msgID select 0) == 1
};
_return = g_rqArray select _msgID select 1;


g_rqArray set [_msgID, 0];

_return
} ];
















 _oop_methodList pushBackUnique "setOwner"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "setOwner")), {
params [ ["_thisObject", "", [""]], ["_newOwner", 0, [0]] ];


private _owner = ( if([_thisObject,    "owner", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 227] call OOP_assert_member) then {( missionNameSpace getVariable ((_thisObject) + "_" +      "owner") )}else{nil} );
if (_owner != clientOwner) exitWith {
diag_log format ["[MessageReceiver:setOwner] Error: can't change ownership of object %1 from %2 to %3. Reason: object is owned not by this machine. This machine owner ID:%4.",
_thisObject, _owner, _newOwner, clientOwner];


false
};


if ( ((allPlayers findif {owner _x == _newOwner}) == -1) || ((_newOwner == 2) && !isMultiplayer) || (clientOwner == 0 && _newOwner == 2) ) exitWith {
diag_log format ["[MessageReceiver:setOwner] Error: can't change ownership of object %1 from %2 to %3. Reason: new owner is invalid.",
_thisObject, _owner, _newOwner, clientOwner];


false
};




private _serData = ([_thisObject] +   []) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "serialize", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 248] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "serialize")) )}else{nil} );
private _parent = (( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )); 

private _uniqueID = g_ownerRqNextID;
private _null = isNil {
g_ownerRqNextID = g_ownerRqNextID + 1; 
};

private _ackVarName = "ownerChangeAck_"+(str _uniqueID); 
missionNamespace setVariable [_ackVarName, nil];
[_thisObject, _parent, _uniqueID, _serdata] remoteExecCall [(("MessageReceiver") + "_fnc_" + ( "receiveOwnership")), _newOwner, false];
private _timeTimeout = time + 2;
waitUntil {
(! (isNil _ackVarName)) || (time > _timeTimeout)
};


if (time > _timeTimeout) exitWith {


[[_thisObject, clientOwner], {if([_this select 0,    "owner", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 268] call OOP_assert_member) then {missionNameSpace setVariable [((_this select 0) + "_" +      "owner"),     _this select 1]};}] remoteExecCall ["call", _newOwner, false];

diag_log format ["[MessageReceiver:setOwner] Error: can't change ownership of object %1 from %2 to %3. Reason: timeout.",
_thisObject, _owner, _newOwner, clientOwner];


false
};



if (! (([_thisObject,   _newOwner]) call ( if([(( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") )),    "transferOwnership", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 279] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_thisObject) + "_" +   "oop_parent") ))) + "_fnc_" + (     "transferOwnership")) )}else{nil} ))) exitWith {





[[_thisObject, clientOwner], {if([_this select 0,    "owner", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 285] call OOP_assert_member) then {missionNameSpace setVariable [((_this select 0) + "_" +      "owner"),     _this select 1]};}] remoteExecCall ["call", _newOwner, false];


if([_thisObject,    "owner", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 288] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +      "owner"),     clientOwner]};


false
};

if([_thisObject,    "owner", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 294] call OOP_assert_member) then {missionNameSpace setVariable [((_thisObject) + "_" +      "owner"),     _newOwner]};


diag_log format ["[MessageReceiver:setOwner] Success: changed owner of %1 to %2", _thisObject, _newOwner];
true

} ];



 _oop_methodList pushBackUnique "receiveOwnership"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "receiveOwnership")), {
params [ ["_objNameStr", "", [""]], ["_objParent", "", [""]], ["_uniqueID", 0, [0]], ["_serialData", 0]];

diag_log format ["Receive ownership was called: %1", _this];


private _newObj = [] call { missionNameSpace setVariable [(( _objNameStr) + "_" +   "oop_parent"),  _objParent];  _objNameStr };
if([_newObj,    "owner", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 311] call OOP_assert_member) then {missionNameSpace setVariable [((_newObj) + "_" +      "owner"),     clientOwner]};


private _deserSuccess = ([_newObj] +   [_serialData]) call ( if([(( missionNameSpace getVariable ((_newObj) + "_" +   "oop_parent") )),    "deserialize", "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\MessageReceiver\MessageReceiver.sqf", 314] call OOP_assert_method) then {( missionNameSpace getVariable (((( missionNameSpace getVariable ((_newObj) + "_" +   "oop_parent") ))) + "_fnc_" + (     "deserialize")) )}else{nil} );

diag_log format ["[MessageReceiver::receiveOwnership] Info: Transfering %1. Sending ACK to %2", _objNameStr, remoteExecutedOwner];


[_uniqueID, {missionNamespace setVariable ["ownerChangeAck_"+(str _this), 1];}] remoteExecCall ["call", remoteExecutedOwner, false];
} ];









 _oop_methodList pushBackUnique "serialize"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "serialize")), {
params [["_thisObject", "", [""]]];
diag_log format ["[MessageReceiver:serialize] Error: method serialize is not implemented for %1!", _thisObject];


0
} ];


 _oop_methodList pushBackUnique "deserialize"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "deserialize")), {
params [["_thisObject", "", [""]], "_serialData"];
diag_log format ["[MessageReceiver:serialize] Error: method deserialize is not implemented for %1!", _thisObject];
} ];




 _oop_methodList pushBackUnique "transferOwnership"; missionNameSpace setVariable [((_oop_classNameStr) + "_fnc_" + ( "transferOwnership")), {
params [ ["_thisObject", "", [""]], ["_newOwner", 0, [0]] ];
diag_log format ["[MessageReceiver:transferOwnership] Error: method transferOwnership is not implemented for %1!", _thisObject];
false
} ];

};}