#include "CustomControlClasses.h"
class TAB_SAVE
{
	idd = -1;
	
	class ControlsBackground
	{
		class TAB_SAVE : MUI_GROUP 
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0;
			w = 0.7;
			h = 0.9;
			style = 0;
			text = "";
			colorBackground[] = {0.498,0.7137,0.6902,0.3689};
			colorText[] = {0.502,0.2863,0.3098,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		
	};
	class Controls
	{
		class TAB_SAVE_LISTNBOX_SAVES : MUI_LISTNBOX_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.01000012;
			y = 0.06000017;
			w = 0.53000009;
			h = 0.52000015;
			text = "123";
			class ListScrollBar
			{
				
			};
			
		};
		class TAB_SAVE_BUTTON_NEW : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.55;
			y = 0.11000007;
			w = 0.14;
			h = 0.05000006;
			text = "New Save";
			borderSize = 0;
			
		};
		class TAB_SAVE_BUTTON_OVERWRITE : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.55000015;
			y = 0.23000038;
			w = 0.14000003;
			h = 0.05000006;
			text = "Overwrite";
			borderSize = 0;
			
		};
		class TAB_SAVE_BUTTON_OVERWRITE_copy1 : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.55000019;
			y = 0.3600004;
			w = 0.14000003;
			h = 0.05000006;
			text = "Load";
			borderSize = 0;
			
		};
		class TAB_SAVE_BUTTON_DELETE : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.55000019;
			y = 0.48000037;
			w = 0.14000003;
			h = 0.05000006;
			text = "Delete";
			borderSize = 0;
			
		};
		class TAB_SAVE_STATIC_PREVIOUS_SAVES : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.01;
			y = 0.01000014;
			w = 0.68000002;
			h = 0.04;
			style = 0;
			text = "Previously saved games:";
			
		};
		class TAB_SAVE_STATIC_SAVE_DATA_copy1 : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.01;
			y = 0.59000016;
			w = 0.68000002;
			h = 0.30000015;
			style = 0;
			text = "Saved game data ...";
			
		};
		
	};
	
};
