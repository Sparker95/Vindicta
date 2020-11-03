#include "..\..\Resources\UIProfileColors.h"
#include "..\ClientMapUI_Macros.h"

// The menu under garrison marker when a garrison is selected

// It's not a dialog, it's a group control

#define __ROW_HEIGHT LSELECT_MENU_ROW_HEIGHT
#define __MENU_WIDTH LSELECT_MENU_WIDTH
#define __DELTA 0.002

class CMUI_LSELECTED_MENU : MUI_GROUP
{
	type = CT_CONTROLS_GROUP;
	idc= -1;
	
	x = 0;
	y = 0;
	w = __MENU_WIDTH + 0.01;
	h = 2*__ROW_HEIGHT + 0.01;

	class Controls
	{
		// Class name must be unique so that we can find it because we don't use IDC any more
		class LSELECTED_BUTTON_RECRUIT : MUI_BUTTON_TXT 
		{
			idc = -1;
			x = 0;
			y = 0*__ROW_HEIGHT;
			w = __MENU_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			//text = "<-\\-> Split";
			text = $STR_UNIT_RECUIT;			
		};

		class LSELECTED_BUTTON_DISBAND : MUI_BUTTON_TXT 
		{
			idc = -1;
			x = 0;
			y = 1*__ROW_HEIGHT;
			w = __MENU_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			//text = "<-\\-> Split";
			text = $STR_UNIT_DISBAND;			
		};

/*
		class BUTTON_DO_SMTH : MUI_BUTTON_TXT 
		{
			idc = IDC_LSELECT_BUTTON_CANCEL_ORDER;
			x = 0;
			y = 2*__ROW_HEIGHT;
			w = __MENU_WIDTH + __DELTA;
			h = __ROW_HEIGHT + __DELTA;
			text = "NYI";
		};
*/
	};
	
};
