#include "..\Tests\TestFramework.h"

Tests = compile preprocessFile "Templates\initVariablesServer.sqf";

[Tests] call Test_wrapper_fn;