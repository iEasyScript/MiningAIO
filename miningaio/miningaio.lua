--- @module "Mining AIO"
--- @version 1.1.0
-- Title: Mining AIO
-- Author: Easy
-- Description: Mining AIO is a script that will mine any ore in the area, including rockertunities. It will also manage stamina and the Grace of the Elves amulet, and can bank or drop ores when the inventory is full.
-- Version: 1.1.0
-- Category: Skilling

local API  = require("api")

local Ores = require("miningaio.ores")
local GUI  = require("miningaio.gui")

local CONFIG = {

    ROCKS = {},
    ORE = nil,
    USE_ROCKERTUNITIES = true,
    ROCKERTUNITY_GFX = { 7164, 7165 },
    STAMINA_BELOW = 200,
    STAMINA_JITTER = { -15, 10 },
    ORE_BOX_CAP    = 140,
    FULL_ACTION    = "stop",
    BANK_PRESET    = 1,
    USE_GRACE          = false,
    GRACE_CHARGE_BELOW = 10,    -- charges out of 500
    GRACE_MAX_ATTEMPTS = 3,     -- charge attempts that change nothing before stopping

    ANIM_WINDOW    = 25,

    COMMIT_TICKS   = 2,
    RT_COMMIT_TICKS = 6,
    COMMIT_CEILING = 12,

    SCAN_RANGE     = 12,   -- tiles to look for rocks
    HIGHLIGHT_RANGE = 16,  -- tiles to look for rockertunity markers
    MAX_FAILS      = 10,   -- passes with no rock found before stopping
    DEBUG          = false,
}
local EXTRA_ROCK_NAMES = {
    "Luminite", "Banite", "Necrite", "Phasmatite", "Orichalcite", "Drakolith",
    "Light animica", "Dark animica", "Seren stone", "Corrupted seren stone",
    "Concentrated coal", "Concentrated gold", "Living rock", "Clay",
}

local ORE_BOX_VARBITS = {
    [8309] = "Copper",       [8310] = "Tin",          [8311] = "Iron",
    [8312] = "Coal",         [8313] = "Silver",       [8314] = "Mithril",
    [8315] = "Adamantite",   [8316] = "Luminite",     [8317] = "Gold",
    [8318] = "Runite",       [8319] = "Orichalcite",  [8320] = "Drakolith",
    [8321] = "Necrite",      [8322] = "Phasmatite",   [8323] = "Banite",
    [8324] = "Light animica",[8325] = "Dark animica",
}

--- Grace of the elves.
---
--- Matched by NAME so it works whatever variant is worn, rather than pinning a
--- single item id.
local GRACE_NAME = "Grace of the elves"

local GRACE_BUFF = 51490
local GRACE_MAX  = 500
local GRACE_CHARGE_ACTION = { 0xffffffff, 0xae06, 6, 1464, 15, 2 }
local PORTER_IDS  = { 29275, 29277, 29279, 29281, 29283, 29285, 51490 }
local PORTER_NAME = "Sign of the porter"

--- Bank objects worth trying, by name.
local BANK_NAMES = { "Bank chest", "Deposit box", "Bank booth", "Banker" }

local IDLE_ANIMS = { [-1] = true, [0] = true, [1] = true }

local startTime      = os.time()
local startXp        = API.GetSkillXP("MINING")
local rockertunities = 0
local staminaRefresh = 0
local bankTrips      = 0
local fails          = 0
local lastClickTick  = -99
local lastRockTile   = nil
--- Tick before which the last click is left alone. See clickInFlight().
local commitUntilTick = -99
local status         = "Starting"
local dumpedGfx      = false

--- The ore picked out of the catalogue, if CONFIG.ORE names one.
local selectedOre    = nil
local selectedKey    = nil
local graceAttempts  = 0
--- Last reading taken by maintainGrace, for the stats panel to reuse.
local graceWornSeen  = false
local graceSeen      = nil
local graceCharged   = 0
local oresDropped    = 0

