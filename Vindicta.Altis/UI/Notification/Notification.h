#include "..\Resources\UIProfileColors.h"
#define __WIDTH 0.5

class NOTIFICATION_GROUP : MUI_GROUP_ABS
{
	idc = -1;
	x = 0;
	y = 0;
	w = __WIDTH + 0.005;
	h = 0.175;
	style = 0;
	text = "";
	colorText[] = {0.5412,0.5255,0.051,1};
	font = "RobotoCondensed";
	sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);

	class Controls
	{

		class NOTIFICATION_ICON
		{
			type = 0;
			idc = -1;
			x = 0; 
			y = 0; 
			w = 0.026; 
			h = 0.035;
			style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
			text = "\A3\ui_f\data\GUI\Rsc\RscDisplayMain\notification_ca.paa";
			colorBackground[] = {0, 0, 0, 0};
			colorText[] = {1, 1, 1, 1};
			font = "RobotoCondensed";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			onLoad = "uiNamespace setVariable ['vin_not_icon', _this#0]";
		};
		class NOTIFICATION_CATEGORY : MUI_HEADLINE_ABS
		{
			type = 0;
			idc = -1;
			x = 0.029; 
			y = 0; 
			w = 0.407; 
			h = 0.035;  

			colorBackground[] = MUIC_MISSION;

			style = 0;
			text = "INTEL";
			sizeEx = 0.035;
			onLoad = "uiNamespace setVariable ['vin_not_category', _this#0]"; // Dont delete this!
		};
		class NOTIFICATION_TEXT : MUI_BASE_ABS
		{
			type = 0;
			idc = -1;
			x = 0; 
			y = 0.041; 
			w = 0.436; 
			h = 0.081;  

			colorBackground[] = {0, 0, 0, 0.65};

			style = 0+16+512;
			text = "Enemy radio cryptokey was found!";
			font = "RobotoCondensed";
			sizeEx = 0.035;
			lineSpacing = 1;
			onLoad = "uiNamespace setVariable ['vin_not_text', _this#0]";  // Dont delete this!
		};
		class NOTIFICATION_HINT : MUI_BASE_ABS
		{
			type = 0;
			idc = -1;
			x = 0; 
			y = 0.123; 
			w = 0.436; 
			h = 0.035; 

			colorBackground[] = {0, 0, 0, 1};

			style = 0+2;
			text = "Cryptokeys are stored in your notes tab";
			colorText[] = {1,1,1,1};
			font = "RobotoCondensed";
			sizeEx = 0.035;
			onLoad = "uiNamespace setVariable ['vin_not_hint', _this#0]";  // Dont delete this!
		};
		
	};
	
};
