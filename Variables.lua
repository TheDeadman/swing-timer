local ADDON_NAME, ADDON = ...

-- 1. Static defaults
local defaults = {
    showTwistMarks = true,
    showGCD        = true,
    gcdSpell = "Flash of Light",
    gcdInterval = 0.00,
    showSwing      = true,
}

local function copyDefaults(src, dest)
    print("COPY DEFAULTS")
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = dest[k] or {}
            copyDefaults(v, dest[k])
        elseif dest[k] == nil then
            dest[k] = v
        end
    end
end

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
        "myVariable is |cffffff00" .. tostring(ADDeadmansSwingTimerDB.showGCD) .. "|r")

    print(ADDON_NAME .. " loaded – interval is "
        .. tostring(ADDeadmansSwingTimerDB.gcdInterval))
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

-- /addeadman timer 100
function Command:gcdinterval(arg)
    local seconds = tonumber(arg)
    if not seconds or seconds <= 0 then
        print("|cff00ff80addeadman|r usage: /addeadman timer <seconds>")
        return
    end
    print(("|cff00ff80addeadman|r: starting %d-second timer…"):format(seconds))
    ADDeadmansSwingTimerDB.gcdInterval = seconds;
end

-- /addeadman test
function Command:test()
    print("|cff00ff80addeadman|r: self-test OK ✅")
    -- put any diagnostic code here
end

-- Fallback (/addeadman or unknown sub-command)
function Command:help()
    print("|cff00ff80addeadman|r commands:")
    print("  /addeadman gcd on|off      – toggle GCD display")
    print("  /addeadman gcdinterval <sec>     – set interval for gcd bar re-draws")
    print("  /addeadman swing on|off      – toggle swing display")
    print("  /addeadman swinginterval <sec>     – set interval for swing bar re-draws")
    print("  /addeadman test            – run self-test")
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
