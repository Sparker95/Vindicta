class DebugTreeUI
{
	idd = -1;

	class ControlsBackground {};

	class Controls {

		class DEBUG_TREE1_REFBOX : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.014; 
			y = safeZoneY + safeZoneH * 0.073; 
			w = safeZoneW * 0.321; 
			h = safeZoneH * 0.028; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.022;
			text = "DEBUG_TREE1_REFBOX";

		};

		class DEBUG_TREE2_REFBOX : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.339; 
			y = safeZoneY + safeZoneH * 0.073; 
			w = safeZoneW * 0.321; 
			h = safeZoneH * 0.028; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.022;
			text = "DEBUG_TREE2_REFBOX";

		};

		class DEBUG_TREE3_REFBOX : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.664; 
			y = safeZoneY + safeZoneH * 0.073; 
			w = safeZoneW * 0.321; 
			h = safeZoneH * 0.028; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.022;
			text = "DEBUG_TREE3_REFBOX";

		};

		class DEBUG_TREE_1 {

			IDC = -1; 
			type = 12;
			x = safeZoneX + safeZoneW * 0.014; 
			y = safeZoneY + safeZoneH * 0.102; 
			w = safeZoneW * 0.321; 
			h = safeZoneH * 0.738;  
			style = TR_SHOWROOT;

		};

		class DEBUG_TREE_2 {

			IDC = -1; 
			type = 12;
			x = safeZoneX + safeZoneW * 0.339; 
			y = safeZoneY + safeZoneH * 0.102; 
			w = safeZoneW * 0.321; 
			h = safeZoneH * 0.599;  
			style = TR_SHOWROOT;
		};

		class DEBUG_TREE_3 {

			IDC = -1; 
			type = 12;
			x = safeZoneX + safeZoneW * 0.664; 
			y = safeZoneY + safeZoneH * 0.102; 
			w = safeZoneW * 0.321; 
			h = safeZoneH * 0.599; 
			style = TR_SHOWROOT;
		};

		class DEBUG_EDITBOX_1 : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.014; 
			y = safeZoneY + safeZoneH * 0.852; 
			w = safeZoneW * 0.157; 
			h = safeZoneH * 0.041; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.022;
			text = "DEBUG_EDITBOX_1";
		};

		class DEBUG_EDITBOX_2 : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.178; 
			y = safeZoneY + safeZoneH * 0.852; 
			w = safeZoneW * 0.157; 
			h = safeZoneH * 0.041; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.022;
			text = "DEBUG_EDITBOX_2";
		};

		class DEBUG_BUTTON_1 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.014; 
			y = safeZoneY + safeZoneH * 0.905; 
			w = safeZoneW * 0.118; 
			h = safeZoneH * 0.041; 
			text = "DEBUG_BUTTON_1"; 

		};

		class DEBUG_BUTTON_2 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.136; 
			y = safeZoneY + safeZoneH * 0.905; 
			w = safeZoneW * 0.118; 
			h = safeZoneH * 0.041; 
			text = "DEBUG_BUTTON_2"; 

		};

		class DEBUG_BUTTON_3 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.258; 
			y = safeZoneY + safeZoneH * 0.905; 
			w = safeZoneW * 0.118; 
			h = safeZoneH * 0.041; 
			text = "DEBUG_BUTTON_3"; 

		};

		class DEBUG_BUTTON_4 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.379; 
			y = safeZoneY + safeZoneH * 0.905; 
			w = safeZoneW * 0.118; 
			h = safeZoneH * 0.041; 
			text = "DEBUG_BUTTON_4"; 

		};

		class DEBUG_BUTTON_5 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.014; 
			y = safeZoneY + safeZoneH * 0.949; 
			w = safeZoneW * 0.118; 
			h = safeZoneH * 0.041; 
			text = "DEBUG_BUTTON_5"; 

		};

		class DEBUG_BUTTON_6 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.136; 
			y = safeZoneY + safeZoneH * 0.949; 
			w = safeZoneW * 0.118; 
			h = safeZoneH * 0.041; 
			text = "DEBUG_BUTTON_6"; 

		};

		class DEBUG_BUTTON_7 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.258; 
			y = safeZoneY + safeZoneH * 0.949; 
			w = safeZoneW * 0.118; 
			h = safeZoneH * 0.041; 
			text = "DEBUG_BUTTON_7"; 

		};

		class DEBUG_BUTTON_8 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.379; 
			y = safeZoneY + safeZoneH * 0.949; 
			w = safeZoneW * 0.118; 
			h = safeZoneH * 0.041; 
			text = "DEBUG_BUTTON_8"; 

		};

		// Large edit window/console
		class DEBUG_CONSOLE : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.504; 
			y = safeZoneY + safeZoneH * 0.711; 
			w = safeZoneW * 0.480; 
			h = safeZoneH * 0.279; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.015;
			text = "class DEBUG_CONSOLE"; 
		};

		class DEBUG_BUTTON_EXEC : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.381; 
			y = safeZoneY + safeZoneH * 0.711; 
			w = safeZoneW * 0.118; 
			h = safeZoneH * 0.041; 
			text = "EXECUTE"; 

		};


	};
};
