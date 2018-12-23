call compile preprocessFileLineNumbers "AI\Action\Action.sqf";

call compile preprocessFileLineNumbers "AI\ActionComposite\ActionComposite.sqf";
call compile preprocessFileLineNumbers "AI\ActionCompositeParallel\ActionCompositeParallel.sqf";
call compile preprocessFileLineNumbers "AI\ActionCompositeSerial\ActionCompositeSerial.sqf";

call compile preprocessFileLineNumbers "AI\AI\AI.sqf";


call compile preprocessFileLineNumbers "AI\Goal\Goal.sqf";

call compile preprocessFileLineNumbers "AI\Sensor\Sensor.sqf";
call compile preprocessFileLineNumbers "AI\SensorStimulatable\SensorStimulatable.sqf";

call compile preprocessFileLineNumbers "AI\WorldState\WorldState.sqf";

call compile preprocessFileLineNumbers "AI\WorldFact\WorldFact.sqf";

call compile preprocessFileLineNumbers "AI\StimulusManager\StimulusManager.sqf";

call compile preprocessFileLineNumbers "AI\Misc\databaseFunctions.sqf";







// Garrison AI classes
call compile preprocessFileLineNumbers "AI\Garrison\initClasses.sqf";
/*
call compile preprocessFileLineNumbers "AI\Garrison\AIGarrison.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\SensorGarrison.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\SensorGarrisonStimulatable.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\SensorGarrisonHealth.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\SensorGarrisonTargets.sqf";

call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonMountCrew.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonMountInfantry.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonMoveMounted.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonMoveMountedCargo.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonMoveDismounted.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonRepairAllVehicles.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonRelax.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonDefendPassive.sqf";

// Cargo operations
call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonLoadCargo.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\ActionGarrisonUnloadCurrentCargo.sqf";

call compile preprocessFileLineNumbers "AI\Garrison\GoalGarrisonRelax.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\GoalGarrisonRepairAllVehicles.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\GoalGarrisonMove.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\GoalGarrisonMoveCargo.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\GoalGarrisonDefendPassive.sqf";


// Create a database with costs, effects, preconditions, etc
call compile preprocessFileLineNumbers "AI\Garrison\initDatabase.sqf";
*/



// Group AI classes
call compile preprocessFileLineNumbers "AI\Group\initClasses.sqf";
/*
call compile preprocessFileLineNumbers "AI\Group\AIGroup.sqf";
call compile preprocessFileLineNumbers "AI\Group\SensorGroup.sqf";
call compile preprocessFileLineNumbers "AI\Group\SensorGroupStimulatable.sqf";

call compile preprocessFileLineNumbers "AI\Group\SensorGroupTargets.sqf";
*/



// Unit AI classes
call compile preprocessFileLineNumbers "AI\Unit\AIUnit.sqf";
call compile preprocessFileLineNumbers "AI\Unit\ActionUnitSalute.sqf";
call compile preprocessFileLineNumbers "AI\Unit\GoalUnitSalute.sqf";
call compile preprocessFileLineNumbers "AI\Unit\SensorUnitSalute.sqf";
call compile preprocessFileLineNumbers "AI\Unit\SensorUnitCivNear.sqf";
call compile preprocessFileLineNumbers "AI\Unit\GoalUnitScareAway.sqf";
call compile preprocessFileLineNumbers "AI\Unit\ActionUnitScareAway.sqf";