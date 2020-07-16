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
		class TAB_NOTES_EDIT : MUI_EDIT_ABS
		{
			idc = -1;
			x = 0.020; 
			y = 0.028; 
			w = 0.659; 
			h = 0.839;
			sizeEx = MUI_TXT_SIZE_M_ABS;
			colorBackground[] = MUIC_TRANSPARENT;
			colorText[] = MUIC_WHITE;
			font = "EtelkaMonospacePro";
			text = "You can write notes here. Radio cryptokeys will also be added here.";
		};		
	};
	
};
