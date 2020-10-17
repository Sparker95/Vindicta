#include "..\..\Resources\UIProfileColors.h"
#include "..\ClientMapUI_Macros.h"

// The menu under garrison marker when a garrison is selected

// It's not a dialog, it's a group control

#define __ROW_HEIGHT GSELECT_MENU_ROW_HEIGHT
#define __MENU_WIDTH GSELECT_MENU_WIDTH
#define __DELTA 0.002

class CMUI_GSELECTED_MENU : MUI_GROUP
{
	type = CT_CONTROLS_GROUP;
	idc= IDC_GSELECT_GROUP;
	
	x = 0;
	y = 0;
	w = __MENU_WIDTH + 0.01;
	h = 3*__ROW_HEIGHT + 0.01;

	class Controls
	{
		class BUTTON_SPLIT : MUI_BUTTON_TXT 
		{
			idc = IDC_GSELECT_BUTTON_SPLIT;
			x = 0;
			y = 0*__ROW_HEIGHT;
			//w = __MENU_WIDTH/2 + __DELTA;
			w = __MENU_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			//text = "<-\\-> Split";
			text = $STR_COMMAND_SPLIT;			
		};
		/*
		class STATIC_HEADER : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = 0.03000007;
			y = 0.10000013;
			w = 0.2;
			h = __ROW_HEIGHT;
			text = "Garrison";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		*/

		/*
		class BUTTON_MERGE : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = IDC_GSELECT_BUTTON_MERGE;
			x = __MENU_WIDTH/2;
			y = 0;
			w = __MENU_WIDTH/2 + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			//text = "->\<-Merge";	
			text = "Merge";
		};*/
		
		class BUTTON_ORDER : MUI_BUTTON_TXT 
		{
			idc = IDC_GSELECT_BUTTON_GIVE_ORDER;
			x = 0;
			y = 1*__ROW_HEIGHT;
			w = __MENU_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			text = $STR_COMMAND_GIVE_ORDER;			
		};

		class BUTTON_CANCEL_ORDER : MUI_BUTTON_TXT 
		{
			idc = IDC_GSELECT_BUTTON_CANCEL_ORDER;
			x = 0;
			y = 2*__ROW_HEIGHT;
			w = __MENU_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			text = $STR_COMMAND_CANCEL_ORDER;
		};
	};
	
};
