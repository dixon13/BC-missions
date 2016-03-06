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

#include "randomstart\settings.sqf";

if (!isServer) exitWith {};

sizeOfSpawnAO = 500; // default 500:
sizeOfObjHold = 25; // default 25:
objTickTime = 1; // default 1: Each tick the seizeMarker increases in seconds
objNumberOfTicks = 60*5; // How much to increase the seizeMarker every interval of time
objSizeTick = (sizeOfSpawnAO - sizeOfObjHold) / objNumberOfTicks;
minDistBetweenSpawn = 250; // default 250: Be careful with this! It is not robust enough to check that all markers can be placed with this constraint, meaning, you can enter an inf loop trying to make all randomstart markers fit the criteria.
objNumber = 0;
currentLoc = nil;

// Array of "Locations": [name, size, pos, angle]
objLocations = [
    ["Abdera",          [160,160], [9428.6553,20241.711], 0],
    ["Kore",            [150,150], [7156.0981,16473.186], 0],
    ["Negades",         [200,150], [4915.6445,16181.08],  0],
    ["Poliakko",        [200,200], [10955.016,13446.202], 0],
    ["Alikampos",       [150,150], [11135.173,14554.855], 0],
    ["Lakka",           [300,300], [12399.981,15723.699], 0],
    ["Telos",           [275,175], [16360.756,17247.285], 0],
    ["Charkia",         [250,200], [18129.295,15239.145], 0],
    ["Agios Dionysios", [460,230], [9372.5176,15907.256], 345],
    ["Frini",           [175,175], [14630.977,20801.369], 0],
    ["Panochori",       [200,200], [5085.7744,11255.75],  0],
    ["Neri",            [150,150], [4166.3979,11750.202], 0],
    ["Zaros",           [150,150], [9109.4814,11982.389], 0],
    ["Therisa",         [150,150], [10660.85,12256.249],  0],
    ["Oreokastro",      [150,150], [4599.4292,21405.762], 0],
    ["Rodopoli",        [150,150], [18813.949,16626.662], 0],
    ["Ghost Hotel",     [150,150], [21969.797,21026.451], 0],
    ["Paros",           [150,150], [20953.289,16983.402], 0],
    ["Kalochori",       [150,150], [21427.215,16356.371], 0],
    ["Sofia",           [150,150], [25680.68,21345.486],  0],
    ["Molos",           [150,150], [27012.621,23235.025], 0],
    ["Dorida",          [150,150], [19394.307,13264.557], 0],
    ["Chalkeia",        [150,150], [20258.314,11690.445], 0],
    ["Panagia",         [150,150], [20531.992,8880.8848], 0],
    ["Feres",           [150,150], [21686.83,7577.3218],  0],
    ["Selakano",        [150,150], [20818.33,6739.6821],  0],
    ["Pyrgos",          [150,150], [16864.756,12691.786], 0],
    ["Anthrakia",       [150,150], [16657.893,16123.546], 0],
    ["Gravia",          [150,150], [14510.347,17623.906], 0],
    ["Athira",          [150,150], [14042.524,18714.863], 0],
    ["Galati",          [150,150], [10330.641,19049.908], 0],
    ["Syrta",           [150,150], [8631.876,18267.607],  0],
    ["Stavros",         [150,150], [12982.067,15043.031], 0],
    ["Neochori",        [150,150], [12584.114,14326.683], 0]
];

/* Chernarus Locations
    ["Chernogorsk",     [200,200], [6711.0625,2650.7988], 0],
    ["Elekrozavodsk",   [200,200], [10322.455,2122.6682], 0],
    ["Berezino",        [200,200], [12042.515,9102.0742], 0],
    ["Berezino Docks",  [200,200], [12885.655,9982.2178], 0]

// Not good enough yet
["Zelenogorsk",     [200,200], [2728.0989,5269.583],  0],
*/

/* Altis Locations

//Not good enough yet
["Aggelochori",     [300,300], [3822.207,13685.973],  0],
["Agia Triada",     [50,200],  [16617.021,20575.688], 323],
["Topolia",         [75,150],  [7378.4136,15335.224], 0],
["Katalaki",        [150,150], [11761.309,13712.03],  0],
["Kavala",          [300,300], [3599.1462,13059.67], 0],
*/

/* United Sahrani Locations
    ["Arcadia", [200, 250], [7622.8159, 6435.5762], 320]
    ["Eponia", [500, 500], [12585.727, 15133.22], 0]
*/

// Array of "Objective Types": ["name"]
objTypes = [
    ["Hold"]
];

/* Incomplete Objectives
    ["Steal"],
    ["Destroy"],
    ["Hold"]
    ["kill"],
    ["transport"],
    ["resupply"],
    ["locate"],
    ["capture"],
    ["inform"],
    ["disguise"]
*/

