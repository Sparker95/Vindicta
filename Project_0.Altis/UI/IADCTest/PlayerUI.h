class PLAYERUI
{

	IDD = 7893478;

	onLoad = "";
	onUnload = "";
	enableSimulation = true;
	movingEnable = true;
	moving = true;
	canDrag = true;

	class ControlsBackground {};

	class Controls {

		class PLAYERUI_BG : MUI_BG_BLACKTRANSPARENT {

			IDC = -1; 
			x = 0.075; 
			y = 0.122; 
			w = 0.848; 
			h = 0.765; 
			text = ""; 

		};

		class PLAYERUI_TAB1 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = 0.075; 
			y = 0.085; 
			w = 0.207; 
			style = ST_LEFT; 
			text = "tab1"; 

		};

		class PLAYERUI_BUTTON_OK : MUI_BUTTON_TXT {

			IDC = -1; 
			x = 0.550; 
			y = 0.891; 
			w = 0.182; 
			text = "OK"; 

		};

		class PLAYERUI_BUTTON_CANCEL : MUI_BUTTON_TXT {

			IDC = -1; 
			x = 0.741; 
			y = 0.891; 
			w = 0.182; 
			text = "CANCEL"; 

		};

		class PLAYERUI_BUTTON_RESET : MUI_BUTTON_TXT {

			IDC = -1; 
			x = 0.289; 
			y = 0.891; 
			w = 0.251; 
			text = "RESET DEFAULTS"; 

		};

		class PLAYERUI_HEADLINE : MUI_HEADLINE {

			IDC = -1; 
			x = 0.075; 
			y = 0.043; 
			w = 0.848; 
			style = ST_LEFT; 
			text = " MISSION MENU"; 

		};

		class PLAYERUI_TAB2 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = 0.289; 
			y = 0.085; 
			w = 0.207; 
			style = ST_LEFT; 
			text = "tab2"; 

		};

		class PLAYERUI_TAB3 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = 0.502; 
			y = 0.085; 
			w = 0.207; 
			style = ST_LEFT; 
			text = "tab3"; 

		};

		class PLAYERUI_TAB4 : MUI_BUTTON_TXT {

			IDC = -1; 
			x = 0.716; 
			y = 0.085; 
			w = 0.207; 
			style = ST_LEFT; 
			text = "tab4"; 

		};

	};

};