local function log(fmt, ...)
    API.printlua(string.format(fmt, ...), 0, false)
end

local function debugLog(fmt, ...)
    if CONFIG.DEBUG then log("[debug] " .. fmt, ...) end
end

local function running()
    return API.Read_LoopyLoop()
end

local function setStatus(text)
    status = text
    pcall(function() API.Write_ScripCuRunning0(text) end)
end

--- Native entity queries can throw when the entity list mutates mid-read.
local function safeQuery(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok or result == nil then
        debugLog("query failed: %s", tostring(result))
        return {}
    end
    return result
end

local function playerIsIdle()
    return IDLE_ANIMS[API.ReadPlayerAnim()] == true
end

local function isMining()
    local ok, animating = pcall(API.CheckAnim, CONFIG.ANIM_WINDOW)
    if ok and type(animating) == "boolean" then return animating end
    return not playerIsIdle()
end

--- The ceiling comes first so a click that never took cannot wedge the loop.
local function clickInFlight()
    local tick = API.Get_tick()
    if tick - lastClickTick >= CONFIG.COMMIT_CEILING then return false end
    if isMining() then return false end

    local ok, moving = pcall(API.ReadPlayerMovin2)
    if ok and moving then return true end

    return tick < commitUntilTick
end

local function stamina()
    local ok, value = pcall(API.LocalPlayer_HoverProgress)
    if ok and type(value) == "number" then return value end
    return nil
end

local function inventoryFull()
    local ok, full = pcall(function() return Inventory:IsFull() end)
    return ok and full == true
end

--- Ore held in the box, as {oreName = count} for anything above zero.
local function oreBoxContents()
    local out = {}
    for varbit, ore in pairs(ORE_BOX_VARBITS) do
        local ok, vb = pcall(API.VB_FindPSett, varbit)
        if ok and vb and type(vb.state) == "number" then
            local count = vb.state & 0x3fff
            if count > 0 then out[ore] = count end
        end
    end
    return out
end

--- Whether any ore in the box has hit the cap.
local function oreBoxFull()
    for _, count in pairs(oreBoxContents()) do
        if count >= CONFIG.ORE_BOX_CAP then return true end
    end
    return false
end

--- Current Mining level.
local function miningLevel()
    local ok, lvl = pcall(function()
        return API.XPLevelTable(API.GetSkillXP("MINING"))
    end)
    return (ok and type(lvl) == "number") and lvl or 1
end

--- @return boolean ok
local function resolveOre()
    if CONFIG.ORE == nil or CONFIG.ORE == "" then return true end

    if tostring(CONFIG.ORE):lower() == "best" then
        selectedOre, selectedKey = Ores.bestForLevel(miningLevel())
        if not selectedOre then
            log("No ore is mineable at Mining level %d.", miningLevel())
            return false
        end
        log("Level %d: mining %s (tier %d).",
            miningLevel(), selectedOre.Name, selectedOre.Tier or 0)
        return true
    end

    selectedOre, selectedKey = Ores.byName(CONFIG.ORE)
    if not selectedOre then
        log('Unknown ore "%s". Known ores:', tostring(CONFIG.ORE))
        for _, cat in ipairs({ "Ores", "Primals", "Gems", "Minerals", "Misc" }) do
            local keys = Ores.byCategory(cat)
            if #keys > 0 then
                log("  %-9s %s", cat, table.concat(keys, ", "))
            end
        end
        return false
    end

    if selectedOre.Level > miningLevel() then
        log("%s needs Mining %d and you have %d.",
            selectedOre.Name, selectedOre.Level, miningLevel())
        return false
    end

    log("Mining %s (level %d, rocks %s).", selectedOre.Name, selectedOre.Level,
        table.concat(selectedOre.RockIDs, "/"))
    return true
end

--- The rock names to look for.
local function rockNames()
    if #CONFIG.ROCKS > 0 then return CONFIG.ROCKS end

    -- "rock" alone catches Copper rock, Iron rock, Gem rock and the rest; the
    -- extras cover the ores that are not named that way.
    local names = { "rock" }
    for _, name in ipairs(EXTRA_ROCK_NAMES) do names[#names + 1] = name end
    return names
end

local function findRocks()
    local found

    if selectedOre then
        found = safeQuery(API.GetAllObjArray1, selectedOre.RockIDs,
                          CONFIG.SCAN_RANGE, { 0, 12 })
    else
        found = safeQuery(API.GetAllObjArrayInteract_str, rockNames(),
                          CONFIG.SCAN_RANGE, { 0, 12 })
    end
    if #found == 0 then return {} end

    local sorted = safeQuery(API.Math_SortAODistA, found)
    return (#sorted > 0) and sorted or found
end

local function dumpHighlights(highlights)
    if dumpedGfx or not CONFIG.DEBUG then return end
    dumpedGfx = true

    log("Highlight (type 4) objects near the rocks:")
    local seen = {}
    for i = 1, #highlights do
        local hl = highlights[i]
        if hl and hl.Id and not seen[hl.Id] then
            seen[hl.Id] = true
            log("  id %s  name %q", tostring(hl.Id), tostring(hl.Name or ""))
        end
    end
    if next(seen) == nil then log("  (none in range)") end
end

--- @param rocks table[] rocks already found, nearest first
--- @return table|nil rock
local function findRockertunity(rocks)
    if not CONFIG.USE_ROCKERTUNITIES or #rocks == 0 then return nil end

    local wanted = (#CONFIG.ROCKERTUNITY_GFX > 0) and CONFIG.ROCKERTUNITY_GFX or { -1 }
    local highlights = safeQuery(API.GetAllObjArray1, wanted,
                                 CONFIG.HIGHLIGHT_RANGE, { 4 })
    if #highlights == 0 then return nil end
    dumpHighlights(highlights)

    local best, bestDist = nil, math.huge
    for i = 1, #rocks do
        local rock = rocks[i]
        local rt = rock and rock.Tile_XYZ
        if rt then
            for j = 1, #highlights do
                local ht = highlights[j] and highlights[j].Tile_XYZ
                if ht then
                    local dx, dy = rt.x - ht.x, rt.y - ht.y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < bestDist then
                        best, bestDist = rock, dist
                    end
                end
            end
        end
    end
    if best and bestDist < 1.0 then return best end
    return nil
end

local function staminaThreshold()
    local lo, hi = CONFIG.STAMINA_JITTER[1] or 0, CONFIG.STAMINA_JITTER[2] or 0
    return CONFIG.STAMINA_BELOW + math.random(lo, hi)
end

--- Whether a rock is the one we are already mining.
local function isCurrentRock(rock)
    if not lastRockTile or not rock or not rock.Tile_XYZ then return false end
    return math.abs(rock.Tile_XYZ.x - lastRockTile.x) < 0.5
       and math.abs(rock.Tile_XYZ.y - lastRockTile.y) < 0.5
end

--- The rock we are already mining, located in the current scan by tile.
---
--- Matched on TILE and not on Id: rocks of one ore share ids across a mine, so
--- an id comparison would happily hand back a different rock two squares away.
local function currentRockIn(rocks)
    for i = 1, #rocks do
        if isCurrentRock(rocks[i]) then return rocks[i] end
    end
    return nil
end

local function mineRock(rock, why, commitTicks)
    if not rock then return false end

    setStatus(why)
    debugLog("%s: %s (%s)", why, tostring(rock.Name), tostring(rock.Id))

    if API.DoAction_Object_Direct(0x3a, API.OFF_ACT_GeneralObject_route0, rock) then
        lastClickTick   = API.Get_tick()
        lastRockTile    = rock.Tile_XYZ
        commitUntilTick = lastClickTick + (commitTicks or CONFIG.COMMIT_TICKS)
        return true
    end
    return false
end

--- Whether the amulet is actually worn.
local function wearingGrace()
    local ok, has = pcall(function() return Equipment:Contains(GRACE_NAME) end)
    return ok and has == true
end

--- @return number|nil
local function graceCharges()
    local ok, bar = pcall(API.Buffbar_GetIDstatus, GRACE_BUFF, false)
    if not ok or type(bar) ~= "table" then return nil end

    local n = tonumber(bar.text)
    if n then return n end

    local found = bar.found == true or (tonumber(bar.id) or 0) > 0
    return (not found) and 0 or nil
end

--- Porters in the pack.
local function porterCount()
    local ok, n = pcall(function() return Inventory:InvItemcount_String(PORTER_NAME) end)
    if ok and type(n) == "number" and n > 0 then return n end

    local ok2, found = pcall(function() return Inventory:InvItemFounds(PORTER_IDS) end)
    return (ok2 and found == true) and 1 or 0
end

--- Tops the amulet up when it runs low.
--- @return boolean keepGoing  false means stop the script
--- @return boolean acted      true if a charge was just attempted
local function maintainGrace()
    if not CONFIG.USE_GRACE then return true, false end
    if not wearingGrace() then
        graceWornSeen = false
        return true, false
    end

    local charges = graceCharges()
    graceWornSeen, graceSeen = true, charges
    if charges == nil then return true, false end

    if charges >= CONFIG.GRACE_CHARGE_BELOW then
        graceAttempts = 0       -- it recovered, so the count starts over
        return true, false
    end

    if porterCount() <= 0 then
        log("Grace of the elves is at %d/%d charges and there are no porters "
            .. "left to charge it with. Stopping.", charges, GRACE_MAX)
        return false, false
    end

    -- Bounded, because a charge click that does not take would otherwise fire
    -- again every pass forever -- the same trap as a cooldown that only
    -- advances on success.
    graceAttempts = graceAttempts + 1
    if graceAttempts > CONFIG.GRACE_MAX_ATTEMPTS then
        log("Charged the Grace of the elves %d times and the count has not "
            .. "moved off %d. Stopping.", graceAttempts - 1, charges)
        return false, false
    end

    setStatus("Charging Grace of the elves")
    log("Grace at %d/%d charges - charging all porters (attempt %d).",
        charges, GRACE_MAX, graceAttempts)

    local a = GRACE_CHARGE_ACTION
    pcall(API.DoAction_Interface, a[1], a[2], a[3], a[4], a[5], a[6],
          API.OFF_ACT_GeneralInterface_route2)
    graceCharged = graceCharged + 1
    API.RandomSleep2(900, 200, 300)
    return true, true
end

--- @return number dropped
local function dropOres()
    local ids = {}
    if selectedOre then
        for _, id in ipairs(selectedOre.OreIDs) do ids[#ids + 1] = id end
    else
        for id in pairs(Ores.allOreIds()) do ids[#ids + 1] = id end
    end

    setStatus("Dropping ore")
    local dropped = 0

    for _, id in ipairs(ids) do
        local ok, count = pcall(function() return Inventory:InvItemcount(id) end)
        if ok and type(count) == "number" and count > 0 then
            for _ = 1, count do
                if not running() then return dropped end
                local okDrop, done = pcall(function() return Inventory:Drop(id) end)
                if not okDrop or done == false then break end
                dropped = dropped + 1
                API.RandomSleep2(120, 40, 60)
            end
        end
    end

    oresDropped = oresDropped + dropped
    if dropped > 0 then debugLog("dropped %d ore", dropped) end
    return dropped
end

local function bank()
    setStatus("Banking")

    local found = safeQuery(API.GetAllObjArrayInteract_str, BANK_NAMES,
                            CONFIG.SCAN_RANGE, { 0, 12 })
    if #found == 0 then
        log("Pack is full and no bank in range.")
        return false
    end

    local sorted = safeQuery(API.Math_SortAODistA, found)
    local chest = (#sorted > 0 and sorted[1]) or found[1]

    API.DoAction_Object_Direct(0x2e, API.OFF_ACT_GeneralObject_route1, chest)
    for _ = 1, 20 do
        API.RandomSleep2(300, 50, 100)
        if not running() then return false end
        local ok, open = pcall(function() return Bank:IsOpen() end)
        if ok and open then break end
    end

    local ok = pcall(function() return Bank:IsOpen() end)
    if not ok then return false end

    pcall(function() Bank:OreBoxDepositOres() end)
    API.RandomSleep2(600, 100, 200)
    pcall(function() Bank:DepositInventory() end)
    API.RandomSleep2(600, 100, 200)

    if CONFIG.BANK_PRESET and CONFIG.BANK_PRESET > 0 then
        pcall(function() Bank:LoadPreset(CONFIG.BANK_PRESET) end)
        API.RandomSleep2(1200, 200, 300)
    end

    bankTrips = bankTrips + 1
    log("Banked (trip %d).", bankTrips)
    return true
end

local function runtime()
    local t = os.difftime(os.time(), startTime)
    return string.format("%02d:%02d:%02d", t // 3600, (t % 3600) // 60, t % 60)
end

local function perHour(value)
    local elapsed = os.difftime(os.time(), startTime)
    if elapsed <= 0 then return 0 end
    return math.floor(value * 3600 / elapsed)
end

local function graceText()
    if not CONFIG.USE_GRACE then return "off" end
    if not graceWornSeen then return "not worn" end
    return graceSeen and (graceSeen .. " / " .. GRACE_MAX) or "?"
end

local function oreBoxSummary()
    local parts = {}
    for ore, count in pairs(oreBoxContents()) do
        parts[#parts + 1] = ore .. " " .. count
    end
    if #parts == 0 then return "empty" end
    table.sort(parts)
    return table.concat(parts, ", ") .. (oreBoxFull() and "  (FULL)" or "")
end

local function drawStats()
    local xp = API.GetSkillXP("MINING") - startXp
    pcall(API.DrawTable, {
        { "Script",         "Mining AIO" },
        { "Runtime",        runtime() },
        { "Status",         status },
        { "Ore",            selectedOre and selectedOre.Name or "Any nearby" },
        { "Mining",         tostring(API.XPLevelTable(API.GetSkillXP("MINING"))) },
        { "XP gained",      tostring(xp) },
        { "XP/hr",          tostring(perHour(xp)) },
        { "Rockertunities", tostring(rockertunities) },
        { "Rockert./hr",    tostring(perHour(rockertunities)) },
        { "Stamina",        tostring(stamina() or "?") .. " / 255" },
        { "Stamina resets", tostring(staminaRefresh) },
        { "Ore box",        oreBoxSummary() },
        { "Grace charges",  graceText() },
        { "Ore dropped",    tostring(oresDropped) },
        { "Bank trips",     tostring(bankTrips) },
    })
end

local function buildGUIData()
    local xp = API.GetSkillXP("MINING") - startXp
    return {
        ore            = selectedOre and selectedOre.Name or "Any nearby rock",
        status         = status,
        runtime        = runtime(),
        level          = API.XPLevelTable(API.GetSkillXP("MINING")),
        xp             = xp,
        xpHr           = perHour(xp),
        rockertunities = rockertunities,
        rockertunityHr = perHour(rockertunities),
        stamina        = stamina(),
        staminaResets  = staminaRefresh,
        oreBox         = oreBoxSummary(),
        grace          = graceText(),
        oresDropped    = oresDropped,
        bankTrips      = bankTrips,
    }
end

ClearRender()
DrawImGui(function()
    if not GUI.open then return end
    if not GUI.started then
        GUI.draw({})
        return
    end
    local ok, data = pcall(buildGUIData)
    GUI.draw(ok and data or {})
end)

log("Mining AIO - pick what to mine in the window, then press Start.")

while running() and not GUI.started do
    if not GUI.open then
        log("GUI closed before start.")
        ClearRender()
        return
    end
    API.RandomSleep2(100, 50, 0)
end

if not running() then
    ClearRender()
    return
end

GUI.apply(CONFIG)

log("Mining AIO started. Rockertunities: %s. Stamina refresh: %s.",
    CONFIG.USE_ROCKERTUNITIES and "on" or "off",
    CONFIG.STAMINA_BELOW > 0 and ("below " .. CONFIG.STAMINA_BELOW) or "off")

if not resolveOre() then
    setStatus("Stopped")
    API.Write_LoopyLoop(false)
end

while running() do
    if GUI.stopped then
        log("Stopped from the GUI.")
        break
    end

    drawStats()

    -- Upkeep before anything else. A flat amulet stops teleporting ore and the
    -- pack quietly starts filling, so this is worth a check every pass.
    local graceOk, graceActed = maintainGrace()
    if not graceOk then
        setStatus("Stopped")
        break
    end

    if not API.PlayerLoggedIn() then
        setStatus("Waiting for login")
        API.RandomSleep2(2000, 200, 300)

    elseif graceActed then
        -- Just clicked the equipment interface; let it settle rather than
        -- clicking a rock in the same breath.
        API.RandomSleep2(300, 100, 200)

    elseif inventoryFull() then
        if CONFIG.FULL_ACTION == "drop" then
            -- Powermining. A full pack with nothing droppable in it means the
            -- pack is full of something else, and dropping again next pass
            -- would do nothing at all -- so stop rather than spin.
            if dropOres() == 0 then
                log("Pack is full but there is no ore in it to drop. Stopping.")
                break
            end

        elseif CONFIG.FULL_ACTION ~= "bank" then
            log("Pack full after %s. Stopping.", runtime())
            break

        elseif not bank() then
            fails = fails + 1
            if fails >= CONFIG.MAX_FAILS then
                log("Could not bank. Stopping.")
                break
            end
            API.RandomSleep2(1500, 300, 400)
        else
            fails = 0
        end

    else
        local rocks = findRocks()

        if #rocks == 0 then
            fails = fails + 1
            setStatus("No rocks in range")
            if fails >= CONFIG.MAX_FAILS then
                log("No rocks within %d tiles after %d passes. Stopping.",
                    CONFIG.SCAN_RANGE, fails)
                break
            end
            API.RandomSleep2(900, 200, 300)

        else
            fails = 0
            local tick = API.Get_tick()
            local rockertunity = findRockertunity(rocks)

            if clickInFlight() then
                setStatus("Walking to rock")

            elseif rockertunity and not isCurrentRock(rockertunity) then
                if mineRock(rockertunity, "Rockertunity!", CONFIG.RT_COMMIT_TICKS) then
                    rockertunities = rockertunities + 1
                    log("Rockertunity taken (%d).", rockertunities)
                end

            elseif not isMining() then
                -- Genuinely not swinging -- not merely walking, which
                -- clickInFlight already ruled out.
                mineRock(rocks[1], "Mining")

            elseif CONFIG.STAMINA_BELOW > 0 and (stamina() or 255) < staminaThreshold()
                and (tick - lastClickTick) >= 3 then
                local target = currentRockIn(rocks)

                if target then
                    if mineRock(target, "Stamina refresh") then
                        staminaRefresh = staminaRefresh + 1
                    end
                else
                    debugLog("stamina low but the current rock is out of range")
                end
            end

            API.RandomSleep2(300, 100, 200)
        end
    end
    
    API.DoRandomEvents()
    API.RandomSleep2(50, 30, 60)
end

setStatus("Stopped")
ClearRender()
log("Session: %d xp, %d rockertunities, %d stamina resets, %d ore dropped, "
    .. "%d grace charges, %d bank trips, %s.",
    API.GetSkillXP("MINING") - startXp, rockertunities, staminaRefresh,
    oresDropped, graceCharged, bankTrips, runtime())
