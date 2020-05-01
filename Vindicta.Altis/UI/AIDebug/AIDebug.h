class AI_DEBUG_GROUP : MUI_GROUP
{
	idc = -1;
	x = safeZoneX + safeZoneW * 0.29375;
	y = safeZoneY + safeZoneH * 0.225;
	w = safeZoneW * 0.2;
	h = safeZoneH * 0.3;
	text = "";

	onLoad = "uiNamespace setVariable ['vin_aidbg_group', _this#0]";

	#define _x0 (safeZoneX + safeZoneW * 0.29375)
	#define _y0 (safeZoneY + safeZoneH * 0.225)

	class Controls
	{
		class AI_DEBUG_STATIC_BACKGROUND : MUI_BG_BLACKTRANSPARENT 
		{
			idc = -1;
			x = 0;
			y = 0;
			w = safeZoneW * 0.19791667;
			h = safeZoneH * 0.29722223;
		};

		class AI_DEBUG_TREE : MUI_TREE
		{
			idc = -1;
			x = safeZoneX + safeZoneW * 0.29791667 - _x0;
			y = safeZoneY + safeZoneH * 0.25833334 - _y0;
			w = safeZoneW * 0.18958334;
			h = safeZoneH * 0.25833334;
			style = 0;
			onLoad = "uiNamespace setVariable ['vin_aidbg_tree', _this#0]";
		};

		class AI_DEBUG_BUTTON_HALT : MUI_BUTTON_TXT 
		{
			idc = -1;
			x = safeZoneX + safeZoneW * 0.4546875 - _x0;
			y = safeZoneY + safeZoneH * 0.23055556 - _y0;
			w = safeZoneW * 0.0328125;
			h = safeZoneH * 0.02222223;
			text = "Halt";
			borderSize = 0;
			onLoad = "uiNamespace setVariable ['vin_aidbg_button_halt', _this#0]";
		};
		
		class AI_DEBUG_EDIT_AI_REF : MUI_EDIT 
		{
			idc = -1;
			x = safeZoneX + safeZoneW * 0.29791667 - _x0;
			y = safeZoneY + safeZoneH * 0.23055556 - _y0;
			w = safeZoneW * 0.15260417;
			h = safeZoneH * 0.02222223;
			text = "AI Object Reference";
			onLoad = "uiNamespace setVariable ['vin_aidbg_edit_ai_ref', _this#0]";
			style = 0;
			canModify = false;
		};
		
	};
	
};
