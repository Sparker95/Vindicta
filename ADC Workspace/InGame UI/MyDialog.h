#include "CustomControlClasses.h"
class MyDialog
{
	idd = -1;
	
	class ControlsBackground
	{
		class STATIC_BACKGROUND : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * 0;
			w = safeZoneW * 0.12;
			h = safeZoneH * 0.06;
			style = 0;
			text = "";
			colorBackground[] = {0,0,0,0.5};
			sizeEx = safezoneh*0.02;
			
		};
		
	};
	class Controls
	{
		class STATIC_LOCATION_NAME : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * 0.00;
			w = safeZoneW * 0.12;
			h = safeZoneH * 0.02;
			style = 0;
			text = "Camp Potato";
			colorBackground[] = {0.102,0.302,0.102,1};
			sizeEx = safezoneh*0.02;
			
		};
		class STATIC_CONSTRUCTION_RESOURCES : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * 0.02;
			w = safeZoneW * 0.12;
			h = safeZoneH * 0.02;
			style = 0;
			text = "Construction resources:  9000";
			colorBackground[] = {0.6,0.2,0,1};
			sizeEx = safezoneh*0.02;
			
		};
		class STATIC_MAX_INF : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.23;
			y = safeZoneY + safeZoneH * 0.04;
			w = safeZoneW * 0.12;
			h = safeZoneH * 0.02;
			style = 0;
			text = "Max infantry: 123";
			colorBackground[] = {0.6,0.4,0.6,1};
			sizeEx = safezoneh*0.02;
			
		};
		
	};
	
};
