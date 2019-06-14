#include "..\..\UIProfileColors.h"
#include "..\..\MissionUIControlClasses.h"

class CMUI_INFOBAR : MUI_STRUCT_TXT 
{
    type = 13;
    idc = IDC_INFOBAR;
    x = safeZoneX + safeZoneW * 0.15;
    y = safeZoneY + safeZoneH * 0.045;
    w = safeZoneW * 0.7;
    h = safeZoneH * 0.1;
    style = 0;
    text = "";
    size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
    colorBackground[] = {1,1,1,0};
    class Attributes
    {
        
    };
};

class CMUI_LOCP_HEADLINE : MUI_HEADLINE
{
    idc = IDC_LOCP_HEADLINE;
    x = safeZoneX + safeZoneW * 0.87;
    y = safeZoneY + safeZoneH * 0.038;
    w = safeZoneW * 0.126;
    text = "Camp Foxtrot";
};

class CMUI_LOCP_TAB1 : MUI_BUTTON_TAB 
{
    idc = IDC_LOCP_TAB1;
    x = safeZoneX + safeZoneW * 0.87;
    y = safeZoneY + safeZoneH * 0.065;
    w = safeZoneW * 0.042;
    h = safeZoneH * 0.07;
    text = "a3\ui_f\data\IGUI\RscTitles\RscHvtPhase\JAC_A3_Signal_4_ca.paa";  
};

class CMUI_LOCP_TAB2 : MUI_BUTTON_TAB
{
    idc = IDC_LOCP_TAB2;
    x = safeZoneX + safeZoneW * 0.912;
    y = safeZoneY + safeZoneH * 0.065;
    w = safeZoneW * 0.042;
    h = safeZoneH * 0.07;
   text = "a3\ui_f\data\IGUI\RscTitles\RscHvtPhase\JAC_A3_Signal_4_ca.paa";    
};

class CMUI_LOCP_TAB3 : MUI_BUTTON_TAB 
{
    idc = IDC_LOCP_TAB3;
    x = safeZoneX + safeZoneW * 0.954;
    y = safeZoneY + safeZoneH * 0.065;
    w = safeZoneW * 0.042;
    h = safeZoneH * 0.07;
   text = "a3\ui_f\data\IGUI\RscTitles\RscHvtPhase\JAC_A3_Signal_4_ca.paa";  
};

class CMUI_LOCP_TAB_TXT : MUI_BASE 
{
    idc = IDC_LOCP_TABCAT;
    x = safeZoneX + safeZoneW * 0.87;
    y = safeZoneY + safeZoneH * 0.135;
    w = safeZoneW * 0.126;
    h = safeZoneH * 0.03;
    text = "TAB HEADLINE";
    font = "PuristaSemiBold";
    sizeEx = MUI_TXT_SIZE_S
    style = 12+2;
    colorBackground[] = MUIC_BLACK;	
};

class CMUI_LOCP_LISTBOXBG : MUI_BASE 
{
    idc = IDC_LOCP_LISTBOXBG;
    x = safeZoneX + safeZoneW * 0.87;
    y = safeZoneY + safeZoneH * 0.164;
    w = safeZoneW * 0.126;
    h = safeZoneH * 0.535;
    colorBackground[] = MUIC_BLACKTRANSP;
    colorText[] = MUIC_TRANSPARENT;
    text = "";
};
class CMUI_LOCP_LISTBOX : MUI_LISTNBOX 
{
    idc = IDC_LOCP_LISTNBOX;
    x = safeZoneX + safeZoneW * 0.87;
    y = safeZoneY + safeZoneH * 0.164;
    w = safeZoneW * 0.126;
    h = safeZoneH * 0.535;
};

class CMUI_BPANEL_BG : MUI_BG_BLACKTRANSPARENT 
{
    idc = IDC_BPANEL_BG;
    x = safeZoneX + safeZoneW * 0.25;
    y = safeZoneY + safeZoneH * 0.94;
    w = safeZoneW * 0.5;
    h = safeZoneH * 0.025;
    text = "";
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
};

class CMUI_BPANEL_HINTS : MUI_BG_BLACKSOLID 
{
    idc = IDC_BPANEL_HINTS;
    x = safeZoneX + safeZoneW * 0.25;
    y = safeZoneY + safeZoneH * 0.965;
    w = safeZoneW * 0.5;
    h = safeZoneH * 0.025;
    text = "Place hint texts here. Text should be centered, white, Purista Medium.";
};

class CMUI_BPANEL_BUTTON_1 : MUI_BUTTON_TXT 
{
    idc = IDC_BPANEL_BUTTON_1;
    x = safeZoneX + safeZoneW * 0.33;
    y = safeZoneY + safeZoneH * 0.943;
    w = safeZoneW * 0.11;
    text = "ADD FRIENDLY GROUP"; //"FAST TRAVEL";
};

class CMUI_BPANEL_BUTTON_2 : MUI_BUTTON_TXT 
{
    idc = IDC_BPANEL_BUTTON_2;
    x = safeZoneX + safeZoneW * 0.445;
    y = safeZoneY + safeZoneH * 0.943;
    w = safeZoneW * 0.11;
    text = "CREATE CAMP";
};

class CMUI_BPANEL_BUTTON_3 : MUI_BUTTON_TXT 
{
    idc = IDC_BPANEL_BUTTON_3;
    x = safeZoneX + safeZoneW * 0.56;
    y = safeZoneY + safeZoneH * 0.943;
    w = safeZoneW * 0.11;
    text = "MISSION MENU";	
};

class CMUI_LOCP_DETAILBG : MUI_BG_BLACKSOLID 
{
    idc = IDC_LOCP_DETAILBG;
    x = safeZoneX + safeZoneW * 0.87;
    y = safeZoneY + safeZoneH * 0.7;
    w = safeZoneW * 0.126;
    h = safeZoneH * 0.2;
    style = 16;
    text = "";    
};
class CMUI_LOCP_DETAILFRAME : MUI_ST_FRAME 
{
    idc = IDC_LOCP_DETAILFRAME;
    x = safeZoneX + safeZoneW * 0.874;
    y = safeZoneY + safeZoneH * 0.706;
    w = safeZoneW * 0.118;
    h = safeZoneH * 0.187;
    style = 64;
    text = "INTEL DESCRIPTION";
    sizeEx = "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.45";
};
class CMUI_LOCP_DETAILTXT : MUI_EDIT 
{
    idc = IDC_LOCP_DETAILTXT;
    x = safeZoneX + safeZoneW * 0.8805;
    y = safeZoneY + safeZoneH * 0.725;
    w = safeZoneW * 0.105;
    h = safeZoneH * 0.16;
    text = "";
    colorBackground[] = MUIC_TRANSPARENT;
    colorText[] = MUIC_WHITE;           
};