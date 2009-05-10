require("utility")
require("gameutility")
require("spellcast\\namespace");
                   
function SC:DumpEvent(Event)

    local EventType = Event:GetType();

    if (EventType == SC.Event.Idle) then
        return "Idle event";
    end
    
    if (EventType == SC.Event.JobAbility) then
        return "Job ability event - " .. tostring(Event:GetArguments().Action);
    end
    
    if (EventType == SC.Event.MagicAbility) then
        return "Magic ability event - " .. tostring(Event:GetArguments().Action);
    end
    
    if (EventType == SC.Event.WeaponSkill) then
        return "Weapon skill event - " .. tostring(Event:GetArguments().Action);
    end

    return "Unknown event";

end