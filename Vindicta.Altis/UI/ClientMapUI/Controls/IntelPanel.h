#include "..\..\Resources\UIProfileColors.h"
#include "..\ClientMapUI_Macros.h"

class CMUI_INTEL_LISTBOX_BG : MUI_BASE {

	IDC = -1;
	x = safeZoneX + safeZoneW * 0.839; 
	y = safeZoneY + safeZoneH * 0.101; 
	w = safeZoneW * 0.154; 
	h = safeZoneH * 0.353; 
	colorBackground[] = MUIC_BLACK; 

};

class CMUI_INTEL_LISTBOX : MUI_LISTNBOX {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.839; 
	y = safeZoneY + safeZoneH * 0.101; 
	w = safeZoneW * 0.154; 
	h = safeZoneH * 0.353; 
	colorBackground[] = MUIC_BLACK; 

};

class CMUI_INTEL_HEADLINE : MUI_HEADLINE {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.839; 
	y = safeZoneY + safeZoneH * 0.043; 
	w = safeZoneW * 0.154; 
	text = "INTEL"; 
	colorText[] = MUIC_BLACK; 
	colorBackground[] = MUIC_MISSION; 

};

class CMUI_INTEL_MINIMIZE : RSCPICTURE {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.981; 
	y = safeZoneY + safeZoneH * 0.045; 
	w = safeZoneW * 0.010; 
	h = safeZoneH * 0.018; 
	style = ST_KEEP_ASPECT_RATIO + ST_PICTURE; 
	text = "a3\ui_f\data\GUI\Rsc\RscDisplayArcadeMap\icon_sidebar_show_down.paa"; 
	colorText[] = MUIC_BLACK; 
	colorBackground[] = MUIC_TRANSPARENT; 

};

class CMUI_INTEL_ACTIVE : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.839; 
	y = safeZoneY + safeZoneH * 0.458; 
	w = safeZoneW * 0.154; 
	h = safeZoneH * 0.028; 
	text = "show active"; 

};

class CMUI_INTEL_INACTIVE : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.839; 
	y = safeZoneY + safeZoneH * 0.488; 
	w = safeZoneW * 0.154; 
	h = safeZoneH * 0.028; 
	text = "show inactive"; 

};

class CMUI_INTEL_ENDED : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.839; 
	y = safeZoneY + safeZoneH * 0.518; 
	w = safeZoneW * 0.154; 
	h = safeZoneH * 0.028; 
	text = "show ended"; 

};

class CMUI_BUTTON_NOTIF : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.580; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.028; 
	text = "CLEAR NOTIFICATIONS"; 

};

class CMUI_BUTTON_INTELP : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.459; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.028; 
	text = "show intel panel"; 

};

class CMUI_HINTS : MUI_BG_TRANSPARENT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.184; 
	y = safeZoneY + safeZoneH * 0.043; 
	w = safeZoneW * 0.631; 
	h = safeZoneH * 0.022; 
	text = "hints hints hints"; 
	colorBackground[] = MUIC_TRANSPARENT; 

};

class CMUI_BUTTON_LOC : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.338; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.028; 
	text = "show locations"; 

};

class CMUI_BUTTON_PLAYERS : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.218; 
	y = safeZoneY + safeZoneH * 0.002; 
	w = safeZoneW * 0.118; 
	h = safeZoneH * 0.028; 
	text = "show players"; 

};

class CMUI_INTEL_BTNGRP : MUI_GROUP {

	IDC = IDC_LOCP_LISTNBOX_BUTTONS_GROUP;
	x = safeZoneX + safeZoneW * 0.839; 
	y = safeZoneY + safeZoneH * 0.069; 
	w = safeZoneW * 0.154; 
	h = safeZoneH * 0.028; 

};


