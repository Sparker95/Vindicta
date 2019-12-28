#include "..\Resources\UIProfileColors.h"

class LoadingScreenGroup : MUI_GROUP
{

	x = safeZoneX + safeZoneW * 0;
	y = safeZoneY + safeZoneH * 0;
	w = safeZoneW + 0.1;
	h = safeZoneH + 0.1;

	type = 15; // group

	class ControlsBackground {};

	class Controls {

		class LS_Screenshot : RSCPICTURE {

			IDC = -1; 
			x = safeZoneW * 0; 
			y = safeZoneH * 0; 
			w = safeZoneW * 1; 
			h = safeZoneH * 1; 
			style = ST_PICTURE + ST_KEEP_ASPECT_RATIO; 
			text = "UI\Images\Screenshot.paa"; 

		};

		class LS_Logo : RSCPICTURE {

			IDC = -1; 
			x = safeZoneW * 0.792; 
			y = safeZoneH * 0.835; 
			w = safeZoneW * 0.204; 
			h = safeZoneH * 0.090; 
			style = ST_PICTURE + ST_KEEP_ASPECT_RATIO; 
			text = "UI\Images\VindictaLogo.paa"; 
			colorText[] = MUIC_MISSION;
		};


		class LS_Authors : MUI_BASE {

			IDC = 64599; 
			x = safeZoneW * 0.014; 
			y = safeZoneH * 0.893; 
			w = safeZoneW * 0.485; 
			h = safeZoneH * 0.032; 
			text = "A guerilla warfare mission"; 
			style = 0;
			colorBackground[] = MUIC_TRANSPARENT;
			colorText[] = MUIC_WHITE;
			font = "PuristaMedium";
			sizeEx = safezoneH * 0.03;
		};
	};
};
