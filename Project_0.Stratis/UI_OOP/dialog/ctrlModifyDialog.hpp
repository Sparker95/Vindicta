class ctrlModifyDialog {
	idd = 9001;
	name= "ctrlModifyDialog";
	movingEnable = false;
	enableSimulation = true;
	onLoad = "with missionNamespace do{['new', _this select 0] call oo_ctrlModifyDialog;};";
	onUnload = "with missionNamespace do{['static', ['deconstructor',nil]] call oo_ctrlModifyDialog;};";
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
					x = 57.9399 * pixelGrid * pixelW;
					y = 27.709 * pixelGrid * pixelH;
					w = 94.8108 * pixelGrid * pixelW;
					h = 70.532 * pixelGrid * pixelH;
					text = "#(rgb,8,8,3)color(0.2,0.2,0.2,0.8)";
				};
				class title_102: OOP_Text {
					idc = 102;
					x = 57.9399 * pixelGrid * pixelW;
					y = 27.709 * pixelGrid * pixelH;
					w = 94.8108 * pixelGrid * pixelW;
					h = 5.038 * pixelGrid * pixelH;
					text = "Modify control:";
					colorText[] = {1, 1, 1, 1};
					colorBackground[] = {0.2, 0.7, 0.2, 1};
					tooltipColorText[] = {1, 1, 1, 1};
				};
				class btnStyle_103: OOP_Button {
					idc = 103;
					x = 57.9399 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 3.7785 * pixelGrid * pixelH;
					text = "Style";
					action = "['static', ['btnAction_btnStyle', nil]] call oo_ctrlModifyDialog;";
				};
				class btnGen_104: OOP_Button {
					idc = 104;
					x = 57.9399 * pixelGrid * pixelW;
					y = 40.304 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 3.97614 * pixelGrid * pixelH;
					text = "Gen EVH";
					action = "['static', ['btnAction_btnGen', nil]] call oo_ctrlModifyDialog;";
				};
				class btnMouse_105: OOP_Button {
					idc = 105;
					x = 57.9399 * pixelGrid * pixelW;
					y = 45.342 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 3.97614 * pixelGrid * pixelH;
					text = "Mouse EVH";
					action = "['static', ['btnAction_btnMouse', nil]] call oo_ctrlModifyDialog;";
				};
				class btnKB_106: OOP_Button {
					idc = 106;
					x = 57.9399 * pixelGrid * pixelW;
					y = 50.38 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 3.97614 * pixelGrid * pixelH;
					text = "Keyboard EVH";
					action = "['static', ['btnAction_btnKB', nil]] call oo_ctrlModifyDialog;";
				};
				class btnLB_107: OOP_Button {
					idc = 107;
					x = 57.9399 * pixelGrid * pixelW;
					y = 55.418 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 3.97614 * pixelGrid * pixelH;
					text = "LB EVH";
					action = "['static', ['btnAction_btnLB', nil]] call oo_ctrlModifyDialog;";
				};
				class btnTree_108: OOP_Button {
					idc = 108;
					x = 57.9399 * pixelGrid * pixelW;
					y = 60.456 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 3.97614 * pixelGrid * pixelH;
					text = "Tree EVH";
					action = "['static', ['btnAction_btnTree', nil]] call oo_ctrlModifyDialog;";
				};
				class btnTool_109: OOP_Button {
					idc = 109;
					x = 57.9399 * pixelGrid * pixelW;
					y = 65.494 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 3.97614 * pixelGrid * pixelH;
					text = "Tool/Cb EVH";
					action = "['static', ['btnAction_btnTool', nil]] call oo_ctrlModifyDialog;";
				};
				class btnOther_110: OOP_Button {
					idc = 110;
					x = 57.9399 * pixelGrid * pixelW;
					y = 70.532 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 3.97614 * pixelGrid * pixelH;
					text = "Other EVH";
					action = "['static', ['btnAction_btnOther', nil]] call oo_ctrlModifyDialog;";
				};
				class btnValider_111: OOP_Button {
					idc = 111;
					x = 115.88 * pixelGrid * pixelW;
					y = 89.4245 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 5.038 * pixelGrid * pixelH;
					text = "Valider";
					action = "['static', ['btnAction_btnValider', nil]] call oo_ctrlModifyDialog;";
				};
				class btnClose_112: OOP_Button {
					idc = 112;
					x = 73.7417 * pixelGrid * pixelW;
					y = 89.4245 * pixelGrid * pixelH;
					w = 18.4354 * pixelGrid * pixelW;
					h = 5.038 * pixelGrid * pixelH;
					text = "Fermer";
					action = "['static', ['btnAction_btnClose', nil]] call oo_ctrlModifyDialog;";
				};
				class layerGen_113 : OOP_SubLayer {
					idc = 113;
					x = 79.009 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 70.2302 * pixelGrid * pixelW;
					h = 50.38 * pixelGrid * pixelH;
					class controls{
						class OOP_TextRight_114_114: OOP_TextRight {
							idc = 114;
							x = 7.9009 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Init";
						};
						class OOP_TextRight_115_115: OOP_TextRight {
							idc = 115;
							x = 7.9009 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onDestroy";
						};
						class OOP_TextRight_116_116: OOP_TextRight {
							idc = 116;
							x = 7.9009 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onLoad";
						};
						class OOP_TextRight_118_118: OOP_TextRight {
							idc = 118;
							x = 36.8709 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onSetFocus";
						};
						class OOP_TextRight_119_119: OOP_TextRight {
							idc = 119;
							x = 36.8709 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onKillFocus";
						};
						class OOP_TextRight_120_120: OOP_TextRight {
							idc = 120;
							x = 36.8709 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onTimer";
						};
						class OOP_TextRight_121_121: OOP_TextRight {
							idc = 121;
							x = 36.8709 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onCanDestroy";
						};
						class cbInit_122: OOP_Checkbox {
							idc = 122;
							x = 23.7027 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbInit', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnDestroy_123: OOP_Checkbox {
							idc = 123;
							x = 23.7027 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnDestroy', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnLoad_124: OOP_Checkbox {
							idc = 124;
							x = 23.7027 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnLoad', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnSetFocus_126: OOP_Checkbox {
							idc = 126;
							x = 52.6727 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnSetFocus', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnKillFocus_127: OOP_Checkbox {
							idc = 127;
							x = 52.6727 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnKillFocus', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnTimer_128: OOP_Checkbox {
							idc = 128;
							x = 52.6727 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnTimer', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnCanDestroy_129: OOP_Checkbox {
							idc = 129;
							x = 52.6727 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnCanDestroy', _this]] call oo_ctrlModifyDialog;";
						};
					};
				};
				class layerMouse_130 : OOP_SubLayer {
					idc = 130;
					x = 79.009 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 70.2302 * pixelGrid * pixelW;
					h = 50.38 * pixelGrid * pixelH;
					class controls{
						class OOP_TextRight_131_131: OOP_TextRight {
							idc = 131;
							x = 2.63363 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onMouseButtonDown";
						};
						class OOP_TextRight_132_132: OOP_TextRight {
							idc = 132;
							x = 2.63363 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onMouseButtonUp";
						};
						class OOP_TextRight_133_133: OOP_TextRight {
							idc = 133;
							x = 2.63363 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onMouseButtonClick";
						};
						class OOP_TextRight_134_134: OOP_TextRight {
							idc = 134;
							x = 2.63363 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onMouseButtonDblClick";
						};
						class OOP_TextRight_135_135: OOP_TextRight {
							idc = 135;
							x = 36.8709 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onMouseMoving";
						};
						class OOP_TextRight_136_136: OOP_TextRight {
							idc = 136;
							x = 36.8709 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onMouseHolding";
						};
						class OOP_TextRight_137_137: OOP_TextRight {
							idc = 137;
							x = 36.8709 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onMouseZChanged";
						};
						class OOP_TextRight_138_138: OOP_TextRight {
							idc = 138;
							x = 36.8709 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onButtonDblClick";
						};
						class cbOnMouseButtonDown_139: OOP_Checkbox {
							idc = 139;
							x = 23.7027 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMouseButtonDown', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnMouseButtonUp_140: OOP_Checkbox {
							idc = 140;
							x = 23.7027 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMouseButtonUp', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnMouseButtonClick_141: OOP_Checkbox {
							idc = 141;
							x = 23.7027 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMouseButtonClick', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnMouseButtonDblClick_142: OOP_Checkbox {
							idc = 142;
							x = 23.7027 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMouseButtonDblClick', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnMouseMoving_143: OOP_Checkbox {
							idc = 143;
							x = 52.6727 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMouseMoving', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnMouseHolding_144: OOP_Checkbox {
							idc = 144;
							x = 52.6727 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMouseHolding', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnMouseZChanged_145: OOP_Checkbox {
							idc = 145;
							x = 52.6727 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMouseZChanged', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnButtonDblClick_146: OOP_Checkbox {
							idc = 146;
							x = 52.6727 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnButtonDblClick', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_147_147: OOP_TextRight {
							idc = 147;
							x = 2.63363 * pixelGrid * pixelW;
							y = 25.19 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onButtonDown";
						};
						class OOP_TextRight_148_148: OOP_TextRight {
							idc = 148;
							x = 2.63363 * pixelGrid * pixelW;
							y = 30.228 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onButtonUp";
						};
						class OOP_TextRight_149_149: OOP_TextRight {
							idc = 149;
							x = 2.63363 * pixelGrid * pixelW;
							y = 35.266 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onButtonClick";
						};
						class OOP_TextRight_150_150: OOP_TextRight {
							idc = 150;
							x = 31.6036 * pixelGrid * pixelW;
							y = 25.19 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onMouseEnter";
						};
						class OOP_TextRight_151_151: OOP_TextRight {
							idc = 151;
							x = 31.6036 * pixelGrid * pixelW;
							y = 30.228 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onMouseExit";
						};
						class cbOnButtonDown_152: OOP_Checkbox {
							idc = 152;
							x = 23.7027 * pixelGrid * pixelW;
							y = 25.19 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnButtonDown', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnButtonUp_153: OOP_Checkbox {
							idc = 153;
							x = 23.7027 * pixelGrid * pixelW;
							y = 30.228 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnButtonUp', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnButtonClick_154: OOP_Checkbox {
							idc = 154;
							x = 23.7027 * pixelGrid * pixelW;
							y = 35.266 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnButtonClick', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnMouseEnter_155: OOP_Checkbox {
							idc = 155;
							x = 52.6727 * pixelGrid * pixelW;
							y = 25.19 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMouseEnter', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnMouseExit_156: OOP_Checkbox {
							idc = 156;
							x = 52.6727 * pixelGrid * pixelW;
							y = 30.228 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMouseExit', _this]] call oo_ctrlModifyDialog;";
						};
					};
				};
				class layerKB_157 : OOP_SubLayer {
					idc = 157;
					x = 79.009 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 70.2302 * pixelGrid * pixelW;
					h = 50.38 * pixelGrid * pixelH;
					class controls{
						class OOP_TextRight_158_158: OOP_TextRight {
							idc = 158;
							x = 2.63363 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onKeyDown";
						};
						class OOP_TextRight_159_159: OOP_TextRight {
							idc = 159;
							x = 2.63363 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onKeyUp";
						};
						class OOP_TextRight_160_160: OOP_TextRight {
							idc = 160;
							x = 2.63363 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onChar";
						};
						class OOP_TextRight_161_161: OOP_TextRight {
							idc = 161;
							x = 36.8709 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onIMEChar";
						};
						class OOP_TextRight_162_162: OOP_TextRight {
							idc = 162;
							x = 36.8709 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onIMEComposition";
						};
						class cbOnKeyDown_163: OOP_Checkbox {
							idc = 163;
							x = 23.7027 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnKeyDown', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnKeyUp_164: OOP_Checkbox {
							idc = 164;
							x = 23.7027 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnKeyUp', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnChar_165: OOP_Checkbox {
							idc = 165;
							x = 23.7027 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnChar', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnIMEChar_166: OOP_Checkbox {
							idc = 166;
							x = 52.6727 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnIMEChar', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnIMEComposition_167: OOP_Checkbox {
							idc = 167;
							x = 52.6727 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnIMEComposition', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_168_168: OOP_TextRight {
							idc = 168;
							x = 36.8709 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "onJoystickButton";
						};
						class cbOnJoystickButton_169: OOP_Checkbox {
							idc = 169;
							x = 52.6727 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnJoystickButton', _this]] call oo_ctrlModifyDialog;";
						};
					};
				};
				class layerLB_170 : OOP_SubLayer {
					idc = 170;
					x = 79.009 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 70.2302 * pixelGrid * pixelW;
					h = 50.38 * pixelGrid * pixelH;
					class controls{
						class OOP_TextRight_171_171: OOP_TextRight {
							idc = 171;
							x = 2.63363 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnLBSelChanged";
						};
						class OOP_TextRight_172_172: OOP_TextRight {
							idc = 172;
							x = 2.63363 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnLBListSelChanged";
						};
						class OOP_TextRight_173_173: OOP_TextRight {
							idc = 173;
							x = 2.63363 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnLBDblClick";
						};
						class OOP_TextRight_174_174: OOP_TextRight {
							idc = 174;
							x = 36.8709 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnLBDrag";
						};
						class OOP_TextRight_175_175: OOP_TextRight {
							idc = 175;
							x = 36.8709 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnLBDragging";
						};
						class cbOnLBSelChanged_176: OOP_Checkbox {
							idc = 176;
							x = 23.7027 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnLBSelChanged', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnLBListSelChanged_177: OOP_Checkbox {
							idc = 177;
							x = 23.7027 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnLBListSelChanged', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnLBDblClick_178: OOP_Checkbox {
							idc = 178;
							x = 23.7027 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnLBDblClick', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnLBDrag_179: OOP_Checkbox {
							idc = 179;
							x = 52.6727 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnLBDrag', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnLBDragging_180: OOP_Checkbox {
							idc = 180;
							x = 52.6727 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnLBDragging', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_181_181: OOP_TextRight {
							idc = 181;
							x = 36.8709 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnLBDrop";
						};
						class cbOnLBDrop_182: OOP_Checkbox {
							idc = 182;
							x = 52.6727 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnLBDrop', _this]] call oo_ctrlModifyDialog;";
						};
					};
				};
				class layerTree_183 : OOP_SubLayer {
					idc = 183;
					x = 79.009 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 70.2302 * pixelGrid * pixelW;
					h = 50.38 * pixelGrid * pixelH;
					class controls{
						class OOP_TextRight_184_184: OOP_TextRight {
							idc = 184;
							x = 2.63363 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnTreeSelChanged";
						};
						class OOP_TextRight_185_185: OOP_TextRight {
							idc = 185;
							x = 2.63363 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnTreeLButtonDown";
						};
						class OOP_TextRight_186_186: OOP_TextRight {
							idc = 186;
							x = 2.63363 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnTreeDblClickk";
						};
						class OOP_TextRight_187_187: OOP_TextRight {
							idc = 187;
							x = 36.8709 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnTreeExpanded";
						};
						class OOP_TextRight_188_188: OOP_TextRight {
							idc = 188;
							x = 36.8709 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnTreeCollapsed";
						};
						class cbOnTreeSelChanged_189: OOP_Checkbox {
							idc = 189;
							x = 23.7027 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnTreeSelChanged', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnTreeLButtonDown_190: OOP_Checkbox {
							idc = 190;
							x = 23.7027 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnTreeLButtonDown', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnTreeDblClick_191: OOP_Checkbox {
							idc = 191;
							x = 23.7027 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnTreeDblClick', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnTreeExpanded_192: OOP_Checkbox {
							idc = 192;
							x = 52.6727 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnTreeExpanded', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnTreeCollapsed_193: OOP_Checkbox {
							idc = 193;
							x = 52.6727 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnTreeCollapsed', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_194_194: OOP_TextRight {
							idc = 194;
							x = 36.8709 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnTreeMouseMove";
						};
						class cbOnTreeMouseMove_195: OOP_Checkbox {
							idc = 195;
							x = 52.6727 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnTreeMouseMove', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_196_196: OOP_TextRight {
							idc = 196;
							x = 2.63363 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnTreeMouseHold";
						};
						class cbOnTreeMouseHold_197: OOP_Checkbox {
							idc = 197;
							x = 23.7027 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnTreeMouseHold', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnTreeMouseExit_198: OOP_Checkbox {
							idc = 198;
							x = 52.6727 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnTreeMouseExit', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_199_199: OOP_TextRight {
							idc = 199;
							x = 36.8709 * pixelGrid * pixelW;
							y = 20.152 * pixelGrid * pixelH;
							w = 15.8018 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnTreeMouseExit";
						};
					};
				};
				class layerToolCB_200 : OOP_SubLayer {
					idc = 200;
					x = 79.009 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 70.2302 * pixelGrid * pixelW;
					h = 50.38 * pixelGrid * pixelH;
					class controls{
						class OOP_TextRight_201_201: OOP_TextRight {
							idc = 201;
							x = 2.63363 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnToolBoxSelChanged";
						};
						class OOP_TextRight_202_202: OOP_TextRight {
							idc = 202;
							x = 2.63363 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnChecked";
						};
						class OOP_TextRight_203_203: OOP_TextRight {
							idc = 203;
							x = 28.97 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 23.7027 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnCheckedChanged";
						};
						class OOP_TextRight_204_204: OOP_TextRight {
							idc = 204;
							x = 28.97 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 23.7027 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnCheckBoxesSelChanged";
						};
						class cbOnToolBoxSelChanged_205: OOP_Checkbox {
							idc = 205;
							x = 23.7027 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnToolBoxSelChanged', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnChecked_206: OOP_Checkbox {
							idc = 206;
							x = 23.7027 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnChecked', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnCheckedChanged_207: OOP_Checkbox {
							idc = 207;
							x = 52.6727 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnCheckedChanged', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnCheckBoxesSelChanged_208: OOP_Checkbox {
							idc = 208;
							x = 52.6727 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnCheckBoxesSelChanged', _this]] call oo_ctrlModifyDialog;";
						};
					};
				};
				class layerOther_209 : OOP_SubLayer {
					idc = 209;
					x = 79.009 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 71.1081 * pixelGrid * pixelW;
					h = 50.38 * pixelGrid * pixelH;
					class controls{
						class OOP_TextRight_210_210: OOP_TextRight {
							idc = 210;
							x = 2.63363 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnHTMLLink";
						};
						class OOP_TextRight_211_211: OOP_TextRight {
							idc = 211;
							x = 2.63363 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnSliderPosChanged";
						};
						class OOP_TextRight_212_212: OOP_TextRight {
							idc = 212;
							x = 28.97 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 23.7027 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnObjectMoved";
						};
						class OOP_TextRight_213_213: OOP_TextRight {
							idc = 213;
							x = 28.97 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 23.7027 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnMenuSelected";
						};
						class cbOnHTMLLink_214: OOP_Checkbox {
							idc = 214;
							x = 23.7027 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnHTMLLink', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnSliderPosChanged_215: OOP_Checkbox {
							idc = 215;
							x = 23.7027 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnSliderPosChanged', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnObjectMoved_216: OOP_Checkbox {
							idc = 216;
							x = 52.6727 * pixelGrid * pixelW;
							y = 5.038 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnObjectMoved', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnMenuSelected_217: OOP_Checkbox {
							idc = 217;
							x = 52.6727 * pixelGrid * pixelW;
							y = 10.076 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnMenuSelected', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_218_218: OOP_TextRight {
							idc = 218;
							x = 2.63363 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnDraw";
						};
						class OOP_TextRight_219_219: OOP_TextRight {
							idc = 219;
							x = 31.6036 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "OnVideoStopped";
						};
						class cbOnVideoStopped_220: OOP_Checkbox {
							idc = 220;
							x = 52.6727 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnVideoStopped', _this]] call oo_ctrlModifyDialog;";
						};
						class cbOnDraw_221: OOP_Checkbox {
							idc = 221;
							x = 23.7027 * pixelGrid * pixelW;
							y = 15.114 * pixelGrid * pixelH;
							w = 2.63363 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onCheckedChanged = "['static', ['onCheckedChanged_cbOnDraw', _this]] call oo_ctrlModifyDialog;";
						};
					};
				};
				class layerStyle_222 : OOP_SubLayer {
					idc = 222;
					x = 79.009 * pixelGrid * pixelW;
					y = 35.266 * pixelGrid * pixelH;
					w = 71.1081 * pixelGrid * pixelW;
					h = 52.899 * pixelGrid * pixelH;
					class controls{
						class OOP_TextRight_223_223: OOP_TextRight {
							idc = 223;
							x = 2.63363 * pixelGrid * pixelW;
							y = 2.519 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "ID Control";
						};
						class editID_224: OOP_Edit {
							idc = 224;
							x = 26.3363 * pixelGrid * pixelW;
							y = 2.519 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
						};
						class OOP_TextRight_225_225: OOP_TextRight {
							idc = 225;
							x = 2.63363 * pixelGrid * pixelW;
							y = 7.557 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Name";
						};
						class editName_226: OOP_Edit {
							idc = 226;
							x = 26.3363 * pixelGrid * pixelW;
							y = 7.557 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onSetFocus = "['static', ['onSetFocus_editName', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_227_227: OOP_TextRight {
							idc = 227;
							x = 2.63363 * pixelGrid * pixelW;
							y = 12.595 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Text";
						};
						class editText_228: OOP_Edit {
							idc = 228;
							x = 26.3363 * pixelGrid * pixelW;
							y = 12.595 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onSetFocus = "['static', ['onSetFocus_editText', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_229_229: OOP_TextRight {
							idc = 229;
							x = 2.63363 * pixelGrid * pixelW;
							y = 17.633 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Background Color";
						};
						class editBGColor_230: OOP_Edit {
							idc = 230;
							x = 26.3363 * pixelGrid * pixelW;
							y = 17.633 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "[-1,-1,-1,-1]";
							onSetFocus = "['static', ['onSetFocus_editBGColor', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_231_231: OOP_TextRight {
							idc = 231;
							x = 2.63363 * pixelGrid * pixelW;
							y = 22.671 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Text Color";
						};
						class editTextColor_232: OOP_Edit {
							idc = 232;
							x = 26.3363 * pixelGrid * pixelW;
							y = 22.671 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "[-1,-1,-1,-1]";
							onSetFocus = "['static', ['onSetFocus_editTextColor', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_233_233: OOP_TextRight {
							idc = 233;
							x = 2.63363 * pixelGrid * pixelW;
							y = 27.709 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Foreground Color";
						};
						class editFGColor_234: OOP_Edit {
							idc = 234;
							x = 26.3363 * pixelGrid * pixelW;
							y = 27.709 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "[-1,-1,-1,-1]";
							onSetFocus = "['static', ['onSetFocus_editFGColor', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_235_235: OOP_TextRight {
							idc = 235;
							x = 2.63363 * pixelGrid * pixelW;
							y = 32.747 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Tooltip";
						};
						class editTooltip_236: OOP_Edit {
							idc = 236;
							x = 26.3363 * pixelGrid * pixelW;
							y = 32.747 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							onSetFocus = "['static', ['onSetFocus_editTooltip', _this]] call oo_ctrlModifyDialog;";
						};
						class editTooltipColorBoX_237: OOP_Edit {
							idc = 237;
							x = 26.3363 * pixelGrid * pixelW;
							y = 37.785 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "[-1,-1,-1,-1]";
							onSetFocus = "['static', ['onSetFocus_editTooltipColorBoX', _this]] call oo_ctrlModifyDialog;";
						};
						class editTooltipColorShade_238: OOP_Edit {
							idc = 238;
							x = 26.3363 * pixelGrid * pixelW;
							y = 42.823 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "[-1,-1,-1,-1]";
							onSetFocus = "['static', ['onSetFocus_editTooltipColorShade', _this]] call oo_ctrlModifyDialog;";
						};
						class editTooltipColorText_239: OOP_Edit {
							idc = 239;
							x = 26.3363 * pixelGrid * pixelW;
							y = 47.861 * pixelGrid * pixelH;
							w = 42.1381 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "[-1,-1,-1,-1]";
							onSetFocus = "['static', ['onSetFocus_editTooltipColorText', _this]] call oo_ctrlModifyDialog;";
						};
						class OOP_TextRight_240_240: OOP_TextRight {
							idc = 240;
							x = 2.63363 * pixelGrid * pixelW;
							y = 37.785 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Tooltip Color Box";
						};
						class OOP_TextRight_241_241: OOP_TextRight {
							idc = 241;
							x = 2.63363 * pixelGrid * pixelW;
							y = 42.823 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Tooltip Color Shade";
						};
						class OOP_TextRight_242_242: OOP_TextRight {
							idc = 242;
							x = 2.63363 * pixelGrid * pixelW;
							y = 47.861 * pixelGrid * pixelH;
							w = 21.0691 * pixelGrid * pixelW;
							h = 2.519 * pixelGrid * pixelH;
							text = "Tooltip Color Text";
						};
					};
				};
			};
		};
	};
	class controls {};
};

