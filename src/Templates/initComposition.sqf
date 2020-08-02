/*
Initialize variables related to composition
*/

#define _CALCULATE_COMP_MASK_FROM_EFF(compMaskVar, effMaskVar) \
	compMaskVar = [1] call comp_fnc_new; \
	[compMaskVar, [effMaskVar], [], [], []] call comp_fnc_applyEfficiencyMasks;

#define _CALCULATE_COMP_MASK_FROM_ITEMS(compMaskVar, itemMaskVar) \
	compMaskVar = [1] call comp_fnc_new; \
	[compMaskVar, [], [], [itemMaskVar], []] call comp_fnc_applyEfficiencyMasks;

// Precalculate composition masks from efficiency masks
_CALCULATE_COMP_MASK_FROM_EFF(T_comp_ground_mask, T_EFF_ground_mask)
_CALCULATE_COMP_MASK_FROM_EFF(T_comp_air_mask, T_EFF_air_mask)
_CALCULATE_COMP_MASK_FROM_EFF(T_comp_water_mask, T_EFF_water_mask)
_CALCULATE_COMP_MASK_FROM_EFF(T_comp_transport_mask, T_EFF_transport_mask)
_CALCULATE_COMP_MASK_FROM_EFF(T_comp_infantry_mask, T_EFF_infantry_mask)

// todo there is nothing in efficiency arrays which tells that this unit is static or not
// We calculate the mask from a specific set of units for now
_CALCULATE_COMP_MASK_FROM_ITEMS(T_comp_static_mask, T_static);

// Comp mask for cargo
_CALCULATE_COMP_MASK_FROM_ITEMS(T_comp_static_cargo, T_PL_cargo);

// Comp mask for the default blacklist (excludes certain units from common actions)
_CALCULATE_COMP_MASK_FROM_ITEMS(T_comp_default_blacklist, T_PL_inf_special);

// Precalculate popular combinations of masks to save time during planning

//diag_log T_comp_infantry_mask;

T_comp_ground_or_infantry_mask = [T_comp_ground_mask, T_comp_infantry_mask] call comp_fnc_maskOrMask;

T_comp_static_or_cargo_mask = [T_comp_static_mask, T_comp_static_cargo] call comp_fnc_maskOrMask;

T_comp_null = [0] call comp_fnc_new;