#define CIV_CLASS_BODY {\
		fsmDanger = "z\project_0\addons\civilianPresence\danger.fsm";\
	};

class CfgVehicles {

	class Man;
	class CAManBase: Man{
		class UserActions{
			class talkTo{
				userActionID = 50;
				displayName = "Talk to";
				displayNameDefault = "<img image='\A3\Ui_f\data\IGUI\Cfg\Actions\talk_ca.paa' size='2.5' />";
				priority = 1.5;
				radius = 5;
				position = "";
				onlyForPlayer = 0;
				condition = "alive this && {!(this isEqualTo player)}";
				statement = "this call Dialog_fnc_interact_talkAction";
			};
		};
	};

	class C_Man_casual_1_F_tanoan;
	class CivilianPresence_C_Man_casual_1_F_tanoan: C_Man_casual_1_F_tanoan
	CIV_CLASS_BODY

	class C_Man_casual_2_F_tanoan;
	class CivilianPresence_C_Man_casual_2_F_tanoan: C_Man_casual_2_F_tanoan
	CIV_CLASS_BODY

	class C_Man_casual_3_F_tanoan;
	class CivilianPresence_C_Man_casual_3_F_tanoan: C_Man_casual_3_F_tanoan
	CIV_CLASS_BODY

	class C_Man_casual_4_F_tanoan;
	class CivilianPresence_C_Man_casual_4_F_tanoan: C_Man_casual_4_F_tanoan
	CIV_CLASS_BODY

	class C_Man_casual_5_F_tanoan;
	class CivilianPresence_C_Man_casual_5_F_tanoan: C_Man_casual_5_F_tanoan
	CIV_CLASS_BODY
	
	class C_Man_casual_6_F_tanoan;
	class CivilianPresence_C_Man_casual_6_F_tanoan: C_Man_casual_6_F_tanoan
	CIV_CLASS_BODY
	
	class C_Man_casual_1_F_euro;
	class CivilianPresence_C_Man_casual_1_F_euro: C_Man_casual_1_F_euro
	CIV_CLASS_BODY
	
	class C_Man_casual_2_F_euro;
	class CivilianPresence_C_Man_casual_2_F_euro: C_Man_casual_2_F_euro
	CIV_CLASS_BODY
	
	class C_Man_casual_3_F_euro;
	class CivilianPresence_C_Man_casual_3_F_euro: C_Man_casual_3_F_euro
	CIV_CLASS_BODY
	
	class C_Man_casual_4_F_euro;
	class CivilianPresence_C_Man_casual_4_F_euro: C_Man_casual_4_F_euro
	CIV_CLASS_BODY
	
	class C_Man_casual_5_F_euro;
	class CivilianPresence_C_Man_casual_5_F_euro: C_Man_casual_5_F_euro
	CIV_CLASS_BODY
	
	class C_Man_casual_6_F_euro;
	class CivilianPresence_C_Man_casual_6_F_euro: C_Man_casual_6_F_euro
	CIV_CLASS_BODY
	
	class C_man_polo_1_F_euro;
	class CivilianPresence_C_man_polo_1_F_euro: C_man_polo_1_F_euro
	CIV_CLASS_BODY
	
	class C_man_polo_2_F_euro;
	class CivilianPresence_C_man_polo_2_F_euro: C_man_polo_2_F_euro
	CIV_CLASS_BODY
	
	class C_man_polo_3_F_euro;
	class CivilianPresence_C_man_polo_3_F_euro: C_man_polo_3_F_euro
	CIV_CLASS_BODY
	
	class C_man_polo_4_F_euro;
	class CivilianPresence_C_man_polo_4_F_euro: C_man_polo_4_F_euro
	CIV_CLASS_BODY
	
	class C_man_polo_5_F_euro;
	class CivilianPresence_C_man_polo_5_F_euro: C_man_polo_5_F_euro
	CIV_CLASS_BODY
	
	class C_man_polo_6_F_euro;
	class CivilianPresence_C_man_polo_6_F_euro: C_man_polo_6_F_euro
	CIV_CLASS_BODY
	
	
};
