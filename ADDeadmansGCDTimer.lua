local ADDONNAME, ADDON = ...
local DB = ADDON.db

local isShown = true

local vector = CreateVector2D(0.5, 0)
local spinner = CreateFrame("Frame", "AlGCDSpinnerFrame", UIParent)
local line = spinner:CreateTexture(nil, "OVERLAY")
line:SetColorTexture(1, 1, 0, 1)
line:SetSize(2, math.max(GetScreenHeight(), 400))
line:SetPoint("BOTTOM", UIParent, "CENTER", 0, 0)

local function updateLines() 
    line:SetColorTexture(1, 1, 0, DB.opacity)
    line:SetSize(DB.thickness, math.max(GetScreenHeight(), 400))
end

local function showHideLine()
    if not isShown and DB.showGCD then
        spinner:Show()
        isShown = true
    elseif isShown and not DB.showGCD then
        spinner:Hide()
        isShown = false
    end
end

local function rotate(tex, radians)
    tex:SetRotation(radians, vector)
end

local t = 0
local function OnUpdate(self, elapsed)
    t = t + elapsed
    if t < DB.gcdInterval then return end
    t = 0

    local start, duration = GetSpellCooldown(DB.gcdSpell)
    local now = GetTime()

    if duration > 0 and now < start + duration then
        local progress = 1 - ((start + duration - now) / duration) -- 0 to 1
        local angle    = -progress * 2 * math.pi                   -- clockwise
        rotate(line, angle)
    else
        rotate(line, 0)
        -- Turn this function off when GCD is not going.
        spinner:SetScript("OnUpdate", nil)
    end
end

-- Hook spellcast to detect GCD
spinner:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
spinner:SetScript("OnEvent", function(self, event, unit)

    -- Exit early if it isn't the current player
    if unit ~= "player" then return end

    updateLines()
    showHideLine()

    local start, duration = GetSpellCooldown(DB.gcdSpell) -- hack for gcd with a no cooldown spell that is on the GCD
    if duration > 0 then
        spinner:SetScript("OnUpdate", OnUpdate)
    end
end)


if DB then -- already loaded (e.g., after /reload)
    if DB.showGCD then
        showHideLine()
    end
else -- wait for the core to finish
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, _, addonName)
        if addonName == ADDONNAME then
            DB = ADDON.db -- refresh local upvalue

            showHideLine()
            f:UnregisterAllEvents()
        end
    end)
end
