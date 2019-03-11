#include "BuildUI_Macros.h"

class BuildUI
{
	idd = 3981;
	enableSimulation = true;
	name = "BuildUI";
	onLoad = "uiNamespace setVariable ['buildUI_display', _this select 0]";
	onUnload = "uiNamespace setVariable ['buildUI_display', displayNull]";
	duration = 10000000;
	
	class ControlsBackground
	{
		
	};
	class Controls
	{
		class TooltipBG : RscPicture
		{
			idc = IDC_TTEXTBG;
			x = safeZoneX + safeZoneW * 0.29375;
			y = safeZoneY + safeZoneH * 0.78148149;
			w = safeZoneW * 0.4125;
			h = safeZoneH * 0.05277778;
			text = "UI\Images\gradient_2way.paa";
			colorText[] = {0.82, 0.561, 0.129, 1.0};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};
		class CategoryBG : RscPicture
		{
			idc = IDC_CTEXTBG;
			x = safeZoneX + safeZoneW * 0.29375;
			y = safeZoneY + safeZoneH * 0.74537038;
			w = safeZoneW * 0.4125;
			h = safeZoneH * 0.03055556;
			text = "UI\Images\gradient_2way.paa";
			colorBackground[] = {0.2,0.2,0.2,0.6};
			colorText[] = {0.1, 0.1, 0.1, 1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};
		class ItemCatBG : RscPicture
		{
			idc = IDC_ITEXTBG;
			x = safeZoneX + safeZoneW * 0.29375;
			y = safeZoneY + safeZoneH * 0.7212963;
			w = safeZoneW * 0.4125;
			h = safeZoneH * 0.01851852;
			text = "UI\Images\gradient_2way.paa";
			colorBackground[] = {0,0,0,0.6};
			colorText[] = {0.1, 0.1, 0.1, 1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};
		class CategoryText_Center
		{
			type = 0;
			idc = IDC_TEXTC;
			x = safeZoneX + safeZoneW * 0.46041667;
			y = safeZoneY + safeZoneH * 0.75;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = "Defenses";
			colorBackground[] = {0.5873,0.7698,0.7302,0};
			colorText[] = {1,1,1,1};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_L2
		{
			type = 0;
			idc = IDC_TEXTL2;
			x = safeZoneX + safeZoneW * 0.2953125;
			y = safeZoneY + safeZoneH * 0.75;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = "Shooting Range";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.3};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_L1 
		{
			type = 0;
			idc = IDC_TEXTL1;
			x = safeZoneX + safeZoneW * 0.378125;
			y = safeZoneY + safeZoneH * 0.75;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = "Decoration";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.5};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_R1 
		{
			type = 0;
			idc = IDC_TEXTR1;
			x = safeZoneX + safeZoneW * 0.54270834;
			y = safeZoneY + safeZoneH * 0.75;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = "Shooting Range";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.5};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_R2
		{
			type = 0;
			idc = IDC_TEXTR2;
			x = safeZoneX + safeZoneW * 0.62552084;
			y = safeZoneY + safeZoneH * 0.75;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = "Shooting Range";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.3};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class ItemText_Center
		{
			type = 0;
			idc = IDC_ITEXTC;
			x = safeZoneX + safeZoneW * 0.46041667;
			y = safeZoneY + safeZoneH * 0.723;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.01296297;
			style = 2;
			text = "Defenses";
			colorBackground[] = {0.5873,0.7698,0.7302,0};
			colorText[] = {1,1,1,1};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		class ItemText_R1
		{
			type = 0;
			idc = IDC_ITEXTR1;
			x = safeZoneX + safeZoneW * 0.54270834;
			y = safeZoneY + safeZoneH * 0.723;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.01296297;
			style = 2;
			text = "Shooting Range";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.5};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		class ItemText_L1
		{
			type = 0;
			idc = IDC_ITEXTL1;
			x = safeZoneX + safeZoneW * 0.378125;
			y = safeZoneY + safeZoneH * 0.723;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.01296297;
			style = 2;
			text = "Decoration";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.5};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		class ItemText_R2 
		{
			type = 0;
			idc = IDC_ITEXTR2;
			x = safeZoneX + safeZoneW * 0.62552084;
			y = safeZoneY + safeZoneH * 0.72314815;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.01296297;
			style = 2;
			text = "Shooting Range";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.3};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		class ItemText_L2
		{
			type = 0;
			idc = IDC_ITEXTL2;
			x = safeZoneX + safeZoneW * 0.2953125;
			y = safeZoneY + safeZoneH * 0.723;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.01296297;
			style = 2;
			text = "Shooting Range";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.3};
			font = "RobotoCondensedBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		
	};
	
};
