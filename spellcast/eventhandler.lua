require("common\\common")
require("spellcast\\namespace")
require("spellcast\\event")

class 'SCEventHandler'

function SCEventHandler:__init()

end

function SCEventHandler:HandleEvent(Event)

    return false;

end

--
-- Add to namespace.
--
SC.EventHandler = SCEventHandler;