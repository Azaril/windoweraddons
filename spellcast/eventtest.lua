require("utility")
require("gameutility")

function SCIsEventType(Event, EventType)

    return (Event:GetType() == EventType);

end

function SCIsEventTypeFunc(EventType)

    return 
        function(Event)
            return SCIsEventType(Event, EventType);
        end

end

function SCIsAction(Event, Action)

    local Arguments = Event:GetArguments();
    
    if(Arguments == nil) then
    
        return false;
    
    end
    
    if(Arguments.Action == nil) then
    
        return false
    
    end
    
    if(type(Action) == "string") then
    
        return (Arguments.Action:lower() == Action:lower());
        
    end
    
    if(type(Action) == "table") then
    
        for i, Act in pairs(Action) do
        
            if(Arguments.Action:lower() == Act:lower()) then
            
                return true;
            
            end
        
        end
    
    end
    
    return false;

end

function SCIsActionFunc(Action)

    return
        function(Event)
            return SCIsAction(Event, Action);
        end

end

function SCIsIdle(Event)

    return SCIsEventType(Event, SC.Event.Idle);

end

function SCIsJobAbility(Event)

    return SCIsEventType(Event, SC.Event.JobAbility);

end

function SCIsMagicAbility(Event)

    return SCIsEventType(Event, SC.Event.MagicAbility);

end

function SCIsWeaponSkill(Event)

    return SCIsEventType(Event, SC.Event.WeaponSkill);

end