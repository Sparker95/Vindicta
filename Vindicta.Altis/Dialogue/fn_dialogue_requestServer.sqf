/*
Called on server from fn_dialogue_request.
*/

params [["_clientOwner", -1, [0]], ["_unit", objNull, [objNull]], ["_unitPlayer", objNull, [objNull]], ["_dialogueSet_id", "", [""]], ["_node_id", "", [""]]];

if (!isServer) exitWith {
	diag_log "[Dialogue] Error: dialogue_requestServer must be called on server!";
};

// Don't bother if player or NPC is dead
if (!alive player) exitWith {};
if (!alive _unit) exitWith {};

// Unit is alive at this point
if ( [_unit] call pr0_dialogue_fnc_canTalkStartNewConversation ) then {
	// Create dialogue on client's machine
	[_unitPlayer, _unit, [_dialogueSet_id], _node_id] remoteExecCall ["pr0_fnc_dialogue_createConversation", _clientOwner, false];
} else {
	// Unit can't talk, create a simple message
	// todo finish this wth proper dialogue
	private _response = selectRandom [
		"I am busy now",
		"I can't talk now",
		"I can't talk right now",
		"I'm too busy for a talk right now"
	];
	[_unit, _response] call pr0_dialogue_fnc_dialogue_createSentence;
};