require("common\\utility")
require("common\\gameutility")
require("spellcast\\namespace")
require("spellcast\\eventhandler")

class 'SCListEventHandler' (SCEventHandler)

function SCListEventHandler:__init(Children)

    SCEventHandler.__init();
    
    if(type(Children) == "table") then
    
        self.Children = Children;
    
    else
    
        self.Children = { };
        
        if(Children ~= nil) then
        
            table.insert(self.Children, Children);
        
        end
    
    end

end

function SCListEventHandler:HandleEvent(Event)

    local Handled = false;

    for i, Child in ipairs(self.Children) do
    
        Handled =  Child:HandleEvent(Event);
        
        if(Handled == true) then
        
            break;
        
        end
    
    end

    return Handled;

end

--
-- Add to namespace.
--
SC.List = SCListEventHandler;