require("common\\utility");
require("common\\ui");
require("bar\\baraddon");

class 'InventoryAddon' (BarAddon)

function InventoryAddon:__init()

    BarAddon.__init(self);
    
    self.UpdateTimer = CTimer();
    self.UpdateTimerOnTickConnection = self.UpdateTimer:GetOnTick():Connect(self.OnUpdateTimerTick, self);

end

function InventoryAddon:__finalize()
    
    self.UpdateTimer:Stop();

end

function InventoryAddon:Load()
    
	self.UIRoot = CEGUI.WindowManager:getSingleton():loadWindowLayout("InventoryAddon.layout", false);
	
	-- Trigger an immediate update.
	self:OnUpdateTimerTick();
	
	self.UpdateTimer:Start(1000);
	
end

function InventoryAddon:Unload()

    self.UpdateTimer:Stop();

end

function InventoryAddon:GetUI()

    return self.UIRoot;

end

function InventoryAddon:OnUpdateTimerTick()

    local ItemCount = 0;
    local MaxItems = 0;
    
    local Inventory = GetInventory();
    
    if(Inventory ~= nil) then
        
        ItemCount = Inventory:GetItemCount();
        MaxItems = Inventory:GetSize();
        
        -- Gil is hidden in the 0th inventory slot so remove that from the count.
        if(MaxItems > 0) then
            MaxItems = MaxItems - 1;
        end
        
        if(ItemCount > 0) then
            ItemCount = ItemCount - 1;
        end
    
    end
    
    self.UIRoot:setText(string.format("Inventory: %i / %i", ItemCount, MaxItems));

end