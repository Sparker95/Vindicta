#include "..\Resources\UIProfileColors.h"
#include "..\..\commonPath.hpp"
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
		class NOTIFICATION_BG : MUI_BASE {

			IDC = -1; 
			x = 0; 
			y = 0; 
			w = 0.427; 
			h = 0.158; 
			//text = "UI\Images\gradient_LtoR.paa";

			//colorText[] = {0, 0, 0, 0.9};
			colorBackground[] = {0, 0, 0, 0.6};

		};

		class NOTIFICATION_CATEGORYBG : RscPicture {

			IDC = -1; 
			x = 0; 
			y = 0; 
			w = 0.427; 
			h = 0.035; 
			text = QUOTE_COMMON_PATH(UI\Images\gradient_LtoR.paa);

			colorText[] = MUIC_MISSION;
			// colorBackground[] = MUIC_MISSION;
			onLoad = "uiNamespace setVariable ['vin_not_categorybg', _this#0]";
		};

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
			font = "RobotoCondensedLight";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			onLoad = "uiNamespace setVariable ['vin_not_icon', _this#0]";
		};

		class NOTIFICATION_CATEGORY : MUI_HEADLINE_ABS
		{
			type = 0;
			idc = -1;
			x = 0.029; 
			y = 0; 
			w = 0.397;
			h = 0.035;  

			colorText[] = MUIC_BLACK;
			colorBackground[] = {0, 0, 0, 0};

			style = 0;
			text = $STR_INT_INTEL;
			font = "PuristaSemibold";
			sizeEx = 0.035;
			onLoad = "uiNamespace setVariable ['vin_not_category', _this#0]"; // Dont delete this!
		};

		class NOTIFICATION_TEXT : MUI_BASE_ABS
		{
			type = 0;
			idc = -1;
			x = 0; 
			y = 0.041; 
			w = 0.41;  
			h = 0.081;  

			colorBackground[] = {0, 0, 0, 0};

			style = 0+16+512;
			text = $STR_NOTI_CRYPTOKEY_FOUND;
			font = "RobotoCondensedLight";
			sizeEx = 0.035;
			lineSpacing = 1;
			onLoad = "uiNamespace setVariable ['vin_not_text', _this#0]";  // Dont delete this!
		};


		class NOTIFICATION_HINTBG : RscPicture {

			IDC = -1; 
			x = 0; 
			y = 0.123; 
			w = 0.427; 
			h = 0.035; 
			text = QUOTE_COMMON_PATH(UI\Images\gradient_LtoR.paa);

			colorText[] = {0, 0, 0, 0.6};
			//colorBackground[] = MUIC_BLACKTRANSP;
			onLoad = "uiNamespace setVariable ['vin_not_hintbg', _this#0]";  // Dont delete this!
		};

		class NOTIFICATION_HINT : MUI_BASE_ABS
		{
			type = 0;
			idc = -1;
			x = 0; 
			y = 0.123; 
			w = 0.427; 
			h = 0.035; 

			colorBackground[] = {0, 0, 0, 0};

			style = ST_LEFT;
			text = $STR_NOTI_CRYPTOKEY_STORED;
			colorText[] = {1,1,1,1};
			font = "RobotoCondensedLight";
			sizeEx = 0.035;
			onLoad = "uiNamespace setVariable ['vin_not_hint', _this#0]";  // Dont delete this!
		};
	};
};
