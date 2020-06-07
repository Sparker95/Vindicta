class pr0_dialogue {
	tag = "pr0";
	class dialogue {
		file = "Dialogue";
		class dialogue_createConversation {};
		class dialogue_createSentence {};
		class dialogue_createHint {};
		class dialogue_registerDataSet {};
		class dialogue_preinit { preinit = 1; };
	};

	class hud {
		file = "Dialogue\HUD";
		class dialogue_HUD_createSentence {};
		class dialogue_HUD_deleteSentence {};
		class dialogue_HUD_updateSentence {};

		class dialogue_HUD_createQuestion {};
		class dialogue_HUD_deleteQuestion {};

		class dialogue_HUD_create {};
		class dialogue_HUD_delete {postinit = 1;};//remove old hud

		class dialogue_HUD_unitSideColor {};
	};

	class mainloop {
		file = "Dialogue\Mainloop";
		class dialogue_mainLoop {};
		class dialogue_mainLoop_sentence {};
		class dialogue_mainLoop_question {};
		class dialogue_mainLoop_question_return {};
		class dialogue_mainLoop_error {};
		class dialogue_mainLoop_end {};
		class dialogue_mainLoop_checkConditions {};
	};

	class examples {
		file = "Dialogue\Examples";
		class dialogue_example {};
	};
};
