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
			h = 0.445; 
		};

		class TAB_SAVE_LISTNBOX_SAVES : MUI_LISTNBOX_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.077; 
			w = 0.452; 
			h = 0.445; 			
			columns[] = {0, 1};	// One column
		};

		class TAB_SAVE_STATIC_STORAGE : MUI_BG_BLACKTRANSPARENT_ABS 
		{
			idc = -1;
			x = 0.49000015;
			y = 0.03000024;
			w = 0.20000005;
			h = 0.04;
			text = "Storage:";
		};

		class TAB_SAVE_COMBO_STORAGE : MUI_COMBOBOX_ABS 
		{
			idc = -1;
			x = 0.49000009;
			y = 0.08000016;
			w = 0.20000007;
			h = 0.04000003;
			text = "---";		
		};

		class TAB_SAVE_BUTTON_NEW : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.49;
			y = 0.18000018;
			w = 0.20000003;
			h = 0.07;
			text = "New Save";			
		};

		class TAB_SAVE_BUTTON_OVERWRITE : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.49000015;
			y = 0.27000043;
			w = 0.20000006;
			h = 0.07;
			text = "Overwrite";	
		};

		class TAB_SAVE_BUTTON_LOAD : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.49000019;
			y = 0.36000045;
			w = 0.20000007;
			h = 0.07;
			text = "Load";
		};

		class TAB_SAVE_BUTTON_DELETE : MUI_BUTTON_TXT_ABS 
		{
			idc = -1;
			x = 0.49000019;
			y = 0.45000042;
			w = 0.20000006;
			h = 0.07;
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
			y = 0.538; 
			w = 0.226; 
			h = 0.040;  
			text = "SAVE NAME:";
		};

		class TAB_SAVE_STATIC_DESCRMAP : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.584; 
			w = 0.226; 
			h = 0.040; 
			text = "MAP:"; 
		};

		class TAB_SAVE_STATIC_DESCRVER : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.629; 
			w = 0.226; 
			h = 0.040;  
			text = "VERSION:";
		};

		class TAB_SAVE_STATIC_DESCRCOUNT : MUI_DESCRIPTION_ABS 
		{
			idc = -1;
			x = 0.020; 
			y = 0.675; 
			w = 0.226; 
			h = 0.040;
			text = "SAVE COUNT:";
		};

		// show save name here
		class TAB_SAVE_STATIC_NAME : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS
		{
			idc = -1;
			x = 0.246; 
			y = 0.538; 
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
			y = 0.584; 
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
			y = 0.629; 
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
			y = 0.675; 
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
			y = 0.733; 
			w = 0.659; 
			h = 0.112;  
			text = "";	
		};


	};
};
