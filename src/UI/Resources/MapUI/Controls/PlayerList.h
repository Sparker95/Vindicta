class PlayerList_Panel : Map_UI_panel
{
    idc = IDC_PL_PANEL;
    x = safeZoneX + safeZoneW * 0.01757813;
    y = safeZoneY + safeZoneH * 0.43923612;
    w = safeZoneW * 0.25976563;
    h = safeZoneH * 0.53993056;
    text = "";
    colorBackground[] = {0,0,0,0.5};
    show = 0;
    enable = 0;
};
class PlayerList_header_list_players : Map_UI_text_base
{
    idc = IDC_PL_HEADER_LISTPLAYERS;
    x = safeZoneX + safeZoneW * 0.02734375;
    y = safeZoneY + safeZoneH * 0.46354167;
    w = safeZoneW * 0.23339844;
    h = safeZoneH * 0.03472223;
    text = $STR_LIST_PLAYER;
    show = 0;
};
class PlayerList_list_name_players : RscListBox
{
    idc = IDC_PL_LISTPLAYERS;
    x = safeZoneX + safeZoneW * 0.02734375;
    y = safeZoneY + safeZoneH * 0.52083334;
    w = safeZoneW * 0.13574219;
    h = safeZoneH * 0.42534723;
    show = 0;
};
class PlayerList_button_add_member : Map_UI_custom_button
{
    idc = IDC_PL_BUTTON_ADD_MEMBER;
    x = safeZoneX + safeZoneW * 0.17675782;
    y = safeZoneY + safeZoneH * 0.52083334;
    w = safeZoneW * 0.09570313;
    h = safeZoneH * 0.03590056;
    text = $STR_LIST_ADD_MEMBER;
    show = 0;
    enable = 1;
};
class PlayerList_button_show_players : Map_UI_custom_button
{
    idc = IDC_PL_BUTTON_SHOW_PLAYERLIST;
    x = safeZoneX + safeZoneW * 0.88476563;
    y = safeZoneY + safeZoneH * 0.56944445;
    w = safeZoneW * 0.09570313;
    h = safeZoneH * 0.03993056;
    text = $STR_LIST_PLAYER;
    enable = 1;
};
