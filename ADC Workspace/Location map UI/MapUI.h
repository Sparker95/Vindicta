//Exported via Arma Dialog Creator (https://github.com/kayler-renslow/arma-dialog-creator)

#include "MapUI_Macros.h"

#include "CustomControlClasses.h"
class MapUI
{
	idd = IDD_MAP_UI;
	
	class ControlsBackground
	{
		
	};
	class Controls
	{
		class LocationData_Panel : Map_UI_panel 
		{
			type = 0;
			idc = IDD_LD_PANEL;
			x = safeZoneX + safeZoneW * 0.73;
			y = safeZoneY + safeZoneH * 0.45;
			w = safeZoneW * 0.26;
			h = safeZoneH * 0.54;
			style = 0;
			text = "";
			onMouseEnter = "diag_log 'on mouse enter!'";
			onMouseExit = "diag_log 'on mouse exit!'";
			
		};
		class LocationData_type : Map_UI_text_base 
		{
			type = 0;
			idc = IDC_LD_TYPE;
			x = safeZoneX + safeZoneW * 0.74;
			y = safeZoneY + safeZoneH * 0.5;
			w = safeZoneW * 0.23;
			h = safeZoneH * 0.04;
			text = "Type: ...";
			
		};
		class LocationData_time : Map_UI_text_base 
		{
			type = 0;
			idc = IDC_LD_TIME;
			x = safeZoneX + safeZoneW * 0.74;
			y = safeZoneY + safeZoneH * 0.58;
			w = safeZoneW * 0.23;
			h = safeZoneH * 0.04;
			text = "Last updated: ...";
			
		};
		class LocationData_composition : Map_UI_text_base 
		{
			type = 0;
			idc = IDC_LD_COMPOSITION;
			x = safeZoneX + safeZoneW * 0.74;
			y = safeZoneY + safeZoneH * 0.62;
			w = safeZoneW * 0.24;
			h = safeZoneH * 0.36;
			text = "Composition: ...";
			
		};
		class LocationData_side : Map_UI_text_base 
		{
			type = 0;
			idc = IDC_LD_SIDE;
			x = safeZoneX + safeZoneW * 0.74;
			y = safeZoneY + safeZoneH * 0.54;
			w = safeZoneW * 0.23;
			h = safeZoneH * 0.04;
			text = "Side: ...";
			
		};
		class LocationData_header : Map_UI_text_base 
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.74;
			y = safeZoneY + safeZoneH * 0.46;
			w = safeZoneW * 0.24;
			h = safeZoneH * 0.03;
			style = 2;
			text = "Location data";
			
		};
		class LocationData_button : Map_UI_button 
		{
			type = 1;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.86;
			y = safeZoneY + safeZoneH * 0.5;
			w = safeZoneW * 0.12;
			h = safeZoneH * 0.04;
			text = "Push me";
			onButtonClick = "diag_log 'buttonClick'";
			onMouseEnter = "diag_log 'Mouse enter!'";
			onMouseExit = "diag_log 'Mouse exit!'";
			
		};
		
	};
	
};
