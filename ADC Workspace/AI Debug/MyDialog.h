#include "CustomControlClasses.h"
class MyDialog
{
	idd = -1;
	
	class ControlsBackground
	{
		class AI_DEBUG_GROUP : MUI_GROUP 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.29375;
			y = safeZoneY + safeZoneH * 0.225;
			w = safeZoneW * 0.2;
			h = safeZoneH * 0.3;
			style = 0;
			text = "";
			colorBackground[] = {0.8,0.4,0.2,1};
			
		};
		
	};
	class Controls
	{
		class AI_DEBUG_STATIC_BACKGROUND : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.29375;
			y = safeZoneY + safeZoneH * 0.225;
			w = safeZoneW * 0.19791667;
			h = safeZoneH * 0.29722223;
			text = "";
			
		};
		class AI_DEBUG_TREE : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.29791667;
			y = safeZoneY + safeZoneH * 0.25833334;
			w = safeZoneW * 0.18958334;
			h = safeZoneH * 0.25833334;
			style = 0;
			text = "Action: doSomething";
			
		};
		class AI_DEBUG_BUTTON_HALT : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.4546875;
			y = safeZoneY + safeZoneH * 0.23055556;
			w = safeZoneW * 0.0328125;
			h = safeZoneH * 0.02222223;
			text = "Halt";
			borderSize = 0;
			
		};
		class AI_DEBUG_EDIT_AI_REF : MUI_EDIT 
		{
			type = 2;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.29791667;
			y = safeZoneY + safeZoneH * 0.23055556;
			w = safeZoneW * 0.15260417;
			h = safeZoneH * 0.02222223;
			style = 0;
			text = "o_AIUnitInfantry_123_456_789";
			autocomplete = "";
			colorDisabled[] = {0,0,0,1};
			colorSelection[] = {1,0,0,1};
			
		};
		
	};
	
};
