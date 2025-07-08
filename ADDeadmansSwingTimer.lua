local ADDONNAME, ADDON = ...
local DB = ADDON.db

local isShown, isMarkOneShown, isMarkTwoShown = true, true, true

TimeToNextSwing = 0

local thickness = 2
local opacity = 1

-- The Swing Spinner
local vector = CreateVector2D(0.5, 0)
local spinner = CreateFrame("Frame", "AlSwingSpinnerFrame", UIParent)
local line = spinner:CreateTexture(nil, "OVERLAY")
line:SetColorTexture(1, 0, 1, opacity)
-- Make it long so it reaches to the edge of the screen
line:SetSize(thickness, math.max(GetScreenHeight(), 400))
-- Set inner pivot point to center of screen
line:SetPoint("BOTTOM", UIParent, "CENTER", 1, 0)

-- Twist Mark One
local twistOne = CreateFrame("Frame", "AlSwingTwistMark1Frame", UIParent)
local twistOneLine = twistOne:CreateTexture(nil, "OVERLAY")
twistOneLine:SetColorTexture(1, 0, 0, opacity)
twistOneLine:SetSize(thickness, math.max(GetScreenHeight(), 400))
twistOneLine:SetPoint("BOTTOM", UIParent, "CENTER", 0, 0)

-- Twist Mark Two
local twistTwo = CreateFrame("Frame", "AlSwingTwistMark2Frame", UIParent)
local twistTwoLine = twistTwo:CreateTexture(nil, "OVERLAY")
twistTwoLine:SetColorTexture(0, 1, 0, opacity)
twistTwoLine:SetSize(thickness, math.max(GetScreenHeight(), 400))
twistTwoLine:SetPoint("BOTTOM", UIParent, "CENTER", 0, 0)

local function updateLines() 
    line:SetColorTexture(1, 0, 1, DB.opacity)
    line:SetSize(DB.thickness, math.max(GetScreenHeight(), 400))
    twistOneLine:SetColorTexture(1, 0, 0, DB.opacity)
    twistOneLine:SetSize(DB.thickness, math.max(GetScreenHeight(), 400))
    twistTwoLine:SetColorTexture(0, 1, 0, DB.opacity)
    twistTwoLine:SetSize(DB.thickness, math.max(GetScreenHeight(), 400))
end

local function updateMarkDisplays()
    updateLines()
    if not isShown and DB.showSwing then
        spinner:Show()
        isShown = true
    elseif isShown and not DB.showSwing then
        spinner:Hide()
        isShown = false
    end

    if not isMarkOneShown and DB.showMarkOne then
        twistOne:Show()
        isMarkOneShown = true
    elseif isMarkOneShown and not DB.showMarkOne then
        twistOne:Hide()
        isMarkOneShown = false
    end

    if not isMarkTwoShown and DB.showMarkTwo then
        twistTwo:Show()
        isMarkTwoShown = true
    elseif isMarkTwoShown and not DB.showMarkTwo then
        twistTwo:Hide()
        isMarkTwoShown = false
    end
end


local t = 0
local aSpeed = 3.9
local lastASpeed = 0
local lastSwingTime = 0

-- Center pivot function for the classic client. May need different function for new clients. Or maybe there is a more efficient funciton for newer clients.
local function rotate(tex, radians)
    tex:SetRotation(radians, vector)
end

local function OnUpdate2(self, elapsed)
    updateMarkDisplays()
    if DB.showSwing then
        -- Calc line positions
        if lastASpeed ~= aSpeed then
            lastASpeed     = aSpeed

            local progress = 1 - (1.5 / aSpeed)  -- 0→1
            local angle    = -progress * 2 * math.pi -- clockwise
            rotate(twistOneLine, angle)

            local progress2 = 1 - (0.4 / aSpeed)   -- 0→1
            local angle2    = -progress2 * 2 * math.pi -- clockwise
            rotate(twistTwoLine, angle2)
        end

        t = t + elapsed
        if t < DB.swingInterval then return end
        t = 0

        local now = GetTime()
        if aSpeed > 0 and now < lastSwingTime + aSpeed then
            local progress = 1 - ((lastSwingTime + aSpeed - now) / aSpeed) -- 0 to 1
            local angle    = -progress * 2 * math.pi                   -- clockwise
            rotate(line, angle)
        else
            -- spinner:Hide()
            rotate(line, 0)
            spinner:SetScript("OnUpdate", nil)
        end
    end
end


local SwingTimerFrame = CreateFrame("Frame", "SwingTimer", UIParent)

local SwingTimer = CreateFrame("Frame")
SwingTimer:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

SwingTimer:SetScript("OnEvent", function(self, event)
    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end

    local _, subEvent, _, sourceGUID, _, _, _, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()

    if sourceGUID == UnitGUID("player") then
        if subEvent == "SWING_DAMAGE" or subEvent == "SWING_MISSED" then
            local attackSpeed, _ = UnitAttackSpeed("player")
            aSpeed = attackSpeed
            lastSwingTime = GetTime()
        end
    end
end)

SwingTimerFrame:SetScript("OnUpdate", function(self, elapsed)
    OnUpdate2(self, elapsed)
end)



if DB then
    if DB.showSwing then
        spinner:Show()
    end
else
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, _, addonName)
        if addonName == ADDONNAME then
            DB = ADDON.db

            updateMarkDisplays()
            f:UnregisterAllEvents()
        end
    end)
end
