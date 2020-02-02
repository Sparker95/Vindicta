class LocationData_Panel : Map_UI_panel
{
    idc = IDD_LD_PANEL;
    x = safeZoneX + safeZoneW * 0.73046875;
    y = safeZoneY + safeZoneH * 0.37673612;
    w = safeZoneW * 0.25976563;
    h = safeZoneH * 0.61284723;
    text = "";
    enable = 0;
};
class HR_label : Map_UI_text_base 
{
    idc = IDC_HR_LABEL;
    x = safeZoneX + safeZoneW * 0.74023438;
    y = safeZoneY + safeZoneH * 0.38715278;
    w = safeZoneW * 0.02050782;
    h = safeZoneH * 0.02951389;
    sizeEx = safeZoneH * 0.025;
    text = "HR:";
    enable = 0;
};
class HR_value : Map_UI_text_base 
{
    idc = IDC_HR_VALUE;
    x = safeZoneX + safeZoneW * 0.76464844;
    y = safeZoneY + safeZoneH * 0.38715278;
    w = safeZoneW * 0.03515625;
    h = safeZoneH * 0.02951389;
    sizeEx = safeZoneH * 0.025;
    text = "000";
};
class LocationData_type : Map_UI_text_base
{
    idc = IDC_LD_TYPE;
    x = safeZoneX + safeZoneW * 0.73984375;
    y = safeZoneY + safeZoneH * 0.5;
    w = safeZoneW * 0.2296875;
    h = safeZoneH * 0.04027778;
    text = "Type: ...";
    enable = 0;
};
class LocationData_time : Map_UI_text_base
{
    idc = IDC_LD_TIME;
    x = safeZoneX + safeZoneW * 0.74;
    y = safeZoneY + safeZoneH * 0.58;
    w = safeZoneW * 0.23;
    h = safeZoneH * 0.04;
    text = "Last updated: ...";
    enable = 0;
};
class LocationData_composition : Map_UI_text_base
{
    idc = IDC_LD_COMPOSITION;
    x = safeZoneX + safeZoneW * 0.74;
    y = safeZoneY + safeZoneH * 0.62;
    w = safeZoneW * 0.24;
    h = safeZoneH * 0.36;
    text = "Composition: ...";
    enable = 0;
};
class LocationData_side : Map_UI_text_base
{
    idc = IDC_LD_SIDE;
    x = safeZoneX + safeZoneW * 0.74;
    y = safeZoneY + safeZoneH * 0.54;
    w = safeZoneW * 0.23;
    h = safeZoneH * 0.04;
    text = "Side: ...";
    enable = 0;
};
class LocationData_header : Map_UI_text_base
{
    idc = -1;
    x = safeZoneX + safeZoneW * 0.74;
    y = safeZoneY + safeZoneH * 0.46;
    w = safeZoneW * 0.24;
    h = safeZoneH * 0.03;
    text = "Location data";
    enable = 0;
};
class LocationData_button : Map_UI_button
{
    idc = -1;
    x = safeZoneX + safeZoneW * 0.86035157;
    y = safeZoneY + safeZoneH * 0.5;
    w = safeZoneW * 0.12011719;
    h = safeZoneH * 0.03993056;
    text = "Push me";
};
