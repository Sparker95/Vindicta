#include "UndercoverUI_Macros.h"

class UndercoverUI
{
	idd = 46;
	name = "UndercoverUI";
	onLoad = "with uiNamespace do { undercoverUI_display = _this select 0; };";
	//onUnload = "with uiNamespace do{ };";
	movingEnable = false;
	enableSimulation = true;
	duration = 1000;
	
	class ControlsBackground
	{
		
	};
	class Controls
	{
		class U_Suspicion_Text
		{
			type = 0;
			idc = IDC_U_SUSPICION_TEXT;
			x = safeZoneX + safeZoneW * 0.46875;
			y = safeZoneY + safeZoneH * 0.01944445;
			w = safeZoneW * 0.0625;
			h = safeZoneH * 0.01296297;
			style = 2;
			text = "SUSPICIOUS";
			colorBackground[] = {0.3569,0.8941,0.1216,0};
			colorText[] = {1,1,1,1};
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7);
			access = 0;
			moving = false;
			shadow = 1;
			
		};
		class U_Tooltip
		{
			type = 0;
			idc = IDC_U_TOOLTIP;
			x = safeZoneX + safeZoneW * 0.41875;
			y = safeZoneY + safeZoneH * 0.03518519;
			w = safeZoneW * 0.1625;
			h = safeZoneH * 0.01851852;
			style = 2;
			text = "Your behavior may attract attention";
			colorBackground[] = {0,0,0,0.5};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * .6);
			
		};
		class U_Suspicion_StatusBar
		{
			type = 8;
			idc = IDC_U_SUSPICION_STATUSBAR;
			x = safeZoneX + safeZoneW * 0.44375;
			y = safeZoneY + safeZoneH * 0.01203704;
			w = safeZoneW * 0.1125;
			h = safeZoneH * 0.00462963;
			style = 0;
			colorBar[] = {1,1,1,1};
			colorFrame[] = {0.2,0.2,0.2,1};
			texture = "#(argb,8,8,3)color(1,1,1,1)";
			access = 0;
			
		};
		
	};
	
};
