#include "BuildUI_Macros.h"
#include "..\Resources\UIProfileColors.h"

#define TEXT_SIZE_CAT		safeZoneH * 0.025
#define TEXT_SIZE_ITEM		safeZoneH * 0.017
#define TEXT_SIZE_TOOLTIP	safeZoneH * 0.02


class BuildUI
{

	name = "BuildUI";
	IDD = 3981;
	onLoad = "uiNamespace setVariable ['buildUI_display', _this select 0]";
	onUnload = "uiNamespace setVariable ['buildUI_display', displayNull]";
	enableSimulation = true;
	duration = 10000000;

	class ControlsBackground {};

	class Controls {

		class CATEGORY_BG : RSCPICTURE {

			IDC = IDC_CTEXTBG; 
			x = safeZoneX + safeZoneW * 0.293; 
			y = safeZoneY + safeZoneH * 0.744; 
			w = safeZoneW * 0.412; 
			h = safeZoneH * 0.030; 
			text = "UI\Images\gradient_2way.paa"; 
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1); 
			colorText[] = MUIC_BLACK; 
			colorBackground[] = MUIC_BLACK; 

		};

		class TOOLTIP_BG : RSCPICTURE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.293; 
			y = safeZoneY + safeZoneH * 0.779; 
			w = safeZoneW * 0.412; 
			h = safeZoneH * 0.056; 
			text = "UI\Images\gradient_2way.paa"; 
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1); 
			colorText[] = MUIC_MISSION; 
			colorBackground[] = MUIC_MISSION; 

		};

		class CATEGORYTEXT_CENTER : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.457; 
			y = safeZoneY + safeZoneH * 0.747; 
			w = safeZoneW * 0.084; 
			h = safeZoneH * 0.024; 
			style = ST_CENTER; 
			text = "CATEGORY 1"; 
			sizeEx = TEXT_SIZE_CAT; 
			font = "PuristaMedium";
			colorText[] = MUIC_WHITE; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class ITEMCAT_BG : RSCPICTURE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.293; 
			y = safeZoneY + safeZoneH * 0.721; 
			w = safeZoneW * 0.412; 
			h = safeZoneH * 0.018; 
			text = "UI\Images\gradient_2way.paa"; 
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1); 
			colorText[] = {0,0,0,0.6}; 
			colorBackground[] = MUIC_BLACK; 

		};

		class TOOLTIP1 : MUI_STRUCT_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.382; 
			y = safeZoneY + safeZoneH * 0.786; 
			w = safeZoneW * 0.117; 
			h = safeZoneH * 0.042; 
			style = ST_CENTER; 
			text = "TAB: OPEN BUILD MENU"; 
			font = "RobotoCondensed";
			colorText[] = MUIC_BLACK; 
			colorBackground[] = MUIC_TRANSPARENT; 
			size = TEXT_SIZE_TOOLTIP;
		};

		class TOOLTIP2 : MUI_STRUCT_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.506; 
			y = safeZoneY + safeZoneH * 0.786; 
			w = safeZoneW * 0.111; 
			h = safeZoneH * 0.042; 
			style = ST_CENTER; 
			text = "TAB: OPEN BUILD MENU"; 
			font = "RobotoCondensed";
			colorText[] = MUIC_BLACK; 
			colorBackground[] = MUIC_TRANSPARENT; 
			size = TEXT_SIZE_TOOLTIP;
		};

		class CATEGORYTEXT_L1 : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.353; 
			y = safeZoneY + safeZoneH * 0.747; 
			w = safeZoneW * 0.084; 
			h = safeZoneH * 0.024; 
			style = ST_CENTER; 
			text = "CATEGORY 1"; 
			sizeEx = TEXT_SIZE_CAT; 
			font = "PuristaMedium";
			colorText[] = {1,1,1,0.5}; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class CATEGORYTEXT_L2 : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.251; 
			y = safeZoneY + safeZoneH * 0.747; 
			w = safeZoneW * 0.084; 
			h = safeZoneH * 0.024; 
			style = ST_CENTER; 
			text = "CATEGORY 1"; 
			sizeEx = TEXT_SIZE_CAT; 
			font = "PuristaMedium";
			colorText[] = {1,1,1,0.3}; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class CATEGORYTEXT_R1 : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.561; 
			y = safeZoneY + safeZoneH * 0.747; 
			w = safeZoneW * 0.084; 
			h = safeZoneH * 0.024; 
			style = ST_CENTER; 
			text = "CATEGORY 1"; 
			sizeEx = TEXT_SIZE_CAT; 
			font = "PuristaMedium";
			colorText[] = {1,1,1,0.5}; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class CATEGORYTEXT_R2 : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.663; 
			y = safeZoneY + safeZoneH * 0.747; 
			w = safeZoneW * 0.084; 
			h = safeZoneH * 0.024; 
			style = ST_CENTER; 
			text = "CATEGORY 1"; 
			sizeEx = TEXT_SIZE_CAT; 
			font = "PuristaMedium";
			colorText[] = {1,1,1,0.3}; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class ITEMTEXT_CENTER : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.430; 
			y = safeZoneY + safeZoneH * 0.720; 
			w = safeZoneW * 0.138; 
			h = safeZoneH * 0.018; 
			style = ST_CENTER; 
			text = "item category"; 
			sizeEx = TEXT_SIZE_ITEM; 
			font = "PuristaLight";
			colorText[] = MUIC_WHITE; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class ITEMTEXT_L1 : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.284; 
			y = safeZoneY + safeZoneH * 0.720; 
			w = safeZoneW * 0.138; 
			h = safeZoneH * 0.018; 
			style = ST_CENTER; 
			text = "item category"; 
			sizeEx = TEXT_SIZE_ITEM; 
			font = "PuristaLight";
			colorText[] = MUIC_WHITE; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class ITEMTEXT_L2 : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.138; 
			y = safeZoneY + safeZoneH * 0.720; 
			w = safeZoneW * 0.138; 
			h = safeZoneH * 0.018; 
			style = ST_CENTER; 
			text = "item category"; 
			sizeEx = TEXT_SIZE_ITEM; 
			font = "PuristaLight";
			colorText[] = MUIC_WHITE; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class ITEMTEXT_R1 : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.577; 
			y = safeZoneY + safeZoneH * 0.720; 
			w = safeZoneW * 0.138; 
			h = safeZoneH * 0.018; 
			style = ST_CENTER; 
			text = "item category"; 
			sizeEx = TEXT_SIZE_ITEM; 
			font = "PuristaLight";
			colorText[] = MUIC_WHITE; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class ITEMTEXT_R2 : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.723; 
			y = safeZoneY + safeZoneH * 0.720; 
			w = safeZoneW * 0.138; 
			h = safeZoneH * 0.018; 
			style = ST_CENTER; 
			text = "item category"; 
			sizeEx = TEXT_SIZE_ITEM; 
			font = "PuristaLight";
			colorText[] = MUIC_WHITE; 
			colorBackground[] = MUIC_TRANSPARENT; 

		};

		class INFO_COST : MUI_STRUCT_TXT {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.703; 
			y = safeZoneY + safeZoneH * 0.079; 
			w = safeZoneW * 0.109; 
			h = safeZoneH * 0.209; 
			style = ST_CENTER; 
			text = "COST: Mo que nonsequ iscipit molorerovit quodicidebis di officiis derovitem. Ecte erumquia coreici llanisque sit ut aut perionsequos debit aut et qui torest, si nis et illam fugiatur, omnihicitio. Ut am, quatist dolluptas nus es et occabo. Nem ditaepernat qui senecerio comnitatiusa doluptae. "; 
			font = "PuristaMedium";
			colorText[] = MUIC_BLACK; 
			colorBackground[] = {0,0,0,0.85}; 

		};

		class INFO_NAME : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.398; 
			y = safeZoneY + safeZoneH * 0.074; 
			w = safeZoneW * 0.203; 
			h = safeZoneH * 0.024; 
			style = ST_CENTER; 
			text = "OBJECT NAME"; 
			font = "PuristaSemiBold";
			colorText[] = MUIC_BLACK; 
			colorBackground[] = MUIC_MISSION; 

		};

		class INFO_COST_DECOLINE : MUI_BASE {

			IDC = -1; 
			x = safeZoneX + safeZoneW * 0.703; 
			y = safeZoneY + safeZoneH * 0.075; 
			w = safeZoneW * 0.109; 
			h = safeZoneH * 0.003; 
			style = ST_CENTER; 
			text = ""; 
			font = "PuristaLight";
			colorText[] = MUIC_BLACK; 
			colorBackground[] = MUIC_MISSION; 

		};

	};

};