/*
["ctrlModifyDialog",9001,[[[["57.9399 * pixelGrid * pixelW","27.709 * pixelGrid * pixelH","94.8108 * pixelGrid * pixelW","70.532 * pixelGrid * pixelH"],"#(rgb,8,8,3)color(0.2,0.2,0.2,0.8)","","","OOP_Picture",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["57.9399 * pixelGrid * pixelW","27.709 * pixelGrid * pixelH","94.8108 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH"],"Modify control:","title","","OOP_Text",true,[],[1,1,1,1],[0.2,0.7,0.2,1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["57.9399 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","3.7785 * pixelGrid * pixelH"],"Style","btnStyle","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["57.9399 * pixelGrid * pixelW","40.304 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","3.97614 * pixelGrid * pixelH"],"Gen EVH","btnGen","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["57.9399 * pixelGrid * pixelW","45.342 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","3.97614 * pixelGrid * pixelH"],"Mouse EVH","btnMouse","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["57.9399 * pixelGrid * pixelW","50.38 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","3.97614 * pixelGrid * pixelH"],"Keyboard EVH","btnKB","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["57.9399 * pixelGrid * pixelW","55.418 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","3.97614 * pixelGrid * pixelH"],"LB EVH","btnLB","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["57.9399 * pixelGrid * pixelW","60.456 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","3.97614 * pixelGrid * pixelH"],"Tree EVH","btnTree","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["57.9399 * pixelGrid * pixelW","65.494 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","3.97614 * pixelGrid * pixelH"],"Tool/Cb EVH","btnTool","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["57.9399 * pixelGrid * pixelW","70.532 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","3.97614 * pixelGrid * pixelH"],"Other EVH","btnOther","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["115.88 * pixelGrid * pixelW","89.4245 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH"],"Valider","btnValider","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["73.7417 * pixelGrid * pixelW","89.4245 * pixelGrid * pixelH","18.4354 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH"],"Fermer","btnClose","","OOP_Button",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["79.009 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","70.2302 * pixelGrid * pixelW","50.38 * pixelGrid * pixelH"],"","layerGen","","OOP_SubLayer",false,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]],[[[["7.9009 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Init","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["7.9009 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onDestroy","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["7.9009 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onLoad","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onSetFocus","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onKillFocus","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onTimer","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onCanDestroy","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbInit","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnDestroy","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnLoad","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnSetFocus","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnKillFocus","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnTimer","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnCanDestroy","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]],[[["79.009 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","70.2302 * pixelGrid * pixelW","50.38 * pixelGrid * pixelH"],"","layerMouse","","OOP_SubLayer",false,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]],[[[["2.63363 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onMouseButtonDown","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onMouseButtonUp","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onMouseButtonClick","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onMouseButtonDblClick","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onMouseMoving","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onMouseHolding","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onMouseZChanged","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onButtonDblClick","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMouseButtonDown","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMouseButtonUp","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMouseButtonClick","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMouseButtonDblClick","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMouseMoving","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMouseHolding","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMouseZChanged","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnButtonDblClick","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","25.19 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onButtonDown","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","30.228 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onButtonUp","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onButtonClick","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["31.6036 * pixelGrid * pixelW","25.19 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onMouseEnter","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["31.6036 * pixelGrid * pixelW","30.228 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onMouseExit","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","25.19 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnButtonDown","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","30.228 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnButtonUp","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnButtonClick","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","25.19 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMouseEnter","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","30.228 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMouseExit","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]],[[["79.009 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","70.2302 * pixelGrid * pixelW","50.38 * pixelGrid * pixelH"],"","layerKB","","OOP_SubLayer",false,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]],[[[["2.63363 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onKeyDown","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onKeyUp","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onChar","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onIMEChar","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onIMEComposition","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnKeyDown","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnKeyUp","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnChar","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnIMEChar","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnIMEComposition","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"onJoystickButton","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnJoystickButton","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]],[[["79.009 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","70.2302 * pixelGrid * pixelW","50.38 * pixelGrid * pixelH"],"","layerLB","","OOP_SubLayer",false,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]],[[[["2.63363 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnLBSelChanged","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnLBListSelChanged","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnLBDblClick","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnLBDrag","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnLBDragging","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnLBSelChanged","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnLBListSelChanged","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnLBDblClick","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnLBDrag","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnLBDragging","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnLBDrop","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnLBDrop","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]],[[["79.009 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","70.2302 * pixelGrid * pixelW","50.38 * pixelGrid * pixelH"],"","layerTree","","OOP_SubLayer",false,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]],[[[["2.63363 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnTreeSelChanged","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnTreeLButtonDown","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnTreeDblClickk","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnTreeExpanded","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnTreeCollapsed","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnTreeSelChanged","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnTreeLButtonDown","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnTreeDblClick","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnTreeExpanded","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnTreeCollapsed","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnTreeMouseMove","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnTreeMouseMove","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnTreeMouseHold","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnTreeMouseHold","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnTreeMouseExit","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["36.8709 * pixelGrid * pixelW","20.152 * pixelGrid * pixelH","15.8018 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnTreeMouseExit","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]],[[["79.009 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","70.2302 * pixelGrid * pixelW","50.38 * pixelGrid * pixelH"],"","layerToolCB","","OOP_SubLayer",false,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]],[[[["2.63363 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnToolBoxSelChanged","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnChecked","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["28.97 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","23.7027 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnCheckedChanged","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["28.97 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","23.7027 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnCheckBoxesSelChanged","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnToolBoxSelChanged","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnChecked","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnCheckedChanged","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnCheckBoxesSelChanged","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]],[[["79.009 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","71.1081 * pixelGrid * pixelW","50.38 * pixelGrid * pixelH"],"","layerOther","","OOP_SubLayer",false,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]],[[[["2.63363 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnHTMLLink","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnSliderPosChanged","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["28.97 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","23.7027 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnObjectMoved","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["28.97 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","23.7027 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnMenuSelected","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnHTMLLink","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnSliderPosChanged","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","5.038 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnObjectMoved","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","10.076 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnMenuSelected","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnDraw","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["31.6036 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"OnVideoStopped","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["52.6727 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnVideoStopped","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["23.7027 * pixelGrid * pixelW","15.114 * pixelGrid * pixelH","2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","cbOnDraw","","OOP_Checkbox",true,["onCheckedChanged"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]],[[["79.009 * pixelGrid * pixelW","35.266 * pixelGrid * pixelH","71.1081 * pixelGrid * pixelW","52.899 * pixelGrid * pixelH"],"","layerStyle","","OOP_SubLayer",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]],[[[["2.63363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"ID Control","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","editID","","OOP_Edit",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","7.557 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Name","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","7.557 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","editName","","OOP_Edit",true,["onSetFocus"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","12.595 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Text","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","12.595 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","editText","","OOP_Edit",true,["onSetFocus"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","17.633 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Background Color","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","17.633 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"[-1,-1,-1,-1]","editBGColor","","OOP_Edit",true,["onSetFocus"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","22.671 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Text Color","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","22.671 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"[-1,-1,-1,-1]","editTextColor","","OOP_Edit",true,["onSetFocus"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","27.709 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Foreground Color","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","27.709 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"[-1,-1,-1,-1]","editFGColor","","OOP_Edit",true,["onSetFocus"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","32.747 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Tooltip","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","32.747 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"","editTooltip","","OOP_Edit",true,["onSetFocus"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","37.785 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"[-1,-1,-1,-1]","editTooltipColorBoX","","OOP_Edit",true,["onSetFocus"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","42.823 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"[-1,-1,-1,-1]","editTooltipColorShade","","OOP_Edit",true,["onSetFocus"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["26.3363 * pixelGrid * pixelW","47.861 * pixelGrid * pixelH","42.1381 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"[-1,-1,-1,-1]","editTooltipColorText","","OOP_Edit",true,["onSetFocus"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","37.785 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Tooltip Color Box","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","42.823 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Tooltip Color Shade","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]],[[["2.63363 * pixelGrid * pixelW","47.861 * pixelGrid * pixelH","21.0691 * pixelGrid * pixelW","2.519 * pixelGrid * pixelH"],"Tooltip Color Text","","","OOP_TextRight",true,[],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1]]]]]]]
*/
