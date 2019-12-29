// Macro to easily make more unit classes for civilian presence module
#define __CP_CLASS(baseClass) class baseClass; \
class vin_cp_##baseClass: baseClass \
{ fsmDanger = "\z\vindicta\addons\civilian_presence\danger.fsm"; };

class CfgVehicles {

	__CP_CLASS(C_Man_casual_1_F_tanoan)
	__CP_CLASS(C_Man_casual_2_F_tanoan)
	__CP_CLASS(C_Man_casual_3_F_tanoan)
	__CP_CLASS(C_Man_casual_4_F_tanoan)
	__CP_CLASS(C_Man_casual_5_F_tanoan)
	__CP_CLASS(C_Man_casual_6_F_tanoan)
	
	__CP_CLASS(C_Man_casual_1_F_euro)
	__CP_CLASS(C_Man_casual_2_F_euro)
	__CP_CLASS(C_Man_casual_3_F_euro)
	__CP_CLASS(C_Man_casual_4_F_euro)
	__CP_CLASS(C_Man_casual_5_F_euro)
	__CP_CLASS(C_Man_casual_6_F_euro)

	__CP_CLASS(C_man_polo_1_F_euro)
	__CP_CLASS(C_man_polo_2_F_euro)
	__CP_CLASS(C_man_polo_3_F_euro)
	__CP_CLASS(C_man_polo_4_F_euro)
	__CP_CLASS(C_man_polo_5_F_euro)
	__CP_CLASS(C_man_polo_6_F_euro)
};
