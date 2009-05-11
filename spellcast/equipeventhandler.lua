require("common\\utility")
require("common\\gameutility")
require("spellcast\\namespace");
require("spellcast\\eventhandler");

class 'SCEquipEventHandler' (SCEventHandler)

function SCEquipEventHandler:__init(Set)

    SCEventHandler.__init(self);

    self.Set = Set;

end

function SCEquipEventHandler:HandleEvent(Event)

    if(self.Set ~= nil) then
    
        local Context = Event:GetContext();
        
        if(Context.EquippedSlots == nil) then
        
            Context.EquippedSlots = { };
        
        end
    
        local Items = self.Set:GetItems();
        
        for Slot, Item in pairs(Items) do
        
            if(Context.EquippedSlots[Slot] == nil) then
            
                Context.EquippedSlots[Slot] = Item;
                
                self:EquipItem(Slot, Item);
            
            end
        
        end
    
    end
    

    return false;

end

function SCEquipEventHandler:EquipItem(Slot, Item)

    --TODO: Add slot mappings here.
    
    Log("Equip: " .. Slot .. " - " .. Item);
    SendInput("/equip " .. Slot .. " \"" .. Item .. "\"");

end

--
-- Add to namespace.
--
SC.Equip = SCEquipEventHandler;