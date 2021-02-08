#include "BuildUI_Macros.h"
#include "..\..\commonPath.hpp"

#define TEXT_SIZE_CAT		safeZoneH * 0.025
#define TEXT_SIZE_ITEM		safeZoneH * 0.017
#define TEXT_SIZE_TOOLTIP	safeZoneH * 0.02

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
			h = safeZoneH * 0.05370371;
			text = QUOTE_COMMON_PATH(UI\Images\gradient_2way.paa);
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
			text = QUOTE_COMMON_PATH(UI\Images\gradient_2way.paa);
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
			text = QUOTE_COMMON_PATH(UI\Images\gradient_2way.paa);
			colorBackground[] = {0,0,0,0.6};
			colorText[] = {0.1, 0.1, 0.1, 1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};
		class Tooltip1
		{
			type = 13;
			idc = IDC_TOOLTIP1;
			x = safeZoneX + safeZoneW * 0.30989584;
			y = safeZoneY + safeZoneH * 0.78611112;
			w = safeZoneW * 0.38020834;
			h = safeZoneH * 0.0175926;
			style = 2;
			text = $STR_BUI_TAB_TOOLTIP;
			colorBackground[] = {0,0,0,0};
			colorText[] = MUIC_BLACK;
			font = "RobotoCondensed";
			size = TEXT_SIZE_TOOLTIP;
			shadow = 1;
		};
		class Tooltip2
		{
			type = 13;
			idc = IDC_TOOLTIP2;
			x = safeZoneX + safeZoneW * 0.30989584;
			y = safeZoneY + safeZoneH * 0.80925926;
			w = safeZoneW * 0.38020834;
			h = safeZoneH * 0.0175926;
			style = 2;
			text = $STR_BUI_TAB_TOOLTIP;
			colorBackground[] = {0,0,0,0};
			colorText[] = MUIC_BLACK;
			font = "RobotoCondensed";
			size = TEXT_SIZE_TOOLTIP;
			shadow = 1;
		};
		class CategoryText_Center
		{
			type = 0;
			idc = IDC_TEXTC;
			x = safeZoneX + safeZoneW * 0.46041667;
			y = safeZoneY + safeZoneH * 0.749;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = $STR_BUI_DEFENSES;
			colorBackground[] = {0.5873,0.7698,0.7302,0};
			colorText[] = {1,1,1,1};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_CAT;
		};
		class CategoryText_L2
		{
			type = 0;
			idc = IDC_TEXTL2;
			x = safeZoneX + safeZoneW * 0.2953125;
			y = safeZoneY + safeZoneH * 0.749;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = $STR_BUI_RANGE;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.3};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_CAT;
			
		};
		class CategoryText_L1 
		{
			type = 0;
			idc = IDC_TEXTL1;
			x = safeZoneX + safeZoneW * 0.378125;
			y = safeZoneY + safeZoneH * 0.749;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = $STR_BUI_DECOR;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.5};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_CAT;
			
		};
		class CategoryText_R1 
		{
			type = 0;
			idc = IDC_TEXTR1;
			x = safeZoneX + safeZoneW * 0.54270834;
			y = safeZoneY + safeZoneH * 0.749;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = $STR_BUI_RANGE;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.5};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_CAT;
			
		};
		class CategoryText_R2
		{
			type = 0;
			idc = IDC_TEXTR2;
			x = safeZoneX + safeZoneW * 0.62552084;
			y = safeZoneY + safeZoneH * 0.749;
			w = safeZoneW * 0.07916667;
			h = safeZoneH * 0.02222223;
			style = 2;
			text = $STR_BUI_RANGE;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.3};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_CAT;
			
		};
		class ItemText_Center
		{
			type = 0;
			idc = IDC_ITEXTC;
			x = safeZoneX + safeZoneW * 0.43;
			y = safeZoneY + safeZoneH * 0.72;
			w = safeZoneW * 0.13;
			h = safeZoneH * 0.02;
			style = 2;
			text = $STR_BUI_DEFENSES;
			colorBackground[] = {0.5873,0.7698,0.7302,0};
			colorText[] = {1,1,1,1};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_ITEM;
			
		};
		class ItemText_R1
		{
			type = 0;
			idc = IDC_ITEXTR1;
			x = safeZoneX + safeZoneW * 0.56;
			y = safeZoneY + safeZoneH * 0.72;
			w = safeZoneW * 0.13;
			h = safeZoneH * 0.02;
			style = 2;
			text = $STR_BUI_RANGE;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.5};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_ITEM;
			
		};
		class ItemText_L1
		{
			type = 0;
			idc = IDC_ITEXTL1;
			x = safeZoneX + safeZoneW * 0.3;
			y = safeZoneY + safeZoneH * 0.72;
			w = safeZoneW * 0.13;
			h = safeZoneH * 0.02;
			style = 2;
			text = $STR_BUI_DECOR;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.5};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_ITEM;
			
		};
		class ItemText_R2 
		{
			type = 0;
			idc = IDC_ITEXTR2;
			x = safeZoneX + safeZoneW * 0.69;
			y = safeZoneY + safeZoneH * 0.72;
			w = safeZoneW * 0.13;
			h = safeZoneH * 0.02;
			style = 2;
			text = $STR_BUI_RANGE;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.3};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_ITEM;
			
		};
		class ItemText_L2
		{
			type = 0;
			idc = IDC_ITEXTL2;
			x = safeZoneX + safeZoneW * 0.17;
			y = safeZoneY + safeZoneH * 0.72;
			w = safeZoneW * 0.13;
			h = safeZoneH * 0.02;
			style = 2;
			text = $STR_BUI_RANGE;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.3};
			font = "RobotoCondensedBold";
			sizeEx = TEXT_SIZE_ITEM;
			
		};
		
	};
	
};
