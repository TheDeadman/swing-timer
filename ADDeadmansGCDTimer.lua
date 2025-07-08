local _, ADDON = ...
local DB = ADDON.db

local isShown = false

local vector = CreateVector2D(0.5, 0)
local spinner = CreateFrame("Frame", "AlGCDSpinnerFrame", UIParent)
local line = spinner:CreateTexture(nil, "OVERLAY")
line:SetColorTexture(1, 1, 0, 1)                           -- solid yellow
line:SetSize(2, math.max(GetScreenHeight(), 400))   -- long, thin strip
-- line:SetSize(2, math.max(GetScreenHeight() * 0.55, 400))   -- long, thin strip
line:SetPoint("BOTTOM", UIParent, "CENTER", 0, 0)          -- inner tip at screen centre

-----------------------------------------------------------
--  Helper:  call SetRotation in the most capable way
-----------------------------------------------------------
local t, INTERVAL = 0, 0.00

local function rotate(tex, radians)
    tex:SetRotation(radians, vector)                           --   centre pivot (Era/Sod)
end

local function OnUpdate2(self, elapsed)
    -- print("ON UPDATE FUNC 2")
    t = t + elapsed
    if t < INTERVAL then return end
    t = 0

    local start, duration = GetSpellCooldown("Flash of Light")
    -- local start, duration = GetSpellCooldown(GCD_SPELL_ID)
    local now = GetTime()

    if duration > 0 and now < start + duration then
        -- spinner:Show()

        local progress = 1 - ((start + duration - now) / duration)   -- 0→1
        local angle    = -progress * 2 * math.pi                     -- clockwise
        rotate(line, angle)
    else
        -- spinner:Hide()
        rotate(line, 0)
        spinner:SetScript("OnUpdate", nil)
    end
end


-- Update function
local function OnUpdate(self, elapsed)
    -- print("ON UPDATE FUNC")
    OnUpdate2(self, elapsed)
    -- local now = GetTime()
    -- local progress = now - gcdStart
    -- if progress >= gcdDuration then
    --     bar:SetValue(0)
    --     updating = false
    --     frame:SetScript("OnUpdate", nil)
    -- else
    --     bar:SetValue(progress / gcdDuration)
    -- end
end

-- Hook spellcast to detect GCD
spinner:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
spinner:SetScript("OnEvent", function(self, event, unit)
    if unit ~= "player" then return end

    print("IS SHOWN: " .. tostring(isShown))
    print("show gcd: " .. tostring(DB.showGCD))
    if not isShown and DB.showGCD then
        print("SHOWING")
        spinner:Show()
        isShown = true
    elseif isShown and not DB.showGCD then
        print("HIDING")
        spinner:Hide()
        isShown = false
    end

    local start, duration = GetSpellCooldown(DB.gcdSpell) -- hack for gcd with a no cooldown spell that is on the GCD
    if duration > 0 then
        print("ON UPDATE")

        spinner:SetScript("OnUpdate", OnUpdate)

    end
end)
