
class dialogue {
	file = "Dialogue";
	class dialogue_create {};
	class dialogue_createSimple {};

	class dialogue_setDataSets {};
	class dialogue_registerDataSet {};
	
	class dialogue_mainLoop {};
	class dialogue_mainLoop_sentence {};
	class dialogue_mainLoop_question {};
	class dialogue_mainLoop_question_return {};
	class dialogue_mainLoop_error {};
	class dialogue_mainLoop_end {};
	class dialogue_mainLoop_checkConditions {};

	class dialogue_createSentence {};
	class dialogue_deleteSentence {};
	class dialogue_updateSentence {};

	class dialogue_createQuestion {};
	class dialogue_deleteQuestion {};

	class dialogue_createHUD {};
	class dialogue_deleteHUD {postinit = 1;};//remove old hud

	class dialogue_unitSideColor {};
};

class dialogue_example {
	file = "Dialogue\Testing";
	class example {};
};

