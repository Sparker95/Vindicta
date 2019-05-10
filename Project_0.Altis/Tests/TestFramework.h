if (isNil "TestFramework_init") then {
    TestFramework_init = true;
    call compile preprocessFile "Tests\TestFramework.sqf";
};