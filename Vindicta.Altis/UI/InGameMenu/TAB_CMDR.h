//Exported via Arma Dialog Creator (https://github.com/kayler-renslow/arma-dialog-creator)


// This is a group control
class TAB_CMDR : MUI_GROUP_ABS
{
	x = 0;
	y = 0;
	w = 0.7;
	h = 0.9;
	text = "";

	class TAB_CMDR_BUTTON : MUI_BUTTON_TXT_ABS 
	{
		type = 1;
		idc = -1;
		font = "PuristaMedium";
		colorText[] = MUIC_BLACK;
		colorBackground[] = MUIC_MISSION;
		colorBackgroundActive[] = MUIC_WHITE;
		colorBackgroundDisabled[] = MUIC_TXT_DISABLED;
		colorBorder[] = MUIC_TRANSPARENT;
		colorDisabled[] = MUIC_WHITE;
		colorFocused[] = MUIC_MISSION; // same as colorBackground to disable blinking
		colorShadow[] = MUIC_TRANSPARENT;
	};

	class Controls
	{
		class TAB_CMDR_STATIC_CREATE_A_LOCATION : MUI_BASE_ABS 
		{
			idc = -1;
			x = 0.020;
			y = 0.030;
			w = 0.659;
			h = 0.038;
			text = "CREATE A LOCATION";
			//colorBackground[] = {0.2, 0.8, 0.2, 0.6};
			style = 0;
			font = "PuristaBold";
		};

		class TAB_CMDR_COMBO_LOC_TYPE : MUI_COMBOBOX_ABS
		{
			idc = -1;
			x = 0.183;
			y = 0.124;
			w = 0.305;
			h = 0.038;
			maxHistoryDelay = 0;
		};

		class TAB_CMDR_EDIT_LOC_NAME : MUI_EDIT_ABS 
		{
			idc = -1;
			x = 0.183; 
			y = 0.080; 
			w = 0.305; 
			h = 0.038; 
			style = 0;
			text = "location name here";
			autocomplete = "";
		};

		class TAB_CMDR_STATIC_0 : MUI_DESCRIPTION_ABS
		{
			type = 0;
			idc = -1;
			x = 0.020;
			y = 0.080;
			w = 0.141;
			h = 0.038;
			text = "NAME";
		};

		class TAB_CMDR_STATIC_1 : MUI_DESCRIPTION_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.020;
			y = 0.124;
			w = 0.141;
			h = 0.038;
			text = "TYPE";
		};

		class TAB_CMDR_BUTTON_CREATE_LOC : TAB_CMDR_BUTTON 
		{
			x = 0.5;
			y = 0.080;
			w = 0.179;
			h = 0.126;
			text = "CREATE";
		};

		class TAB_CMDR_STATIC_2 : MUI_DESCRIPTION_ABS
		{
			type = 0;
			idc = -1;
			x = 0.020;
			y = 0.168;
			w = 0.141;
			h = 0.038;
			text = "COST";
		};

		class TAB_CMDR_STATIC_BUILD_RESOURCES : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.183;
			y = 0.168;
			w = 0.305;
			h = 0.038;
			style = ST_LEFT;
			font = "RobotoCondensed";
			text = "666 build resources";
		};

		class TAB_CMDR_STATIC_HELP : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS
		{
			type = 0;
			idc = -1;
			x = 0.020;
			y = 0.245;
			w = 0.468;
			h = 0.080;
			style = 16+0+0x200; // multi line, no rect
			text = "Build resources must be in your backpack or in the vehicle you are looking at.";
			lineSpacing = 1;	
		};

		class TAB_CMDR_SKIP_TIME_LABEL : MUI_DESCRIPTION_ABS
		{
			type = 0;
			idc = -1;
			x = 0.020;
			y = 0.335;
			w = 0.141;
			h = 0.038;
			text = "SKIP TIME";
		};

		class TAB_CMDR_BUTTON_SKIP_TO_DUSK : TAB_CMDR_BUTTON 
		{
			x = 0.183;
			y = 0.335;
			w = 0.146;
			h = 0.038;
			text = "Dusk";
		};

		class TAB_CMDR_BUTTON_SKIP_TO_PREDAWN : TAB_CMDR_BUTTON 
		{
			x = 0.183 + (0.156 * 1);
			y = 0.335;
			w = 0.146;
			h = 0.038;
			text = "Predawn";
		};

		class TAB_CMDR_BUTTON_SKIP_TO_DAWN : TAB_CMDR_BUTTON 
		{
			x = 0.183 + (0.156 * 2);
			y = 0.335;
			w = 0.146;
			h = 0.038;
			text = "Dawn";
		};
	};
};
