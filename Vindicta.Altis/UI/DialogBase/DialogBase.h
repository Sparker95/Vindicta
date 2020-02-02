#include "DialogBase_Macros.h"

class MUI_DIALOG_BASE
{
	idd = IDD_MUI_DIALOG_BASE;
	
	// On creation of the dialog we set a variable, which we immediately read to get the handle to the new display
	onLoad = "uiNamespace setVariable ['gDialogBaseNewDisplay', _this select 0];";
	
	class ControlsBackground
	{
		class STATIC_BACKGROUND : MUI_BG_BLACKTRANSPARENT_ABS
		{
			idc = IDC_DIALOG_BASE_STATIC_BACKGROUND;
			x = 0;
			y = 0;
			w = 1;
			h = 1;
			style = 0;
			text = "";
		};
		
		class STATIC_HEADLINE : MUI_HEADLINE_ABS
		{
			idc = IDC_DIALOG_BASE_STATIC_HEADLINE;
			x = 0;
			y = 0;
			w = 1;
			h = 0.04;
			style = 0;
			text = "Headline";
		};

		class STATIC_TAB_BUTTONS_BACKGROUND : MUI_BG_BLACKTRANSPARENT_ABS
		{
			idc = IDC_DIALOG_BASE_STATIC_TAB_BUTTONS_BACKGROUND;
			x = 0;
			y = 0.04;
			w = 0.22;
			h = 0.96;	
		};
	};
	class Controls
	{

		class BUTTON_CLOSE : RscButton
		{
			idc = IDC_DIALOG_BASE_BUTTON_CLOSE;
			x = 0.95;
			y = 0.00;
			w = 0.05;
			h = 0.04;
			style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
			text = "\z\vindicta\addons\ui\pictures\close_ca.paa";
			colorText[] = MUIC_BLACK;
			colorBackground[] = MUIC_TRANSPARENT;
			colorFocused[] = MUIC_TRANSPARENT;
			colorBackgroundActive[] = MUIC_TRANSPARENT;
			onMouseEnter = "_this#0 ctrlSetTextColor [1, 1, 1, 1];"; // Set text black
			onMouseExit = "_this#0 ctrlSetTextColor [0, 0, 0, 1];"; // Set text white
			shadow = 0;
		};

		class BUTTON_QUESTION : RscButton
		{
			idc = IDC_DIALOG_BASE_BUTTON_QUESTION;
			x = 0.95;
			y = 0.00;
			w = 0.05;
			h = 0.04;
			style = ST_PICTURE + ST_KEEP_ASPECT_RATIO; 
			text = "\z\vindicta\addons\ui\pictures\unknown_ca.paa";
			colorText[] = MUIC_BLACK;
			colorBackground[] = MUIC_TRANSPARENT;
			colorFocused[] = MUIC_TRANSPARENT;
			colorBackgroundActive[] = MUIC_TRANSPARENT;
			onMouseEnter = "_this#0 ctrlSetTextColor [1, 1, 1, 1];"; // Set text black
			onMouseExit = "_this#0 ctrlSetTextColor [0, 0, 0, 1];"; // Set text white
			shadow = 0;
		};

		class GROUP_TAB_BUTTONS : MUI_GROUP_ABS 
		{
			idc = IDC_DIALOG_BASE_GROUP_TAB_BUTTONS;
			x = 0;
			y = 0.04;
			w = 0.22;
			h = 0.96;			
		};

		class STATIC_HINTS : MUI_BG_BLACKTRANSPARENT_ABS
		{
			idc = IDC_DIALOG_BASE_STATIC_HINTS;
			x = 0.22;
			y = 0.96;
			w = 0.78;
			h = 0.04;
			text = "Hint";
			font = "RobotoCondensedLight";
			sizeEx = 0.036;
			style = ST_LEFT;			
		};

		// Button example
		/*
		class BUTTON_TAB_0 : Map_UI_button 
		{
			idc = -1;
			x = 0;
			y = 0.04;
			w = 0.22;
			h = 0.08;
			style = 0+2;
			text = "X";
			borderSize = 0;
			colorBackground[] = {0.502,0.302,0.502,1};
			colorBackgroundActive[] = {1,0,0,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,1};
			font = "PuristaMedium";
		};
		*/

		/*
		// That's where actual payload groups should be
		class GROUP
		{
			type = 0;
			idc = -1;
			x = 0.23;
			y = 0.05;
			w = 0.76;
			h = 0.9;
			style = 64;
			text = "";
			colorBackground[] = {0.4235,0.1529,0.4784,0.5952};
			colorText[] = {0.5765,0.8471,0.5216,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		*/
	};
	
};
