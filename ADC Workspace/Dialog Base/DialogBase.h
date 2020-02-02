#include "CustomControlClasses.h"
class DialogBase
{
	idd = -1;
	
	class ControlsBackground
	{
		class Control1265447955 : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0;
			w = 1;
			h = 1;
			style = 0;
			text = "";
			colorText[] = {0,0.302,0.3059,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		
	};
	class Controls
	{
		class BUTTON_QUESTION
		{
			type = 1;
			idc = -1;
			x = 0.90000012;
			y = 0.00000006;
			w = 0.05;
			h = 0.04;
			style = 0+2;
			text = "?";
			borderSize = 0;
			colorBackground[] = {0.8941,0.9216,0.6667,1};
			colorBackgroundActive[] = {1,0,0,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,1};
			colorText[] = {0.1059,0.0784,0.3333,1};
			font = "PuristaMedium";
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			
		};
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
		class STATIC_HEADLINE : MUI_HEADLINE 
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0;
			w = 1;
			h = 0.04;
			style = 0;
			text = "Headline";
			sizeEx = 0.04;
			
		};
		class GROUP_TAB_BUTTONS : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0.04;
			w = 0.22;
			h = 0.96;
			style = 0;
			text = "";
			colorBackground[] = {0.2,0.4,0.2,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class STATIC_HINTS : MUI_BG_BLACKSOLID 
		{
			type = 0;
			idc = -1;
			x = 0.22000008;
			y = 0.96000015;
			w = 0.78;
			h = 0.04;
			style = 0;
			text = "Hint";
			sizeEx = 0.04;
			
		};
		class BUTTON_CLOSE : Map_UI_button 
		{
			type = 1;
			idc = -1;
			x = 0.95000012;
			y = 0.00000006;
			w = 0.05;
			h = 0.04;
			style = 0+2;
			text = "X";
			borderSize = 0;
			colorBackground[] = {0.8941,0.9216,0.6667,1};
			colorBackgroundActive[] = {1,0,0,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,1};
			colorText[] = {0.1059,0.0784,0.3333,1};
			font = "PuristaMedium";
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class BUTTON_TAB_0 : Map_UI_button 
		{
			type = 1;
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
		
	};
	
};
