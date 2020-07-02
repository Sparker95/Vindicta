#include "..\Resources\UIProfileColors.h"

class RadioKeyTab : MUI_GROUP_ABS
{

	x = 0;
	y = 0;
	w = 0.7;
	h = 1;
	text = "";

	class Controls
	{
		class EDIT_ENTER_KEY : MUI_EDIT_ABS
		{
			idc = -1;
			x = 0.02;
			y = 0.94;
			w = 0.5;
			h = 0.04;
			//style = 0;
			text = "";
			colorBackground[] = MUIC_BLACKTRANSP;
			sizeEx = 0.04;			
		};
		class STATIC_KEYS : MUI_BASE_ABS
		{
			x = 0.02;
			y = 0.07000008;
			w = 0.66;
			h = 0.81;
			colorBackground[] = MUIC_BLACKTRANSP;
			style = 0 + 16 + 0x200; // Multi line
			lineSpacing = 1;
			text = "";
			font = "EtelkaMonospacePro"; // Monospace font
			sizeEx = 0.75*MUI_TXT_SIZE_M_ABS; // Why is this font bigger than others? Wtf
		};
		class BUTTON_ADD_KEY : MUI_BUTTON_TXT_ABS
		{
			x = 0.54;
			y = 0.94000002;
			w = 0.14000003;
			h = 0.04;
			text = "Add key";			
		};
		class Control919808632 : MUI_BASE_ABS
		{
			x = 0.0250001;
			y = 0.01500006;
			w = 0.65;
			h = 0.05000004;
			style = 0;
			text = "Added enemy cryptokeys:";
			sizeEx = 0.04;			
		};
		class Control919808632_copy1 : MUI_BASE_ABS
		{
			x = 0.02;
			y = 0.9;
			w = 0.5;
			h = 0.04;
			style = 0;
			text = "Enter cryptokey:";		
		};
		
	};
	
};
