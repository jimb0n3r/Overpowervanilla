-- OPAlert.lua - With Custom Fahh Sound Support

local frame = OPAlertFrame
local icon = OPAlertIcon

local timeLeft = 0
local OVERPOWER_WINDOW = 5.0
local soundEnabled = true
local useCustomFahh = true   -- Set to false to use built-in sounds instead

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[OPAlert]|r " .. msg)
end

function OPAlert_OnLoad()
    this:RegisterEvent("ADDON_LOADED")
    this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
    this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
    
    if OPAlertDB and OPAlertDB.position then
        frame:ClearAllPoints()
        frame:SetPoint(unpack(OPAlertDB.position))
    end
    
    if OPAlertDB then
        if OPAlertDB.soundEnabled ~= nil then soundEnabled = OPAlertDB.soundEnabled end
        if OPAlertDB.useCustomFahh ~= nil then useCustomFahh = OPAlertDB.useCustomFahh end
    end
end

function OPAlert_OnEvent()
    if event == "ADDON_LOADED" and arg1 == "OPAlert" then
        if not OPAlertDB then OPAlertDB = {} end
        
    elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
        local _, _, target = string.find(arg1 or "", "You attack%. (.+) dodges%.")
        if target then OPAlert_TriggerOverpower() end
        
    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        local _, _, spell, target = string.find(arg1 or "", "Your (.+) was dodged by (.+)%.")
        if target then OPAlert_TriggerOverpower() end
        
        local _, _, spellUsed = string.find(arg1 or "", "Your (.+) (hits|crits)")
        if spellUsed == "Overpower" then
            timeLeft = 0
            if frame then frame:Hide() end
        end
    end
end

function OPAlert_TriggerOverpower()
    timeLeft = OVERPOWER_WINDOW
    if frame and icon then
        frame:Show()
        icon:SetAlpha(1)
        
        if soundEnabled then
            if useCustomFahh then
                -- Custom Fahh sound
                PlaySoundFile("Interface\\AddOns\\OPAlert\\Sound\\fahh.wav")
            else
                -- Built-in fallback
                PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
            end
        end
    end
end

function OPAlert_OnUpdate(delta)
    if timeLeft > 0 then
        timeLeft = timeLeft - delta
        if timeLeft <= 0 then
            timeLeft = 0
            if frame then frame:Hide() end
        else
            local pulse = 0.7 + 0.3 * math.sin(GetTime() * 8)
            icon:SetAlpha(pulse)
        end
    end
end

-- Dragging (unchanged)
function OPAlert_OnMouseDown()
    if arg1 == "LeftButton" then frame:StartMoving() end
end

function OPAlert_OnMouseUp()
    frame:StopMovingOrSizing()
    if not OPAlertDB then OPAlertDB = {} end
    OPAlertDB.position = {frame:GetPoint()}
end

-- Slash commands
SLASH_OPALERT1 = "/opalert"
SLASH_OPALERT2 = "/op"
SlashCmdList["OPALERT"] = function(msg)
    msg = string.lower(msg or "")
    
    if msg == "test" or msg == "t" then
        OPAlert_TriggerOverpower()
        
    elseif msg == "sound" or msg == "toggle" then
        soundEnabled = not soundEnabled
        if OPAlertDB then OPAlertDB.soundEnabled = soundEnabled end
        Print("Sound " .. (soundEnabled and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))
        
    elseif msg == "fahh" then
        useCustomFahh = not useCustomFahh
        if OPAlertDB then OPAlertDB.useCustomFahh = useCustomFahh end
        Print("Custom Fahh sound " .. (useCustomFahh and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r (using built-in)"))
        
    else
        Print("Commands:")
        Print("  /opalert test     - Test")
        Print("  /opalert sound    - Toggle sound")
        Print("  /opalert fahh     - Toggle custom Fahh vs built-in")
    end
end