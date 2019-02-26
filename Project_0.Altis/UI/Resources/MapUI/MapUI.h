//Exported via Arma Dialog Creator (https://github.com/kayler-renslow/arma-dialog-creator)

#include "MapUI_Macros.h"

#include "CustomControlClasses.h"
class MapUI
{
	idd = IDD_MAP_UI;

	class ControlsBackground
	{

	};
	class Controls
	{
		class LocationData_Panel : Map_UI_panel
		{
			type = 0;
			idc = IDD_LD_PANEL;
			x = safeZoneX + safeZoneW * 0.73046875;
			y = safeZoneY + safeZoneH * 0.44965278;
			w = safeZoneW * 0.25976563;
			h = safeZoneH * 0.53993056;
			style = 0;
			text = "";
			onMouseEnter = "diag_log 'on mouse enter!'";
			onMouseExit = "diag_log 'on mouse exit!'";

		};
		class LocationData_type : Map_UI_text_base
		{
			type = 0;
			idc = IDC_LD_TYPE;
			x = safeZoneX + safeZoneW * 0.73984375;
			y = safeZoneY + safeZoneH * 0.5;
			w = safeZoneW * 0.2296875;
			h = safeZoneH * 0.04027778;
			text = "Type: ...";

		};
		class LocationData_time : Map_UI_text_base
		{
			type = 0;
			idc = IDC_LD_TIME;
			x = safeZoneX + safeZoneW * 0.74;
			y = safeZoneY + safeZoneH * 0.58;
			w = safeZoneW * 0.23;
			h = safeZoneH * 0.04;
			text = "Last updated: ...";

		};
		class LocationData_composition : Map_UI_text_base
		{
			type = 0;
			idc = IDC_LD_COMPOSITION;
			x = safeZoneX + safeZoneW * 0.74;
			y = safeZoneY + safeZoneH * 0.62;
			w = safeZoneW * 0.24;
			h = safeZoneH * 0.36;
			text = "Composition: ...";

		};
		class LocationData_side : Map_UI_text_base
		{
			type = 0;
			idc = IDC_LD_SIDE;
			x = safeZoneX + safeZoneW * 0.74;
			y = safeZoneY + safeZoneH * 0.54;
			w = safeZoneW * 0.23;
			h = safeZoneH * 0.04;
			text = "Side: ...";

		};
		class LocationData_header : Map_UI_text_base
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.74;
			y = safeZoneY + safeZoneH * 0.46;
			w = safeZoneW * 0.24;
			h = safeZoneH * 0.03;
			style = 2;
			text = "Location data";

		};
		class LocationData_button : Map_UI_button
		{
			type = 1;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.86035157;
			y = safeZoneY + safeZoneH * 0.5;
			w = safeZoneW * 0.12011719;
			h = safeZoneH * 0.03993056;
			text = "Push me";
			onButtonClick = "diag_log 'buttonClick'";
			onMouseEnter = "diag_log 'Mouse enter!'";
			onMouseExit = "diag_log 'Mouse exit!'";

		};
		class PlayerList_Panel : Map_UI_panel
		{
			type = 0;
			idc = IDC_PL_PANEL;
			x = safeZoneX + safeZoneW * 0.01757813;
			y = safeZoneY + safeZoneH * 0.43923612;
			w = safeZoneW * 0.25976563;
			h = safeZoneH * 0.53993056;
			style = 0;
			text = "";
			colorBackground[] = {0,0,0,0.5};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			lineSpacing = 1;
			onMouseEnter = "";
			onMouseExit = "";

		};
		class PlayerList_header_list_players : Map_UI_text_base
		{
			type = 0;
			idc = IDC_PL_HEADER_LISTPLAYERS;
			x = safeZoneX + safeZoneW * 0.02734375;
			y = safeZoneY + safeZoneH * 0.46354167;
			w = safeZoneW * 0.23339844;
			h = safeZoneH * 0.03472223;
			text = "Players list";

		};
		class PlayerList_list_name_players : RscListBox
		{
			idc = IDC_PL_LISTPLAYERS;
			x = safeZoneX + safeZoneW * 0.02734375;
			y = safeZoneY + safeZoneH * 0.52083334;
			w = safeZoneW * 0.13574219;
			h = safeZoneH * 0.42534723;
		};
		class PlayerList_button_add_member : Map_UI_button
		{
			type = 1;
			idc = IDC_PL_BUTTON_ADD_MEMBER;
			x = safeZoneX + safeZoneW * 0.17675782;
			y = safeZoneY + safeZoneH * 0.52083334;
			w = safeZoneW * 0.09570313;
			h = safeZoneH * 0.03993056;
			text = "Add member";

		};

	};

};
