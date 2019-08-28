#include "..\..\UIProfileColors.h"
#include "..\ClientMapUI_Macros.h"

// Classes for UI associated with commanding garrisons

class CMUI_GCOM_ACTION_LISTBOX_BG : MUI_BASE 
{
    idc = IDC_LOCP_LISTBOXBG;
    x = 0; // We change the position anyway
    y = 0;
    w = safeZoneW * 0.05;
    h = safeZoneH * 0.01; //0.14;
    colorBackground[] = MUIC_BLACKTRANSP;
    colorText[] = MUIC_TRANSPARENT;
    text = "";
};

class CMUI_GCOM_ACTION_LISTBOX : MUI_LISTNBOX
{
    idc = IDC_GCOM_ACTION_LISTNBOX;
    x = 0; // We change the position anyway
    y = 0;
    w = safeZoneW * 0.09;
    h = safeZoneH * 0.14;
	rows = 3;
};
