class DebugUI
{
	idd = 189445;

	class ControlsBackground {};

	class Controls {

		class DEBUG_LISTBOX2_BG : MUI_BG_BLACKTRANSPARENT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.810; 
			y = safeZoneY + safeZoneH * 0.325; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.600; 
			colorBackground[] = {0, 0, 0, 0.7};
		};
		
		class DEBUG_LISTBOX1_BG : MUI_BG_BLACKTRANSPARENT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.626; 
			y = safeZoneY + safeZoneH * 0.325; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.600; 
			colorBackground[] = {0, 0, 0, 0.7};
		};

		class DEBUG_LISTBOX1 : RscEdit  {

			IDC = 645; 
			x = safeZoneX + safeZoneW * 0.626; 
			y = safeZoneY + safeZoneH * 0.325; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.600; 
			colorBackground[] = {0, 0, 0, 0.7};
		};

		class DEBUG_LISTBOX2 : MUI_LISTNBOX {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.810; 
			y = safeZoneY + safeZoneH * 0.325; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.600; 

		};

		class DEBUG_LISTBOX1_EDITBOX2 : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.626; 
			y = safeZoneY + safeZoneH * 0.274; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.024;
		};

		class DEBUG_LISTBOX2_EDITBOX2 : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.810; 
			y = safeZoneY + safeZoneH * 0.274; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.024;
		};

		class DEBUG_LISTBOX1_EDITBOX : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.626; 
			y = safeZoneY + safeZoneH * 0.223; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.024;
		};

		class DEBUG_LISTBOX2_EDITBOX : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.810; 
			y = safeZoneY + safeZoneH * 0.223; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.024;
		};

		class DEBUG_LISTBOX3_WIDE : MUI_LISTNBOX {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.014; 
			y = safeZoneY + safeZoneH * 0.577; 
			w = safeZoneW * 0.389; 
			h = safeZoneH * 0.349; 

		};

		class DEBUG_LISTBOX3_EDITBOX : MUI_EDIT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.014; 
			y = safeZoneY + safeZoneH * 0.524; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 
			colorBackground[] = {0, 0, 0, 0.7};
			sizeEx = safeZoneW * 0.024;

		};

		class DEBUG_LISTBOX1_DROPDOWN : MUI_COMBOBOX {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.626; 
			y = safeZoneY + safeZoneH * 0.172; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 
			sizeEx = safeZoneW * 0.017;
		};

		class DEBUG_LISTBOX2_DROPDOWN : MUI_COMBOBOX {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.810; 
			y = safeZoneY + safeZoneH * 0.172; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 
			sizeEx = safeZoneW * 0.017;

		};

		class DEBUG_LISTBOX3_DROPDOWN : MUI_COMBOBOX {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.195; 
			y = safeZoneY + safeZoneH * 0.524; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 
			sizeEx = safeZoneW * 0.017;
		};

		class DEBUG_BUTTON1 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.436; 
			y = safeZoneY + safeZoneH * 0.884; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 

		};

		class DEBUG_BUTTON2 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.436; 
			y = safeZoneY + safeZoneH * 0.836; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 

		};

		class DEBUG_BUTTON3 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.436; 
			y = safeZoneY + safeZoneH * 0.788; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042;

		};

		class DEBUG_BUTTON4 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.436; 
			y = safeZoneY + safeZoneH * 0.740; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 

		};

		class DEBUG_BUTTON5 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.436; 
			y = safeZoneY + safeZoneH * 0.693; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 

		};

		class DEBUG_BUTTON6 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.436; 
			y = safeZoneY + safeZoneH * 0.645; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 

		};

		class DEBUG_BUTTON7 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.436; 
			y = safeZoneY + safeZoneH * 0.597; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 

		};

		class DEBUG_BUTTON8 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.436; 
			y = safeZoneY + safeZoneH * 0.550; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042; 

		};

		class DEBUG_BUTTON9 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.436; 
			y = safeZoneY + safeZoneH * 0.502; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042;
		};

		class DEBUG_BUTTON_LISTBOX3 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.379; 
			y = safeZoneY + safeZoneH * 0.524; 
			w = safeZoneW * 0.025; 
			h = safeZoneH * 0.042;
		};

		class DEBUG_BUTTON_LISTBOX1 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.626; 
			y = safeZoneY + safeZoneH * 0.121; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042;
		};

		class DEBUG_BUTTON_LISTBOX2 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.810; 
			y = safeZoneY + safeZoneH * 0.121; 
			w = safeZoneW * 0.174; 
			h = safeZoneH * 0.042;
		};

	};
};
