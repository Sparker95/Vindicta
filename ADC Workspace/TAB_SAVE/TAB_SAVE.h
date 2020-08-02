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
			x = 0.02;
			y = 0.077;
			w = 0.452;
			h = 0.445;
			text = "123";
			class ListScrollBar
			{
				
			};
			
		};
		class TAB_SAVE_BUTTON_NEW : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.49;
			y = 0.18000018;
			w = 0.20000003;
			h = 0.07;
			text = "New Save";
			borderSize = 0;
			
		};
		class TAB_SAVE_BUTTON_OVERWRITE : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.49000015;
			y = 0.27000043;
			w = 0.20000006;
			h = 0.07;
			text = "Overwrite";
			borderSize = 0;
			
		};
		class TAB_SAVE_BUTTON_OVERWRITE_copy1 : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.49000019;
			y = 0.36000045;
			w = 0.20000007;
			h = 0.07;
			text = "Load";
			borderSize = 0;
			
		};
		class TAB_SAVE_BUTTON_DELETE : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.49000019;
			y = 0.45000042;
			w = 0.20000006;
			h = 0.07;
			text = "Delete";
			borderSize = 0;
			
		};
		class TAB_SAVE_STATIC_STORAGE : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.49000015;
			y = 0.03000024;
			w = 0.20000005;
			h = 0.04;
			style = 0;
			text = "Storage:";
			
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
		class TAB_SAVE_COMBO_STORAGE : MUI_COMBOBOX_ABS 
		{
			type = 4;
			idc = -1;
			x = 0.49000009;
			y = 0.08000016;
			w = 0.20000007;
			h = 0.04000003;
			class ComboScrollBar
			{
				color[] = {1,1,1,1};
				thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
				arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
				arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
				border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
				
			};
			
		};
		class TAB_SAVE_STATIC_PREVIOUS_SAVES : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.02;
			y = 0.028;
			w = 0.452;
			h = 0.04;
			style = 0;
			text = "Previously saved games:";
			
		};
		
	};
	
};
