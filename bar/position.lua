require("utility");
require("gameutility");
require("ui");
require("bar\\baraddon");

class 'PositionAddon' (BarAddon)

function PositionAddon:__init()

    BarAddon.__init(self);
    
    self.UpdateTimer = CTimer();
    self.UpdateTimerOnTickConnection = self.UpdateTimer:GetOnTick():Connect(self.OnUpdateTimerTick, self);

end

function PositionAddon:__finalize()
    
    self.UpdateTimer:Stop();

end

function PositionAddon:Load()
    
	self.UIRoot = CEGUI.WindowManager:getSingleton():loadWindowLayout("PositionAddon.layout", false);
	
	-- Trigger an immediate update.
	self:OnUpdateTimerTick();
	
	self.UpdateTimer:Start(200);
	
end

function PositionAddon:Unload()

    self.UpdateTimer:Stop();

end

function PositionAddon:GetUI()

    return self.UIRoot;

end

function PositionAddon:OnUpdateTimerTick()

    local GotTarget = false;
    
    local Player = GetPlayer();
    
    if(Player ~= nil) then
    
        self.UIRoot:setText(
            string.format("Position - X: %.2f, Y: %.2f, Z: %.2f", Player:GetXPosition(), Player:GetYPosition(), Player:GetZPosition())
        );    
        
    else

        self.UIRoot:setText("Position - Unknown");
            
    end

end