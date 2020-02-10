#include "CustomControlClasses.h"
class MyDialog
{
	idd = -1;
	
	class ControlsBackground
	{
		class TAB_GAME_MODE_INIT
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0;
			w = 0.7;
			h = 0.9;
			style = 0;
			text = "";
			colorBackground[] = {0,0,0,0.6429};
			colorText[] = {0.9216,0.3961,0.6549,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		
	};
	class Controls
	{
		class STATIC_GAME_MODE : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.02000013;
			y = 0.0700001;
			w = 0.38000013;
			h = 0.04000007;
			style = 0;
			text = "Game Mode:";
			
		};
		class STATIC_ENEMY_FORCE_PERCENTAGE : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.02000014;
			y = 0.22000022;
			w = 0.38000013;
			h = 0.04000007;
			style = 0;
			text = "Enemy force percentage:";
			
		};
		class STATIC_MILITARY_FACTION : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.02000014;
			y = 0.12000019;
			w = 0.38000007;
			h = 0.04000007;
			style = 0;
			text = "Military faction:";
			
		};
		class STATIC_CAMPAIGN_NAME : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.02000013;
			y = 0.0200001;
			w = 0.38000013;
			h = 0.04000007;
			style = 0;
			text = "Campaign Name:";
			
		};
		class STATIC_POLICE_FACTION : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.02000014;
			y = 0.17000022;
			w = 0.38000007;
			h = 0.04000007;
			style = 0;
			text = "Police faction:";
			
		};
		class TAB_GMINIT_EDIT_ENEMY_PERCENTAGE : MUI_EDIT_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.41000015;
			y = 0.22000015;
			w = 0.27000009;
			h = 0.04000005;
			style = 0;
			text = "100";
			
		};
		class TAB_GMINIT_EDIT_CAMPAIGN_NAME : MUI_EDIT_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.41000015;
			y = 0.02000018;
			w = 0.27000009;
			h = 0.04000005;
			style = 0;
			text = "Campaign 0";
			
		};
		class TAB_GMINIT_COMBO_GAME_MODE : MUI_COMBOBOX_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.41000046;
			y = 0.07000031;
			w = 0.27000013;
			h = 0.0400001;
			style = 0;
			text = "Civil War";
			colorBackground[] = {0.4,0.6,0.4,1};
			class ComboScrollBar
			{
				
			};
			
		};
		class TAB_GMINIT_COMBO_ENEMY_FACTION : MUI_COMBOBOX_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.41000046;
			y = 0.12000033;
			w = 0.27000013;
			h = 0.0400001;
			style = 0;
			text = "AAF";
			colorBackground[] = {0.4,0.6,0.4,1};
			class ComboScrollBar
			{
				
			};
			
		};
		class TAB_GMINIT_COMBO_POLICE_FACTION : MUI_COMBOBOX_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.41000046;
			y = 0.17000036;
			w = 0.27000013;
			h = 0.0400001;
			style = 0;
			text = "Standard";
			colorBackground[] = {0.4,0.6,0.4,1};
			class ComboScrollBar
			{
				
			};
			
		};
		class TAB_GMINIT_BUTTON_START : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.29000015;
			y = 0.84000037;
			w = 0.14000006;
			h = 0.04000012;
			text = "Start";
			borderSize = 0;
			
		};
		class STATIC_DESCRIPTION : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.02000014;
			y = 0.28000028;
			w = 0.66000017;
			h = 0.54000017;
			style = 0;
			text = "Desctiption...";
			
		};
		
	};
	
};
