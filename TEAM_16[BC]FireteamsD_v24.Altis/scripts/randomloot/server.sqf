if (!isServer) exitWith {};

// Set probability of loot spawning 1-100%
_probability=100; //default 25

// Set the max amount of spawns per building
_maxItemSpawns = 100; // default 8

// Show loot position and type on map (Debugging)
_showLootType=false;
_showLootRarity=false;

// 37%
// Backpacks, vests, utilities
itemsHighlyCommon = [["Binocular", "item"],
					 ["FirstAidKit", "item"],
					 ["B_AssaultPack_blk", "backpack"],
					 ["B_Carryall_mcamo", "backpack"],
					 ["B_FieldPack_blk", "backpack"],
					 ["MNP_B_ROK_KB", "backpack"],
					 ["MNP_B_RU1_FP", "backpack"],
					 ["Chemlight_green", "item"],
					 ["Chemlight_blue", "item"],
					 ["Chemlight_red", "item"],
					 ["Chemlight_yellow", "item"],
					 ["MNP_Vest_USMC_Xtreme_A", "vest"],
					 ["MNP_Vest_UKR_A", "vest"],
                     ["acc_flashlight", "item"],
                     ["rhs_acc_2dpZenit", "item"]
					];

/* Unused commons
["B_AssaultPack_cbr", "backpack"],
					 ["B_AssaultPack_khk", "backpack"],
["B_Carryall_cbr", "backpack"],
					 ["B_Carryall_khk", "backpack"],
["B_FieldPack_cbr", "backpack"],
					 ["B_FieldPack_khk", "backpack"],
*/

// struct for desire to be able to set individual probabilities under a class of rarity
/*itemsStructure = [
    [80, ["name", "type"]],
    [20, ["name", "type"]]
];*/

// 30%
// Ammunition, smokes, grenades
itemsCommon = [
			   ["rhs_mag_30Rnd_556x45_Mk318_Stanag", "mag"],
			   ["rhs_30Rnd_762x39mm", "mag"]
			  ];
/*No pistol shit for now
               ["rhsusf_weap_m1911a1", "weapon"],
               ["rhsusf_mag_7x45acp_MHP", "mag"],
			   ["rhs_weap_makarov_pmm", "weapon"],
               ["rhs_mag_9x18_12_57N181S", "mag"]
*/
                //["30Rnd_556x45_Stanag_Tracer_Red", "mag"],
				 //["rhs_weapon_240B", "mag"],
				 /*["rhs_weap_m16a4", "weapon_mag"],
			   ["rhs_weap_249_pip", "weapon_mag"],
				 ["rhs_weapon_pkp", "mag"]
			   ["muzzle_snds_M", "item"],
			   ["muzzle_snds_L", "item"],
			   ["muzzle_snds_H_SW", "item"],
			   ["muzzle_snds_H_MG", "item"],
			   ["muzzle_snds_H", "item"],
			   ["muzzle_snds_B", "item"],
			   ["optic_Arco", "item"],
			   ["optic_Aco", "item"],
			   ["optic_Holosight", "item"],
			   ["optic_Yorris", "item"],
			   ["muzzle_snds_acp", "item"]
*/

// 19%
// Special utilities, attachments
itemsUncommon = [
				 ["Rangefinder", "item"],
				 ["ToolKit", "item"],
				 ["MediKit", "item"],
				 ["ItemGPS", "item"],
                 ["rhs_acc_pso1m2", "item"],
                 ["rhsusf_acc_rotex5_grey", "item"],
                 ["rhsusf_acc_ACOG_USMC", "item"],
                 ["rhsusf_acc_harris_bipod", "item"],
                 ["SmokeShell", "item"],
			     ["HandGrenade", "item"],
			     ["MiniGrenade", "item"]
				];

// 9%
// rare weapons (high powered), utilities (NVG, rangefinder), rare attachments (long range scopes, silencers), explosives
itemsHighlyUncommon = [["rhs_weap_ak103", "weapon"],
				       ["rhs_weap_akm", "weapon"],
                       ["rhs_weap_akms", "weapon"],
				       ["rhs_weap_m16a4", "weapon"],
				       ["rhs_weap_m4", "weapon"],
				       ["rhs_weap_m4_carryhandle", "weapon"]
					  ];

// 4%
// RPGs
itemsRare = [["NVGoggles", "item"],
             ["rhs_10Rnd_762x54mmR_7N1", "mag"]
            ];
//["DemoCharge_F", "item"],
//["SatchelCharge_F", "item"],

// 1%
itemsExtremelyRare = [["rhs_weap_M136_hedp", "weapon"],
					  ["rhs_weap_svd", "weapon"],
                      ["rhs_weap_svdp_wd", "weapon"]
                     ];

// Exclude buildings from loot spawn. Use 'TYPEOF' to find building name
_exclusionList=[];//	["Land_Pier_F","Land_Pier_small_F","Land_NavigLight","Land_LampHarbour_F"];

private ["_distance","_houseList"];
_mkr=(_this select 0);
_mkr setmarkerAlpha 0;
_pos=markerpos _mkr;
_mkrY= getmarkerSize _mkr select 0;
_mkrX= getmarkerSize _mkr select 1;

_distance=_mkrX;
if (_mkrY > _mkrX) then {
	_distance=_mkrY;
};

 _houseList= _pos nearObjects ["House",_distance];
 _numHouses = count _houseList;
{ // foreach in _houseList
    _spawnCheck = false;
    if (400 > random _numHouses) then {_spawnCheck=true};
    if (_spawnCheck) then {
    _house=_X;

	if (!(typeOf _house in _exclusionList)) then {
        // Using sizeOf
        _buildingSize = sizeOf (typeOf _house);
        _numItemSpawns = _buildingSize;
        
        if (_numItemSpawns > _maxItemSpawns) then {_numItemSpawns = _maxItemSpawns};
        
		for "_n" from 1 to _numItemSpawns do {
			_buildingPos = _house buildingPos _n;
            
			if (str _buildingPos == "[0,0,0]") exitwith {};
				if (_probability > random 100) then {
					[_buildingPos, _buildingSize, _showLootType, _showLootRarity] execVM "scripts\randomloot\spawnLoot.sqf";
				};
			};
		};
    };
} foreach _houseList;