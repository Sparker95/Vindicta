#include "BuildUI_Macros.h"

#include "CustomControlClasses.h"
class BuildUI
{
	idd = 3981;
	enableSimulation = true;
	name = "BuildUI";
	onLoad = "uiNamespace setVariable ['buildUI_display', _this select 0]";
	onUnload = "uiNamespace setVariable ['buildUI_display', displayNull]";
	
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
			h = safeZoneH * 0.02407408;
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
			y = safeZoneY + safeZoneH * 0.74907408;
			w = safeZoneW * 0.4125;
			h = safeZoneH * 0.02962963;
			style = 0;
			text = "";
			colorBackground[] = {0.2,0.2,0.2,0.6};
			colorText[] = {0.702,0.102,0.102,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class Category Text_Center : CategoryTextControl 
		{
			type = 0;
			idc = IDC_TEXTC;
			x = 0.40404042;
			y = 0.94932661;
			w = 0.1919192;
			h = 0.05361955;
			style = 2;
			text = "Defenses";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_L2 : CategoryTextControl 
		{
			type = 0;
			idc = IDC_TEXTL2;
			x = 0.00404051;
			y = 0.94932662;
			w = 0.1919192;
			h = 0.05361955;
			style = 2;
			text = "Shooting Range";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.4};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_L1 : CategoryTextControl 
		{
			type = 0;
			idc = IDC_TEXTL1;
			x = 0.20404042;
			y = 0.94932665;
			w = 0.1919192;
			h = 0.05361955;
			style = 2;
			text = "Decoration";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.7};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_R1 : CategoryTextControl 
		{
			type = 0;
			idc = IDC_TEXTR1;
			x = 0.60404042;
			y = 0.94932661;
			w = 0.1919192;
			h = 0.05361955;
			style = 2;
			text = "Shooting Range";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.7};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class CategoryText_R2 : CategoryTextControl 
		{
			type = 0;
			idc = IDC_TEXTR2;
			x = 0.80404045;
			y = 0.94932661;
			w = 0.1919192;
			h = 0.05361955;
			style = 2;
			text = "Shooting Range";
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,0.4};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		
	};
	
};
