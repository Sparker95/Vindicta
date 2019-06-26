class dialogue_question
{
	idd = -1;
	movingEnabled = true;
	onLoad = "uiNamespace setVariable ['dialogueUI_display', _this select 0]";
	onUnload = "uiNamespace setVariable ['dialogueUI_display', displayNull]";
	class controls
	{
		
		class BackgroundMain: RscText
		{
			x = -0.4;
			y = 1-safeZoneY-0.25-0.1;
			w = 0.4;
			h = 0.25;
			colorBackground[] = {0,0,0,0.2};
		};	
		
		class FrameMain: RscFrame
		{
			x = -0.4;
			y = 1-safeZoneY-0.25-0.1;
			w = 0.4;
			h = 0.25;
			colorText[] = {0,0,0,0.5};
		};
		
		class TextAnwers: RscStructuredText
		{
			idc = 1;
			x = -0.4;
			y = 1-safeZoneY-0.25-0.1;
			w = 0.4;
			h = 0.25;
			colorText[] = {1,1,1,1};
			shadow = 0;
		};
		
	};
};