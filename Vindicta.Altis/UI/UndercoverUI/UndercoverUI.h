#include "..\InGameUI\InGameUI_Macros.h"

/*
UndercoverUI
Author: Marvis 19.02.2019

*/

class UndercoverUI
{
	idd = 9222;
	name = "UndercoverUI";
	onLoad = "uiNamespace setVariable ['undercoverUI_display', _this select 0]";
	onUnload = "uiNamespace setVariable ['undercoverUI_display', displayNull]";
	movingEnable = false;
	enableSimulation = true;
	duration = 10000000;

	class ControlsBackground
	{
		
	};

	class Controls
	{
		class U_Suspicion_Text
		{
			type = 0;
			idc = IDC_U_SUSPICION_TEXT;
			x = safeZoneX + safeZoneW * 0.39270834;
			y = safeZoneY + safeZoneH * 0.01574075;
			w = safeZoneW * 0.21458334;
			h = safeZoneH * 0.02037038;
			style = 2;
			text = "";
			colorBackground[] = {0.3569,0.8941,0.1216,0};
			colorText[] = {1,1,1,1};
			font = "PuristaSemibold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.82);
			shadow = 0;
		};
		class U_Suspicion_StatusBar
		{
			type = 8;
			idc = IDC_U_SUSPICION_STATUSBAR;
			x = safeZoneX + safeZoneW * 0.44;
			y = safeZoneY + safeZoneH * 0.012;
			w = safeZoneW * 0.12;
			h = safeZoneH * 0.006;
			style = 0;
			colorBar[] = {1,1,1,1};
			colorFrame[] = {0.2,0.2,0.2,0.2};
			texture = "#(argb,8,8,3)color(1,1,1,1)";
			access = 0;
		};
	};
};
