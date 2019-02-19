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

call compile preprocessFileLineNumbers "AI\Misc\repairFunctions.sqf";

call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf";



// *Commander* AI
call compile preprocessFileLineNumbers "AI\Commander\initClasses.sqf";

// Garrison AI classes
call compile preprocessFileLineNumbers "AI\Garrison\initClasses.sqf";


// Group AI classes
call compile preprocessFileLineNumbers "AI\Group\initClasses.sqf";

// Unit AI classes
call compile preprocessFileLineNumbers "AI\Unit\initClasses.sqf";
