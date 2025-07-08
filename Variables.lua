local ADDON_NAME, ADDON = ...

-- 1. Static defaults
local defaults = {
    showTwistMarks = true,
    showGCD        = true,
    gcdSpell = "Flash of Light",
    gcdInterval = 0.00,
    showSwing      = true,
    swingInterval = 0.00,
    showMarkOne = true,
    showMarkTwo = true,
    thickness = 1,
    opacity = 1
}

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

-- 2. Ensure SavedVariable exists
ADDeadmansSwingTimerDB = ADDeadmansSwingTimerDB or {}

-- -- 3. Metatable fallback
setmetatable(ADDeadmansSwingTimerDB, { __index = defaults })

-- -- 4. Hand it to the rest of the addon
-- ADDON.db = ADDeadmansSwingTimerDB

print(ADDON_NAME .. " loaded – showGCD is!! "
    .. tostring(ADDeadmansSwingTimerDB.showGCD))

-- -----------------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, addonName)
    if addonName ~= ADDON_NAME then return end

    -- If first run, global ADDeadmansSwingTimerDB is nil: create it
    ADDeadmansSwingTimerDB = ADDeadmansSwingTimerDB or {}
    DB = ADDeadmansSwingTimerDB

    ADDON.db = DB

    -- -- Fill in missing defaults without clobbering player settings
    copyDefaults(defaults, DB)

    print("|cff59f0ff" .. ADDON_NAME .. ":|r loaded.  " ..
        "Show GCD is |cffffff00" .. tostring(ADDeadmansSwingTimerDB.showGCD) .. " - " .. tostring(ADDeadmansSwingTimerDB.gcdInterval) .. "|r")

    print("|cff59f0ff" .. ADDON_NAME .. ":|r loaded.  " ..
        "Show Swing is |cffffff00" .. tostring(ADDeadmansSwingTimerDB.showSwing) .. " - " .. tostring(ADDeadmansSwingTimerDB.swingInterval) .. "|r")

    print("|cff59f0ff" .. ADDON_NAME .. ":|r loaded.  " ..
        "Show Mark One is |cffffff00" .. tostring(ADDeadmansSwingTimerDB.showMarkOne) .. "|r")

    print("|cff59f0ff" .. ADDON_NAME .. ":|r loaded.  " ..
        "Show Mark Two is |cffffff00" .. tostring(ADDeadmansSwingTimerDB.showMarkTwo) .. "|r")

        
    print("|cff59f0ff" .. ADDON_NAME .. ":|r loaded.  " ..
        "Opacity is |cffffff00" .. tostring(ADDeadmansSwingTimerDB.opacity) .. "|r")

        
    print("|cff59f0ff" .. ADDON_NAME .. ":|r loaded.  " ..
        "Thickness is |cffffff00" .. tostring(ADDeadmansSwingTimerDB.thickness) .. "|r")

end)


local function splitFirst(msg)
    msg = msg:gsub("^%s+", ""):gsub("%s+$", "")      -- trim
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")    -- allow empty
    return cmd:lower(), rest
end

local Command = {}

function Command:gcd(arg)
    arg = arg:lower()
    if arg == "on" then
        ADDeadmansSwingTimerDB.showGCD = true
        print("|cff00ff80addeadman|r: GCD display |cff00ff00ENABLED|r.")
        -- (enable whatever frame/logic you use)
    elseif arg == "off" then
        ADDeadmansSwingTimerDB.showGCD = false
        print("|cff00ff80addeadman|r: GCD display |cffff2020DISABLED|r.")
        -- (disable the frame/logic)
    else
        print("|cff00ff80addeadman|r usage: /addeadman gcd on|off")
    end
end

-- /addeadman gcdinterval 0.05
function Command:gcdinterval(arg)
    local seconds = tonumber(arg)
    if not seconds then
        print("not seconds")
    end
    if not seconds or seconds < 0 then
        print("|cff00ff80addeadman|r usage: /addeadman gcdinterval <0.5|0.05|etc>")
        return
    end
    ADDeadmansSwingTimerDB.gcdInterval = seconds;
end



