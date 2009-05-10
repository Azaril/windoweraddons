require("utility")
require("gameutility")

--require("spellcast\\eventhandler");

class 'SCTraceEventHandler' (SCEventHandler)

function SCTraceEventHandler:__init(Trace)

    SCEventHandler.__init(self);
    
    self.Trace = Trace;

end

function SCTraceEventHandler:HandleEvent(Event)

    if(self.Trace ~= nil) then
    
        if(type(self.Trace) == "string") then
        
            Log(self.Trace);
            
        elseif(type(self.Trace) == "function") then
        
            local Text = self.Trace(Event);
            
            if(Text ~= nil) then
            
                Log(Text);
            
            end
            
        end
    
    end    

    return false;

end