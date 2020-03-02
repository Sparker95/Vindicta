class pr0 {

	class dialogue_common {
		file = "Dialogue\Common";
		class dialogue_common_bearingToID {};
	};

	class dialogue {
		file = "Dialogue";
		class dialogue_create {};

		class dialogue_setDataSets {};
		class dialogue_registerDataSet {};
		
		class dialogue_createSentence {};
		class dialogue_removeSentence {};
		class dialogue_updateSentence {};
		
		class dialogue_createHUD {};
		class dialogue_removeHUD {postinit = 1;};//remove old hud
	};

	class dialogue_example {
		file = "Dialogue";
		class example {};
	}
	/*
	class voice {
		file = "Dialogue\Voice";
		class voice_init {preinit = 1;};
		class voice_say {};
	};
	*/


};
