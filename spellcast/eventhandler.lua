require("common\\utility")
require("common\\gameutility")
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