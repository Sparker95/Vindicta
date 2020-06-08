/*
Called on client when player wants to talk to some NPC.

Returns: nothing

!! Assumes player as one character who will talk.
*/

params[
	["_unit",objNull,[objNull]],
	["_dialogueSet_id", "", [""]],
	["_node_id", "", [""]]
];

if (!hasInterface) exitWith {
	diag_log "[Dialogue] Error: dialogueRequest must be called on client!";
};

// Bail if player or NPC is dead
if (!alive player) exitWith {};
if (!alive _unit) exitWith {};

[clientOwner, _unit, player, clientOwner, _dialogueSet_id, _node_id] remoteExecCall ["pr0_fnc_dialogue_requestServer", 2, false];