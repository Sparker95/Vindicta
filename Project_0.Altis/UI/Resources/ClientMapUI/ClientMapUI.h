#include "ClientMapUI_Macros.h"

#include "..\MissionUIControlClasses.h"
class ClientMapUI
{
	idd = -1;
	enableSimulation = true;
	
	class ControlsBackground
	{
		
	};
	class Controls
	{
		class CMUI_LOCP_HEADLINE : MUI_HEADLINE 
		{
			type = 0;
			idc = IDC_LOCP_HEADLINE;
			x = safeZoneX + safeZoneW * 0.86;
			y = safeZoneY + safeZoneH * 0.055;
			w = safeZoneW * 0.132;
			text = "Camp Foxtrot";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85);
		};

		class CMUI_LOCP_TAB2 : MUI_BUTTON_TAB 
		{
			type = 1;
			idc = IDC_LOCP_TAB2;
			x = safeZoneX + safeZoneW * 0.9;
			y = safeZoneY + safeZoneH * 0.078;
			w = safeZoneW * 0.05;
			h = safeZoneH * 0.075;
			text = "TAB 2";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
		};

		class CMUI_LOCP_TAB1 : MUI_BUTTON_TAB 
		{
			type = 1;
			idc = IDC_LOCP_TAB1;
			x = safeZoneX + safeZoneW * 0.86;
			y = safeZoneY + safeZoneH * 0.078;
			w = safeZoneW * 0.044;
			h = safeZoneH * 0.075;
			text = "TAB 1";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
		};

		class CMUI_LOCP_TAB3 : MUI_BUTTON_TAB 
		{
			type = 1;
			idc = IDC_LOCP_TAB3;
			x = safeZoneX + safeZoneW * 0.948;
			y = safeZoneY + safeZoneH * 0.078;
			w = safeZoneW * 0.044;
			h = safeZoneH * 0.075;
			text = "TAB 3";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};

		class CMUI_LOCP_TAB_TXT : MUI_BASE 
		{
			type = 0;
			idc = IDC_LOCP_TABCAT;
			x = safeZoneX + safeZoneW * 0.86;
			y = safeZoneY + safeZoneH * 0.152;
			w = safeZoneW * 0.132;
			h = safeZoneH * 0.03;
			text = "TAB HEADLINE";
			colorBackground[] = {0,0,0,1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
		};

		class CMUI_LOCP_LISTBOX : MUI_LISTBOX 
		{
			type = 5;
			idc = IDC_LOCP_LISTBOX;
			x = safeZoneX + safeZoneW * 0.86;
			y = safeZoneY + safeZoneH * 0.183;
			w = safeZoneW * 0.132;
			h = safeZoneH * 0.55;
			style = 16;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			class ListScrollBar
			{
				color[] = {1,1,1,1};
				thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
				arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
				arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
				border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
			};	
		};

		class CMUI_BPANEL_BG : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = IDC_BPANEL_BG;
			x = safeZoneX + safeZoneW * 0.225;
			y = safeZoneY + safeZoneH * 0.94;
			w = safeZoneW * 0.55;
			h = safeZoneH * 0.032;
			text = "";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
		};

		class CMUI_BPANEL_HINTS : MUI_STRUCT_TXT 
		{
			type = 13;
			idc = IDC_BPANEL_HINTS;
			x = safeZoneX + safeZoneW * 0.225;
			y = safeZoneY + safeZoneH * 0.97;
			w = safeZoneW * 0.55;
			h = safeZoneH * 0.025;
			style = 0;
			text = "Place hint texts here. Text should be centered, white, Purista Medium.";
			size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			colorBackground[] = {0.12,0.12,0.12,1};
			class Attributes
			{
				
			};
		};

		class CMUI_BPANEL_BUTTON_1 : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_1;
			x = safeZoneX + safeZoneW * 0.33;
			y = safeZoneY + safeZoneH * 0.9445;
			w = safeZoneW * 0.11;
			text = "BUTTON 1";
			borderSize = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};

		class CMUI_BPANEL_BUTTON_2 : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_2;
			x = safeZoneX + safeZoneW * 0.445;
			y = safeZoneY + safeZoneH * 0.9445;
			w = safeZoneW * 0.11;
			text = "BUTTON 2";
			borderSize = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};

		class CMUI_BPANEL_BUTTON_3 : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.56;
			y = safeZoneY + safeZoneH * 0.9445;
			w = safeZoneW * 0.11;
			text = "BUTTON 3";
			borderSize = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
		};
		
	};
	
};
