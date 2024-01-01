local frame = CreateFrame("FRAME");
frame:RegisterEvent("RAID_INSTANCE_WELCOME");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("CHAT_MSG_ADDON");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");

local prefix = "gurklogprefix";

local green = "|cff00ff00";
local red = "|cffff0000";
local nocolor = "|r";
local on = green .. "ON" .. nocolor;
local off = red .. "OFF" .. nocolor;

local playerName = UnitName("player");
local loggingRequest = "GurkLogRequest";

-- TODO
-- Message when joining raid asking if anyone is logging
-- Send messages to raid or party or whisper self
-- Remove sending playername when aswering logging requests (and remove split)

function frame:OnEvent(event, arg1, arg2, arg3, arg4, ...)
   debugLog(event, arg1, arg2, arg3, arg4, ...);

   if event == "RAID_INSTANCE_WELCOME" then
      debugLog("IsLoggingInstance() = ", IsLoggingInstance())
      if IsLoggingInstance() then
         isInLoggingInstance = true
	 C_Timer.After(3, function() StartLogging() end);
      end
      
   elseif event == "ADDON_LOADED" and arg1 == "GurkLog" then
      init();

   elseif event == "CHAT_MSG_ADDON" and arg1 == prefix then
      HandleAddonMsg(arg2, arg4);

   elseif event == "ZONE_CHANGED_NEW_AREA" then
      HandleZoneChange();

   end
end

frame:SetScript("OnEvent", frame.OnEvent);

SLASH_HAVEWEMET1 = "/gurk";
function SlashCmdList.HAVEWEMET(msg)
   if msg == "on" then
      StartLogging();

   elseif msg == "off" then
      StopLogging();

   elseif msg == "ask" then
      SendLoggingRequest();

   elseif msg == "debug" then
      GurkDebug = not GurkDebug;

   else
      CheckLogging();

   end
end

function init()
   C_ChatInfo.RegisterAddonMessagePrefix(prefix);
   SetAdvancedCombatLogging();

   if GurkDebug == nil then
      GurkDebug = false;
   end

   if isInLoggingInstance == nil then
      isInLoggingInstance = false;
   end

   if IsLoggingInstance() then
      isInLoggingInstance = true
      C_Timer.After(3, function() StartLogging() end);
   end
end

function SetAdvancedCombatLogging()
   result = GetCVar("advancedCombatLogging");
   if result == "0" then
      SetCVar("advancedCombatLogging", 1);
      print("Enabled Advanced Combat Logging");
   end
end   

----------------------------------------
-- Manage logging
----------------------------------------

function CheckLogging()
   if LoggingCombat() then
      print("Combat logging is " .. on);
   else
      print("Combat logging is " .. off);
   end
end

function StartLogging()
   if LoggingCombat() then
      print("Combat logging is already " .. on);
   else
      C_ChatInfo.SendAddonMessage(prefix, playerName .. " started combat logging", "RAID");
      LoggingCombat(true);
      print("Combat logging turned " .. on);
   end
end

function StopLogging()
   if LoggingCombat() then
      LoggingCombat(false);
      print("Combat logging turned " .. off);
   else
      print("Combat logging is already " .. off);
   end
end

StaticPopupDialogs["GURK_STOP_LOG"] = {
   text = "Do you want to turn off combat logging?",
   button1 = "Yes",
   button2 = "No",
   OnAccept = function()
      StopLogging()
   end,
   timeout = 0,
   whileDead = true,
   hideOnEscape = true,
   preferredIndex = 3,
}

function HandleZoneChange()
   newIsInLogginInstance = IsLoggingInstance()
   if isInLoggingInstance and not newIsInLogginInstance and LoggingCombat() then
      StaticPopup_Show("GURK_STOP_LOG")
   end

   isInLoggingInstance = newIsInLoggingInstance
end

----------------------------------------
-- Message handeling
----------------------------------------

function AnswerLoggingRequest(sender)
   if LoggingCombat() then
      C_ChatInfo.SendAddonMessage(prefix, playerName .. " is combat logging", "WHISPER", sender);
   end
end

function SendLoggingRequest()
   C_ChatInfo.SendAddonMessage(prefix, loggingRequest .. ":" .. playerName, "RAID");
end

function HandleAddonMsg(msg, sender)
   splitMessage = Split(msg);
   if splitMessage[1] == loggingRequest then
      AnswerLoggingRequest(sender);
   else
      print(msg);
   end
end

function Split(s, delimiter)
   if delimiter == nil then
      delimiter = ":"
   end
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

----------------------------------------
-- Utilities
----------------------------------------

function IsLoggingInstance()
  inInstance, instanceType = IsInInstance()
  return isInstance and (instanceType == "party" or instanceType == "raid") and IsInRaid()
end

function debugLog(msg, ...)
   if GurkDebug then
      print("Gurk debug: " .. msg, ...);
   end
end

