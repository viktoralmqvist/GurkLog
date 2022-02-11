local frame = CreateFrame("FRAME");
frame:RegisterEvent("RAID_INSTANCE_WELCOME");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("CHAT_MSG_ADDON");

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
-- Only send messages when in raid
-- Add reminder to stop logging

function frame:OnEvent(event, arg1, arg2, ...)
   debugLog(event);

   if event == "RAID_INSTANCE_WELCOME" then
      if IsRaidInstance() then
	 GurkStartLogging();
      end
      
   elseif event == "ADDON_LOADED" and arg1 == "GurkLog" then
      init();

   elseif event == "CHAT_MSG_ADDON" and arg1 == prefix then
      HandleAddonMsg(arg2);

   end
end

frame:SetScript("OnEvent", frame.OnEvent);

SLASH_HAVEWEMET1 = "/gurk";
function SlashCmdList.HAVEWEMET(msg)
   if msg == "start" then
      GurkStartLogging();

   elseif msg == "stop" then
      GurkStopLogging();

   elseif msg == "ask" then
      GurkSendLoggingRequest();

   elseif msg == "debug" then
      GurkDebug = not GurkDebug;

   else
      GurkCheckLogging();

   end
end

function init()
   C_ChatInfo.RegisterAddonMessagePrefix(prefix);

   if GurkDebug == nil then
      GurkDebug = false;
   end

   if IsRaidInstance() then
      GurkStartLogging();
   end
end

function IsRaidInstance()
   local _, zoneType = GetInstanceInfo();
   return zoneType == "raid";
end

function debugLog(msg)
   if GurkDebug then
      print("Gurk debug: " .. msg);
   end
end

function GurkCheckLogging()
   if LoggingCombat() then
      print("Combat logging is " .. on);
   else
      print("Combat logging is " .. off);
   end
end

function GurkStartLogging()
   if LoggingCombat() then
      print("Combat logging is already " .. on);
   else
      LoggingCombat(true);
      C_ChatInfo.SendAddonMessage(prefix, playerName .. " started combat logging", "RAID");
      print("Combat logging turned " .. on);
   end
end

function GurkStopLogging()
   if LoggingCombat() then
      LoggingCombat(false);
      print("Combat logging turned " .. off);
   else
      print("Combat logging is already " .. off);
   end
end

function GurkAnswerLoggingRequest(requester)
   if LoggingCombat() then
      C_ChatInfo.SendAddonMessage(prefix, playerName .. " is combat logging", "WHISPER", requester);
   end
end

function GurkSendLoggingRequest()
   C_ChatInfo.SendAddonMessage(prefix, loggingRequest .. ":" .. playerName, "RAID");
end

function HandleAddonMsg(msg)
   splitMessage = Split(msg);
   if splitMessage[1] == loggingRequest then
      GurkAnswerLoggingRequest(splitMessage[2]);
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
