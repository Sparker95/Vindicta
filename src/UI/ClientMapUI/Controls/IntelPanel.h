#include "..\..\Resources\UIProfileColors.h"
#include "..\ClientMapUI_Macros.h"
#include "..\..\..\commonPath.hpp"

class CMUI_INTEL_LISTBOX_BG : MUI_BASE 
{
	IDC = -1;
	x = safeZoneX + safeZoneW * 0.760; 
	y = safeZoneY + safeZoneH * 0.103; 
	w = safeZoneW * 0.233; 
	h = safeZoneH * 0.374; 
	colorBackground[] = {0, 0, 0, 0.85};
	colorText[] = MUIC_TRANSPARENT;
    text = ""; 
};

class CMUI_INTEL_LISTBOX : MUI_LISTNBOX 
{
	IDC = IDC_LOCP_LISTNBOX; 
	x = safeZoneX + safeZoneW * 0.760; 
	y = safeZoneY + safeZoneH * 0.111; 
	w = safeZoneW * 0.233; 
	h = safeZoneH * 0.366;
	colorBackground[] = MUIC_BLACK; 
	font = "EtelkaMonospacePro";
	sizeEx = safeZoneH*0.015;
	style = LB_MULTI;
	//columns[] = {0,0.2,0.8};
	rowHeight = 0.048;
};

class CMUI_INTEL_HEADLINE : MUI_HEADLINE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.760; 
	y = safeZoneY + safeZoneH * 0.043; 
	w = safeZoneW * 0.233; 
	text = $STR_INT_INTEL; 
	colorText[] = MUIC_BLACK; 
	colorBackground[] = MUIC_MISSION; 
};

// static control description, no interaction
class CMUI_INTEL_ACTIVE_DESCR : MUI_DESCRIPTION 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.760; 
	y = safeZoneY + safeZoneH * 0.675; 
	w = safeZoneW * 0.102; 
	h = safeZoneH * 0.028;  
	text = $STR_INT_ACTIVE; 
	style = ST_RIGHT;
};

// static control description, no interaction
class CMUI_INTEL_INACTIVE_DESCR : MUI_DESCRIPTION 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.760; 
	y = safeZoneY + safeZoneH * 0.705; 
	w = safeZoneW * 0.102; 
	h = safeZoneH * 0.028; 
	text = $STR_INT_PLANNED; 
	style = ST_RIGHT;
};

// static control description, no interaction
class CMUI_INTEL_ENDED_DESCR : MUI_DESCRIPTION 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.760; 
	y = safeZoneY + safeZoneH * 0.735; 
	w = safeZoneW * 0.102; 
	h = safeZoneH * 0.028; 
	text = $STR_INT_ENDED;
	style = ST_RIGHT; 
};

class CMUI_INTEL_BTN_ACTIVE_MAP : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.866; 
	y = safeZoneY + safeZoneH * 0.675; 
	w = safeZoneW * 0.061; 
	h = safeZoneH * 0.028;
	text = $STR_INT_MAP; 
};

class CMUI_INTEL_BTN_ACTIVE_LIST : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.932; 
	y = safeZoneY + safeZoneH * 0.675; 
	w = safeZoneW * 0.061; 
	h = safeZoneH * 0.028;
	text = $STR_INT_LIST; 
};

class CMUI_INTEL_BTN_INACTIVE_MAP : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.866; 
	y = safeZoneY + safeZoneH * 0.705; 
	w = safeZoneW * 0.061; 
	h = safeZoneH * 0.028; 
	text = $STR_INT_MAP; 
};

class CMUI_INTEL_BTN_INACTIVE_LIST : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.932; 
	y = safeZoneY + safeZoneH * 0.705; 
	w = safeZoneW * 0.061; 
	h = safeZoneH * 0.028; 
	text = $STR_INT_LIST; 
};

class CMUI_INTEL_BTN_ENDED_MAP : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.866; 
	y = safeZoneY + safeZoneH * 0.735; 
	w = safeZoneW * 0.061; 
	h = safeZoneH * 0.028; 
	text = $STR_INT_MAP; 
};

class CMUI_INTEL_BTN_ENDED_LIST : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.932; 
	y = safeZoneY + safeZoneH * 0.735; 
	w = safeZoneW * 0.061; 
	h = safeZoneH * 0.028;  
	text = $STR_INT_LIST; 
};

// background gradient image for the hint panel
class CMUI_HINTS_BG : RscPicture
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.184; 
	y = safeZoneY + safeZoneH * 0.043; 
	w = safeZoneW * 0.58; 
	h = safeZoneH * 0.026;
	text = QUOTE_COMMON_PATH(UI\Images\gradient_2way.paa);
	colorBackground[] = {0.2,0.2,0.2,0.6};
	colorText[] = {0.1, 0.1, 0.1, 1};
};

