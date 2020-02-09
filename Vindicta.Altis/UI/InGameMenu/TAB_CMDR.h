//Exported via Arma Dialog Creator (https://github.com/kayler-renslow/arma-dialog-creator)

// This is a group control
class TAB_CMDR : MUI_GROUP_ABS
{
	x = 0;
	y = 0;
	w = 0.7;
	h = 0.9;
	text = "";

	class Controls
	{

		class TAB_CMDR_STATIC_CREATE_A_LOCATION : MUI_BASE_ABS 
		{
			idc = -1;
			x = 0.01000001;
			y = 0.01000014;
			w = 0.34055589;
			h = 0.04;
			text = "CREATE A LOCATION";
			//colorBackground[] = {0.2, 0.8, 0.2, 0.6};
			style = 0;
			font = "PuristaBold";
		};

		class TAB_CMDR_COMBO_LOC_TYPE : MUI_COMBOBOX_ABS
		{
			x = 0.09000001;
			y = 0.11000001;
			w = 0.41000004;
			h = 0.04;
			maxHistoryDelay = 0;	
		};
		class TAB_CMDR_EDIT_LOC_NAME : MUI_EDIT_ABS 
		{
			idc = -1;
			x = 0.09000001;
			y = 0.06000002;
			w = 0.41000007;
			h = 0.04;
			style = 0;
			text = "Noname";
			autocomplete = "";			
		};
		class TAB_CMDR_STATIC_0 : MUI_BASE_ABS
		{
			type = 0;
			idc = -1;
			x = 0.01;
			y = 0.06000001;
			w = 0.07000006;
			h = 0.04;
			style = ST_RIGHT;
			text = "NAME:";
		};
		class TAB_CMDR_STATIC_1 : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.01;
			y = 0.11000004;
			w = 0.07;
			h = 0.04;
			style = ST_RIGHT;
			text = "TYPE:";		
		};
		class TAB_CMDR_BUTTON_CREATE_LOC : MUI_BUTTON_TXT_ABS 
		{
			type = 1;
			idc = -1;
			x = 0.54000028;
			y = 0.09000019;
			w = 0.13000001;
			h = 0.09000002;
			text = "CREATE";			
		};
		class TAB_CMDR_STATIC_2 : MUI_BASE_ABS
		{
			type = 0;
			idc = -1;
			x = 0.01;
			y = 0.16000005;
			w = 0.07;
			h = 0.04;
			text = "COST:";	
			style = ST_RIGHT;	
		};
		class TAB_CMDR_STATIC_BUILD_RESOURCES : MUI_BASE_ABS 
		{
			type = 0;
			idc = -1;
			x = 0.09000001;
			y = 0.16000005;
			w = 0.41000007;
			h = 0.04;
			style = ST_LEFT; 
			text = "666 build resources";			
		};

		class TAB_CMDR_STATIC_HELP : MUI_BG_TRANSPARENT_MULTILINE_LEFT_ABS
		{
			type = 0;
			idc = -1;
			x = 0.01;
			y = 0.21000008;
			w = 0.68000039;
			h = 0.08;
			colorText[] = MUIC_BTN_RED;
			style = 16+0+0x200; // multi line, no rect
			text = "Build resources must be in your backpack or in the vehicle you are looking at.";
			lineSpacing = 1;	
		};
	};
	
};
