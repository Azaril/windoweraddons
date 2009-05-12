require("common\\common")
require("spellcast\\namespace")
require("spellcast\\event")
require("spellcast\\eventtype")
                   
SC.DumpEvent = function(Event)

    local EventType = Event:GetType();

    if (EventType == SC.EventType.Idle) then
        return "Idle event";
    end
    
    if (EventType == SC.EventType.JobAbility) then
        return "Job ability event - " .. tostring(Event:GetArguments().Action);
    end
    
    if (EventType == SC.EventType.MagicAbility) then
        return "Magic ability event - " .. tostring(Event:GetArguments().Action);
    end
    
    if (EventType == SC.EventType.WeaponSkill) then
        return "Weapon skill event - " .. tostring(Event:GetArguments().Action);
    end

    return "Unknown event";

end