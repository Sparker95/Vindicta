// - - - - - - - SAVING - - - - - - -

Classes we want to save:

- - Base - -
MessageReceiver
MessageReceiverEx

- - Containers - - 
Location
Garrison
Group
Unit

- - Commander AI - - 
Intel
AICommander
ModelBase
ClusterModel
GarrisonModel
LocationModel
WorldModel
CmdrAction - all actions
ASTs - all ASTs
CmdrStrategy - all strategies
Grid

- - Game Mode - -
GameMode, CivilWarGameMode

Saving methods of objects:

```
void preSave() { //    - call before saving

    // Call preSave of our parent class
    parent::preSave();

    // Setup all variables we are going to serialize from the game world
    // For instance, convert object handles of ARMA objects created by
    // player into [objClassName, objPos, objRotation] to restore that later
    // ...
    // ...
}

// Actual method which saves this object
// Each class which needs saving will implement this on its own,
// But will have a similar algorithm
void save(storageInterface* saver) {
    // Before serialization we might do some setup
    this.preSave();
    
    serializedObj = this.serialize(ATTR_SAVE);  // Serialize all vars marked for saving into an array
    
    saver.saveVariable( this,               // A unique string, our reference
                        serializedObj);     // Data to save

    // Save objects which we own as well:
    forEach this.compositions do { // Let's imagine that Composition is some other class
        _x.save(saver);
    }
    forEach this.vehicles do {
        _x.save(saver);
    }

    // Clear up all the extra variables we have made for serialization
    this.postSave();
}

void postSave() {    // call after saving
    // Do our stuff
    // ...

    // Call parent class postSave
    parent::postSave();
}
```

Loading methods:

```
//
void load(storageInterface* loader) { 
    // By now the object is 'created' but its constructors have not run
    // It is just 'preallocated space', its variables are not defined
    
    // Get serialized array
    serializedObj = storageInterface.loadVariable(this);

    // Deserialize into this object ref
    deserialize(this, serializedObj);

    // Load objects which we own
        forEach this.compositions do { // Let's imagine that Composition is some other class
        _x.load(loader);
    }
    forEach this.vehicles do {
        _x.load(loader);
    }

    // Run our post-load code
    this.postLoad();
}

void postLoad() {
    // Call parent class's method
    parent::postLoad();

    // Start our timers, etc
    this.timer = new timer(2);
}
```