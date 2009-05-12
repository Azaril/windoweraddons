require("common\\common")
require("spellcast\\namespace");
require("spellcast\\listeventhandler");

class 'SCConditionEventHandler' (SCListEventHandler)

function SCConditionEventHandler:__init(Condition, Children)

    SCListEventHandler.__init(self, Children);

    self.Condition = Condition;

end

function SCConditionEventHandler:HandleEvent(Event)

    if(self.Condition ~= nil and self.Condition(Event)) then
    
        return SCListEventHandler.HandleEvent(self, Event);
    
    end

    return false;

end

--
-- Add to namespace.
--
SC.Condition = SCConditionEventHandler;