function Command:swing(arg)
    arg = arg:lower()
    if arg == "on" then
        ADDeadmansSwingTimerDB.showSwing = true
        print("|cff00ff80addeadman|r: Swing display |cff00ff00ENABLED|r.")
        -- (enable whatever frame/logic you use)
    elseif arg == "off" then
        ADDeadmansSwingTimerDB.showSwing = false
        print("|cff00ff80addeadman|r: Swing display |cffff2020DISABLED|r.")
        -- (disable the frame/logic)
    else
        print("|cff00ff80addeadman|r usage: /addeadman swing on|off")
    end
end

-- /addeadman swinginterval 0.05
function Command:swinginterval(arg)
    local seconds = tonumber(arg)
    if not seconds or seconds <= 0 then
        print("|cff00ff80addeadman|r usage: /addeadman swinginterval <|0.5|0.05|etc>")
        return
    end
    ADDeadmansSwingTimerDB.swingInterval = seconds;
end


function Command:markone(arg)
    arg = arg:lower()
    if arg == "on" then
        ADDeadmansSwingTimerDB.showMarkOne = true
        print("|cff00ff80addeadman|r: Mark One display |cff00ff00ENABLED|r.")
        -- (enable whatever frame/logic you use)
    elseif arg == "off" then
        ADDeadmansSwingTimerDB.showMarkOne = false
        print("|cff00ff80addeadman|r: Mark One display |cffff2020DISABLED|r.")
        -- (disable the frame/logic)
    else
        print("|cff00ff80addeadman|r usage: /addeadman swing on|off")
    end
end


function Command:marktwo(arg)
    arg = arg:lower()
    if arg == "on" then
        ADDeadmansSwingTimerDB.showMarkTwo = true
        print("|cff00ff80addeadman|r: Mark Two display |cff00ff00ENABLED|r.")
        -- (enable whatever frame/logic you use)
    elseif arg == "off" then
        ADDeadmansSwingTimerDB.showMarkTwo = false
        print("|cff00ff80addeadman|r: Mark Two display |cffff2020DISABLED|r.")
        -- (disable the frame/logic)
    else
        print("|cff00ff80addeadman|r usage: /addeadman swing on|off")
    end
end


function Command:thickness(arg)
    local thick = tonumber(arg)
    if not thick or thick <= 0 then
        print("|cff00ff80addeadman|r usage: /addeadman thickness <1|2|etc>")
        return
    end
    ADDeadmansSwingTimerDB.thickness = thick;
end

function Command:opacity(arg)
    local opacity = tonumber(arg)
    if not opacity or opacity <= 0 then
        print("|cff00ff80addeadman|r usage: /addeadman opacity <1|0.5|etc>")
        return
    end
    ADDeadmansSwingTimerDB.opacity = opacity;
end


function Command:gcdspell(arg)
    local spell = arg;
    if not spell then
        print("|cff00ff80addeadman|r usage: /addeadman spell <spell name> e.g. Flash of Light")
        return
    end
    ADDeadmansSwingTimerDB.gcdSpell = spell;
end


-- Fallback (/addeadman or unknown sub-command)
function Command:help()
    print("|cff00ff80addeadman|r commands:")
    print("  /addeadman gcd on|off      – toggle GCD display")
    print("  /addeadman gcdinterval <sec>     – set interval for gcd bar re-draws (e.g. 0.05)")
    print("  /addeadman swing on|off      – toggle swing display")
    print("  /addeadman swinginterval <sec>     – set interval for swing bar re-draws (e.g. 0.05)")
    print("  /addeadman markOne on|off      – toggle markOne display")
    print("  /addeadman markTwo on|off      – toggle markTwo display")
    print("  /addeadman opacity <1|0.5|etc>      – Update line opacity")
    print("  /addeadman width <1|2|etc>      – Update line thickness")
    print("  /addeadman gcdspell <name of spell>      – Set the spell to be used as the GCD indicator. It should be a spell that is on the GCD and has no cooldown.")
end

SLASH_ADDEADMAN1 = "/addeadman"
SlashCmdList["ADDEADMAN"] = function(msg)

     local cmd, rest = splitFirst(msg)
    if cmd == "" then cmd = "help" end                -- no input → help
    local fn = Command[cmd]
    if fn then
        fn(Command, rest)                             -- pass self table
    else
        print("|cff00ff80addeadman|r: unknown command “"..cmd.."”. Type “/addeadman” for help.")
    end
end
