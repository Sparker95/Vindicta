class pr0 {
	
	class dialogue {
		file = "Dialogue";
		class dialogue_array {postinit = 1;};
		
		class dialogue_findConversation {};
		class dialogue_createConversation {};
		
		class dialogue_createSentence {};
		class dialogue_removeSentence {};
		class dialogue_updateSentence {};
		
		class dialogue_createHUD {};
		class dialogue_removeHUD {postinit = 1;};//remove old hud
	};
	class Voice {
		file = "Dialogue\Voice";
		class voice_init {preinit = 1;};
		class voice_say {};
	};

};
