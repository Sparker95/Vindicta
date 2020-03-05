#include "defineCommon.inc"

private _array1 = [
	["main_intro",{
		[
			[TYPE_SENTENCE, "Hello, sir", 2],
			[TYPE_SENTENCE, "Hello, person", 1],
			[TYPE_JUMP_TO, "main_question"]
		]
	}],
	["main_question",{
		[
			[TYPE_QUESTION, "How can i help you?",2]
		]
	}]
];

private _array2 = [
	["main_question",TYPE_INHERIT,{
		[
			[TYPE_ANSWER, "Lets do some math", "math_intro"]
		]
	}],
	["math_intro",{
		[
			[TYPE_SENTENCE, "So you want to play some game", 2],
			[TYPE_SENTENCE, "Yes, plz!", 1],
			[TYPE_JUMP_TO, "math_question"]
		]
	}],
	["math_question",{
		[
			[TYPE_QUESTION, "What is 1+1?",2],
			[TYPE_ANSWER, "2", "math_good"],
			[TYPE_ANSWER, "4", "math_bad"],
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
			[TYPE_SENTENCE, ["You got it!","Not bad"], 2],
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


params [["_unit",objNull,[objNull]]];

["main", _array1] call pr0_fnc_dialogue_registerDataSet;
["math", _array2] call pr0_fnc_dialogue_registerDataSet;

[_unit, ["main","math"]] call pr0_fnc_dialogue_setDataSets;
