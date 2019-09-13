#include "CustomControlClasses.h"
class MyDialog
{
	idd = -1;
	
	class ControlsBackground
	{
		class BACKPANEL : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0;
			w = 0.28;
			h = 0.08;
			style = 0;
			text = "";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		
	};
	class Controls
	{
		class BUTTON_SPLIT : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0;
			y = 0;
			w = 0.14;
			h = 0.04;
			text = "<-\\-> Split";
			borderSize = 0;
			
		};
		class BUTTON_ORDER : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0;
			y = 0.04000001;
			w = 0.28;
			h = 0.04;
			text = "Give order ...";
			borderSize = 0;
			
		};
		class STATIC_HEADER : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = 0.03000007;
			y = 0.10000013;
			w = 0.2;
			h = 0.04;
			text = "Garrison";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class BUTTON_MERGE : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.14;
			y = 0;
			w = 0.14;
			h = 0.04;
			text = "->\<-Merge";
			borderSize = 0;
			
		};
		
	};
	
};
