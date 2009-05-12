require("common\\common")

--
-- Include all spellcast files.
--
require("spellcast\\namespace")
require("spellcast\\eventtype")
require("spellcast\\conditioneventhandler")
require("spellcast\\equipeventhandler")
require("spellcast\\event")
require("spellcast\\eventhandler")
require("spellcast\\listeventhandler")
require("spellcast\\set")
require("spellcast\\eventtest")
require("spellcast\\traceeventhandler")
require("spellcast\\core")

--    
-- Conditions
--
SC.IsEvent =   
    function(EventType, Children)
        return SCConditionEventHandler(SCIsEventTypeFunc(EventType), Children);
    end
    
SC.IsAction =  
    function(Action, Children) 
        return SCConditionEventHandler(SCIsActionFunc(Action), Children);
    end
                
SC.IsIdle =    
    function(Children)
        return SCConditionEventHandler(SCIsIdle, Children);
    end

SC.IsJobAbility =    
    function(Children)
        return SCConditionEventHandler(SCIsMagicAbility, Children);
    end
    
SC.IsMagicAbility =    
    function(Children)
        return SCConditionEventHandler(SCIsMagicAbility, Children);
    end
    
SC.IsWeaponSkill =    
    function(Children)
        return SCConditionEventHandler(SCIsWeaponSkill, Children);
    end