cleanOldObjective = {
    private ["_oldObjMarker"];
    _oldObjMarker = format ["objHold%1", objNumber];
    _oldObj = createMarker [_oldObjMarker, getMarkerPos "objHold"];
    _oldObj setMarkerShape "ELLIPSE";
    _oldObj setMarkerSize [sizeOfSpawnAO, sizeOfSpawnAO];
    _oldObj setMarkerBrush "SolidBorder";
    _oldObj setMarkerColor (getMarkerColor "objHold");
};

nextObjectiveLocation = {
    _nextLoc = selectRandom objLocations;
    _nextLoc
};

nextObjectiveType = {
    _nextType = selectRandom objTypes;
    _nextType
};

moveTriggersAndMarkers = {
    private ["_nextLoc","_objPos","_nextType","_typeName","_3dObjPos","_objSize","_objHold"];
    _nextLoc = _this select 0;
    _objPos = _this select 1;
    
    _nextType = _this select 2;
    _typeName = _nextType select 0;
    
    _3dObjPos = [_objPos select 0, _objPos select 1, 0];
    _objTriggerArea = [sizeOfObjHold, sizeOfObjHold, 0, false];
    
    switch (_typeName) do {
        case "Hold": {
            objBlue setPos _3dObjPos;
            objBlue setTriggerArea _objTriggerArea;
            objBlueSeize setPos _3dObjPos;
            objBlueSeize setTriggerArea _objTriggerArea;

            objRed setPos _3dObjPos;
            objRed setTriggerArea _objTriggerArea;
            objRedSeize setPos _3dObjPos;
            objRedSeize setTriggerArea _objTriggerArea;

            objGreen setPos _3dObjPos;
            objGreen setTriggerArea _objTriggerArea;
            objGreenSeize setPos _3dObjPos;
            objGreenSeize setTriggerArea _objTriggerArea;

            objPurple setPos _3dObjPos;
            objPurple setTriggerArea _objTriggerArea;
            objPurpleSeize setPos _3dObjPos;
            objPurpleSeize setTriggerArea _objTriggerArea;

            objNumber = objNumber + 1;
            _objHold = "objHold";
            _objHold setMarkerPos _objPos;
            _objHold setMarkerShape "ELLIPSE";
            _objHold setMarkerSize [sizeOfObjHold, sizeOfObjHold];
            _objHold setMarkerBrush "SolidBorder";
            _objHold setMarkerColor "ColorUNKNOWN";
            
            {
                _x setMarkerPos _objPos;
                _x setMarkerSize [sizeOfObjHold, sizeOfObjHold];
                _x setMarkerAlpha 0;
            } forEach ["blueSeize", "redSeize", "greenSeize", "purpleSeize"];
        };
    };
    
    _objMarker = "objMarker";
    _objMarker setMarkerPos _objPos;
    _objMarker setMarkerText _typeName;
};

randItemSpawn = {
    _nextLoc = _this select 0;
    _locSize = _nextLoc select 1;
    _locPos = _nextLoc select 2;
    _itemSpawnMarker = "randItemsMarker";
    
    // Move the randomloot marker
    //_itemSpawnPos = getMarkerPos _itemSpawnMarker;
    _itemSpawnMarker setMarkerPos _locPos;
    _itemSpawnMarker setMarkerSize [sizeOfSpawnAO,sizeOfSpawnAO];//_locSize;
    
    //Call item randomloot
    [_itemSpawnMarker] execVM "scripts\randomloot\server.sqf";
};

moveObjective = {
    private ["_nextLoc","_nextType","_locSize","_locPos","_typeName"];
    _nextLoc = _this select 0;
    _nextType = _this select 1;
    _locSize = _nextLoc select 1;
    _locPos = _nextLoc select 2;
    _locDir = _nextLoc select 3;
    _typeName = _nextType select 0;
    
    _objAreaMarker = "objAreaMarker";
    _objAreaMarker setMarkerPos _locPos;
    _objAreaMarker setMarkerSize [(_locSize select 0)*0.1, (_locSize select 1)*0.1];
    _objAreaMarker setMarkerDir _locDir;
    _objPos = [_objAreaMarker, false] call CBA_fnc_randPosArea;
    
    [_nextLoc, _objPos, _nextType] call moveTriggersAndMarkers;
    
    _locName = _nextLoc select 0;
    currentLoc = _nextLoc;
};

cinematic = {
    private ["_nextLoc","_locName"];
    _nextLoc = _this select 0;
    _locName = _nextLoc select 0;
    //titleText [ format ["Fireteams - %1\nBravo Company",_locName],"BLACK FADED", 5];
    0 cutText [ format ["Fireteams - %1\nBravo Company",_locName],"BLACK FADED", 1];
};

fadeCinematic = {
    sleep 3;
    0 cutFadeOut 1;
};

