class Dialog {
	
	class HUD {
		file = "Dialogue\HUD";
		class hud_init {postinit = 1;};
		class hud_createSentence {};
	};
	class Voice {
		file = "Dialogue\Voice";
		class voice_init {preinit = 1;};
		class voice_say {};
	};

};
