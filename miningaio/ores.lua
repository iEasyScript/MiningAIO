local ORE_BOX_IDS = { 44779, 44781, 44783, 44785, 44787, 44789, 44791, 44793, 44795, 44797, 57172 }

local GEM_BAG_IDS = { 18338, 31455 }

local GEM_IDS = { 1627, 1625, 1629, 1623, 1621, 1619, 1617, 1631, 21345 }

local SPARKLE_IDS = { 7164, 7165 }

local ORES = {

    ----- ORES
    Copper = {
        Name     = "Copper",
        Category = "Ores",
        Level    = 1,
        OreIDs   = { 436 },
        RockIDs  = { 113026, 113027, 113028 },
        Tier     = 1,
        Spot     = { x = 2287, y = 4514, z = 0 },
    },
    Tin = {
        Name     = "Tin",
        Category = "Ores",
        Level    = 1,
        OreIDs   = { 438 },
        RockIDs  = { 113030, 113031 },
        Tier     = 2,
        Spot     = { x = 2287, y = 4514, z = 0 },
    },
    Iron = {
        Name     = "Iron",
        Category = "Ores",
        Level    = 10,
        OreIDs   = { 440 },
        RockIDs  = { 113040, 113038, 113039 },
        Tier     = 3,
        Spot     = { x = 2278, y = 4501, z = 0 },
    },
    Coal = {
        Name     = "Coal",
        Category = "Ores",
        Level    = 20,
        OreIDs   = { 453 },
        RockIDs  = { 113042, 113041, 113043 },
        Tier     = 5,
        Spot     = { x = 3049, y = 9822, z = 0 },
    },
    Silver = {
        Name     = "Silver",
        Category = "Ores",
        Level    = 20,
        OreIDs   = { 442 },
        RockIDs  = { 113045, 113046 },
        Tier     = 4,
        Spot     = { x = 3300, y = 3289, z = 0 },
    },
    Mithril = {
        Name     = "Mithril",
        Category = "Ores",
        Level    = 30,
        OreIDs   = { 447 },
        RockIDs  = { 113051, 113052, 113050 },
        Tier     = 6,
        Spot     = { x = 3287, y = 3363, z = 0 },
    },
    Adamantite = {
        Name     = "Adamantite",
        Category = "Ores",
        Level    = 40,
        OreIDs   = { 449 },
        RockIDs  = { 113055, 113053 },
        Tier     = 7,
        Spot     = { x = 3287, y = 3363, z = 0 },
    },
    Gold = {
        Name     = "Gold",
        Category = "Ores",
        Level    = 40,
        OreIDs   = { 444 },
        RockIDs  = { 113059, 113061, 113060 },
        Tier     = 8,
        Spot     = { x = 3300, y = 3289, z = 0 },
    },
    Luminite = {
        Name     = "Luminite",
        Category = "Ores",
        Level    = 40,
        OreIDs   = { 44820 },
        RockIDs  = { 113056, 113057, 113058 },
        Tier     = 9,
        Spot     = { x = 3039, y = 9766, z = 0 },
    },
    Runite = {
        Name     = "Runite",
        Category = "Ores",
        Level    = 50,
        OreIDs   = { 451 },
        RockIDs  = { 113125, 113126, 113127 },
        Tier     = 10,
        Spot     = { x = 3101, y = 3564, z = 0 },
    },
    Drakolith = {
        Name     = "Drakolith",
        Category = "Ores",
        Level    = 60,
        OreIDs   = { 44824 },
        RockIDs  = { 113131, 113132, 113133 },
        Tier     = 12,
        Spot     = { x = 3184, y = 3633, z = 0 },
    },
    Orichalcite = {
        Name     = "Orichalcite",
        Category = "Ores",
        Level    = 60,
        OreIDs   = { 44822 },
        RockIDs  = { 113070, 113069 },
        Tier     = 11,
        Spot     = { x = 3044, y = 9738, z = 0 },
    },
    Necrite = {
        Name     = "Necrite",
        Category = "Ores",
        Level    = 70,
        OreIDs   = { 44826 },
        RockIDs  = { 113207, 113206, 113208 },
        Tier     = 13,
        Spot     = { x = 3027, y = 3800, z = 0 },
    },
    Phasmatite = {
        Name     = "Phasmatite",
        Category = "Ores",
        Level    = 70,
        OreIDs   = { 44828 },
        RockIDs  = { 113139, 113138, 113137 },
        Tier     = 14,
        Spot     = { x = 3690, y = 3397, z = 0 },
    },
    Banite = {
        Name     = "Banite",
        Category = "Ores",
        Level    = 80,
        OreIDs   = { 21778 },
        RockIDs  = { 113140, 113141, 113142 },
        Tier     = 15,
        Spot     = { x = 3058, y = 3945, z = 0 },
    },
    Corrupted = {
        Name     = "Seren Stone",
        Category = "Ores",
        Level    = 89,
        OreIDs   = { 32262 },
        RockIDs  = { 113016 },
        Tier     = 16,
        Spot     = { x = 2220, y = 3298, z = 1 },
    },
    DarkAnimica = {
        Name     = "Dark Animica",
        Category = "Ores",
        Level    = 90,
        OreIDs   = { 44832 },
        RockIDs  = { 113022, 113021, 113020 },
        Tier     = 18,
        Spot     = { x = 2876, y = 12637, z = 2 },
    },
    LightAnimica = {
        Name     = "Light Animica",
        Category = "Ores",
        Level    = 90,
        OreIDs   = { 44830 },
        RockIDs  = { 113018 },
        Tier     = 17,
        Spot     = { x = 5339, y = 2255, z = 0 },
    },

    ----- PRIMALS
    Argonite = {
        Name     = "Argonite",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57187 },
        RockIDs  = { 130785, 130786, 130787 },
        Spot     = { x = 3397, y = 3665, z = 0 },
    },
    Bathus = {
        Name     = "Bathus",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57177 },
        RockIDs  = { 130801, 130802 },
        Spot     = { x = 3473, y = 3663, z = 0 },
    },
    Fractite = {
        Name     = "Fractite",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57183 },
        RockIDs  = { 130779, 130780, 130781 },
        Spot     = { x = 3473, y = 3663, z = 0 },
    },
    Gorgonite = {
        Name     = "Gorgonite",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57191 },
        RockIDs  = { 130791, 130792, 130793 },
        Spot     = { x = 3504, y = 3735, z = 0 },
    },
    Katagon = {
        Name     = "Katagon",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57189 },
        RockIDs  = { 130818, 130819, 130820 },
        Spot     = { x = 3397, y = 3665, z = 0 },
    },
    Kratonium = {
        Name     = "Kratonium",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57181 },
        RockIDs  = { 130776, 130777, 130778 },
        Spot     = { x = 3443, y = 3643, z = 0 },
    },
    Marmaros = {
        Name     = "Marmaros",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57179 },
        RockIDs  = { 130803, 130804, 130805 },
        Spot     = { x = 3504, y = 3735, z = 0 },
    },
    Novite = {
        Name     = "Novite",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57175 },
        RockIDs  = { 130797, 130798, 130799 },
        Spot     = { x = 3415, y = 3719, z = 0 },
    },
    Promethium = {
        Name     = "Promethium",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57193 },
        RockIDs  = { 130824, 130825, 130826 },
        Spot     = { x = 3401, y = 3758, z = 0 },
    },
    Zephyrium = {
        Name     = "Zephyrium",
        Category = "Primals",
        Level    = 100,
        OreIDs   = { 57185 },
        RockIDs  = { 130812, 130813, 130814 },
        Spot     = { x = 3393, y = 3714, z = 0 },
    },

    ----- GEMS
    CommonGem = {
        Name     = "Common Gem Rock",
        Category = "Gems",
        Level    = 1,
        OreIDs   = { 1627, 1625, 1629, 1623, 1621, 1619, 1617, 1631, 21345 },
        RockIDs  = { 113036, 113037 },
        Spot     = { x = 2267, y = 4496, z = 0 },
    },
    UncommonGem = {
        Name     = "Uncommon Gem Rock",
        Category = "Gems",
        Level    = 20,
        OreIDs   = { 1627, 1625, 1629, 1623, 1621, 1619, 1617, 1631, 21345 },
        RockIDs  = { 113047, 113048, 113049 },
        Spot     = { x = 3299, y = 3311, z = 0 },
    },
    PreciousGem = {
        Name     = "Precious Gem Rock",
        Category = "Gems",
        Level    = 25,
        OreIDs   = { 1627, 1625, 1629, 1623, 1621, 1619, 1617, 1631, 21345 },
        RockIDs  = { 113062, 113063, 113064 },
        Spot     = { x = 1186, y = 4509, z = 0 },
    },
    PrifGem = {
        Name     = "Prifddinas Gem Rock",
        Category = "Gems",
        Level    = 75,
        OreIDs   = { 1627, 1625, 1629, 1623, 1621, 1619, 1617, 1631, 21345 },
        RockIDs  = { 112998, 112999 },
        Spot     = { x = 2235, y = 3320, z = 1 },
    },

    ----- MINERALS
    Clay = {
        Name     = "Clay",
        Category = "Minerals",
        Level    = 1,
        OreIDs   = { 434 },
        RockIDs  = { 113032, 113033, 113034 },
        Spot     = { x = 2272, y = 4525, z = 0 },
    },
    Limestone = {
        Name     = "Limestone",
        Category = "Minerals",
        Level    = 10,
        OreIDs   = { 3211 },
        RockIDs  = { 112893, 112894, 112895 },
        Spot     = { x = 3373, y = 3500, z = 0 },
    },
    Granite = {
        Name     = "Granite",
        Category = "Minerals",
        Level    = 45,
        OreIDs   = { 6979, 6981, 6983 },
        RockIDs  = { 112955, 112957, 112956 },
        Spot     = { x = 3174, y = 2914, z = 0 },
    },
    Sandstone = {
        Name     = "Sandstone",
        Category = "Minerals",
        Level    = 50,
        OreIDs   = { 6971, 6973, 6975, 6977 },
        RockIDs  = { 112935, 112937 },
        Spot     = { x = 3174, y = 2914, z = 0 },
    },
    CrystalSandstone = {
        Name     = "Crystal Sandstone",
        Category = "Minerals",
        Level    = 81,
        OreIDs   = { 32847 },
        RockIDs  = { 112696, 112697, 112698, 112699 },
        Spot     = { x = 2145, y = 3351, z = 1 },
    },
    RedSandstone = {
        Name     = "Red Sandstone",
        Category = "Minerals",
        Level    = 81,
        OreIDs   = { 23194 },
        RockIDs  = { 67969, 67970, 67971, 67972 },
        Spot     = { x = 2586, y = 2879, z = 0 },
    },

    ----- MISC
    RuneEssence = {
        Name     = "Rune/Pure Essence",
        Category = "Misc",
        Level    = 1,
        OreIDs   = { 1436, 7936 },
        RockIDs  = { 2491, 16684 },
        Spot     = { x = 15151, y = 2031, z = 0 },
    },
}