checkRandomStartPos = {
    private ["_pos","_placedPos","_check","_checkWater"];
    _pos = _this select 0;
    _placedPos = _this select 1;
    
    _check = false;
    // Fail check if pos is in water
    _checkWater = !(surfaceIsWater _pos);
    
    // Fail check if pos is too close to other markers
    _checkDist = true;
    {
        _placed = _x;
        _dist = _placed distance2D _pos;
        // 
        if (_dist < minDistBetweenSpawn) exitWith {_checkDist=false};
    } forEach _placedPos;
    
    // AND all checks together; all must be true for check to pass
    _check = _checkWater && _checkDist; 
    _check
};

playerStart = {
    private ["_nextLoc","_locPos","_marker","_randomPos"];
    _nextLoc = _this select 0;
    _locPos = _nextLoc select 2;
    
    //Move the random start markers around the perim. of the AO (800m circle around the _nextLoc position)
    _objAreaMarker = "objAreaMarker";
    _objAreaMarker setMarkerPos _locPos;
    _objAreaMarker setMarkerSize [sizeOfSpawnAO, sizeOfSpawnAO];
    //_objAreaMarker setMarkerAlpha 0;
    
    _placedMarkerPos = [];
    {
        _marker = _x;
        _check = false;
        
        // Continually try a new randomPos until checkRandomStartPos returns true
        while { !_check } do {
            _randomPos = [_objAreaMarker, true] call CBA_fnc_randPosArea;
            _check = [_randomPos, _placedMarkerPos] call checkRandomStartPos;
        };
        
        // Found a good random pos
        _marker setMarkerPos _randomPos;
        
        // Keep that marker pos for further checks
        _placedMarkerPos pushBack _randomPos;
        
    } forEach _markerArrayWest;
    
    // All markers are randomly set...
    
    // Call player randomstart
    [] execVM "scripts\randomstart\server.sqf";
};

respawnPlayers = {
    private ["_nextLoc","_locPos","_marker","_randomPos"];
    _nextLoc = _this select 0;
    _locPos = _nextLoc select 2;
    
    //Move the random start markers around the perim. of the AO (800m circle around the _nextLoc position)
    _objAreaMarker = "objAreaMarker";
    _objAreaMarker setMarkerPos _locPos;
    _objAreaMarker setMarkerSize [sizeOfSpawnAO, sizeOfSpawnAO];
    //_objAreaMarker setMarkerAlpha 0;
    
    /*_placedMarkerPos = [];
    {
        _marker = _x;
        _check = false;
        
        // Continually try a new randomPos until checkRandomStartPos returns true
        while { !_check } do {
            _randomPos = [_objAreaMarker, true] call CBA_fnc_randPosArea;
            _check = [_randomPos, _placedMarkerPos] call checkRandomStartPos;
        };
        
        // Found a good random pos
        _marker setMarkerPos _randomPos;
        
        // Keep that marker pos for further checks
        _placedMarkerPos pushBack _randomPos;
        
    } forEach _markerArrayWest;
    */
    // All markers are randomly set...
};

// Doing AI implementation last
//shouldSpawnAI = {false};
//spawnAI = {};

completedObjective = {
    private ["_nextLoc","_nextType"];
    // Delete old AI specifically. Not sure if anything else needs to happen yet
    [] call cleanOldObjective;
    
    _nextLoc = [] call nextObjectiveLocation;
    _nextType = [] call nextObjectiveType;
    
    [_nextLoc, _nextType] call moveObjective;
    
    [_nextLoc] call respawnPlayers;
    
    // Change time of day
    _skipTime = (random 24);
    skiptime _skipTime;
    
    // Change overcast
    _currentTime = floor daytime;
    _newTime = _currentTime + _skipTime;
    _randOvercast = 0.0;
    if ((_newTime > 5.0) && _newTime < 17.0) then {
        // Daytime allows for any overcast setting from 1.0 to 0.0
        _randOvercast = (random 100) / 100.0;
    } else {
        // Only use 0.2 to 0.0 overcast in nighttime
        _randOvercast = (random 20) / 100.0;
    };
    50 setOvercast _randOvercast;
    
    // Only some objective types use AI
    //if ([] call shouldSpawnAI) then {
    //    [] call spawnAI;
    //};
    
    // Spawn items last because it may take some time...
    [_nextLoc] call randItemSpawn;
};

// On loading of the map, this func will run
firstObjective = {
    private ["_nextLoc","_nextType"];
    _nextLoc = selectRandom objLocations;
    _nextType = selectRandom objTypes;
    
    [_nextLoc, _nextType] call moveObjective;
    [_nextLoc] call cinematic;
    [_nextLoc] call playerStart;
    
    // Spawn items last because it may take some time...
    [_nextLoc] call randItemSpawn;
    [] call fadeCinematic;
};

[] call firstObjective;