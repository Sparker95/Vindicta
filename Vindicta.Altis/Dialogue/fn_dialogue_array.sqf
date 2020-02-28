#include "defineCommon.inc"



pr0_dialogue_array = [
	["",{
		params["_unit_1","_unit_2"];
		private _return = [];

		_return;
	}],
	
	["math_intro",{
		[
			[TYPE_SENTENCE, "Hello, player", 2],
			[TYPE_SENTENCE, "Hello, ai", 1],
			[TYPE_JUMP_TO, "math_intro"]
		]
	}],
	["math_question",{
		[
			[TYPE_QUESTION, "What is 1+1?"],
			[TYPE_OPTION, "2", "math_good"],
			[TYPE_OPTION, "4", "math_bad"],
			[TYPE_EVENT_WALKED_AWAY, "math_WALKED_AWAY"],
			[TYPE_EVENT_OUT_OF_TIME, "math_OUT_OF_TIME"]
		]
	}],
	["math_WALKED_AWAY",{
		[
			[TYPE_SENTENCE, "Yes walk away!", 2],
			[TYPE_JUMP_TO, "#end"]
		]
		
	}],
	["math_OUT_OF_TIME",{
		[
			[TYPE_SENTENCE, "To slow", 2],
			[TYPE_JUMP_TO, "#end"]
		]
	}],
	["math_good",{
		[
			[TYPE_SENTENCE, "You got it!", 2],
			[TYPE_JUMP_TO, "#end"]
		]
	}],
	["math_bad",{
		[
			[TYPE_SENTENCE, "No stupid try again!", 2],
			[TYPE_JUMP_TO, "math_question"]
		]
	}]
];