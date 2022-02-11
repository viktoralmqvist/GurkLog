local frame = CreateFrame("FRAME");
frame:RegisterEvent("RAID_INSTANCE_WELCOME");
frame:RegisterEvent("ADDON_LOADED");

function frame:OnEvent(event, arg1, ...)
  debugLog(event);

  if event == "RAID_INSTANCE_WELCOME" then
    if isRaidInstance() then
      GurkStartLogging();
    end

  elseif event == "ADDON_LOADED" and arg1 == "GurkLog" then
    init();

  end
end

frame:SetScript("OnEvent", frame.OnEvent);

SLASH_HAVEWEMET1 = "/gurk";
function SlashCmdList.HAVEWEMET(msg)
 if msg == "start" then
   GurkStartLogging();

 elseif msg == "stop" then
   GurkStopLogging();

 elseif msg == "debug" then
   GurkDebug = not GurkDebug;

 else
   GurkCheckLogging();

 end
end

function init()
  if GurkDebug == nil then
    GurkDebug = false;
  end

  if isRaidInstance() then
    GurkStartLogging();
  end
end

function isRaidInstance()
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
   print("Combat logging is enabled");
  else
   print("Combat logging is disabled");
  end
end

function GurkStartLogging()
  if LoggingCombat() then
    print("Combat logging is already enabled");
  else
    LoggingCombat(true);
    print("Combat logging enabled");
  end
end

function GurkStopLogging()
  if LoggingCombat() then
    LoggingCombat(false);
    print("Combat logging disabled");
  else
    print("Combat logging is already disabled");
  end
end