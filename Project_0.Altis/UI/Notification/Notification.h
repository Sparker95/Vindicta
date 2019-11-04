#define __WIDTH 0.5

class NOTIFICATION_GROUP : MUI_GROUP_ABS
{
	idc = -1;
	x = 0;
	y = 0;
	w = __WIDTH + 0.005;
	h = 0.175;
	style = 0;
	text = "";
	colorText[] = {0.5412,0.5255,0.051,1};
	font = "PuristaMedium";
	sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);

	class Controls
	{

		class NOTIFICATION_BACKGROUND : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0;
			w = __WIDTH;
			h = 0.17;
			style = 0;
			text = "";
			colorText[] = {0.5412,0.5255,0.051,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};

		class NOTIFICATION_ICON
		{
			type = 0;
			idc = -1;
			x = 0.0000002;
			y = 0.0000003;
			w = 0.05;
			h = 0.05;
			style = 0+48;
			text = "\A3\ui_f\data\GUI\Rsc\RscDisplayMain\notification_ca.paa";
			colorBackground[] = {0, 0, 0, 0};
			colorText[] = {1, 1, 1, 1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			onLoad = "uiNamespace setVariable ['vin_not_icon', _this#0]";
		};
		class NOTIFICATION_CATEGORY : MUI_BASE_ABS
		{
			type = 0;
			idc = -1;
			x = 0.05000032;
			y = 0.00000031;
			w = __WIDTH - 0.05;
			h = 0.05;
			style = 0;
			text = "INTEL";
			colorBackground[] = {0.702,0.102,0.102,0.3572};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = 0.05;
			onLoad = "uiNamespace setVariable ['vin_not_category', _this#0]"; // Dont delete this!
		};
		class NOTIFICATION_TEXT : MUI_BASE_ABS
		{
			type = 0;
			idc = -1;
			x = 0.00000066;
			y = 0.05000038;
			w = __WIDTH;
			h = 0.08;
			style = 0+16+512;
			text = "Enemy radio cryptokey was found!";
			font = "PuristaMedium";
			sizeEx = 0.04;
			lineSpacing = 1;
			onLoad = "uiNamespace setVariable ['vin_not_text', _this#0]";  // Dont delete this!
		};
		class NOTIFICATION_HINT : MUI_BASE_ABS
		{
			type = 0;
			idc = -1;
			x = 0.00000043;
			y = 0.1300005;
			w = __WIDTH;
			h = 0.04000017;
			style = 0+2;
			text = "Cryptokeys are stored in your notes tab";
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = 0.04;
			onLoad = "uiNamespace setVariable ['vin_not_hint', _this#0]";  // Dont delete this!
		};
		
	};
	
};
