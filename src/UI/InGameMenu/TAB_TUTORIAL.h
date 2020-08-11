class TAB_TUTORIAL : MUI_GROUP
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
		class TAB_TUT_PICTURE : RscPicture
		{

			IDC = -1;
			x = 0.020; 
			y = 0.036; 
			w = 0.416; 
			h = 0.277;
			text = "\z\vindicta\addons\ui\pictures\tut_image_default.paa";
			style = ST_PICTURE; 

		};

		class TAB_TUT_TEXT : MUI_BG_TRANSPARENT_MULTILINE_CENTER_ABS  
		{

			IDC = -1;
			x = 0.020; 
			y = 0.402; 
			w = 0.659; 
			h = 0.471;  
			colorBackground[] = MUIC_TRANSPARENT;
			font = "RobotoCondensedLight";
			sizeEx = 0.036;
			style = ST_LEFT + 16+0+0x200;
			text = "Int, ullamet ipis dolorat iistore prepre poraerc hicidenda aut ullabor aectam fugit apellatem aut odi tem. Molorumquia cus ad moluptur, et aut liquidem que eiunt fugit utemporrunt atibusdaecta prate dere poribus aut ullesed ut que cus nobis mil ipidi";

		};

		class TAB_TUT_HEADLINE : MUI_BASE_ABS  
		{

			IDC = -1;
			x = 0.020; 
			y = 0.335; 
			w = 0.416; 
			h = 0.040;  
			colorBackground[] = MUIC_TRANSPARENT;
			font = "PuristaSemibold";
			sizeEx = 0.045;
			text = "Headline";
			style = ST_LEFT;

		};

		class TAB_TUT_LISTBOX : MUI_LISTNBOX_ABS 
		{

			IDC = -1; 
			x = 0.439; 
			y = 0.036; 
			w = 0.239; 
			h = 0.277;  
			sizeEx = 0.032;

		};

	};

};

class TAB_TUTORIAL_TEMP : MUI_GROUP_ABS
{
	x = 0;
	y = 0;
	w = 0.7;
	h = 0.9;
	text = "";

	class Controls
	{
		class TAB_TOTORIAL_TEMP_EDIT : MUI_EDIT_ABS
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
			text = "";
			canModify = false;
		};		
	};
	
};