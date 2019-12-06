#include "CustomControlClasses.h"
class TAB_RECRUIT
{
	idd = -1;
	
	class ControlsBackground
	{
		class TAB_RECRUIT_BACKGROUND : MUI_GROUP 
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0;
			w = 0.36000008;
			h = 0.63000006;
			style = 0;
			text = "";
			colorBackground[] = {0.6863,0.7569,0.3725,1};
			colorText[] = {0.3137,0.2431,0.6275,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		
	};
	class Controls
	{
		class TAB_RECRUIT_STATIC_N_RECRUITS : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.01000014;
			y = 0.01000004;
			w = 0.3400001;
			h = 0.04000007;
			style = 0;
			text = "Recruits available: 123";
			
		};
		class TAB_RECRUIT_STATIC_0 : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.01000004;
			y = 0.06000006;
			w = 0.3400001;
			h = 0.04000007;
			style = 0;
			text = "Available loadouts:";
			
		};
		class TAB_RECRUIT_BUTTON_RECRUIT : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.13000005;
			y = 0.58000016;
			w = 0.11000002;
			h = 0.04000006;
			text = "Recruit";
			
		};
		class TAB_RECRUIT_LISTBOX : MUI_LISTNBOX_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.01000004;
			y = 0.11000001;
			w = 0.34000006;
			h = 0.46000009;
			text = "";
			class ListScrollBar
			{
				
			};
			
		};
		
	};
	
};
