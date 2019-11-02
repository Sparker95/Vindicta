//location panel, selected location name
#define IDC_LOCP_HEADLINE 4001
//location panel, selected tab category name
#define IDC_LOCP_TABCAT 4002
//location panel, leftmost button
#define IDC_LOCP_TAB1 4003
//location panel, middle button
#define IDC_LOCP_TAB2 4004
//location panel, rightmost button
#define IDC_LOCP_TAB3 4005
//location panel, scrolling list box
#define IDC_LOCP_LISTBOXBG 4006
//bottom panel, black transparent background 
#define IDC_BPANEL_BG 6001
//bottom panel, button 1
#define IDC_BPANEL_BUTTON_1 6002
//bottom panel, button 2
#define IDC_BPANEL_BUTTON_2 6003
//bottom panel, button 3
#define IDC_BPANEL_BUTTON_3 6004
//bottom panel, structured text panel for hints
#define IDC_BPANEL_HINTS 6005
#define IDC_INFOBAR 7801
#define MUI_TXT_SIZE_M safeZoneH*0.020

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
			x = safeZoneX + safeZoneW * 0.86979167;
			y = safeZoneY + safeZoneH * 0.13518519;
			w = safeZoneW * 0.12604167;
			h = safeZoneH * 0.02777778;
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
			x = safeZoneX + safeZoneW * 0.26;
			y = safeZoneY + safeZoneH * 0.94;
			w = safeZoneW * 0.1;
			text = "Do smth";
			borderSize = 0;
			
		};
		class CMUI_BPANEL_BUTTON_2 : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_2;
			x = safeZoneX + safeZoneW * 0.36979167;
			y = safeZoneY + safeZoneH * 0.93981482;
			w = safeZoneW * 0.08020834;
			text = "Create camp";
			borderSize = 0;
			
		};
		class CMUI_BPANEL_BUTTON_3 : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.46041667;
			y = safeZoneY + safeZoneH * 0.93981482;
			w = safeZoneW * 0.1;
			text = "Mission menu";
			borderSize = 0;
			sizeEx = MUI_TXT_SIZE_M;
			
		};
		class CMUI_BPANEL_BUTTON_SHOW_INTEL : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.56927084;
			y = safeZoneY + safeZoneH * 0.93981482;
			w = safeZoneW * 0.06041667;
			style = 2;
			text = "[X] Show intel";
			borderSize = 0;
			sizeEx = safeZoneH*0.02;
			
		};
		class CMUI_BPANEL_BUTTON_CLEAR_NOTIFICATIONS : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.63854167;
			y = safeZoneY + safeZoneH * 0.93981482;
			w = safeZoneW * 0.1;
			text = "Clear notifications";
			borderSize = 0;
			sizeEx = safeZoneH*0.02;
			
		};
		class CMUI_LOCP_DETAILTXT : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.8805;
			y = safeZoneY + safeZoneH * 0.725;
			w = safeZoneW * 0.105;
			h = safeZoneH * 0.16;
			style = 16;
			text = "Click on a piece of intel to learn more. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
			colorBackground[] = {1,1,1,1};
			colorText[] = {0,0,0,1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.58);
			
		};
		class CMUI_INFOBAR : MUI_BASE 
		{
			type = 13;
			idc = IDC_INFOBAR;
			x = safeZoneX + safeZoneW * 0.16979167;
			y = safeZoneY + safeZoneH * 0.0175926;
			w = safeZoneW * 0.7;
			h = safeZoneH * 0.02037038;
			style = 0;
			text = "";
			size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			colorBackground[] = {1,1,1,0};
			class Attributes
			{
				
			};
			
		};
		class CMUI_STATIC_SHOW_INTEL : MUI_BASE 
		{
			type = 0;
			idc = IDC_LOCP_TABCAT;
			x = safeZoneX + safeZoneW * 0.80;
			y = safeZoneY + safeZoneH * 0.07;
			w = safeZoneW * 0.06;
			h = safeZoneH * 0.02;
			style = 2;
			text = "Show intel:";
			colorBackground[] = {0,0,0,1};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = safeZoneH * 0.02;
			blinkingPeriod = 0;
			fixedWidth = false;
			lineSpacing = 0;
			moving = false;
			onCanDestroy = "";
			onChar = "";
			onDestroy = "";
			onIMEChar = "";
			onIMEComposition = "";
			onJoystickButton = "";
			onKeyDown = "";
			onKeyUp = "";
			onKillFocus = "";
			onLoad = "";
			onMouseButtonDblClick = "";
			onMouseButtonDown = "";
			onMouseButtonUp = "";
			onMouseEnter = "";
			onMouseExit = "";
			onMouseMoving = "";
			onMouseZChanged = "";
			onSetFocus = "";
			onTimer = "";
			onVideoStopped = "";
			shadow = 0;
			tileH = 0;
			tileW = 0;
			
		};
		class CMUI_BUTTON_INTEL_INACTIVE : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.8;
			y = safeZoneY + safeZoneH * 0.09074075;
			w = safeZoneW * 0.06041667;
			h = safeZoneH * 0.02037038;
			style = 0;
			text = "[X] Inactive";
			borderSize = 0;
			colorBackground[] = {0,0,0,1};
			colorBackgroundActive[] = {1,1,1,1};
			colorBackgroundDisabled[] = {0,0,0,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.5,0.5,0.5,1};
			colorFocused[] = {1,1,1,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0;
			offsetPressedY = 0;
			offsetX = 0;
			offsetY = 0;
			sizeEx = safeZoneH*0.02;
			soundClick[] = {"",0.0,0.0};
			soundEnter[] = {"",0.0,0.0};
			soundEscape[] = {"",0.0,0.0};
			soundPush[] = {"",0.0,0.0};
			action = "";
			blinkingPeriod = 0;
			onButtonClick = "";
			onButtonDblClick = "";
			onButtonDown = "";
			onButtonUp = "";
			onCanDestroy = "";
			onChar = "";
			onDestroy = "";
			onIMEChar = "";
			onIMEComposition = "";
			onJoystickButton = "";
			onKeyDown = "";
			onKeyUp = "";
			onKillFocus = "";
			onLBDrop = "";
			onLoad = "";
			onMouseButtonClick = "";
			onMouseButtonDblClick = "";
			onMouseButtonDown = "";
			onMouseButtonUp = "";
			onMouseEnter = "";
			onMouseExit = "";
			onMouseMoving = "";
			onMouseZChanged = "";
			onSetFocus = "";
			onTimer = "";
			onVideoStopped = "";
			shadow = 0;
			
		};
		class CMUI_BUTTON_INTEL_ACTIVE : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.8;
			y = safeZoneY + safeZoneH * 0.11111112;
			w = safeZoneW * 0.05989584;
			h = safeZoneH * 0.02037038;
			style = 0;
			text = "[X] Active";
			borderSize = 0;
			colorBackground[] = {0,0,0,1};
			colorBackgroundActive[] = {1,1,1,1};
			colorBackgroundDisabled[] = {0,0,0,1};
			colorBorder[] = {0,0,0,0};
			colorDisabled[] = {0.5,0.5,0.5,1};
			colorFocused[] = {1,1,1,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0;
			offsetPressedY = 0;
			offsetX = 0;
			offsetY = 0;
			sizeEx = safeZoneH*0.02;
			soundClick[] = {"",0.0,0.0};
			soundEnter[] = {"",0.0,0.0};
			soundEscape[] = {"",0.0,0.0};
			soundPush[] = {"",0.0,0.0};
			action = "";
			blinkingPeriod = 0;
			onButtonClick = "";
			onButtonDblClick = "";
			onButtonDown = "";
			onButtonUp = "";
			onCanDestroy = "";
			onChar = "";
			onDestroy = "";
			onIMEChar = "";
			onIMEComposition = "";
			onJoystickButton = "";
			onKeyDown = "";
			onKeyUp = "";
			onKillFocus = "";
			onLBDrop = "";
			onLoad = "";
			onMouseButtonClick = "";
			onMouseButtonDblClick = "";
			onMouseButtonDown = "";
			onMouseButtonUp = "";
			onMouseEnter = "";
			onMouseExit = "";
			onMouseMoving = "";
			onMouseZChanged = "";
			onSetFocus = "";
			onTimer = "";
			onVideoStopped = "";
			shadow = 0;
			
		};
		class CMUI_BUTTON_INTEL_ENDED : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.8;
			y = safeZoneY + safeZoneH * 0.13240741;
			w = safeZoneW * 0.05989584;
			h = safeZoneH * 0.02037038;
			style = 0;
			text = "[X] Ended";
			borderSize = 0;
			sizeEx = safeZoneH*0.02;
			
		};
		class CMUI_STATIC_SHOW_ON_MAP : MUI_BASE 
		{
			type = 0;
			idc = IDC_LOCP_TABCAT;
			x = safeZoneX + safeZoneW * 0.79010417;
			y = safeZoneY + safeZoneH * 0.17037038;
			w = safeZoneW * 0.06979167;
			h = safeZoneH * 0.02037038;
			style = 2;
			text = "Show on the map:";
			colorBackground[] = {0,0,0,1};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = safeZoneH * 0.02;
			blinkingPeriod = 0;
			fixedWidth = false;
			lineSpacing = 0;
			moving = false;
			onCanDestroy = "";
			onChar = "";
			onDestroy = "";
			onIMEChar = "";
			onIMEComposition = "";
			onJoystickButton = "";
			onKeyDown = "";
			onKeyUp = "";
			onKillFocus = "";
			onLoad = "";
			onMouseButtonDblClick = "";
			onMouseButtonDown = "";
			onMouseButtonUp = "";
			onMouseEnter = "";
			onMouseExit = "";
			onMouseMoving = "";
			onMouseZChanged = "";
			onSetFocus = "";
			onTimer = "";
			onVideoStopped = "";
			shadow = 0;
			tileH = 0;
			tileW = 0;
			
		};
		class CMUI_BUTTON_SHOW_ENEMIES : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.79;
			y = safeZoneY + safeZoneH * 0.21;
			w = safeZoneW * 0.07;
			h = safeZoneH * 0.02;
			style = 0;
			text = "[X] Enemies";
			borderSize = 0;
			sizeEx = safeZoneH*0.02;
			
		};
		class CMUI_BUTTON_SHOW_LOCATIONS : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_BPANEL_BUTTON_3;
			x = safeZoneX + safeZoneW * 0.79010417;
			y = safeZoneY + safeZoneH * 0.19;
			w = safeZoneW * 0.07;
			h = safeZoneH * 0.02;
			style = 0;
			text = "[X] Locations";
			borderSize = 0;
			sizeEx = safeZoneH*0.02;
			
		};
		
	};
	
};
