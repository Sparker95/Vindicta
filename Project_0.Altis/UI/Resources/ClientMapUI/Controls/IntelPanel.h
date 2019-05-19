class CMUI_LOCP_HEADLINE : MUI_HEADLINE 
{
    idc = IDC_LOCP_HEADLINE;
    x = safeZoneX + safeZoneW * 0.86;
    y = safeZoneY + safeZoneH * 0.055;
    w = safeZoneW * 0.132;
    text = "Camp Foxtrot";
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85);
};

class CMUI_LOCP_TAB1 : MUI_BUTTON_TAB 
{
    idc = IDC_LOCP_TAB1;
    x = safeZoneX + safeZoneW * 0.86;
    y = safeZoneY + safeZoneH * 0.078;
    w = safeZoneW * 0.044;
    h = safeZoneH * 0.075;
    text = "a3\ui_f\data\IGUI\RscTitles\RscHvtPhase\JAC_A3_Signal_4_ca.paa";

    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
};

class CMUI_LOCP_TAB2 : MUI_BUTTON_TAB 
{
    idc = IDC_LOCP_TAB2;
    x = safeZoneX + safeZoneW * 0.9;
    y = safeZoneY + safeZoneH * 0.078;
    w = safeZoneW * 0.05;
    h = safeZoneH * 0.075;
    text = "a3\3DEN\data\Displays\Display3DEN\PanelRight\modeTriggers_ca.paa";
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);    
};

class CMUI_LOCP_TAB3 : MUI_BUTTON_TAB 
{
    idc = IDC_LOCP_TAB3;
    x = safeZoneX + safeZoneW * 0.948;
    y = safeZoneY + safeZoneH * 0.078;
    w = safeZoneW * 0.044;
    h = safeZoneH * 0.075;
    text = "";
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
};

class CMUI_LOCP_TAB_TXT : MUI_BASE 
{
    idc = IDC_LOCP_TABCAT;
    x = safeZoneX + safeZoneW * 0.86;
    y = safeZoneY + safeZoneH * 0.152;
    w = safeZoneW * 0.132;
    h = safeZoneH * 0.03;
    text = "TAB HEADLINE";
    colorBackground[] = {0,0,0,1};
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
};

class CMUI_LOCP_LISTBOXBG : MUI_LISTBOX 
{
    idc = IDC_LOCP_LISTBOXBG;
    x = safeZoneX + safeZoneW * 0.86;
    y = safeZoneY + safeZoneH * 0.183;
    w = safeZoneW * 0.132;
    h = safeZoneH * 0.55;
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
    colorBackground[] = {0,0,0,0.6};
};
class CMUI_LOCP_LISTBOX : MUI_LISTBOX 
{
    idc = IDC_LOCP_LISTNBOX;
    x = safeZoneX + safeZoneW * 0.86;
    y = safeZoneY + safeZoneH * 0.183;
    w = safeZoneW * 0.132;
    h = safeZoneH * 0.55;
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
};

class CMUI_BPANEL_BG : MUI_BG_BLACKTRANSPARENT 
{
    idc = IDC_BPANEL_BG;
    x = safeZoneX + safeZoneW * 0.225;
    y = safeZoneY + safeZoneH * 0.94;
    w = safeZoneW * 0.55;
    h = safeZoneH * 0.032;
    text = "";
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
};

class CMUI_BPANEL_HINTS : MUI_BG_GRAYSOLID 
{
    idc = IDC_BPANEL_HINTS;
    x = safeZoneX + safeZoneW * 0.225;
    y = safeZoneY + safeZoneH * 0.97;
    w = safeZoneW * 0.55;
    h = safeZoneH * 0.025;
    text = "Place hint texts here. Text should be centered, white, Purista Medium.";
    sizeEx = "4.32 * (1 / (getResolution select 3)) * pixelGrid * 0.5";
    colorBackground[] = {0.12,0.12,0.12,1};
};

class CMUI_BPANEL_BUTTON_1 : MUI_BUTTON_TXT 
{
    idc = IDC_BPANEL_BUTTON_1;
    x = safeZoneX + safeZoneW * 0.33;
    y = safeZoneY + safeZoneH * 0.9445;
    w = safeZoneW * 0.11;
    text = "FAST TRAVEL";
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
};

class CMUI_BPANEL_BUTTON_2 : MUI_BUTTON_TXT 
{
    idc = IDC_BPANEL_BUTTON_2;
    x = safeZoneX + safeZoneW * 0.445;
    y = safeZoneY + safeZoneH * 0.9445;
    w = safeZoneW * 0.11;
    text = "CREATE CAMP";
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
};

class CMUI_BPANEL_BUTTON_3 : MUI_BUTTON_TXT 
{
    idc = IDC_BPANEL_BUTTON_3;
    x = safeZoneX + safeZoneW * 0.56;
    y = safeZoneY + safeZoneH * 0.9445;
    w = safeZoneW * 0.11;
    text = "MISSION MENU";
    sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);	
};