class TAB_SAVE : MUI_GROUP
{
	idc = -1;
	x = 0;
	y = 0;
	w = 0.7;
	h = 0.9;
	style = 0;
	text = "";

	class Controls
	{
		class TAB_SAVE_STATIC_LISTBOX_BACKGROUND : MUI_BG_BLACKTRANSPARENT_ABS
		{
			x = 0.01000012;
			y = 0.06000017;
			w = 0.53000009;
			h = 0.52000015;
		};

		class TAB_SAVE_LISTNBOX_SAVES : MUI_LISTNBOX_ABS 
		{
			idc = -1;
			x = 0.01000012;
			y = 0.06000017;
			w = 0.53000009;
			h = 0.52000015;			
			columns[] = {0, 1};	// One column
		};

		class TAB_SAVE_BUTTON_NEW : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.55;
			y = 0.11000007;
			w = 0.14;
			h = 0.05000006;
			text = "New Save";			
		};
		class TAB_SAVE_BUTTON_OVERWRITE : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.55000015;
			y = 0.23000038;
			w = 0.14000003;
			h = 0.05000006;
			text = "Overwrite";	
		};
		class TAB_SAVE_BUTTON_LOAD : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.55000019;
			y = 0.3600004;
			w = 0.14000003;
			h = 0.05000006;
			text = "Load";
		};
		class TAB_SAVE_BUTTON_DELETE : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.55000019;
			y = 0.48000037;
			w = 0.14000003;
			h = 0.05000006;
			text = "Delete";			
		};
		class TAB_SAVE_STATIC_PREVIOUS_SAVES : MUI_BASE_ABS 
		{
			idc = -1;
			x = 0.01;
			y = 0.01000014;
			w = 0.68000002;
			h = 0.04;
			style = 0;
			text = "Previously saved games:";			
		};
		class TAB_SAVE_STATIC_SAVE_DATA : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS
		{
			idc = -1;
			x = 0.01;
			y = 0.59000016;
			w = 0.68000002;
			h = 0.30000015;
			text = "";		
		};
		
	};
	
};
