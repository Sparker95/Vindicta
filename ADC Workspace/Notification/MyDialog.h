#include "CustomControlClasses.h"
class MyDialog
{
	idd = -1;
	
	class ControlsBackground
	{
		class NOTIFICATION_GROUP : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0;
			w = 0.42;
			h = 0.1400001;
			style = 0;
			text = "";
			colorText[] = {0.5412,0.5255,0.051,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class NOTIFICATION_BACKGROUND : MUI_BG_BLACKTRANSPARENT 
		{
			type = 0;
			idc = -1;
			x = 0.00000006;
			y = 0;
			w = 0.42;
			h = 0.17000016;
			style = 0;
			text = "";
			colorText[] = {0.5412,0.5255,0.051,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		
	};
	class Controls
	{
		class NOTIFICATION_ICON
		{
			type = 0;
			idc = -1;
			x = 0.0000002;
			y = 0.0000003;
			w = 0.05;
			h = 0.05;
			style = 0+48;
			text = "";
			colorBackground[] = {0.6196,0.7216,0.0902,1};
			colorText[] = {0.3804,0.2784,0.9098,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class NOTIFICATION_CATEGORY : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = 0.05000032;
			y = 0.00000031;
			w = 0.37000011;
			h = 0.05;
			style = 0;
			text = "INTEL";
			colorBackground[] = {0.702,0.102,0.102,0.3572};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = 0.04;
			
		};
		class NOTIFICATION_TEXT : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = 0.00000066;
			y = 0.05000038;
			w = 0.42000013;
			h = 0.08;
			style = 0+16+512;
			text = "Enemy radio cryptokey was found!";
			colorBackground[] = {0.4,0.2,0.4,1};
			font = "PuristaMedium";
			sizeEx = 0.04;
			
		};
		class NOTIFICATION_HINT : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = 0.00000043;
			y = 0.1300005;
			w = 0.42000011;
			h = 0.04000017;
			style = 0+2;
			text = "Cryptokeys are stored in your notes tab";
			colorBackground[] = {0.2,0.102,0.502,1};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = 0.04;
			
		};
		
	};
	
};
