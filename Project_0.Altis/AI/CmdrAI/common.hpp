#define OOP_INFO
#define OOP_DEBUG
#define OOP_WARNING
#define OOP_ERROR
#define OOP_ASSERT

#define MODEL_HANDLE_INVALID -1

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Templates\Efficiency.hpp"
#include "CmdrAction\CmdrActionStates.hpp"

#define EFF_ZERO T_EFF_null

// Minimum efficiency of a garrison.
// Controls lots of commander actions, e.g. reinforcements won't be less than this, or leave less than this at an outpost.
#define EFF_MIN_EFF [6, 0, 0, 0, 6, 0, 0, 0]

