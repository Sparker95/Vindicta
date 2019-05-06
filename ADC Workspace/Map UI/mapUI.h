#include "CustomControlClasses.h"
class mapUI
{
	idd = -1;
	
	class ControlsBackground
	{
		
	};
	class Controls
	{
		class MUI_PANELB_1
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.20989584;
			y = safeZoneY + safeZoneH * 0.95833334;
			w = safeZoneW * 0.58020834;
			h = safeZoneH * 0.03148149;
			style = 2;
			text = "ALERT: Alert this garrison to an impending attack. All units in this garrison will switch into combat state.";
			colorBackground[] = {0.1,0.1,0.1,1};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			shadow = 2;
			
		};
		class MUI_PANELB_2
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.20989584;
			y = safeZoneY + safeZoneH * 0.925;
			w = safeZoneW * 0.58020834;
			h = safeZoneH * 0.03425926;
			style = 0;
			text = "";
			colorBackground[] = {0,0,0,0.5};
			colorText[] = {0.9569,0.3843,0.9843,0};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class MUI_PANELB_BUTTON_1
		{
			type = 1;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.44010417;
			y = safeZoneY + safeZoneH * 0.92870371;
			w = safeZoneW * 0.11979167;
			h = safeZoneH * 0.02685186;
			style = 0+0;
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
			font = "PuristaSemiBold";
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			shadow = 0;
			
		};
		class MUI_PANELB_BUTTON_2
		{
			type = 1;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.56614584;
			y = safeZoneY + safeZoneH * 0.92870371;
			w = safeZoneW * 0.11979167;
			h = safeZoneH * 0.02685186;
			style = 0+0;
			text = "PERSONAL ASSISTANT";
			borderSize = 0;
			colorBackground[] = {0,0,0,1};
			colorBackgroundActive[] = {1,1,1,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaSemiBold";
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			shadow = 0;
			
		};
		class MUI_PANELB_BUTTON_3
		{
			type = 1;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.3140625;
			y = safeZoneY + safeZoneH * 0.92870371;
			w = safeZoneW * 0.11979167;
			h = safeZoneH * 0.02685186;
			style = 0+0;
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
			font = "PuristaSemiBold";
			offsetPressedX = 0.01;
			offsetPressedY = 0.01;
			offsetX = 0.01;
			offsetY = 0.01;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};
			shadow = 0;
			tooltip = "Create a camp at your current location.";
			tooltipColorBox[] = {0,0,0,1};
			tooltipColorText[] = {1,1,1,1};
			
		};
		
	};
	
};
