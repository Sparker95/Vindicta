

class RecruitTab : MUI_GROUP
{
	idc = -1;
	x = 0;
	y = 0;
	#define DLG_WIDTH 1.2
	#define DLG_HEIGHT 0.9
	w = DLG_WIDTH;
	h = DLG_HEIGHT;
	style = 0;
	text = "";

	class Controls {
		#define OUTER_BORDER 0.020
		#define INNER_BORDER 0.010
		#define RECRUIT_BUTTON_HGT 0.112
		#define LABEL_HGT 0.040
		#define BIG_LABEL_HGT 0.060
		#define MAIN_PANEL_Y (OUTER_BORDER + BIG_LABEL_HGT + INNER_BORDER)
		#define MAIN_PANEL_WID (DLG_WIDTH - OUTER_BORDER * 2)
		#define MAIN_PANEL_HGT (DLG_HEIGHT - MAIN_PANEL_Y - OUTER_BORDER - RECRUIT_BUTTON_HGT - OUTER_BORDER)

		class TAB_RECRUIT_BUTTON_RECRUIT : MUI_BUTTON_TXT_ABS
		{
			IDC = -1;
			x = OUTER_BORDER;
			y = MAIN_PANEL_Y + MAIN_PANEL_HGT + OUTER_BORDER;
			w = MAIN_PANEL_WID;
			h = RECRUIT_BUTTON_HGT;
			text = "RECRUIT";
			font = "PuristaMedium";
			SizeEx = 0.050;
			colorText[] = MUIC_BLACK;
			colorBackground[] = MUIC_MISSION;
			colorBackgroundActive[] = MUIC_WHITE;
			colorBackgroundDisabled[] = MUIC_TXT_DISABLED;
			colorBorder[] = MUIC_TRANSPARENT;
			colorDisabled[] = MUIC_WHITE;
			colorFocused[] = MUIC_MISSION;// same as colorBackground to disable blinking
			colorShadow[] = MUIC_TRANSPARENT;
		};

		#define INNER_COLS 3
		#define INNER_WID (MAIN_PANEL_WID - (INNER_COLS - 1) * INNER_BORDER)
		#define INNER_HGT (MAIN_PANEL_HGT - INNER_BORDER - LABEL_HGT)
		#define LOADOUT_WID (INNER_WID * 0.26)
		#define WEAPONS_COL_X (OUTER_BORDER + LOADOUT_WID + INNER_BORDER)
		#define WEAPONS_COL_WID (INNER_WID * 0.37)
		#define HELMET_VEST_COL_X (WEAPONS_COL_X + WEAPONS_COL_WID + INNER_BORDER)
		#define HELMET_VEST_COL_WID (INNER_WID * 0.37)

		class TAB_RECRUIT_STATIC_N_RECRUITS : MUI_DESCRIPTION_ABS 
		{
			IDC = -1;
			x = OUTER_BORDER;
			y = OUTER_BORDER;
			w = MAIN_PANEL_WID;
			h = BIG_LABEL_HGT;
			style = ST_LEFT;
			SizeEx = 0.050;
		};

		class TAB_RECRUIT_AVAILABLE_LOADOUTS_LABEL : MUI_DESCRIPTION_ABS 
		{
			IDC = -1;
			x = OUTER_BORDER;
			y = MAIN_PANEL_Y;
			w = LOADOUT_WID;
			h = LABEL_HGT;
			style = ST_LEFT;
			text = "AVAILABLE LOADOUTS:";
		};

		class TAB_RECRUIT_WEAPONS_LABEL : MUI_DESCRIPTION_ABS 
		{
			IDC = -1;
			x = WEAPONS_COL_X;
			y = MAIN_PANEL_Y;
			w = WEAPONS_COL_WID;
			h = LABEL_HGT;
			style = ST_LEFT;
			text = "WEAPONS:";
		};

		class TAB_RECRUIT_GEAR_LABEL : MUI_DESCRIPTION_ABS 
		{
			IDC = -1;
			x = HELMET_VEST_COL_X;
			y = MAIN_PANEL_Y;
			w = HELMET_VEST_COL_WID;
			h = LABEL_HGT;
			style = ST_LEFT;
			text = "GEAR:";
		};

