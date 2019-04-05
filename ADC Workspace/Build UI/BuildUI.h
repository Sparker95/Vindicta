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
		class TooltipBG
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.29375;
			y = safeZoneY + safeZoneH * 0.78148149;
			w = safeZoneW * 0.4125;
			h = safeZoneH * 0.05277778;
			style = 0;
			text = "";
			colorBackground[] = {0.702,0.102,0.102,1};
			colorText[] = {0.702,0.102,0.102,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryBG
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.29375;
			y = safeZoneY + safeZoneH * 0.74537038;
			w = safeZoneW * 0.4125;
			h = safeZoneH * 0.03055556;
			style = 0;
			text = "";
			colorBackground[] = {0.2,0.2,0.2,0.6};
			colorText[] = {0.702,0.102,0.102,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class ItemCatBG
		{
			type = 0;
			idc = -1;
			x = safeZoneX + safeZoneW * 0.29375;
			y = safeZoneY + safeZoneH * 0.7212963;
			w = safeZoneW * 0.4125;
			h = safeZoneH * 0.01851852;
			style = 0;
			text = "";
			colorBackground[] = {0,0,0,0.6};
			colorText[] = {0.702,0.102,0.102,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class Category Text_Center : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_L2 : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_L1 : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_R1 : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_R2 : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class ItemText_Center : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		class ItemText_R1 : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		class ItemText_L1 : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		class ItemText_R2 : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		class ItemText_L2 : CategoryTextControl 
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
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8);
			
		};
		
	};
	
};
