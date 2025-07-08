AlsSwing = {}

AlsSwing.TimeToNextSwingGlobal = 0
AlsSwing.TimeToNextSwingGlobalDebug = 0

-- local test_cameraHeadMovementRangeScale

-- local DB


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


-----------------------------------------------------------
--  Helper:  call SetRotation in the most capable way
-----------------------------------------------------------
local t, INTERVAL = 0, 0.00
local aSpeed = 3.9
local lastASpeed = 0
local lastSwingTime = 0
local nextSwingTime = 0

-- Center pivot function for the classic client. May need different function for new clients. Or maybe there is a more efficient funciton for newer clients.
local function rotate(tex, radians)
    tex:SetRotation(radians, vector)                           --   centre pivot (Era/Sod)
end

local function OnUpdate2(self, elapsed)

    -- Calc line positions
    if lastASpeed ~= aSpeed then
        print("reposition")
        lastASpeed = aSpeed

        local progress = 1 - (1.5 / aSpeed)   -- 0→1
        local angle    = -progress * 2 * math.pi                     -- clockwise
        rotate(twistOneLine, angle)

        local progress2 = 1 - (0.4 / aSpeed)   -- 0→1
        local angle2    = -progress2 * 2 * math.pi                     -- clockwise
        rotate(twistTwoLine, angle2)
    end

    t = t + elapsed
    if t < INTERVAL then return end
    t = 0

    local now = GetTime()
    if aSpeed > 0 and now < lastSwingTime + aSpeed then
        spinner:Show()

        local progress = 1 - ((lastSwingTime + aSpeed - now) / aSpeed)   -- 0→1
        local angle    = -progress * 2 * math.pi                     -- clockwise
        rotate(line, angle)
    else
        -- spinner:Hide()
        rotate(line, 0)
        spinner:SetScript("OnUpdate", nil)
    end
end


local SwingTimerFrame = CreateFrame("Frame", "SwingTimer", UIParent)
-- SwingTimerFrame:SetSize(120, 20)
-- SwingTimerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
-- SwingTimerFrame:SetMovable(true)
-- SwingTimerFrame:EnableMouse(true)
-- SwingTimerFrame:RegisterForDrag("RightButton")
-- SwingTimerFrame:SetScript("OnDragStart", SwingTimerFrame.StartMoving)
-- SwingTimerFrame:SetScript("OnDragStop", SwingTimerFrame.StopMovingOrSizing)

-- SwingTimerFrame.bg = SwingTimerFrame:CreateTexture(nil, "BACKGROUND")
-- SwingTimerFrame.bg:SetAllPoints()
-- SwingTimerFrame.bg:SetColorTexture(0, 0, 0, 0.5)

-- SwingTimerFrame.text = SwingTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
-- SwingTimerFrame.text:SetPoint("CENTER", SwingTimerFrame, "CENTER")
-- SwingTimerFrame.text:SetText("Swing: 0.0s")
-- SwingTimerFrame:Show()



function AlsSwing.GetTimeToNextSwingGlobal()
    return AlsSwing.TimeToNextSwingGlobal
end

local function GetTimeToNextSwing()
    local timeRemaining = nextSwingTime - GetTime()
    AlsSwing.TimeToNextSwingGlobal = math.max(0, timeRemaining)
    return AlsSwing.GetTimeToNextSwingGlobal() -- Ensure it never goes negative
end

local function UpdateSwingTimer()
    local timeLeft = GetTimeToNextSwing()
    -- SwingTimerFrame.text:SetText(string.format("Swing: %.1fs", timeLeft))
end

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
            nextSwingTime = lastSwingTime + attackSpeed
        end
    end
end)

SwingTimerFrame:SetScript("OnUpdate", function(self, elapsed)
    UpdateSwingTimer()
    OnUpdate2(self, elapsed)
end)