class CMUI_HINTS : MUI_BG_TRANSPARENT 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.184; 
	y = safeZoneY + safeZoneH * 0.043; 
	w = safeZoneW * 0.58; 
	h = safeZoneH * 0.026;
	text = "testestest"; 
	font = "RobotoCondensed";
};

class CMUI_BUTTON_PLAYERS : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.116; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.029; 
	text = $STR_INT_PLAYERS; 
};

class CMUI_BUTTON_LOC : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.236; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.029; 
	text = $STR_INT_LOC; 
};

class CMUI_BUTTON_LOC_MINI_PANELS : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.599; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.028; 
	text = $STR_INT_OVERVIEW; 
};

class CMUI_BUTTON_INTELP : MUI_BUTTON_TXT_CHECKBOX_LIKE 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.357; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.029; 
	text = $STR_INT_PANEL; 
};

class CMUI_BUTTON_NOTIF : MUI_BUTTON_TXT 
{

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.478; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.029;
	text = $STR_INT_CLEAR_NOTIFICATIONS; 
};

/*
// For now, 'Show overview' is located at its place
class CMUI_BUTTON_CONTACTREP : MUI_BUTTON_TXT
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.599; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.028; 
	text = "SHOW CONTACT REPORTS"; 
};
*/

// black background for buttons to fix ugly gap
class CMUI_INTEL_BTNGRP_BG : MUI_BG_BLACKSOLID 
{
	IDC = -1;
	x = safeZoneX + safeZoneW * 0.760; 
	y = safeZoneY + safeZoneH * 0.070; 
	w = safeZoneW * 0.233; 
	h = safeZoneH * 0.028; 
};

class CMUI_INTEL_BTNGRP : MUI_GROUP 
{
	IDC = IDC_LOCP_LISTNBOX_BUTTONS_GROUP;
	x = safeZoneX + safeZoneW * 0.760; 
	y = safeZoneY + safeZoneH * 0.070; 
	w = safeZoneW * 0.233; 
	h = safeZoneH * 0.028; 

	class VScrollbar {};
	class HScrollbar {};
};

// description box, larger background

class CMUI_INTEL_DESCRIPTION_BG : MUI_BG_BLACKSOLID 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.760; 
	y = safeZoneY + safeZoneH * 0.482; 
	w = safeZoneW * 0.233; 
	h = safeZoneH * 0.185; 
	colorBackground[] = {0, 0, 0, 0.85};
	text = ""; 
};

// description box, frame with headline
class CMUI_INTEL_DESCRIPTION_FRAME : MUI_GROUP 
{
	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.766; 
	y = safeZoneY + safeZoneH * 0.488; 
	w = safeZoneW * 0.220; 
	h = safeZoneH * 0.170; 

	//text = "Information";
	class Controls 
	{
		// this is where the actual description text goes
		class CMUI_INTEL_DESCRIPTION : MUI_STRUCT_TXT // MUI_BG_TRANSPARENT_MULTILINE_LEFT 
		{
			IDC = -1; 
			x = 0; 
			y = 0; 
			w = safeZoneW * 0.208; 
			h = 1; 
			colorBackground[] = MUIC_TRANSPARENT;
			text = $STR_INT_DESC;
			sizeEx = safeZoneH*0.016;
			style = ST_MULTI;
		};
	};
};

/*
	RESPAWN CONTROLS
*/
class CMUI_BUTTON_RESPAWN : MUI_BUTTON_TXT 
{
    IDC = -1; 
    x = safeZoneX + safeZoneW * 0.353; 
    y = safeZoneY + safeZoneH * 0.822; 
    w = safeZoneW * 0.3; 
    h = safeZoneH * 0.065; 

	font = "PuristaLight";
    text = $STR_INT_RESPAWN; 
	sizeEx = 0.06;
	shadow = 1;

	colorBackground[] = MUIC_BTN_GREEN;
	colorBackgroundActive[] = MUIC_WHITE;
	colorBackgroundDisabled[] = MUIC_BTN_RED;
};

class CMUI_STATIC_RESPAWN : MUI_BG_BLACKSOLID
{
	IDC = -1;
	x = safeZoneX + safeZoneW * 0.353; 
    y = safeZoneY + safeZoneH * 0.889; 
    w = safeZoneW * 0.3; 
    h = safeZoneH * 0.035; 
    text = $STR_INT_RESPAWN_HINT;
    font = "RobotoCondensed";
};