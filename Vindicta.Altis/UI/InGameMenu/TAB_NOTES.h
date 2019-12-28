//Exported via Arma Dialog Creator (https://github.com/kayler-renslow/arma-dialog-creator)

// This is a group control
class TAB_NOTES : MUI_GROUP_ABS
{
	x = 0;
	y = 0;
	w = 0.7;
	h = 0.9;
	text = "";

	class Controls
	{
		class TAB_NOTES_EDIT : MUI_EDIT
		{
			idc = -1;
			x = 0.00;
			y = 0.00;
			w = 0.7;
			h = 0.9;
			sizeEx = MUI_TXT_SIZE_M_ABS;
			colotBackground[] = {0,0,0,0.5};
			text = "I can write notes here... Use Shift+Enter for a new line";
		};		
	};
	
};
