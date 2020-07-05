//#include "..\Resources\UIBase.hpp"
#include "..\Resources\UIProfileColors.h"

class LoadingScreenGroup : MUI_GROUP
{
	x = safeZoneX + safeZoneW * 0;
	y = safeZoneY + safeZoneH * 0;
	w = safeZoneW + 0.1;
	h = safeZoneH + 0.1;

	type = 15; // group

	class ControlsBackground {
	};

	class Controls {
		class LS_Background : MUI_BASE {
			IDC = -1;
			x = safeZoneW * 0;
			y = safeZoneH * 0;
			w = safeZoneW * 1;
			h = safeZoneH * 1;
			colorBackground[] = MUIC_BLACK;
		};

		class LS_Screenshot : RSCPICTURE {
			IDC = -1;
			x = safeZoneW * 0;
			y = safeZoneH * 0;
			w = safeZoneW * 1;
			h = safeZoneH * 1;
			style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
			text = "\z\vindicta\addons\ui\Pictures\Screenshot.paa";
		};

		class LS_Topbar : MUI_BASE {
			IDC = -1;
			x = safeZoneW * 0;
			y = safeZoneH * 0;
			w = safeZoneW * 1;
			h = safeZoneH * 0.15;
			colorBackground[] = MUIC_BLACK;
		};

		class LS_TitleText : MUI_BASE {
			IDC = 666;
			x = safeZoneW * 0;
			y = safeZoneH * 0;
			w = safeZoneW * 1;
			h = safeZoneH * 0.09;
			text = "";
			//style = ST_LEFT + ST_VCENTER;
			colorBackground[] = MUIC_TRANSPARENT;
			colorText[] = MUIC_WHITE;
			font = "PuristaMedium";
			sizeEx = safezoneH * 0.07;
		};

		class LS_SubtitleText : MUI_BASE {
			IDC = 667;
			x = safeZoneW * 0;
			y = safeZoneH * 0.09;
			w = safeZoneW * 1;
			h = safeZoneH * 0.04;
			text = "";
			//style = ST_LEFT + ST_VCENTER;
			colorBackground[] = MUIC_TRANSPARENT;
			colorText[] = MUIC_WHITE;
			font = "PuristaMedium";
			sizeEx = safezoneH * 0.03;
		};

		class LS_ProgressbarLoading : MUI_PROGRESSBAR {
			IDC = 103;
			x = safeZoneW * 0;
			y = safeZoneH * 0.135;
			w = safeZoneW * 1;
			h = safeZoneH * 0.005;
			colorFrame[] = MUIC_TRANSPARENT;
		};

		class LS_ProgressbarLoading2 : MUI_PROGRESSBAR {
			IDC = 668;
			x = safeZoneW * 0;
			y = safeZoneH * 0.140;
			w = safeZoneW * 1;
			h = safeZoneH * 0.005;
			colorFrame[] = MUIC_TRANSPARENT;
			colorBar[] = MUIC_LOGO;
		};

		class LS_ProgressbarOther : MUI_PROGRESSBAR {
			IDC = 104;
			x = safeZoneW * 0;
			y = safeZoneH * 0.145;
			w = safeZoneW * 1;
			h = safeZoneH * 0.005;
			colorFrame[] = MUIC_TRANSPARENT;
		};

		class LS_Bottombar : MUI_BASE {
			IDC = -1;
			x = safeZoneW * 0;
			y = safeZoneH * 0.85;
			w = safeZoneW * 1;
			h = safeZoneH * 0.15;
			colorBackground[] = MUIC_BLACK;
		};

		class LS_Logo : RSCPICTURE {
			IDC = -1;
			x = safeZoneW * 0.72;
			y = safeZoneH * 0.86;
			w = safeZoneW * 0.26;
			h = safeZoneH * 0.10;
			style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
			text = "\z\vindicta\addons\ui\Pictures\VindictaLogo.paa";
			colorText[] = MUIC_LOGO;
		};

		class LS_Version : MUI_BASE {
			IDC = 64599;
			x = safeZoneW * 0.72;
			y = safeZoneH * 0.96;
			w = safeZoneW * 0.26;
			h = safeZoneH * 0.02;
			text = "v0.0.0";
			style = ST_RIGHT;// + ST_VCENTER;
			colorBackground[] = MUIC_TRANSPARENT;
			colorText[] = MUIC_WHITE;
			font = "PuristaMedium";
			sizeEx = safezoneH * 0.02;
		};
	};
};
