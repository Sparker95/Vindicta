#include "ClientMapUI_Macros.h"

#include "CustomControlClasses.h"
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
			x = safeZoneX + safeZoneW * 0.87;
			y = safeZoneY + safeZoneH * 0.042;
			w = safeZoneW * 0.126;
			text = "Camp Foxtrot";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85);
			
		};
		class CMUI_LOCP_TAB1 : MUI_BUTTON_TAB 
		{
			type = 1;
			idc = IDC_LOCP_TAB1;
			x = safeZoneX + safeZoneW * 0.87;
			y = safeZoneY + safeZoneH * 0.065;
			w = safeZoneW * 0.042;
			h = safeZoneH * 0.07;
			text = "TAB 1";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CMUI_LOCP_TAB2 : MUI_BUTTON_TAB 
		{
			type = 1;
			idc = IDC_LOCP_TAB2;
			x = safeZoneX + safeZoneW * 0.912;
			y = safeZoneY + safeZoneH * 0.065;
			w = safeZoneW * 0.042;
			h = safeZoneH * 0.07;
			text = "TAB 2";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			onMouseEnter = "";
			
		};
		class CMUI_LOCP_TAB3 : MUI_BUTTON_TAB 
		{
			type = 1;
			idc = IDC_LOCP_TAB3;
			x = safeZoneX + safeZoneW * 0.954;
			y = safeZoneY + safeZoneH * 0.065;
			w = safeZoneW * 0.042;
			h = safeZoneH * 0.07;
			text = "TAB 3";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CMUI_LOCP_LISTBOX : MUI_LISTBOX 
		{
			type = 5;
			idc = IDC_LOCP_LISTBOXBG;
			x = safeZoneX + safeZoneW * 0.87;
			y = safeZoneY + safeZoneH * 0.164;
			w = safeZoneW * 0.126;
			h = safeZoneH * 0.535;
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
		class CMUI_LOCP_DETAILBG : MUI_BG_GRAYSOLID 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.87;
			y = safeZoneY + safeZoneH * 0.7;
			w = safeZoneW * 0.126;
			h = safeZoneH * 0.2;
			style = 16;
			text = "";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CMUI_LOCP_DETAILFRAME : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.874;
			y = safeZoneY + safeZoneH * 0.706;
			w = safeZoneW * 0.118;
			h = safeZoneH * 0.187;
			style = 64;
			text = "DETAIL PANEL";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.45);
			
		};
		class CMUI_LOCP_TAB_TXT : MUI_BASE 
		{
			type = 0;
			idc = IDC_LOCP_TABCAT;
			x = safeZoneX + safeZoneW * 0.87;
			y = safeZoneY + safeZoneH * 0.135;
			w = safeZoneW * 0.126;
			h = safeZoneH * 0.028;
			text = "TAB HEADLINE";
			colorBackground[] = {0,0,0,1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CMUI_BPANEL_BG : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = IDC_BPANEL_BG;
			x = safeZoneX + safeZoneW * 0.25;
			y = safeZoneY + safeZoneH * 0.94;
			w = safeZoneW * 0.5;
			h = safeZoneH * 0.025;
			text = "";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CMUI_BPANEL_HINTS : MUI_STRUCT_TXT 
		{
			type = 13;
			idc = IDC_BPANEL_HINTS;
			x = safeZoneX + safeZoneW * 0.25;
			y = safeZoneY + safeZoneH * 0.965;
			w = safeZoneW * 0.5;
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
			y = safeZoneY + safeZoneH * 0.942;
			w = safeZoneW * 0.11;
			text = "BUTTON 1";
			borderSize = 0;
			
		};
		class CMUI_BPANEL_BUTTON_2 : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_2;
			x = safeZoneX + safeZoneW * 0.445;
			y = safeZoneY + safeZoneH * 0.942;
			w = safeZoneW * 0.11;
			text = "BUTTON 2";
			borderSize = 0;
			
		};
		class CMUI_BPANEL_BUTTON_3 : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.56;
			y = safeZoneY + safeZoneH * 0.942;
			w = safeZoneW * 0.11;
			text = "BUTTON 3";
			borderSize = 0;
			
		};
		class CMUI_LOCP_DETAILTXT : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.8805;
			y = safeZoneY + safeZoneH * 0.72;
			w = safeZoneW * 0.105;
			h = safeZoneH * 0.165;
			style = 16;
			text = "Click on a piece of intel to learn more. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
			colorBackground[] = {1,1,1,1};
			colorText[] = {0,0,0,1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.58);
			
		};
		
	};
	
};
