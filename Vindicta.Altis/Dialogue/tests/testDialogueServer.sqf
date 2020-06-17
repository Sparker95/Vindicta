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

pr _nodes = [
	NODE_SENTENCE("", TALKER_NPC, "Hello I am NPC"),
	NODE_SENTENCE("", TALKER_PLAYER, "Hello I am player"),
	NODE_SENTENCE("", TALKER_NPC, "Can I help you?"),
	
	NODE_OPTIONS("main", ["opt_weather" ARG "opt_news" ARG "opt_bye"]),

	NODE_OPTION("opt_weather", "Could you tell me the weather forecast?"),
	NODE_SENTENCE("", TALKER_NPC, "It's raining whole day"),
	NODE_SENTENCE("", TALKER_PLAYER, "Thanks for the info"),
	NODE_JUMP("", "main"),

	NODE_OPTION("opt_news", "Have you heard any interesting news recently?"),
	NODE_SENTENCE("", TALKER_NPC, "Malta’s Ministry for Tourism and Consumer Protection and the Malta Tourism Authority (MTA) welcomes the announcement made yesterday by Prime Minister Robert Abela that a further six countries have been added to the list of destinations for when the airport in Malta officially reopens on July 1, and that restrictions on all other flight destinations will be lifted on July 15th."),
	NODE_SENTENCE("", TALKER_PLAYER, "Wow that was really interesting!"),
	NODE_SENTENCE("", TALKER_NPC, "Yes I know!"),
	NODE_JUMP("", "main"),

	NODE_OPTION("opt_bye", "Bye, I must leave now"),
	NODE_SENTENCE("", TALKER_NPC, "See you next time!"),
	NODE_END("")
];
pr _args = [ _nodes, _object, player, clientOwner];
gDialogue = NEW("Dialogue", _args);

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