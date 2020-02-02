#include "CustomControlClasses.h"
class RadioKeyTab
{
	idd = -1;
	
	class ControlsBackground
	{
		class TAB_RADIO_KEY
		{
			type = 0;
			idc = -1;
			x = 0;
			y = 0;
			w = 0.7;
			h = 1;
			style = 0;
			text = "";
			colorBackground[] = {0.9216,0.4157,0.8941,1};
			colorText[] = {0.0784,0.5843,0.1059,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		
	};
	class Controls
	{
		class EDIT_ENTER_KEY
		{
			type = 0;
			idc = -1;
			x = 0.02;
			y = 0.94;
			w = 0.5;
			h = 0.04;
			style = 0;
			text = "01-02-GREEN-123-456-789-123";
			colorBackground[] = {0.451,0.8863,0.4784,1};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			sizeEx = 0.04;
			
		};
		class STATIC_KEYS
		{
			type = 0;
			idc = -1;
			x = 0.02;
			y = 0.07000008;
			w = 0.66;
			h = 0.81;
			style = 0;
			text = "";
			colorBackground[] = {0.8,0.1373,0.3608,1};
			colorText[] = {0.2,0.8627,0.6392,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class BUTTON_ADD_KEY : MUI_BUTTON_TXT 
		{
			type = 1;
			idc = -1;
			x = 0.54;
			y = 0.94000002;
			w = 0.14000003;
			h = 0.04;
			style = 0;
			text = "Add key";
			borderSize = 0;
			colorText[] = {1,1,1,1};
			sizeEx = 0.04;
			
		};
		class Control919808632 : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = 0.0250001;
			y = 0.01500006;
			w = 0.65;
			h = 0.05000004;
			style = 0;
			text = "Added keys:";
			sizeEx = 0.04;
			
		};
		class Control919808632_copy1 : MUI_BASE 
		{
			type = 0;
			idc = -1;
			x = 0.02;
			y = 0.9;
			w = 0.5;
			h = 0.04;
			style = 0;
			text = "Enter key:";
			colorBackground[] = {0.302,0.102,0.302,1};
			sizeEx = 0.04;
			
		};
		
	};
	
};