		#define LISTBOX_TOP_Y (MAIN_PANEL_Y + LABEL_HGT + INNER_BORDER)
		class TAB_RECRUIT_LISTBOX_BG : MUI_BG_BLACKTRANSPARENT_ABS 
		{
			IDC = -1;
			x = OUTER_BORDER;
			y = LISTBOX_TOP_Y;
			w = LOADOUT_WID;
			h = INNER_HGT;
			text = "";
		};

		class TAB_RECRUIT_LISTBOX : MUI_LISTNBOX_ABS 
		{
			IDC = -1;
			x = OUTER_BORDER;
			y = LISTBOX_TOP_Y;
			w = LOADOUT_WID;
			h = INNER_HGT;
			text = "";
			columns[] = {0, 1};	// One column	
		};

		#define GEAR_LISTBOX_HGT ((INNER_HGT - INNER_BORDER) / 2)
		class TAB_RECRUIT_LISTBOX_PRIMARY_BG : MUI_BG_BLACKTRANSPARENT_ABS 
		{
			IDC = -1;
			x = WEAPONS_COL_X;
			y = LISTBOX_TOP_Y;
			w = WEAPONS_COL_WID;
			h = GEAR_LISTBOX_HGT;
			text = "";
		};

		// Two columns
		#define ITEM_COLS {0, 0.8, 1}
		class TAB_RECRUIT_LISTBOX_PRIMARY : MUI_LISTNBOX_ABS 
		{
			IDC = -1;
			x = WEAPONS_COL_X;
			y = LISTBOX_TOP_Y;
			w = WEAPONS_COL_WID;
			h = GEAR_LISTBOX_HGT;
			text = "";
			columns[] = ITEM_COLS;
		};

		class TAB_RECRUIT_LISTBOX_SECONDARY_BG : MUI_BG_BLACKTRANSPARENT_ABS 
		{
			IDC = -1;
			x = WEAPONS_COL_X;
			y = LISTBOX_TOP_Y + INNER_BORDER + GEAR_LISTBOX_HGT;
			w = WEAPONS_COL_WID;
			h = GEAR_LISTBOX_HGT;
			text = "";
		};

		class TAB_RECRUIT_LISTBOX_SECONDARY : MUI_LISTNBOX_ABS 
		{
			IDC = -1;
			x = WEAPONS_COL_X;
			y = LISTBOX_TOP_Y + INNER_BORDER + GEAR_LISTBOX_HGT;
			w = WEAPONS_COL_WID;
			h = GEAR_LISTBOX_HGT;
			text = "";
			columns[] = ITEM_COLS;
		};

		class TAB_RECRUIT_LISTBOX_HELMET_BG : MUI_BG_BLACKTRANSPARENT_ABS 
		{
			IDC = -1;
			x = HELMET_VEST_COL_X;
			y = LISTBOX_TOP_Y;
			w = HELMET_VEST_COL_WID;
			h = GEAR_LISTBOX_HGT;
			text = "";
		};

		class TAB_RECRUIT_LISTBOX_HELMET : MUI_LISTNBOX_ABS 
		{
			IDC = -1;
			x = HELMET_VEST_COL_X;
			y = LISTBOX_TOP_Y;
			w = HELMET_VEST_COL_WID;
			h = GEAR_LISTBOX_HGT;
			text = "";
			columns[] = ITEM_COLS;
		};

		class TAB_RECRUIT_LISTBOX_VEST_BG : MUI_BG_BLACKTRANSPARENT_ABS 
		{
			IDC = -1;
			x = HELMET_VEST_COL_X;
			y = LISTBOX_TOP_Y + INNER_BORDER + GEAR_LISTBOX_HGT;
			w = HELMET_VEST_COL_WID;
			h = GEAR_LISTBOX_HGT;
			text = "";
		};

		class TAB_RECRUIT_LISTBOX_VEST : MUI_LISTNBOX_ABS 
		{
			IDC = -1;
			x = HELMET_VEST_COL_X;
			y = LISTBOX_TOP_Y + INNER_BORDER + GEAR_LISTBOX_HGT;
			w = HELMET_VEST_COL_WID;
			h = GEAR_LISTBOX_HGT;
			text = "";
			columns[] = ITEM_COLS;
		};
	};
};
