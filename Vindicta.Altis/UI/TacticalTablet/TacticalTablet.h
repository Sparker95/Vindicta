class TACTICAL_TABLET
{
	idd = -1;
	
	// On creation of the dialog we set a variable, which we immediately read to get the handle to the new display
	onLoad = "uiNamespace setVariable ['gTacticalTabletNewDisplay', _this select 0];";

	class ControlsBackground
	{
		
	};
	class Controls
	{
		class TABLET_BG_FRAME
		{
			type = 0;
			idc = -1;
			x = 0.02000006;
			y = 0.02000011;
			w = 0.96;
			h = 0.96;
			style = 0;
			text = "";
			colorBackground[] = {0.3024,0.5545,0.3141,1};
			colorText[] = {0.3804,0.0314,0.7725,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TABLET_BG
		{
			type = 0;
			idc = -1;
			x = 0.025;
			y = 0.025;
			w = 0.95;
			h = 0.95;
			style = 0;
			text = "";
			colorBackground[] = {0.2707,0.4196,0.2824,1};
			colorText[] = {0.3804,0.0314,0.7725,1};
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TABLET_TITLE
		{
			type = 0;
			idc = -1;
			x = 0.0500002;
			y = 0.90000015;
			w = 0.30000009;
			h = 0.05000004;
			style = 0;
			text = "MilTech inc.    Tacticool Tablet V1.1";
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.702,0.702,0.702,1};
			font = "PuristaMedium";
			sizeEx = 0.03;
			
		};
		class TABLET_DISPLAY_BG
		{
			type = 0;
			idc = -1;
			x = 0.0650001;
			y = 0.0650001;
			w = 0.87000005;
			h = 0.82000007;
			style = 0;
			text = "";
			colorBackground[] = {0.1595,0.2689,0.1792,1};
			colorText[] = {0.949,0.949,0.949,1};
			font = "EtelkaMonospacePro";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TABLET_DISPLAY
		{
			type = 0;
			idc = -1;
			x = 0.07500004;
			y = 0.07500002;
			w = 0.85000017;
			h = 0.80000007;
			style = 0;
			text = "";
			colorBackground[] = {0.102,0.102,0.102,1};
			colorText[] = {0.949,0.949,0.949,1};
			font = "EtelkaMonospacePro";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			
		};
		class TABLET_DISPLAY_TEXT : MUI_EDIT_ABS
		{
			type = 2; // Edit
			idc = -1;
			x = 0.08500066;
			y = 0.08500066;
			w = 0.83000005;
			h = 0.78000007;
			style = 0+16+0x200;
			text = "Line 1 Line 2 Line 3";
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.949,0.949,0.949,1};
			colorSelection[] = {0.3024,0.5545,0.3141,1};
			font = "EtelkaMonospacePro";
			sizeEx = 0.04;
			lineSpacing = 1;	
			canModify = false; // Can't modify it but can select text		
		};
		
	};
	
};
