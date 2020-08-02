#include "UndercoverUIDebug_Macros.h"

class UndercoverUIDebug
{
	idd = 13999;
	name = "UndercoverUIDebug";
	onLoad = "uiNamespace setVariable ['undercoverUIDebug_display', _this select 0]";
	onUnload = "uiNamespace setVariable ['undercoverUIDebug_display', displayNull]";
	enableSimulation = true;
	duration = 10000000;
	
	class ControlsBackground
	{
		
	};
	class Controls
	{
		class TextCAPTIVE
		{
			type = 0;
			idc = IDC_CAPT;
			x = 1.35833365;
			y = -0.38863635;
			w = 0.27272728;
			h = 0.09545455;
			style = 0+2;
			text = "NOT CAPTIVE";
			colorBackground[] = {0.754,0.1111,0.0952,1};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class Text1
		{
			type = 0;
			idc = IDC_T1;
			x = -0.64166665;
			y = -0.38863635;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {0,0,0,0.7};
			colorText[] = {0.302,1,0.2226,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class Text2
		{
			type = 0;
			idc = IDC_T2;
			x = -0.36666658;
			y = -0.38863635;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {0,0,0,0.7};
			colorText[] = {0.302,1,0.2226,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class Text3 
		{
			type = 0;
			idc = IDC_T3;
			x = -0.09166656;
			y = -0.38863635;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {0,0,0,0.7};
			colorText[] = {0.302,1,0.2226,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class Text4
		{
			type = 0;
			idc = IDC_T4;
			x = 0.1833335;
			y = -0.38863635;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {0,0,0,0.7};
			colorText[] = {0.302,1,0.2226,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class Text5
		{
			type = 0;
			idc = IDC_T5;
			x = 0.45833353;
			y = -0.38863635;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {0,0,0,0.7};
			colorText[] = {0.302,1,0.2226,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class Text6 
		{
			type = 0;
			idc = IDC_T6;
			x = 0.73333357;
			y = -0.38863635;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {0,0,0,0.7};
			colorText[] = {0.302,1,0.2226,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class Text7 
		{
			type = 0;
			idc = IDC_T7;
			x = safeZoneX + safeZoneW * 0.70989584;
			y = safeZoneY + safeZoneH * 0.01111112;
			w = safeZoneW * 0.1125;
			h = safeZoneH * 0.025;
			style = 0;
			text = "##################";
			colorBackground[] = {0,0,0,0.7};
			colorText[] = {0.302,1,0.2226,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TextBool1 
		{
			type = 0;
			idc = IDC_T8;
			x = -0.64166636;
			y = -0.33863631;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {1,0,0,0.7};
			colorText[] = {1,1,0.9686,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TextBool2
		{
			type = 0;
			idc = IDC_T9;
			x = -0.3666663;
			y = -0.33863631;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {1,0,0,0.7};
			colorText[] = {1,1,0.9686,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TextBool3
		{
			type = 0;
			idc = IDC_T10;
			x = -0.09166627;
			y = -0.33863631;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {1,0,0,0.7};
			colorText[] = {1,1,0.9686,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TextBool4
		{
			type = 0;
			idc = IDC_T11;
			x = 0.18333376;
			y = -0.33863631;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {1,0,0,0.7};
			colorText[] = {1,1,0.9686,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TextBool5
		{
			type = 0;
			idc = IDC_T12;
			x = 0.45833386;
			y = -0.33863631;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {1,0,0,0.7};
			colorText[] = {1,1,0.9686,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TextBool6
		{
			type = 0;
			idc = IDC_T13;
			x = 0.73333386;
			y = -0.3386363;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {1,0,0,0.7};
			colorText[] = {1,1,0.9686,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TextBool7 
		{
			type = 0;
			idc = IDC_T14;
			x = 1.0083339;
			y = -0.3386363;
			w = 0.27272728;
			h = 0.04545455;
			style = 0;
			text = "##################";
			colorBackground[] = {1,0,0,0.7};
			colorText[] = {1,1,0.9686,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		
	};
	
};
