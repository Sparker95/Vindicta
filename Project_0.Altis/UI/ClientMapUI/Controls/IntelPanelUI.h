#include "..\..\Resources\UIProfileColors.h"

class CMUI_LOCP_LISTBOX : MUI_LISTNBOX {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.845; 
	y = safeZoneY + safeZoneH * 0.093; 
	w = safeZoneW * 0.148; 
	h = safeZoneH * 0.729; 

};

class CMUI_LOCP_FILTERTXT : MUI_BG_BLACKSOLID {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.845; 
	y = safeZoneY + safeZoneH * 0.068; 
	w = safeZoneW * 0.054; 
	h = safeZoneH * 0.024; 
	style = ST_LEFT; 
	text = "FILTER:"; 
	colorText[] = MUIC_WHITE; 
	colorBackground[] = MUIC_BLACK; 

};

class CMUI_LOCP_FILTER : MUI_COMBOBOX {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.9; 
	y = safeZoneY + safeZoneH * 0.068; 
	w = safeZoneW * 0.093; 
	h = safeZoneH * 0.024; 

};

class CMUI_LOCP_HEADLINE : MUI_HEADLINE {

	IDC = -1; 
	x = safeZoneX + safeZoneW * 0.845; 
	y = safeZoneY + safeZoneH * 0.043; 
	w = safeZoneW * 0.148; 
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


