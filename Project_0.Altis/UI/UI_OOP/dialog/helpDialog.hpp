class helpDialog {
	idd = 9009;
	name= "helpDialog";
	movingEnable = false;
	enableSimulation = true;
	onLoad = "with missionNamespace do{['new', _this select 0] call oo_helpDialog;};";
	onUnload = "with missionNamespace do{['static', ['deconstructor',nil]] call oo_helpDialog;};";
	class controlsBackground {
		class OOP_MainLayer_100_100 : OOP_MainLayer {
			idc = 100;
			x = -61.9078 * pixelGrid * pixelW;
			y = -28.35 * pixelGrid * pixelH;
			w = 210.691 * pixelGrid * pixelW;
			h = 125.95 * pixelGrid * pixelH;
			class controls{
				class OOP_Picture_101_101: OOP_Picture {
					idc = 101;
					x = 39.5045 * pixelGrid * pixelW;
					y = 17.633 * pixelGrid * pixelH;
					w = 131.682 * pixelGrid * pixelW;
					h = 80.608 * pixelGrid * pixelH;
					text = "#(rgb,8,8,3)color(0.2,0.2,0.2,0.8)";
				};
				class OOP_Text_102_102: OOP_Text {
					idc = 102;
					x = 39.5045 * pixelGrid * pixelW;
					y = 17.633 * pixelGrid * pixelH;
					w = 131.682 * pixelGrid * pixelW;
					h = 5.038 * pixelGrid * pixelH;
					text = "Help";
					colorBackground[] = {0, 0.96, 0.17, 1};
				};
				class OOP_Picture_103_103: OOP_Picture {
					idc = 103;
					x = 104.687 * pixelGrid * pixelW;
					y = 22.671 * pixelGrid * pixelH;
					w = 1.31682 * pixelGrid * pixelW;
					h = 75.57 * pixelGrid * pixelH;
					text = "#(rgb,8,8,3)color(1,1,1,1)";
				};
				class OOP_Text_104_104: OOP_Text {
					idc = 104;
					x = 47.4054 * pixelGrid * pixelW;
					y = 32.747 * pixelGrid * pixelH;
					w = 28.97 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "F1 => Show help";
				};
				class OOP_Text_105_105: OOP_Text {
					idc = 105;
					x = 47.4054 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "F2 => Config display ";
				};
				class OOP_Text_106_106: OOP_Text {
					idc = 106;
					x = 47.4054 * pixelGrid * pixelW;
					y = 37.785 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "F3 => Export as HPP";
				};
				class OOP_Text_107_107: OOP_Text {
					idc = 107;
					x = 47.4054 * pixelGrid * pixelW;
					y = 40.304 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "F4 => Export as OOP";
				};
				class OOP_Text_108_108: OOP_Text {
					idc = 108;
					x = 47.4054 * pixelGrid * pixelW;
					y = 42.823 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "F5 => Enable all control  (usefull to get real color)";
				};
				class OOP_Text_109_109: OOP_Text {
					idc = 109;
					x = 47.4054 * pixelGrid * pixelW;
					y = 47.861 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "O => Open layer as fullscreen mod ";
				};
				class OOP_Text_110_110: OOP_Text {
					idc = 110;
					x = 47.4054 * pixelGrid * pixelW;
					y = 50.38 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "I => Import your display from clipboard";
				};
				class OOP_Text_111_111: OOP_Text {
					idc = 111;
					x = 47.4054 * pixelGrid * pixelW;
					y = 52.899 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Space => Colorize all control in layer";
				};
				class OOP_Text_112_112: OOP_Text {
					idc = 112;
					x = 47.4054 * pixelGrid * pixelW;
					y = 55.418 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "T => Show/Hide Tree dialog";
				};
				class OOP_Text_113_113: OOP_Text {
					idc = 113;
					x = 110.613 * pixelGrid * pixelW;
					y = 25.19 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Tree dialog";
					colorText[] = {0.92, 0.52, 0, 1};
					tooltipColorText[] = {0.92, 0.52, 0, 1};
				};
				class OOP_Text_114_114: OOP_Text {
					idc = 114;
					x = 44.7718 * pixelGrid * pixelW;
					y = 25.19 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "In display";
					colorText[] = {0.92, 0.52, 0, 1};
					tooltipColorText[] = {0.92, 0.52, 0, 1};
				};
				class OOP_Text_115_115: OOP_Text {
					idc = 115;
					x = 113.246 * pixelGrid * pixelW;
					y = 30.228 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "PageUp => Put control over other";
				};
				class OOP_Text_116_116: OOP_Text {
					idc = 116;
					x = 113.246 * pixelGrid * pixelW;
					y = 32.747 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "PageDown => Put control under other";
				};
				class OOP_Text_117_117: OOP_Text {
					idc = 117;
					x = 113.246 * pixelGrid * pixelW;
					y = 40.304 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "H => Show/Hide control";
				};
				class OOP_Text_118_118: OOP_Text {
					idc = 118;
					x = 47.4054 * pixelGrid * pixelW;
					y = 60.456 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "H => Hide control";
				};
				class OOP_Text_119_119: OOP_Text {
					idc = 119;
					x = 47.4054 * pixelGrid * pixelW;
					y = 62.975 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Del. => Delete control";
				};
				class OOP_Text_120_120: OOP_Text {
					idc = 120;
					x = 113.246 * pixelGrid * pixelW;
					y = 42.823 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Del. => Delete control";
				};
				class OOP_Text_121_121: OOP_Text {
					idc = 121;
					x = 47.4054 * pixelGrid * pixelW;
					y = 68.013 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "C => Center horizontally control";
				};
				class OOP_Text_122_122: OOP_Text {
					idc = 122;
					x = 47.4054 * pixelGrid * pixelW;
					y = 73.051 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Ctrl + C => Copy";
				};
				class OOP_Text_123_123: OOP_Text {
					idc = 123;
					x = 47.4054 * pixelGrid * pixelW;
					y = 75.57 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Ctrl + V => Paste";
				};
				class OOP_Text_124_124: OOP_Text {
					idc = 124;
					x = 47.4054 * pixelGrid * pixelW;
					y = 70.532 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "V => Center vertically control";
				};
				class OOP_Text_125_125: OOP_Text {
					idc = 125;
					x = 47.4054 * pixelGrid * pixelW;
					y = 80.608 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Arrow => move control";
				};
				class OOP_Text_126_126: OOP_Text {
					idc = 126;
					x = 47.4054 * pixelGrid * pixelW;
					y = 83.127 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Arrow + alt => resize control";
				};
				class OOP_Text_127_127: OOP_Text {
					idc = 127;
					x = 47.4054 * pixelGrid * pixelW;
					y = 88.165 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Right click => Control create/Control config";
				};
				class OOP_Text_128_128: OOP_Text {
					idc = 128;
					x = 47.4054 * pixelGrid * pixelW;
					y = 90.684 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Left click => select control";
				};
				class OOP_Text_129_129: OOP_Text {
					idc = 129;
					x = 113.246 * pixelGrid * pixelW;
					y = 47.861 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "DblClick => Show config";
				};
				class OOP_Text_130_130: OOP_Text {
					idc = 130;
					x = 110.613 * pixelGrid * pixelW;
					y = 52.899 * pixelGrid * pixelH;
					w = 39.5045 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Tips";
					colorText[] = {0.92, 0.52, 0, 1};
					tooltipColorText[] = {0.92, 0.52, 0, 1};
				};
				class OOP_Text_131_131: OOP_Text {
					idc = 131;
					x = 113.246 * pixelGrid * pixelW;
					y = 57.937 * pixelGrid * pixelH;
					w = 52.6727 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Give name to control create variable in oop class to use them";
				};
				class OOP_Text_132_132: OOP_Text {
					idc = 132;
					x = 113.246 * pixelGrid * pixelW;
					y = 60.456 * pixelGrid * pixelH;
					w = 55.3063 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = 'Ex: give "title" to RscText will create you MEMBER("control","title")';
				};
				class OOP_Text_133_133: OOP_Text {
					idc = 133;
					x = 113.246 * pixelGrid * pixelW;
					y = 62.975 * pixelGrid * pixelH;
					w = 50.039 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Add event on control will also create to you a new variable";
				};
				class OOP_Text_134_134: OOP_Text {
					idc = 134;
					x = 113.246 * pixelGrid * pixelW;
					y = 65.494 * pixelGrid * pixelH;
					w = 50.039 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "If you don't give name. Name Variable will be generate";
				};
				class OOP_Text_135_135: OOP_Text {
					idc = 135;
					x = 113.246 * pixelGrid * pixelW;
					y = 68.013 * pixelGrid * pixelH;
					w = 50.039 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "And you won't do that if you wan't read your script later";
				};
				class OOP_Text_136_136: OOP_Text {
					idc = 136;
					x = 113.246 * pixelGrid * pixelW;
					y = 73.051 * pixelGrid * pixelH;
					w = 50.039 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "All event handler will call function as STATIC";
				};
				class OOP_Text_137_137: OOP_Text {
					idc = 137;
					x = 113.246 * pixelGrid * pixelW;
					y = 75.57 * pixelGrid * pixelH;
					w = 57.9399 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Then you could only read/write static variable inside those function";
				};
				class OOP_Text_138_138: OOP_Text {
					idc = 138;
					x = 113.246 * pixelGrid * pixelW;
					y = 80.608 * pixelGrid * pixelH;
					w = 57.9399 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "You could export into your mission HelperGui";
				};
				class OOP_Text_139_139: OOP_Text {
					idc = 139;
					x = 113.246 * pixelGrid * pixelW;
					y = 83.127 * pixelGrid * pixelH;
					w = 57.9399 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Which is class to manage easier your control";
				};
				class OOP_Text_140_140: OOP_Text {
					idc = 140;
					x = 113.246 * pixelGrid * pixelW;
					y = 85.646 * pixelGrid * pixelH;
					w = 57.9399 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "You could export SliderH, ColorPicker(which need sliderH)";
				};
				class OOP_Text_141_141: OOP_Text {
					idc = 141;
					x = 113.246 * pixelGrid * pixelW;
					y = 90.684 * pixelGrid * pixelH;
					w = 57.9399 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "THIS IS BETA VERSION";
					colorText[] = {1, 0, 0, 1};
					tooltipColorText[] = {1, 0, 0, 1};
				};
				class OOP_Text_142_142: OOP_Text {
					idc = 142;
					x = 47.4054 * pixelGrid * pixelW;
					y = 30.228 * pixelGrid * pixelH;
					w = 34.2372 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "ESC => Exit from layer/Exit from editor";
				};
				class OOP_Text_143_143: OOP_Text {
					idc = 143;
					x = 47.4054 * pixelGrid * pixelW;
					y = 93.203 * pixelGrid * pixelH;
					w = 34.2372 * pixelGrid * pixelW;
					h = 2.519 * pixelGrid * pixelH;
					text = "Dbl Click => enter on layer";
				};
			};
		};
	};
	class controls {};
};

