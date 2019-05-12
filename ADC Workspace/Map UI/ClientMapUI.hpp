#include "ClientMapUI_Macros.hpp"

#include "CustomControlClasses.hpp"
class ClientMapUI
{
	idd = 12;
	enableSimulation = true;
	
	class ControlsBackground
	{
		
	};
	class Controls
	{
		class MUI_PANELB_DECOLINE : MUI_Text_Base 
		{
			type = 0;
			idc = IDC_DECO1;
			x = safeZoneX + safeZoneW * 0.225;
			y = safeZoneY + safeZoneH * 0.9815;
			w = safeZoneW * 0.55;
			h = safeZoneH * 0.01;
			style = 0;
			text = "";
			colorBackground[] = {1,1,1,1};
			colorText[] = {1,1,1,0};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			shadow = 2;
			
		};
		class MUI_PANELB_BUTTONS : MUI_BG_BlackGlass 
		{
			type = 0;
			idc = IDC_BUTTONPANEL;
			x = safeZoneX + safeZoneW * 0.225;
			y = safeZoneY + safeZoneH * 0.94;
			w = safeZoneW * 0.55;
			h = safeZoneH * 0.03;
			style = 0;
			text = "";
			colorBackground[] = {0,0,0,0.5};
			colorText[] = {0.9569,0.3843,0.9843,0};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class MUI_PANELB_BUTTON_1 : MUI_Button_Base 
		{
			type = 1;
			idc = IDC_BUTTON2;
			x = safeZoneX + safeZoneW * 0.445;
			y = safeZoneY + safeZoneH * 0.943;
			w = safeZoneW * 0.11;
			text = "FAST TRAVEL";
			borderSize = 0;
			colorBackground[] = {0,0,0,1};
			colorBackgroundActive[] = {1,1,1,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			shadow = 0;
			
		};
		class MUI_PANELB_BUTTON_2 : MUI_Button_Base 
		{
			type = 1;
			idc = IDC_BUTTON3;
			x = safeZoneX + safeZoneW * 0.56;
			y = safeZoneY + safeZoneH * 0.943;
			w = safeZoneW * 0.11;
			text = "SETTINGS";
			borderSize = 0;
			colorBackground[] = {0,0,0,1};
			colorBackgroundActive[] = {1,1,1,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			shadow = 0;
			
		};
		class MUI_PANELB_BUTTON_3 : MUI_Button_Base 
		{
			type = 1;
			idc = IDC_BUTTON1;
			x = safeZoneX + safeZoneW * 0.33;
			y = safeZoneY + safeZoneH * 0.943;
			w = safeZoneW * 0.11;
			text = "CREATE CAMP";
			borderSize = 0;
			colorBackground[] = {0,0,0,1};
			colorBackgroundActive[] = {1,1,1,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {1,1,1,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			blinkingPeriod = 0;
			shadow = 0;
			tooltip = "Create a camp at your current location.";
			tooltipColorBox[] = {0,0,0,1};
			tooltipColorText[] = {1,1,1,1};
			
		};
		class MUI_PANELA_HEADLINE : MUI_Header_SideRGB 
		{
			type = 0;
			idc = IDC_HEADLINE;
			x = safeZoneX + safeZoneW * 0.86;
			y = safeZoneY + safeZoneH * 0.051;
			w = safeZoneW * 0.132;
			text = "Camp Foxtrot";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85);
			shadow = 1;
			
		};
		class MUI_PANELA_LISTBOX : MUI_Text_Base 
		{
			type = 5;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.86;
			y = safeZoneY + safeZoneH * 0.183;
			w = safeZoneW * 0.132;
			h = safeZoneH * 0.55;
			style = 16;
			colorBackground[] = {0.1,0.1,0.1,0.8};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorSelect[] = {1,1,1,1};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			maxHistoryDelay = 0;
			rowHeight = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect",0.09,1.0};
			shadow = 0;
			class ListScrollBar
			{
				color[] = {1,1,1,1};
				thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
				arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
				arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
				border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
				
			};
			
		};
		class MUI_PANELA_TAB1 : MUI_Button_Tab 
		{
			type = 1;
			idc = IDC_TAB1;
			x = safeZoneX + safeZoneW * 0.86;
			y = safeZoneY + safeZoneH * 0.078;
			text = "LEFT";
			borderSize = 0;
			colorBackgroundActive[] = {1,1,1,1};
			colorBackgroundDisabled[] = {0,0,0,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {1,1,1,1};
			colorShadow[] = {0,0,0,0};
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			blinkingPeriod = 0;
			shadow = 0;
			tooltip = "Create a camp at your current location.";
			tooltipColorBox[] = {0,0,0,1};
			tooltipColorText[] = {1,1,1,1};
			
		};
		class MUI_PANELA_TAB2 : MUI_Button_Tab 
		{
			type = 1;
			idc = IDC_TAB3;
			x = safeZoneX + safeZoneW * 0.948;
			y = safeZoneY + safeZoneH * 0.078;
			text = "RIGHT";
			borderSize = 0;
			colorBackgroundActive[] = {1,1,1,1};
			colorBackgroundDisabled[] = {0,0,0,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {1,1,1,1};
			colorShadow[] = {0,0,0,0};
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			blinkingPeriod = 0;
			shadow = 0;
			tooltip = "Create a camp at your current location.";
			tooltipColorBox[] = {0,0,0,1};
			tooltipColorText[] = {1,1,1,1};
			
		};
		class MUI_PANELA_TAB3 : MUI_Button_Tab 
		{
			type = 1;
			idc = IDC_TAB2;
			x = safeZoneX + safeZoneW * 0.9;
			y = safeZoneY + safeZoneH * 0.078;
			w = safeZoneW * 0.05;
			text = "CENTER";
			borderSize = 0;
			colorBackgroundActive[] = {1,1,1,1};
			colorBackgroundDisabled[] = {0,0,0,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {1,1,1,1};
			colorShadow[] = {0,0,0,0};
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			blinkingPeriod = 0;
			shadow = 0;
			tooltip = "Create a camp at your current location.";
			tooltipColorBox[] = {0,0,0,1};
			tooltipColorText[] = {1,1,1,1};
			
		};
		class MUI_PANELA_TABNAME : MUI_Text_Base 
		{
			type = 0;
			idc = IDC_TABCAT;
			x = safeZoneX + safeZoneW * 0.86;
			y = safeZoneY + safeZoneH * 0.145;
			w = safeZoneW * 0.132;
			h = safeZoneH * 0.035;
			style = 2;
			text = "SETTINGS AND STATUS";
			colorBackground[] = {0,0,0,1};
			colorText[] = {1,1,1,1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.94);
			shadow = 0;
			
		};
		class MUI_PANELB_HINTS : MUI_BG_GraySolid 
		{
			type = 0;
			idc = IDC_HINTPANEL;
			x = safeZoneX + safeZoneW * 0.225;
			y = safeZoneY + safeZoneH * 0.965;
			w = safeZoneW * 0.55;
			h = safeZoneH * 0.025;
			style = 2;
			text = "ALERT: Alert this garrison to an impending attack. All units in this garrison will switch into combat state.";
			shadow = 2;
			
		};
		
	};
	
};
