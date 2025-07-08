-- Boilerplate to get the addon name (works in every flavor of WoW)
local ADDON_NAME, ADDON = ...

-----------------------------------------------------------------------
-- 1.  Defaults
-----------------------------------------------------------------------
local defaults = {
    myVariable = true, -- default value shown here
}

-----------------------------------------------------------------------
-- 2.  Utility: copy table recursively
-----------------------------------------------------------------------
local function copyDefaults(src, dest)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = dest[k] or {}
            copyDefaults(v, dest[k])
        elseif dest[k] == nil then
            dest[k] = v
        end
    end
end

-----------------------------------------------------------------------
-- 3.  SavedVariable pointer (created by WoW when addon loads)
-----------------------------------------------------------------------
local DB -- will point at MyAddonDB after ADDON_LOADED

-----------------------------------------------------------------------
-- 4.  ADDON_LOADED handler
-----------------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, addonName)
    if addonName ~= ADDON_NAME then return end

    -- If first run, global MyAddonDB is nil: create it
    MyAddonDB = MyAddonDB or {}
    DB = MyAddonDB

    -- Fill in missing defaults without clobbering player settings
    copyDefaults(defaults, DB)

    print("|cff59f0ff" .. ADDON_NAME .. ":|r loaded.  " ..
        "myVariable is |cffffff00" .. tostring(DB.myVariable) .. "|r")
end)


-- Simple toggler: `/myaddon` prints current value, `/myaddon on/off`
SLASH_MYADDON1 = "/myaddon"

SlashCmdList["MYADDON"] = function(msg)
    msg = msg:lower():trim() -- remove spaces, handle ON/off/etc.

    if msg == "" then
        -- Just report current state
        print("myVariable is |cffffff00" .. tostring(DB.myVariable) .. "|r")
        return
    end

    if msg == "on" or msg == "true" or msg == "1" then
        DB.myVariable = true
    elseif msg == "off" or msg == "false" or msg == "0" then
        DB.myVariable = false
    else
        print("Usage: /myaddon [on|off]")
        return
    end

    print("myVariable set to |cffffff00" .. tostring(DB.myVariable) .. "|r")
end
