/*
Extends fn_arsenal_init.
Initializes the arsenal persistently, handles generation of a unique JIP ID  string.
Must run on the server.

Author: Sparker
*/

#define __JIPID(ID) format ["jna_init_%1", ID]

if (!isServer) exitWith {};

params [["_object", objNull, [objNull]], ["_initialValue", []]];

// Bail if a null object is passed (why??)
if (isNull _object) exitWith {};

// Set initial arsenal item array value
if (count _initialValue > 0) then {
	_object setVariable ["jna_datalist", _initialValue];
};

// Generate a JIP ID
private _ID = 0;
if(isNil "jna_nextID") then {
	jna_nextID = 0;
	_ID = 0;
} else {
	_ID = jna_nextID;
};
jna_nextID = jna_nextID + 1;

private _JIPID = __JIPID(_ID);
_object setVariable ["jna_id", _ID];
[_object] remoteExecCall ["jn_fnc_arsenal_init", 0, _JIPID]; // Execute globally, add to the JIP queue

// Add an event handler to delete the init from the JIP queue when the object is gone
_object addEventHandler ["Deleted", {
	params ["_entity"];
	private _ID = _entity getVariable "jna_id";
	if (isNil "_ID") exitWith {
		diag_log format ["JNA arsenal_initPersistent: error: no JIP ID for object %1", _entity];
	};
	private _JIPID = __JIPID(_ID);
	remoteExecCall ["", _JIPID]; // Remove it from the queue
}];