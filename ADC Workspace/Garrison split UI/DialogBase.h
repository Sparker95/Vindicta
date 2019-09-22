#include "CustomControlClasses.h"
class DialogBase
{
	idd = -1;
	
	class ControlsBackground
	{
		
	};
	class Controls
	{
		class GSPLIT_BG : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0.15;
			y = 0.00;
			w = 0.7;
			h = 1;
			text = "";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class GSPLIT_LB_LEFT : MUI_LISTBOX 
		{
			type = 5;
			idc = -1;
			x = 0.16;
			y = 0.17;
			w = 0.31;
			h = 0.72;
			style = 16;
			class ListScrollBar
			{
				color[] = {1,1,1,1};
				thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
				arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
				arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
				border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
				
			};
			
		};
		class GSPLIT_LB_RIGHT : MUI_LISTBOX 
		{
			type = 5;
			idc = -1;
			x = 0.53;
			y = 0.17;
			w = 0.31;
			h = 0.72;
			style = 16;
			class ListScrollBar
			{
				color[] = {1,1,1,1};
				thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
				arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
				arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
				border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
				
			};
			
		};
		class GSPLIT_MOVE_RIGHT : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.48;
			y = 0.62;
			w = 0.04;
			h = 0.07;
			style = 0+2;
			text = ">";
			borderSize = 0;
			
		};
		class GSPLIT_MOVE_RIGHT_ALL : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.48;
			y = 0.54;
			w = 0.04;
			h = 0.07;
			style = 0+2;
			text = ">>";
			borderSize = 0;
			
		};
		class GSPLIT_MOVE_LEFT : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.48;
			y = 0.38;
			w = 0.04;
			h = 0.07;
			style = 0+2;
			text = "<";
			borderSize = 0;
			
		};
		class GSPLIT_MOVE_LEFT_ALL : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.48;
			y = 0.46;
			w = 0.04;
			h = 0.07;
			style = 0+2;
			text = "<<";
			borderSize = 0;
			
		};
		class GSPLIT_HEADLINE : MUI_BG_BLACKSOLID 
		{
			type = 0;
			idc = -1;
			x = 0.15;
			y = 0.00;
			w = 0.65;
			h = 0.04;
			text = "Split garrison";
			sizeEx = 0.03;
			
		};
		class GSPLIT_HINTS : MUI_BG_BLACKSOLID 
		{
			type = 0;
			idc = -1;
			x = 0.15;
			y = 0.95;
			w = 0.7;
			h = 0.05;
			style = 0;
			text = "We can place hints here";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class GSPLIT_STATIC : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0.53;
			y = 0.05;
			w = 0.31;
			h = 0.04;
			style = 2;
			text = "New garrison";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class GSPLIT_STATIC_copy1 : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0.53;
			y = 0.13;
			w = 0.31;
			h = 0.04;
			style = 0;
			text = "Infantry: 666";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class GSPLIT_STATIC_copy1_copy1 : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0.16;
			y = 0.05;
			w = 0.31;
			h = 0.04;
			style = 2;
			text = "Current garrison";
			sizeEx = 0.03;
			
		};
		class GSPLIT_STATIC_copy1_copy2 : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0.53;
			y = 0.09;
			w = 0.31;
			h = 0.04;
			style = 0;
			text = "Cargo seats: 666";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class GSPLIT_STATIC_copy1_copy2_copy1 : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0.16;
			y = 0.09;
			w = 0.31;
			h = 0.04;
			style = 0;
			text = "Cargo seats: 666";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class GSPLIT_STATIC_copy1_copy3 : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0.16;
			y = 0.13;
			w = 0.31;
			h = 0.04;
			style = 0;
			text = "Infantry: 666";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class GSPLIT_BUTTON_CLOSE : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.80;
			y = 0.0;
			w = 0.05;
			h = 0.04;
			text = "X";
			borderSize = 0;
			colorBackground[] = {0.6,0,0,1};
			
		};
		class GSPLIT_BUTTON_CANCEL : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.64;
			y = 0.9;
			w = 0.11;
			h = 0.04;
			text = "Cancel";
			borderSize = 0;
			
		};
		class GSPLIT_BUTTON_SPLIT_copy1 : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.25;
			y = 0.90;
			w = 0.11;
			h = 0.04;
			text = "Split";
			borderSize = 0;
			
		};
		
	};
	
};
