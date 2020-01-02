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
			w = 0.659;
			h = 0.552;
			colorBackground[] = MUIC_TRANSPARENT;
			text = "INSERT IMAGE PATH HERE";

		};

		class TAB_TUT_TEXT : MUI_BG_TRANSPARENT_MULTILINE_CENTER_ABS  
		{

			IDC = -1;
			x = 0.020;
			y = 0.661;
			w = 0.659;
			h = 0.158; 
			colorBackground[] = MUIC_TRANSPARENT;
			font = "RobotoCondensedLight";
			sizeEx = 0.036;
			text = "Int, ullamet ipis dolorat iistore prepre poraerc hicidenda aut ullabor aectam fugit apellatem aut odi tem. Molorumquia cus ad moluptur, et aut liquidem que eiunt fugit utemporrunt atibusdaecta prate dere poribus aut ullesed ut que cus nobis mil ipidi";

		};

		class TAB_TUT_HEADLINE : MUI_BASE_ABS  
		{

			IDC = -1;
			x = 0.020;
			y = 0.621;
			w = 0.659;
			h = 0.040;
			colorBackground[] = MUIC_TRANSPARENT;
			font = "PuristaSemibold";
			sizeEx = MUI_TXT_SIZE_M_ABS;
			text = "Headline";
			style = ST_LEFT;

		};

		class TAB_TUT_BUTTON_NEXT : MUI_BUTTON_TXT_ABS 
		{

			IDC = -1;
			x = 0.527;
			y = 0.838;
			w = 0.151;
			h = 0.044;
			text = "NEXT";

		};

		class TAB_TUT_BUTTON_PREV : MUI_BUTTON_TXT_ABS  
		{

			IDC = -1;
			x = 0.020;
			y = 0.838;
			w = 0.151;
			h = 0.044;
			text = "PREVIOUS";

		};

	};

};