/*
["helpDialog",9009,[[[["39.5045 * pixelGrid * pixelW","17.633 * pixelGrid * pixelH","131.682 * pixelGrid * pixelW","80.608 * pixelGrid * pixelH"],"#(rgb,8,8,3)color(0.2,0.2,0.2,0.8)","","","OOP_Picture",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["39.5045 * pixelGrid * pixelW","17.633 * pixelGrid * pixelH","131.682 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH"],"Help","","","OOP_Text",true,[],[-1,-1,-1,-1],[0,0.96,0.17,1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["104.687 * pixelGrid * pixelW","22.671 * pixelGrid * pixelH","1.31682 * pixelGrid * pixelW","75.57 * pixelGrid * pixelH"],"#(rgb,8,8,3)color(1,1,1,1)","","","OOP_Picture",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","32.747 * pixelGrid * pixelH","28.97 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"F1 => Show help","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"F2 => Config display ","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","37.785 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"F3 => Export as HPP","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","40.304 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"F4 => Export as OOP","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","42.823 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"F5 => Enable all control  (usefull to get real color)","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","47.861 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"O => Open layer as fullscreen mod ","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","50.38 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"I => Import your display from clipboard","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","52.899 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Space => Colorize all control in layer","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","55.418 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"T => Show/Hide Tree dialog","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["110.613 * pixelGrid * pixelW","25.19 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Tree dialog","","","OOP_Text",true,[],[0.92,0.52,0,1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["44.7718 * pixelGrid * pixelW","25.19 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"In display","","","OOP_Text",true,[],[0.92,0.52,0,1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","30.228 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"PageUp => Put control over other","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","32.747 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"PageDown => Put control under other","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","40.304 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"H => Show/Hide control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","60.456 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"H => Hide control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","62.975 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Del. => Delete control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","42.823 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Del. => Delete control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","68.013 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"C => Center horizontally control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","73.051 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Ctrl + C => Copy","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","75.57 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Ctrl + V => Paste","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","70.532 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"V => Center vertically control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","80.608 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Arrow => move control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","83.127 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Arrow + alt => resize control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","88.165 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Right click => Control create/Control config","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","90.684 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Left click => select control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","47.861 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"DblClick => Show config","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["110.613 * pixelGrid * pixelW","52.899 * pixelGrid * pixelH","39.5045 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Tips","","","OOP_Text",true,[],[0.92,0.52,0,1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","57.937 * pixelGrid * pixelH","52.6727 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Give name to control create variable in oop class to use them","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","60.456 * pixelGrid * pixelH","55.3063 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Ex: give ""title"" to RscText will create you MEMBER(""control"",""title"")","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","62.975 * pixelGrid * pixelH","50.039 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Add event on control will also create to you a new variable","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","65.494 * pixelGrid * pixelH","50.039 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"If you don't give name. Name Variable will be generate","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","68.013 * pixelGrid * pixelH","50.039 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"And you won't do that if you wan't read your script later","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","73.051 * pixelGrid * pixelH","50.039 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"All event handler will call function as STATIC","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","75.57 * pixelGrid * pixelH","57.9399 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Then you could only read/write static variable inside those function","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","80.608 * pixelGrid * pixelH","57.9399 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"You could export into your mission HelperGui","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","83.127 * pixelGrid * pixelH","57.9399 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Which is class to manage easier your control","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","85.646 * pixelGrid * pixelH","57.9399 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"You could export SliderH, ColorPicker(which need sliderH)","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["113.246 * pixelGrid * pixelW","90.684 * pixelGrid * pixelH","57.9399 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"THIS IS BETA VERSION","","","OOP_Text",true,[],[1,0,0,1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","30.228 * pixelGrid * pixelH","34.2372 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"ESC => Exit from layer/Exit from editor","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["47.4054 * pixelGrid * pixelW","93.203 * pixelGrid * pixelH","34.2372 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Dbl Click => enter on layer","","","OOP_Text",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]]
*/
