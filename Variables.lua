local ADDON_NAME, ADDON = ...

-- 1. Static defaults
local defaults = {
    showTwistMarks = true,
    showGCD        = true,
    gcdSpell = "Flash of Light",
    showSwing      = true,
}

local function inherit(dest, src)
    return setmetatable(dest or {}, {
        __index = function(t, k)
            local v = src[k]
            if type(v) == "table" then              -- auto-spawn nested tables
                v = inherit(nil, v)                 -- give child its own metatable
                rawset(t, k, v)                     -- cache for future lookups
            end
            return v
        end,
    })
end

-- 2. Ensure SavedVariable exists
ADDeadmansSwingTimerDB = ADDeadmansSwingTimerDB or {}

-- 3. Metatable fallback
setmetatable(ADDeadmansSwingTimerDB, { __index = defaults })

-- 4. Hand it to the rest of the addon
ADDON.db = ADDeadmansSwingTimerDB

print(ADDON_NAME .. " loaded – myVariable is!! "
    .. tostring(ADDeadmansSwingTimerDB.showGCD))

-----------------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, addonName)
    if addonName ~= ADDON_NAME then return end

    -- -- If first run, global MyAddonDB is nil: create it
    -- MyAddonDB = MyAddonDB or {}
    -- DB = MyAddonDB

    -- -- Fill in missing defaults without clobbering player settings
    -- copyDefaults(defaults, DB)

    print("|cff59f0ff" .. ADDON_NAME .. ":|r loaded.  " ..
        "myVariable is |cffffff00" .. tostring(ADDeadmansSwingTimerDB.showGCD) .. "|r")

    print(ADDON_NAME .. " loaded – myVariable is "
        .. tostring(ADDeadmansSwingTimerDB.showGCD))
end)

SLASH_ADDEADMAN1 = "/addeadman"
SlashCmdList["ADDEADMAN"] = function(msg)
    msg = strtrim(msg):lower()

    if msg == "gcdon" then
        ADDeadmansSwingTimerDB.showGCD = true
    elseif msg == "gcdoff" then
        ADDeadmansSwingTimerDB.showGCD = false
    elseif msg ~= "" then
        print("Usage: /myaddon [on|off]  (current: "
              .. tostring(ADDeadmansSwingTimerDB.showGCD) .. ")")

              
        print("Usage: /myaddon [on|off]  (current DB: "
              .. tostring(ADDON.db.showGCD) .. ")")
        return
    end

    print("myVariable is now |cffffff00" .. tostring(ADDeadmansSwingTimerDB.myVariable) .. "|r")
end

-- Simple toggler: `/myaddon` prints current value, `/myaddon on/off`
-- SLASH_MYADDON1 = "/myaddon"

-- SlashCmdList["MYADDON"] = function(msg)
--     msg = msg:lower():trim() -- remove spaces, handle ON/off/etc.

--     if msg == "" then
--         -- Just report current state
--         print("myVariable is |cffffff00" .. tostring(DB.myVariable) .. "|r")
--         return
--     end

--     if msg == "on" or msg == "true" or msg == "1" then
--         DB.myVariable = true
--     elseif msg == "off" or msg == "false" or msg == "0" then
--         DB.myVariable = false
--     else
--         print("Usage: /myaddon [on|off]")
--         return
--     end

--     print("myVariable set to |cffffff00" .. tostring(DB.myVariable) .. "|r")
-- end