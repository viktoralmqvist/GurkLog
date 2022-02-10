local frame = CreateFrame("FRAME");
frame:RegisterEvent("RAID_INSTANCE_WELCOME");

function frame:OnEvent(event, arg1, ...)
  if event == "RAID_INSTANCE_WELCOME" then
    local _, zoneType = GetInstanceInfo();
    if zoneType == "raid" then
      GurkStartLogging();
    end
  end
end

frame:SetScript("OnEvent", frame.OnEvent);


SLASH_HAVEWEMET1 = "/gurk";
function SlashCmdList.HAVEWEMET(msg)
 if msg == "start" then
   GurkStartLogging();

 elseif msg == "stop" then
   GurkStopLogging();

 else
   GurkCheckLogging();

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