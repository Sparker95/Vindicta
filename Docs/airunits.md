Options for air AI

# Disposition

Each location has its own air garrison.

# Coordination

- AI commander coordinates via a new system:
    - General garrisons request aid from AI commander.
    - AI commander assigns jobs to air garrisons -- needs to decide which ones, starts to seems like scoring of CmdrAI??

    PROS
    - faster response than planning
    CONS
    - another AI system?!

- AI commander coordiantes via planning:
    - Cmdr generates air support CmdrActions
    - Normal CmdrAction behavior -- scoring based on distance and resources, etc.

    PROS
    - reusing existing system designed for multi garrison interactions. Could have AST_AirTransport that assigns goals to both garrisons for instance?

    CONS
    - painful to write new actions? maybe not so much if air actions are quite simple? maybe even reuse existing ones
    - can model support air actions/units/garrisons?
    - not very dynamic

- Garrison AI itself coordinates:
    PROS
    - We can have more fluid behavior --
        garrison can have worldstate property of "air transport available"
        causing goal "move with air" to activate instead of normal move
        garrison will find location for pickup, then directly request air transport from some garrison it decides on, or from commander?...

    CONS
    - Not really coordinating, which ever one happens to process when a job is available takes it / requesting garrison picks
    - No intel on this actions -- is it bad? air actions are support mostly, not independant.

Can we support CmdrAction + another system?
    - Yes, if garrison always splits to perform operations then remaining garrison can be assigned external goals/split without it interfering with in progress actions.


Conclusions:
  - air garrisons are always spawned, actions that involve air units force spawning of garrisons involved
  - always split off a new garrison for air support actions (rather than assigning groups):
    - it means original garrison is free to persue more general goals (or external goals from CmdrAction / whatever)
    - spawning is more sensical (groups don't need to spawn at different points on the map for one garrison)
    - follows existing pattern
    - allows them to easily return to any location they want to, not just the original one
  - spawn air garrisons first on loading -- should happen anyway if air garrisons are marked to be always spawned they
    should spawn on creation, whereas other enemy garrisons will spawn by process function later
  - for transport:
    - use world state property of "air transport available" OR "has helicopters attached"
    MoveAirAction:
      Store the action persistent state on AIGarrison (what is required to spawn/despawn it)

      Inf units have states:
        WaitingForPickup - go to near pickup location
        InTransit - whatever you do stay in vehicle!
        Arrived - defend landing area, garrison nearby buildings etc. Do NOT regroup!
      Air units have states:
        GoToPickup - liftoff, fly to pickup location and wait for landing
        Pickup - land at pickup location and wait until passengers indicate they are ready
        GoToDropOff - liftoff, fly to dropoff location
        DropOff - land at dropoff location and kick out all units immediately

      Need to handle multiple air groups properly, e.g. landing one at a time / loitering.

      ACTIVATE:
        Force spawn of this garrison
        Select pickup and drop off locations or read from AIGarrison
        Assign more air groups from free air garrisons if available (avoid teleporting them...)
        Order all units to move *near* pickup location (not right on it, need space for landings)
        Set all unit states or read from AIGarrison the saved states

      PROCESS:
        Air units state machine:
          None -> GoToPickup : passengers remain at pickup
          GoToPickup -> Pickup : passengers remain at pickup and pickup area is clear
          Pickup -> GoToDropOff : either full or no passengers remain at pickup
          GoToDropOff -> DropOff : contains passengers and drop off area is clear
          All -> None : no passengers mounted, nor remaining at pickup

        Inf units:
          Board all units possible at pickup onto air units in state Pickup and on the ground
          Kick all units out of air units in state DropOff and on the ground (how about fast rope / air drop?), set defensive unit goals
          Set all units at destination to cover the area (NO re-group allowed or they might run back to the pickup!)

        If all units are at destination and dismounted from air units then:
          Split air groups back into separate air garrison, let them use ambient goals to rtb or whatever

      SPAWN:
        We use loaded state from AIGarrison to control the spawning, we have states for all air units and inf so we can place them somehow appropriately.
        Spawn air units based on state:
          GoToPickup: spawn in near the pickup location
          Pickup: spawn on the ground at pickup location
          GotoDropOff: spawn in the air enroute to drop off (randomly I guess?)
          DropOff: spawn on the ground at drop off location
        Spawn inf units based on state:
          WaitingForPickup: spawn at pickup location
          InTransit: spawn in assigned helicopter
          Arrived: spawn in defensive position at drop off

    ActionSendAirSupportGarrison:
      Triggered by goal of support requested, targets spotted, whatever
      ACTIVATE:
        Split off attack wing into a new garrison
        Give new garrison the external goal GoalAirAttackGarrison / whatever

      PROCESS:
        Activate and then done

    ActionAirAttackGarrison:

        Inf units:
          Board all units possible at pickup onto air units in state Pickup and on the ground
          Kick all units out of air units in state DropOff and on the ground (how about fast rope / air drop?), set defensive unit goals
          Set all units at destination to cover the area (NO re-group allowed or they might run back to the pickup!)

        If all units are at destination and dismounted from air units then:
          Split air groups back into separate air garrison, let them use ambient goals to rtb or whatever

      SPAWN:

  Default air garrison goals can be things like:
    - return to base (default goal if not at base and no other goal) -- will select a base to return to
    - flee -- if assigned location general garrison is destroyed or location taken
    - defend -- general take off and fly around when area is dangerous
    - air patrol
    - recon
    - attack -- attack known enemies (clusters or actual units maybe?)

AI object of each garrison just takes what ever jobs are available


To get CAS:
- make air garrisons always spawned, and spawn on load correctly
- add choppers to reinforcement, have them fly in from off map perhaps, like police?

- AIGarrisonAir should remember home base?
- AIGarrison can split off another garrison and give it a goal?
- specialize AIGroup for air units, at least goals etc, maybe sensors and world state?
- add air AI group behaviors for defensive postures
- add air AI garrison attack
- add new QRF / attack for air units -- don't send them home, air garrison finds its own home as it requires space, just split + attack goal

TODO:
- fix spawn on load for inflight helis -- need to use action spawn in somehow, 