#include "InGameUI_Macros.h"

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
		class STATIC_LOCATION_NAME : MUI_BASE 
		{
			type = 0;
			idc = IDC_INGAME_STATIC_LOCATION_NAME;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * 0.00;
			w = safeZoneW * 0.12;
			h = safeZoneH * 0.02;
			style = 0;
			text = "Camp Potato";
			colorBackground[] = {0,0,0,0};
			sizeEx = safezoneh*0.02;
			
		};
		class STATIC_CONSTRUCTION_RESOURCES : MUI_BASE 
		{
			type = 0;
			idc = IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * 0.02;
			w = safeZoneW * 0.12;
			h = safeZoneH * 0.02;
			style = 0;
			text = "Construction resources:  9000";
			colorBackground[] = {0,0,0,0};
			sizeEx = safezoneh*0.02;
			
		};
		
	};
	
};
