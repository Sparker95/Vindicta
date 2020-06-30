#include "..\common.hpp"

// Test dialogue class

#define OOP_CLASS_NAME DialogueTest
CLASS("DialogueTest", "Dialogue")

	protected override METHOD(getNodes)
		params [P_THISOBJECT, P_OBJECT("_unit0"), P_OBJECT("_unit1")];
		pr _array = [
			NODE_SENTENCE("", TALKER_NPC, "Hello I am NPC"),
			NODE_SENTENCE("", TALKER_PLAYER, "Hello I am player"),
			NODE_SENTENCE("main", TALKER_NPC, "Can I help you with something?"),
			
			NODE_OPTIONS("", ["opt_weather" ARG "opt_news" ARG "opt_bye" ARG "opt_testJumpIf" ARG "opt_testCall" ARG "opt_testCallMethod" ARG "opt_testSentMethod"]),

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
			NODE_END(""),

			NODE_OPTION("opt_testCall", "Test NODE_CALL"),
			NODE_CALL("", "node_testSrt"),
			NODE_JUMP("", "main"),

			NODE_OPTION("opt_testCallMethod", "Test NODE_CALL_METHOD"),
			NODE_SENTENCE("", TALKER_NPC, "Calling method"),
			NODE_CALL_METHOD("", "testMethod", [123]), // tag, method name, arguments
			NODE_SENTENCE("", TALKER_NPC, "Method called"),
			NODE_JUMP("", "main"),

			// Test subroutine with JUMP_IF
			NODE_OPTION("opt_testJumpIf", "Test NODE_JUMP_IF"),
			NODE_SENTENCE("", TALKER_NPC, "You must be between 2 and 5 meters away from me"),
			NODE_JUMP_IF("", "fail_tooClose", "isTooClose", []),
			NODE_JUMP_IF("", "fail_tooFar", "isTooFar", []),
			// If we are here, then we are neither too close nor too far
			NODE_SENTENCE("", TALKER_NPC, "Perfect! You are at perfect distance!"),
			NODE_JUMP("", "main"),

			NODE_SENTENCE("fail_tooClose", TALKER_NPC, "You are too close! Try again!"),
			NODE_JUMP("", "main"),
			NODE_SENTENCE("fail_tooFar", TALKER_NPC, "You are too far! Try again!"),
			NODE_JUMP("", "main"),

			// Test NODE_SENTENCE_METHOD
			NODE_OPTION("opt_testSentMethod", "Test NODE_SENTENCE_METHOD"),
			NODE_SENTENCE_METHOD("", TALKER_NPC, "getDynamicText"),	// It will call a method getDynamicText to get the actual sentence
			NODE_JUMP("", "main"),

			// Test subroutine
			// After nodes are executed, it should return back to where it was called from
			NODE_SENTENCE("node_testSrt", TALKER_NPC, "One"),
			NODE_SENTENCE("", TALKER_PLAYER, "Two"),
			NODE_SENTENCE("", TALKER_NPC, "Three"),
			NODE_RETURN("")
		];

		_array;
	ENDMETHOD;

	METHOD(testMethod)
		params [P_THISOBJECT, P_NUMBER("_value")];
		systemChat format ["testMethod: %1", _value];
	ENDMETHOD;

	METHOD(isTooClose)
		params [P_THISOBJECT];
		(T_GETV("unit0") distance T_GETV("unit1")) < 2;
	ENDMETHOD;

	METHOD(isTooFar)
		params [P_THISOBJECT];
		(T_GETV("unit0") distance T_GETV("unit1")) > 5;
	ENDMETHOD;

	METHOD(getDynamicText)
		params [P_THISOBJECT];
		format ["We are located at %1, random number: %2", mapGridPosition T_GETV("unit0"), random 3];
	ENDMETHOD;

ENDCLASS;