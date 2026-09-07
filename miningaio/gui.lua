local API    = require("api")
local GUILib = require("core.gui_lib")
local Ores   = require("miningaio.ores")

local ui = GUILib.new()

local MGUI = {
    open    = true,
    started = false,
    stopped = false,
}

local MODE_BEST, MODE_PICK, MODE_ANY = 1, 2, 3
local MODES = { "Best for my level", "Pick a specific ore", "Anything nearby" }

local CATEGORIES = { "Ores", "Primals", "Gems", "Minerals", "Misc" }

local FULL_ACTIONS       = { "Stop the script", "Bank it", "Drop the ore" }
local FULL_ACTION_VALUES = { "stop", "bank", "drop" }
MGUI.choice = {
    mode         = MODE_BEST,
    category     = 1,
    ore          = 1,      -- index into the current category's key list

    rockertunity = true,
    staminaBelow = 200,
    fullAction   = 1,      -- index into FULL_ACTIONS
    bankPreset   = 1,

    useGrace     = false,
    graceBelow   = 10,
    scanRange    = 12,
}

local keyCache = {}
local function oreKeys(category)
    if not keyCache[category] then keyCache[category] = Ores.byCategory(category) end
    return keyCache[category]
end

local function miningLevel()
    local ok, lvl = pcall(function()
        return API.XPLevelTable(API.GetSkillXP("MINING"))
    end)
    return (ok and type(lvl) == "number") and lvl or 1
end

local labelCache = {}
local function oreLabels(category, level)
    local cacheKey = category .. "@" .. level
    if labelCache[cacheKey] then return labelCache[cacheKey] end

    local labels = {}
    for i, key in ipairs(oreKeys(category)) do
        local ore = Ores.ORES[key]
        labels[i] = ("%s  (level %d)%s"):format(
            ore.Name, ore.Level, ore.Level > level and "  [LOCKED]" or "")
    end
    labelCache[cacheKey] = labels
    return labels
end

--- The ore key the player currently has selected, or nil in the other modes.
function MGUI.selectedKey()
    if MGUI.choice.mode ~= MODE_PICK then return nil end
    local keys = oreKeys(CATEGORIES[MGUI.choice.category])
    return keys[MGUI.choice.ore]
end

--- The selected catalogue entry, or nil.
function MGUI.selectedOre()
    local key = MGUI.selectedKey()
    return key and Ores.ORES[key] or nil
end

--- Why the run cannot start, or nil when it can.
local function blocker()
    if MGUI.choice.mode ~= MODE_PICK then return nil end

    local ore = MGUI.selectedOre()
    if not ore then return "Pick an ore first." end

    if ore.Level > miningLevel() then
        return ("%s needs Mining %d and you have %d.")
            :format(ore.Name, ore.Level, miningLevel())
    end
    if ore.Category == "Primals" then
        return nil  -- allowed, but warned about below
    end
    return nil
end

function MGUI.apply(CONFIG)
    local c = MGUI.choice

    if c.mode == MODE_BEST then
        CONFIG.ORE = "best"
    elseif c.mode == MODE_PICK then
        CONFIG.ORE = MGUI.selectedKey()
    else
        CONFIG.ORE = nil
    end

    CONFIG.USE_ROCKERTUNITIES = c.rockertunity
    CONFIG.STAMINA_BELOW      = c.staminaBelow
    CONFIG.FULL_ACTION        = FULL_ACTION_VALUES[c.fullAction] or "stop"
    CONFIG.USE_GRACE          = c.useGrace
    CONFIG.GRACE_CHARGE_BELOW = c.graceBelow
    CONFIG.BANK_PRESET        = c.bankPreset
    CONFIG.SCAN_RANGE         = c.scanRange
end

