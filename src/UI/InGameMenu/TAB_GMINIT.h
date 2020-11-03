class TAB_GMINIT : MUI_GROUP_ABS
{
	
	x = 0;
	y = 0;
	w = 0.7;
	h = 0.9;

	class Controls
	{

		class LISTBOX_DESCR : MUI_DESCRIPTION_ABS 
		{
			IDC = -1; 
			x = 0.020; 
			y = 0.414; 
			w = 0.659; 
			h = 0.038;
			text = $STR_GMINIT_CHOSEN_FACTIONS;
		};

		// static background, absolutely no need to manipulate in sqf!
		class TAB_GMINIT_LISTNBOX_SETTINGS_BG : MUI_BG_BLACKTRANSPARENT_ABS 
		{
			IDC = -1; 
			x = 0.020; 
			y = 0.462; 
			w = 0.659; 
			h = 0.299;
		};

		// listbox for game settings
		class TAB_GMINIT_LISTNBOX_SETTINGS : MUI_LISTNBOX_ABS 
		{
			IDC = -1; 
			x = 0.020; 
			y = 0.462; 
			w = 0.659; 
			h = 0.299;
			columns[] = {0, 1};	// One column 
		};

		/*
		// displays selected faction info and errors
		class TAB_GMINIT_STATIC_DESCRIPTION : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS
		{
			idc = -1;
			x = 0.020; 
			y = 0.324; 
			w = 0.659; 
			h = 0.436; 
			text = x"Description...";
			
		}; */

		class STATIC_GMINIT_HEADLINE : MUI_BASE_ABS 
		{
			IDC = -1; 
			x = 0.020; 
			y = 0.030; 
			w = 0.659; 
			h = 0.038; 
			text = $STR_GMINIT_NEW_CAMPAIGN;
			style = 0;
			font = "PuristaBold";
		};
		
		class STATIC_GAME_MODE : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.138; 
			w = 0.266; 
			h = 0.038;
			text = $STR_GMINIT_GAMEMODE;
		};

		class STATIC_ENEMY_FORCE_PERCENTAGE : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.313; 
			w = 0.266; 
			h = 0.038;  
			text = $STR_GMINIT_INITIAL_ENY;
			hint = "Hint Hint";
		};

		class STATIC_ENEMY_OUTPOSTS_OCCUPIED : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.357; 
			w = 0.266; 
			h = 0.038;  
			text = $STR_GMINIT_INITIAL_ENEMY_OUTPOSTS;
			hint = "Hint Hint";
		};

		class STATIC_MILITARY_FACTION : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.182; 
			w = 0.266; 
			h = 0.038;
			text = $STR_GMINIT_MIL_FACTION;
		};

		class STATIC_CAMPAIGN_NAME : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.094; 
			w = 0.266; 
			h = 0.038; 
			text = $STR_GMINIT_CAMPAIGN_NAME;
		};

		class STATIC_POLICE_FACTION : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.225; 
			w = 0.266; 
			h = 0.038;
			text = $STR_GMINIT_CIV_FACTION;
		};

		class STATIC_ENEMY_CIV_FACTION : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.269; 
			w = 0.266; 
			h = 0.038;  
			text = $STR_GMINIT_POL_FACTION;
		};

		class TAB_GMINIT_EDIT_ENEMY_PERCENTAGE : MUI_EDIT_ABS 
		{
			idc = -1;
			x = 0.308; 
			y = 0.313; 
			w = 0.371; 
			h = 0.038; 
			text = "100";
			style = 0;
		};

		class TAB_GMINIT_EDIT_ENEMY_OUTPOSTS_OCCUPIED : MUI_EDIT_ABS 
		{
			idc = -1;
			x = 0.308; 
			y = 0.357; 
			w = 0.371; 
			h = 0.038; 
			text = "35";
			style = 0;
		};

		class TAB_GMINIT_EDIT_CAMPAIGN_NAME : MUI_EDIT_ABS 
		{
			idc = -1;
			x = 0.308; 
			y = 0.094; 
			w = 0.333; 
			h = 0.038;
			text = $STR_GMINIT_NAME;
			style = 0;
		};

		class TAB_GMINIT_BUTTON_RND : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.646; 
			y = 0.094; 
			w = 0.033; 
			h = 0.038;
			text = "~";
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

		class TAB_GMINIT_COMBO_GAME_MODE : MUI_COMBOBOX_ABS 
		{
			idc = -1;
			x = 0.308; 
			y = 0.138; 
			w = 0.371; 
			h = 0.038;
			text = $STR_GMINIT_CIV_WAR;			
		};

		// military faction combobox
		class TAB_GMINIT_COMBO_ENEMY_FACTION : MUI_COMBOBOX_ABS 
		{
			idc = -1;
			x = 0.308; 
			y = 0.182; 
			w = 0.371; 
			h = 0.038; 
			text = "AAF";			
		};

		class TAB_GMINIT_COMBO_POLICE_FACTION : MUI_COMBOBOX_ABS 
		{
			idc = -1;
			x = 0.308; 
			y = 0.225; 
			w = 0.371; 
			h = 0.038;
			text = $STR_GMINIT_STD;
		};

		class TAB_GMINIT_COMBO_CIV_FACTION : MUI_COMBOBOX_ABS 
		{
			idc = -1;
			x = 0.308; 
			y = 0.269; 
			w = 0.371; 
			h = 0.038; 
			text = $STR_GMINIT_STD;
		};

		class TAB_GMINIT_BUTTON_SETTINGS : MUI_BUTTON_TXT_ABS
		{
			IDC = -1; 
			x = 0.020; 
			y = 0.780; 
			w = 0.404; 
			h = 0.087; 
			text = $STR_GMINIT_ADV_SETTINGS;
			font = "PuristaMedium";
		};

		class TAB_GMINIT_BUTTON_START : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.428; 
			y = 0.780; 
			w = 0.250; 
			h = 0.087;
			text = $STR_GMINIT_START;
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
		
	};
	
};
