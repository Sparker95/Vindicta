class RecruitTab : MUI_GROUP
{

	idc = -1;
	x = 0;
	y = 0;
	w = 0.7;
	h = 0.9;
	style = 0;
	text = "";

	class Controls {

		class TAB_RECRUIT_BUTTON_RECRUIT : MUI_BUTTON_TXT_ABS 
		{

			IDC = -1; 
			x = 0.020; 
			y = 0.754; 
			w = 0.659; 
			h = 0.112; 
			text = "RECRUIT"; 
			font = "PuristaMedium";
			colorText[] = MUIC_BLACK;
			colorBackground[] = MUIC_MISSION;
			colorBackgroundActive[] = MUIC_WHITE;
			colorBackgroundDisabled[] = MUIC_TXT_DISABLED;
			colorBorder[] = MUIC_TRANSPARENT;
			colorDisabled[] = MUIC_WHITE;
			colorFocused[] = MUIC_MISSION; // same as colorBackground to disable blinking
			colorShadow[] = MUIC_TRANSPARENT;

		};

		class TAB_RECRUIT_STATIC_3 : MUI_DESCRIPTION_ABS 
		{

			IDC = -1; 
			x = 0.020; 
			y = 0.086; 
			w = 0.379; 
			h = 0.040; 
			style = ST_LEFT;
			text = "AVAILABLE LOADOUTS:"; 

		};

		class TAB_RECRUIT_STATIC_2 : MUI_DESCRIPTION_ABS 
		{

			IDC = -1; 
			x = 0.020; 
			y = 0.040; 
			w = 0.256;
			h = 0.040; 
			style = ST_LEFT;
			text = "RECRUITS AVAILABLE:"; 

		};

		class TAB_RECRUIT_STATIC_N_RECRUITS : MUI_BASE_ABS 
		{

			IDC = -1; 
			x = 0.276; 
			y = 0.040; 
			w = 0.123; 
			h = 0.040; 
			style = ST_LEFT; 

		};

		class TAB_RECRUIT_STATIC_1 : MUI_DESCRIPTION_ABS 
		{

			IDC = -1; 
			x = 0.409; 
			y = 0.086; 
			w = 0.269; 
			h = 0.040; 
			style = ST_LEFT;
			text = "WEAPONS:"; 

		};

		class TAB_RECRUIT_LISTBOX_BG : MUI_BG_BLACKTRANSPARENT_ABS 
		{

			IDC = -1; 
			x = 0.020; 
			y = 0.137; 
			w = 0.379; 
			h = 0.591; 
			text = ""; 

		};

		class TAB_RECRUIT_LISTBOX : MUI_LISTNBOX_ABS 
		{

			IDC = -1; 
			x = 0.020; 
			y = 0.137; 
			w = 0.379; 
			h = 0.591; 
			text = ""; 
			columns[] = {0, 1};	// One column	

		};

		class TAB_RECRUIT_LISTBOX_PRIMARY_BG : MUI_BG_BLACKTRANSPARENT_ABS 
		{

			IDC = -1; 
			x = 0.409; 
			y = 0.137; 
			w = 0.269; 
			h = 0.289; 
			text = ""; 

		};

		class TAB_RECRUIT_LISTBOX_PRIMARY : MUI_LISTNBOX_ABS 
		{

			IDC = -1; 
			x = 0.409; 
			y = 0.137; 
			w = 0.269; 
			h = 0.289; 
			text = ""; 
			columns[] = {0, 1};	// One column	

		};

		class TAB_RECRUIT_LISTBOX_SECONDARY_BG : MUI_BG_BLACKTRANSPARENT_ABS 
		{

			IDC = -1; 
			x = 0.409; 
			y = 0.440; 
			w = 0.269; 
			h = 0.289; 
			text = ""; 

		};

		class TAB_RECRUIT_LISTBOX_SECONDARY : MUI_LISTNBOX_ABS 
		{

			IDC = -1; 
			x = 0.409; 
			y = 0.440; 
			w = 0.269; 
			h = 0.289; 
			text = ""; 
			columns[] = {0, 1};	// One column	

		};

	};
};
