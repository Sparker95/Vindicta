/*
Initialize variables related to composition
*/

#define _CALCULATE_COMP_MASK(compMaskVar, effMaskVar) compMaskVar = [1] call comp_fnc_new; \
[compMaskVar, [effMaskVar], [], [], []] call comp_fnc_applyEfficiencyMasks; \

// Precalculate composition masks from efficiency masks
_CALCULATE_COMP_MASK(T_comp_ground_mask, T_EFF_ground_mask)
_CALCULATE_COMP_MASK(T_comp_air_mask, T_EFF_air_mask)
_CALCULATE_COMP_MASK(T_comp_water_mask, T_EFF_water_mask)
_CALCULATE_COMP_MASK(T_comp_transport_mask, T_EFF_transport_mask)
_CALCULATE_COMP_MASK(T_comp_infantry_mask, T_EFF_infantry_mask)

// todo there is nothing in efficiency arrays which tells that this unit is static or not
// We calculate the mask from a specific set of units for now
T_comp_static_mask = [1] call comp_fnc_new;
[T_comp_static_mask, [], [], [T_static], []] call comp_fnc_applyEfficiencyMasks;


// Precalculate popular combinations of masks to save time during planning
T_comp_ground_or_infantry_mask = [T_comp_ground_mask, T_comp_infantry_mask] call comp_fnc_maskOrMask;
/*
T_comp_ground_and_transport_or_infantry_mask = [([T_comp_ground_mask, T_comp_transport_mask] call comp_fnc_maskAndMask),
												T_comp_infantry_mask] call comp_fnc_maskOrMask;
*/