#include "InGameUI_Macros.h"

#define __ROW_H 0.025

class Vin_InGameUI
{
	idd = -1;
	name = "Vin_InGameUI";
	onLoad = "uiNamespace setVariable ['p0_InGameUI_display', _this select 0]";
	onUnload = "uiNamespace setVariable ['p0_InGameUI_display', displayNull]";
	movingEnable = false;
	enableSimulation = true;
	duration = 10000000;

	class Controls
	{
		class STATIC_BACKGROUND : MUI_BASE 
		{
			type = 0;
			idc = IDC_INGAME_STATIC_LOCATION_BACKGROUND;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * 0;
			w = safeZoneW * 0.145;
			h = safeZoneH * __ROW_H * 3;
			style = 0;
			text = "";
			colorBackground[] = MUIC_BLACKTRANSP;			
		};

		class STATIC_LOCATION_NAME : MUI_BASE 
		{
			type = 0;
			idc = IDC_INGAME_STATIC_LOCATION_NAME;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * __ROW_H * 0;
			w = safeZoneW * 0.18;
			h = safeZoneH * __ROW_H;
			style = 0;
			text = "Camp Potato";
			colorBackground[] = {0,0,0,0};
			sizeEx = safezoneh*0.025;
			//colorText[] = {4/255, 213/255, 206/255, 1};
			colorText[] = MUIC_WHITE;
		};
		class STATIC_CONSTRUCTION_RESOURCES : MUI_BASE 
		{
			type = 0;
			idc = IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * __ROW_H * 1;
			w = safeZoneW * 0.18;
			h = safeZoneH * __ROW_H;
			style = 0;
			text = "Construction resources:  9000";
			colorBackground[] = {0,0,0,0};
			sizeEx = safezoneh*0.025;
			//colorText[] = {4/255, 213/255, 206/255, 1};
			colorText[] = MUIC_WHITE;
		};

		class STATIC_MAX_INF : MUI_BASE 
		{
			type = 0;
			idc = IDC_INGAME_STATIC_MAX_INF;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * __ROW_H * 2;
			w = safeZoneW * 0.12;
			h = safeZoneH * __ROW_H;
			style = 0;
			text = "Max infantry: 123";
			colorBackground[] = {0,0,0,0};
			sizeEx = safezoneh*0.025;
			colorText[] = MUIC_WHITE;		
		};
		
	};
	
};
