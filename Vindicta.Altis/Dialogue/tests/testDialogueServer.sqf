#include "..\common.hpp"

/*
Tests server-client dialogue interaction, but not MP-compatible.
*/

// Delete previous dialogue if it exists
if (!isNil "gDialogue") then {
	if (IS_OOP_OBJECT(gDialogue)) then {
		DELETE(gDialogue);

		removeMissionEventHandler ["EachFrame", gDialogueEHID]; 
	};
};

pr _object = cursorObject;
if (isNull _object) exitWith {
	diag_log "Error: cursor object is null";
};

pr _args = [ _object, player, clientOwner];
gDialogue = NEW("DialogueTest", _args);

// Add per frame handler
gDialogueEHID = addMissionEventHandler ["EachFrame", {
	CALLM0(gDialogue, "process");
	private _ended = CALLM0(gDialogue, "hasEnded");
	if (_ended) then {
		OOP_INFO_0("Dialogue has ended!");
		DELETE(gDialogue);
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
	};
}];