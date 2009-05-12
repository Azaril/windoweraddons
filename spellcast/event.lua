require("common\\common")
require("spellcast\\namespace")

class 'SCEvent'

function SCEvent:__init(Type, Arguments)

    self.Type = Type;
    
    if(Arguments ~= nil) then
        self.Arguments = Arguments;
    else
        self.Arguments = { };
    end
    
    self.Context = { };
    
    self.Canceled = false;

end

function SCEvent:GetType()

    return self.Type;

end

function SCEvent:GetArguments()

    return self.Arguments;

end

function SCEvent:Cancel()

    self.Canceled = true;

end

function SCEvent:IsCanceled()

    return self.Canceled;
    
end

function SCEvent:GetContext()

    return self.Context;

end

--
-- Add to namespace.
--
SC.Event = SCEvent;