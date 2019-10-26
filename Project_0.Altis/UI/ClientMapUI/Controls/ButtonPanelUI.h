#include "..\..\Resources\UIProfileColors.h"

class CMUI_BP_BG : MUI_BG_BLACKTRANSPARENT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.345; 
	y = safeZoneY + safeZoneH * 0.043; 
	w = safeZoneW * 0.309; 
	h = safeZoneH * 0.027; 

};

class CMUI_BP_BUTTON_CLEARN : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.552; 
	y = safeZoneY + safeZoneH * 0.047; 
	w = safeZoneW * 0.099; 
	text = "CLEAR NOTIFICATIONS"; 

};

class CMUI_BP_BUTTON_TINTEL : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.450; 
	y = safeZoneY + safeZoneH * 0.047; 
	w = safeZoneW * 0.099; 
	text = "toggle intel"; 

};

class CMUI_BP_BUTTON_INTELPANEL : MUI_BUTTON_TXT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.347; 
	y = safeZoneY + safeZoneH * 0.047; 
	w = safeZoneW * 0.099; 
	text = "TOGGLE INTEL PANEL"; 

};

class CMUI_BP_HINTS : MUI_BG_TRANSPARENT {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.213; 
	y = safeZoneY + safeZoneH * 0.070; 
	w = safeZoneW * 0.572; 
	h = safeZoneH * 0.027; 
	text = "hints hints hints"; 
	colorBackground[] = MUIC_TRANSPARENT; 

};


