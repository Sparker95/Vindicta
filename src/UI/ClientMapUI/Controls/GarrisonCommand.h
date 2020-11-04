#include "..\..\Resources\UIProfileColors.h"
#include "..\ClientMapUI_Macros.h"

// Classes for UI associated with commanding garrisons

#define __ROW_WIDTH 0.2
#define __ROW_HEIGHT 0.04
#define __DELTA 0.002

class CMUI_GCOM_ACTION_LISTBOX_BG : MUI_GROUP
{
	type = CT_CONTROLS_GROUP;
	
	idc = IDC_LOCP_LISTBOXBG;
	x = 0;
	y = 0;
	w = __ROW_WIDTH + 0.01;
	h = 5*__ROW_HEIGHT + 0.01;

	class Controls
	{
		class BUTTON_MOVE : MUI_BUTTON_TXT 
		{
			idc = IDC_GCOM_ACTION_MENU_BUTTON_MOVE;
			x = 0;
			y = 0*__ROW_HEIGHT;
			w = __ROW_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			text = $STR_COMMAND_MOVE;
		};
		class BUTTON_ATTACK : MUI_BUTTON_TXT 
		{
			idc = IDC_GCOM_ACTION_MENU_BUTTON_ATTACK;
			x = 0;
			y = 1*__ROW_HEIGHT;
			w = __ROW_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			text = $STR_COMMAND_ATTACK;
		};
        class BUTTON_REINFORCE : MUI_BUTTON_TXT 
		{
			idc = IDC_GCOM_ACTION_MENU_BUTTON_REINFORCE;
			x = 0;
			y = 2*__ROW_HEIGHT;
			w = __ROW_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			text = $STR_COMMAND_REINFORCE;
		};
        class BUTTON_PATROL : MUI_BUTTON_TXT 
		{
			idc = IDC_GCOM_ACTION_MENU_BUTTON_PATROL;
			x = 0;
			y = 3*__ROW_HEIGHT;
			w = __ROW_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			text = $STR_COMMAND_PATROL;
		};
        class BUTTON_CLOSE : MUI_BUTTON_TXT 
		{
			idc = IDC_GCOM_ACTION_MENU_BUTTON_CLOSE;
			x = 0;
			y = 4*__ROW_HEIGHT;
			w = __ROW_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			text = $STR_COMMAND_CANCEL;
		};	
	};
};