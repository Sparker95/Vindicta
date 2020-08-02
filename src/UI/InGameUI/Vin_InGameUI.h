#include "InGameUI_Macros.h"
#include "..\Resources\UIProfileColors.h"

#define TEXTSIZE_MED safeZoneH*0.018
#define TEXTSIZE_SMALL safeZoneH*0.014

#define __ROW_H 0.025

class Vin_InGameUI
{
	idd = -1;
	name = "Vin_InGameUI";
	onLoad = "uiNamespace setVariable ['p0_InGameUI_display', _this select 0]";
	onUnload = "uiNamespace setVariable ['p0_InGameUI_display', displayNull]";
	movingEnable = false;
	enableSimulation = true;
	duration = 10000000;

	class Controls
	{
		class VIN_ResourceText : MUI_BASE
		{
			IDC = IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES; 
			x = safeZoneX + safeZoneW * 0.659; 
			y = safeZoneY + safeZoneH * 0.023; 
			w = safeZoneW * 0.094; 
			h = safeZoneH * 0.020;  
			text = "9 999 999 999"; 
			font = "PuristaMedium";
			sizeEx = TEXTSIZE_MED;
			style = ST_LEFT;
			shadow = 1;
			colorText[] = MUIC_WHITE;
		};

		class VIN_LocationText : MUI_BASE
		{
			IDC = IDC_INGAME_STATIC_LOCATION_NAME; 
			x = safeZoneX + safeZoneW * 0.221; 
			y = safeZoneY + safeZoneH * 0.023; 
			w = safeZoneW * 0.149; 
			h = safeZoneH * 0.020;    
			text = "UI Not Initialized"; 
			font = "PuristaMedium";
			sizeEx = TEXTSIZE_MED;
			style = ST_LEFT;
			shadow = 1;
			colorText[] = MUIC_WHITE;
		};

		class VIN_UndercoverBar
		{

			type = 8;
			IDC = IDC_U_SUSPICION_STATUSBAR; 
			x = safeZoneX + safeZoneW * 0.432; 
			y = safeZoneY + safeZoneH * 0.018; 
			w = safeZoneW * 0.134; 
			h = safeZoneH * 0.002; 
			style = 0;
			colorBar[] = {1,1,1,1};
			colorFrame[] = {0.2,0.2,0.2,0.2};
			texture = "#(argb,8,8,3)color(1,1,1,1)";
			access = 0;
		};

		class VIN_UndercoverHint : MUI_BASE 
		{
			IDC = IDC_U_SUSPICION_TEXT; 
			x = safeZoneX + safeZoneW * 0.378; 
			y = safeZoneY + safeZoneH * 0.023; 
			w = safeZoneW * 0.242; 
			h = safeZoneH * 0.020;  
			text = "UNDERCOVER"; 
			font = "PuristaSemibold";
			sizeEx = TEXTSIZE_MED;
			style = ST_CENTER;
			shadow = 1;
			colorText[] = MUIC_WHITE;
		};

		class VIN_ResourceDescr : MUI_BASE
		{
			IDC = IDC_INGAME_STATIC_CONSTRUCTION_RESOURCES_DESCR; 
			x = safeZoneX + safeZoneW * 0.659; 
			y = safeZoneY + safeZoneH * 0.011; 
			w = safeZoneW * 0.094; 
			h = safeZoneH * 0.012;  
			text = "CONSTRUCTION RESOURCES";
			sizeEx = TEXTSIZE_SMALL;
			font = "PuristaSemibold"; 
			style = ST_LEFT;
			shadow = 1;
			colorText[] = MUIC_WHITE;
		};

		class VIN_LocationDescr : MUI_BASE
		{
			IDC = IDC_INGAME_STATIC_LOCATION_NAME_DESCR; 
			x = safeZoneX + safeZoneW * 0.221; 
			y = safeZoneY + safeZoneH * 0.011; 
			w = safeZoneW * 0.149; 
			h = safeZoneH * 0.012; 
			text = "LOCATION"; 
			sizeEx = TEXTSIZE_SMALL;
			font = "PuristaSemibold";
			style = ST_LEFT;
			shadow = 1;
			colorText[] = MUIC_WHITE;
		};
			
	};
	
};