local function drawSetup()
    local c = MGUI.choice
    local level = miningLevel()

    ui:sectionHeader("What to mine", "Mining level " .. level)

    c.mode = ui:labeledCombo("Selection", "##mode", c.mode, MODES)

    if c.mode == MODE_BEST then
        local ore = Ores.bestForLevel(level)
        if ore then
            ui:text(("Level %d gets you %s."):format(level, ore.Name), "hint")
        else
            ui:text("No ore is mineable at your level.", "error")
        end
        ui:text("Surface ores only - primals, gems and minerals are a "
                .. "deliberate pick, not an upgrade.", "hint")

    elseif c.mode == MODE_PICK then
        local newCat = ui:labeledCombo("Category", "##cat", c.category, CATEGORIES)
        if newCat ~= c.category then
            c.category = newCat
            c.ore = 1       -- the old index means nothing in a new category
        end

        local category = CATEGORIES[c.category]
        c.ore = ui:labeledCombo("Ore", "##ore", c.ore, oreLabels(category, level))

        local ore = MGUI.selectedOre()
        if ore then
            ui:text(("Rock ids: %s"):format(table.concat(ore.RockIDs, ", ")), "hint")
            if ore.Category == "Primals" then
                ui:text("Primals are Daemonheim only and need a ring of "
                        .. "kinship. Stand in the resource dungeon.", "warning")
            end
        end

    else
        ui:text("Mines whatever rock is nearest, matched by name.", "hint")
        ui:text("Use this when you are somewhere the catalogue does not "
                .. "cover.", "hint")
    end

    ui:separator(2, 3)
    ui:sectionHeader("Behaviour")

    c.rockertunity = ui:checkbox("Take rockertunities##rt", c.rockertunity)
    ui:text("The sparkling rock. Worth x4 to x8 damage - the single biggest "
            .. "xp gain in modern mining.", "hint")

    c.staminaBelow = ui:labeledSliderInt("Reset stamina below##stam",
                                         "##stamval", c.staminaBelow, 0, 255)
    ui:text(c.staminaBelow > 0
        and "Re-clicks the rock you are already on to reset the bar. 0 turns "
            .. "it off and accepts the damage penalty."
        or  "Off - fully AFK, at 20% damage once the bar empties.", "hint")

    c.scanRange = ui:labeledSliderInt("Scan range (tiles)##range",
                                      "##rangeval", c.scanRange, 4, 30)

    ui:separator(2, 3)
    ui:sectionHeader("Banking")

    c.fullAction = ui:labeledCombo("When the pack is full", "##full",
                                   c.fullAction, FULL_ACTIONS)

    if FULL_ACTION_VALUES[c.fullAction] == "drop" then
        ui:text("Powermining. Only items the ore catalogue recognises are "
                .. "dropped, so your pickaxe, ore box and porters are safe.",
                "hint")
    end

    if FULL_ACTION_VALUES[c.fullAction] == "bank" then
        c.bankPreset = ui:labeledInputInt("Bank preset##preset", "##presetval",
                                          c.bankPreset, 1)
        ui:text("Needs a bank chest, booth, banker or deposit box in range.",
                "hint")
    else
        ui:text("The script stops when the pack is full.", "hint")
    end

    ui:separator(2, 3)
    ui:sectionHeader("Grace of the elves",
                     "Teleports ore straight to the bank, so the pack never fills.")

    c.useGrace = ui:checkbox("Keep it charged from porters##grace", c.useGrace)
    if c.useGrace then
        c.graceBelow = ui:labeledSliderInt("Charge when below##gbelow",
                                           "##gbelowval", c.graceBelow, 1, 500)
        ui:text("Wear the amulet and keep signs of the porter in your pack. "
                .. "The script stops if it runs low with no porters left.",
                "hint")
    end

    ui:separator(2, 3)

    local why = blocker()
    if why then
        ui:text(why, "error")
    elseif ui:buttonSuccess("Start Mining##start") then
        MGUI.started = true
    end
end

local function drawRuntime(data)
    ui:sectionHeader(data.ore or "Mining", data.status or "")

    if ui:beginInfoTable("##minestats", 0.45) then
        ui:tableRow("Runtime",        data.runtime or "00:00:00")
        ui:tableRow("Mining level",   tostring(data.level or "?"))
        ui:tableRow("XP gained",      GUILib.formatNumber(data.xp or 0))
        ui:tableRow("XP/hr",          GUILib.formatNumber(data.xpHr or 0))
        ui:tableRow("Rockertunities", tostring(data.rockertunities or 0))
        ui:tableRow("Rockert./hr",    tostring(data.rockertunityHr or 0))
        ui:tableRow("Stamina",        tostring(data.stamina or "?") .. " / 255")
        ui:tableRow("Stamina resets", tostring(data.staminaResets or 0))
        ui:tableRow("Ore box",        data.oreBox or "empty")
        ui:tableRow("Grace charges",  data.grace or "off")
        ui:tableRow("Ore dropped",    tostring(data.oresDropped or 0))
        ui:tableRow("Bank trips",     tostring(data.bankTrips or 0))
        ImGui.EndTable()
    end

    ui:spacing(2)
    if ui:buttonDanger("Stop Script##stop") then MGUI.stopped = true end
end

function MGUI.draw(data)
    data = data or {}

    ImGui.SetNextWindowPos(100, 100, ImGuiCond.FirstUseEver)
    ImGui.SetNextWindowSize(420, 0, ImGuiCond.Always)
    local colorCount, styleCount = ui:pushTheme()

    local title = ("Mining AIO - %s###MiningAIO"):format(API.ScriptRuntimeString())
    local visible = ui:beginWindow(title, 64)   -- AlwaysAutoResize

    if visible then
        local ok, err = pcall(MGUI.started and drawRuntime or drawSetup, data)
        if not ok then ui:text("GUI error: " .. tostring(err), "error") end
    end

    ui:endWindow()
    ui:popTheme(colorCount, styleCount)

    return MGUI.open
end

return MGUI
