// Fireteam Gamemode

// Description:
// * Players start with an unarmed vehicle around the objective.
// * Objective type and location is placed randomly.
// * New objectives will be assigned after the current objective is completed and will only be placed in adjacent locations.
// * A player will remain dead until the objective is complete.
// * Dead players will respawn upon a new objective being assigned.
// * Equipment will spawn in buildings around the current objective AO.
// * Vehicles will also spawn in the AO. Higher value vehicles spawn with fewer ammo and fuel.

// Configuration:
// * randomloot\server.sqf - _maxSpawns     // Maxmimum number of items per building
// * randomloot\server.sqf - _probability   // Probability that the item spawns in a building

if (!isServer) exitWith {};

// Array of "Locations": [name, size, pos, angle]
_objLocations = [
    ["Eponia", [500, 500], [12585.727, 15133.22], 0],
    ["", [200, 250], [7622.8159, 6435.5762], 320]
]; //[12585.727,181.9342,15133.22]

/* United Sahrani Locations
    [],
    []
*/

// Array of "Objective Types": ["name"]
_objTypes = [
    ["Steal"],
    ["Destroy"],
    ["Hold"]
];

/* Incomplete Objectives
    ["kill"],
    ["transport"],
    ["resupply"],
    ["locate"],
    ["capture"],
    ["inform"],
    ["disguise"]
*/

cleanOldObjective = {};

nextObjectiveLocation = {
    _nextLoc = selectRandom _objLocations;
    _nextLoc
};

nextObjectiveType = {
    _nextType = selectRandom _objTypes;
    _nextType
};

moveTriggers = {};

moveMarkers = {
    private ["_nextLoc","_nextType"];
    _nextLoc = _this select 0;
    _objPos = _nextLoc select 1;
    
    _nextType = _this select 2;
    _typeName = _nextType select 0;
    
    _objMarker = "objMarker";
    _objMarker setMarkerPos _objPos;
    _objMarker setMarkerText _typeName;
    
    /*
    //Boundary marker for starting location
    _startMark = createMarkerLocal ["startZone",_startMarkPos];
    _startMark setMarkerShapeLocal "ELLIPSE";
    _startMark setMarkerSizeLocal [50, 50];
    _startMark setMarkerDirLocal (markerDir _randomMarker);
    _startMark setMarkerBrushLocal "SolidBorder";
    _startMark setMarkerColorLocal _color;
    //Text marker for starting location
    _startMarkTwo = createMarkerLocal ["startZoneTwo",_startMarkPos];
    _startMarkTwo setMarkerShapeLocal "ICON";
    _startMarkTwo setMarkerColorLocal "ColorBlack";
    _startMarkTwo setMarkerTypeLocal "hd_dot";
    _startMarkTwo setMarkerDirLocal (markerDir _randomMarker);
    _startMarkTwo setMarkerTextLocal _text;
    
    //Find player distance and direction to the placement marker.
    _dis = player distance2D _placeMarkerPos;
    _dir = ((player getDir _placeMarkerPos) + (markerDir _randomMarker)) - 180;
    
    //Returns a position that is a specified distance and compass direction from the passed position or object.
    _newPos = _startMarkPos getPos [_dis, _dir];
    
    //Move player
    player setPos [(_newPos select 0), (_newPos select 1)];
    player setDir (markerDir _randomMarker);*/
};

randItemSpawn = {
    _nextLoc = _this select 0;
    _locSize = _nextLoc select 1;
    _locPos = _nextLoc select 2;
    _itemSpawnMarker = "randItemsMarker";
    
    // Move the randomloot marker
    //_itemSpawnPos = getMarkerPos _itemSpawnMarker;
    _itemSpawnMarker setMarkerPos _locPos;
    _itemSpawnMarker setMarkerSize _locSize;
    
    //Call item randomloot
    [_itemSpawnMarker] execVM "scripts\randomloot\server.sqf";
};

moveObjective = {
    private ["_nextLoc","_nextType","_locSize","_locPos","_typeName"];
    _nextLoc = _this select 0;
    _nextType = _this select 1;
    _locSize = _nextLoc select 1;
    _locPos = _nextLoc select 2;
    _typeName = _nextType select 0;
    
    _objAreaMarker = "objAreaMarker";
    _objAreaMarker setMarkerPos _locPos;
    _objAreaMarker setMarkerSize [(_locSize select 0)*0.9, (_locSize select 1)*0.9];
    _objPos = [_objAreaMarker, false] call CBA_fnc_randPos;
    
    [_nextLoc, _objPos, _nextType] call moveTriggers;
    [_nextLoc, _objPos, _nextType] call moveMarkers;
    [_nextLoc] call randItemSpawn;
    _locName = _nextLoc select 0;
};

playerStart = {
    //Call player randomstart
    [] execVM "scripts\randomstart\server.sqf";
    [] execVM "scripts\randomstart\client.sqf";
};

respawnPlayers = {
    
};

// Doing AI implementation last
shouldSpawnAI = {false};
spawnAI = {};

// On loading of the map, this func will run
firstObjective = {
    private ["_nextLoc","_nextType"];
    _nextLoc = selectRandom _objLocations;
    _nextType = selectRandom _objTypes;
    
    [_nextLoc, _nextType] call moveObjective;
    
    [] call playerStart;
};

completedObjective = {
    private ["_nextLoc","_nextType"];
    // Delete old AI specifically. Not sure if anything else needs to happen yet
    [] call cleanOldObjective;
    
    _nextLoc = [] call nextObjectiveLocation;
    _nextType = [] call nextObjectiveType;
    
    [_nextLoc, _nextType] call moveObjective;
    
    /* Not respawning players yet
    if (deadPlayers > 0) then {
        [_nextLoc, _nextType] call respawnPlayers;
    };*/
    
    // Only some objective types use AI
    if ([] call shouldSpawnAI) then {
        [] call spawnAI;
    };
};

[] call firstObjective;