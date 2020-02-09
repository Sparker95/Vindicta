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
			idc = -1;
			x = 0.020; 
			y = 0.077; 
			w = 0.452; 
			h = 0.565; 
		};

		class TAB_SAVE_LISTNBOX_SAVES : MUI_LISTNBOX_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.077; 
			w = 0.452; 
			h = 0.565; 			
			columns[] = {0, 1};	// One column
		};

		class TAB_SAVE_BUTTON_NEW : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.478; 
			y = 0.077; 
			w = 0.200; 
			h = 0.126;  
			text = "New Save";			
		};

		class TAB_SAVE_BUTTON_OVERWRITE : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.478; 
			y = 0.223; 
			w = 0.200; 
			h = 0.126; 
			text = "Overwrite";	
		};

		class TAB_SAVE_BUTTON_LOAD : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.478; 
			y = 0.370; 
			w = 0.200; 
			h = 0.126; 
			text = "Load";
		};

		class TAB_SAVE_BUTTON_DELETE : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.478; 
			y = 0.508; 
			w = 0.200; 
			h = 0.133;
			text = "Delete";	
			colorBackground[] = MUIC_BTN_RED;	
		};

		class TAB_SAVE_STATIC_PREVIOUS_SAVES : MUI_BASE_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.028; 
			w = 0.452; 
			h = 0.040;  
			style = 0;
			text = "PREVIOUSLY SAVED GAMES:";	
			colorBackground[] = MUIC_BLACK;		
		};

		class TAB_SAVE_STATIC_DESCRNAME : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.651; 
			w = 0.226; 
			h = 0.040; 
			text = "SAVE NAME:";
		};

		class TAB_SAVE_STATIC_DESCRMAP : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.693; 
			w = 0.226; 
			h = 0.040;
			text = "MAP:"; 
		};

		class TAB_SAVE_STATIC_DESCRVER : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.735; 
			w = 0.226; 
			h = 0.040; 
			text = "VERSION:";
		};

		class TAB_SAVE_STATIC_DESCRCOUNT : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.777; 
			w = 0.226; 
			h = 0.040; 
			text = "SAVE COUNT:";
		};

		// show save name here
		class TAB_SAVE_STATIC_NAME : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS
		{
			idc = -1;
			x = 0.246; 
			y = 0.651; 
			w = 0.226; 
			h = 0.040; 
			text = "";
			font = "RobotoCondensed";
			style = ST_RIGHT+ST_VCENTER; 
		};

		// show map name here
		class TAB_SAVE_STATIC_MAP : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS 
		{
			idc = -1;
			x = 0.246; 
			y = 0.693; 
			w = 0.226; 
			h = 0.040; 
			text = "";
			font = "RobotoCondensed";
			style = ST_RIGHT+ST_VCENTER; 
		};

		// show version # here
		class TAB_SAVE_STATIC_VER : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS 
		{
			idc = -1;
			x = 0.246; 
			y = 0.735; 
			w = 0.226; 
			h = 0.040;
			text = ""; 
			font = "RobotoCondensed";
			style = ST_RIGHT+ST_VCENTER; 
		};

		// show save count here
		class TAB_SAVE_STATIC_COUNT : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS 
		{
			idc = -1;
			x = 0.246; 
			y = 0.777; 
			w = 0.226; 
			h = 0.040;
			text = "";
			font = "RobotoCondensed";
			style = ST_RIGHT+ST_VCENTER; 
		};

		// show additional info here
		class TAB_SAVE_STATIC_SAVE_DATA : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS
		{
			idc = -1;
			x = 0.020; 
			y = 0.827; 
			w = 0.659; 
			h = 0.040;  
			text = "";		
		};		
	};
	
};