local M = {
    ORES         = ORES,
    ORE_BOX_IDS  = ORE_BOX_IDS,
    GEM_BAG_IDS  = GEM_BAG_IDS,
    GEM_IDS      = GEM_IDS,
    SPARKLE_IDS  = SPARKLE_IDS,
}

--- Finds an ore by key or display name, case- and space-insensitive.
--- "dark animica", "DarkAnimica" and "Dark Animica" all land on the same entry.
--- @return table|nil ore, string|nil key
function M.byName(name)
    if type(name) ~= "string" then return nil end
    local want = name:lower():gsub("[%s_]", "")
    for key, ore in pairs(ORES) do
        if key:lower() == want or ore.Name:lower():gsub("[%s_/]", "") == want then
            return ore, key
        end
    end
    return nil
end

--- Every rock id for a list of ore names, flattened.
---
--- Unknown names are RETURNED rather than skipped silently, because a typo in
--- a config that just quietly mines nothing is the worst way to find out.
--- @return table rockIds, table unknownNames
function M.rockIds(names)
    local ids, unknown = {}, {}
    for _, name in ipairs(names or {}) do
        local ore = M.byName(name)
        if ore then
            for _, id in ipairs(ore.RockIDs) do ids[#ids + 1] = id end
        else
            unknown[#unknown + 1] = name
        end
    end
    return ids, unknown
end

--- @return table|nil ore, string|nil key
function M.bestForLevel(level)
    local best, bestKey = nil, nil
    for key, ore in pairs(ORES) do
        if ore.Category == "Ores" and ore.Tier and ore.Level <= (level or 1) then
            if not best or ore.Tier > best.Tier then best, bestKey = ore, key end
        end
    end
    return best, bestKey
end

--- Ore keys in a category, sorted by level then name -- for a GUI dropdown.
function M.byCategory(category)
    local out = {}
    for key, ore in pairs(ORES) do
        if ore.Category == category then out[#out + 1] = key end
    end
    table.sort(out, function(a, b)
        if ORES[a].Level ~= ORES[b].Level then return ORES[a].Level < ORES[b].Level end
        return a < b
    end)
    return out
end

local oreIdSet = nil
function M.allOreIds()
    if oreIdSet then return oreIdSet end
    oreIdSet = {}
    for _, ore in pairs(ORES) do
        for _, id in ipairs(ore.OreIDs or {}) do oreIdSet[id] = true end
    end
    return oreIdSet
end

return M
