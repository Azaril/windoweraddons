require("utility");
require("ui");
require("bar\\baraddon");

class 'ClockAddon' (BarAddon)

function ClockAddon:__init()

    BarAddon.__init(self);
    
    self.UpdateTimer = CTimer();
    self.UpdateTimerOnTickConnection = self.UpdateTimer:GetOnTick():Connect(self.OnUpdateTimerTick, self);

end

function ClockAddon:__finalize()
    
    self.UpdateTimer:Stop();

end

function ClockAddon:Load()
    
	self.UIRoot = CEGUI.WindowManager:getSingleton():loadWindowLayout("ClockAddon.layout", false);
	
	-- Trigger an immediate update.
	self:OnUpdateTimerTick();
	
	self.UpdateTimer:Start(1000);
	
end

function ClockAddon:Unload()

    self.UpdateTimer:Stop();

end

function ClockAddon:GetUI()

    return self.UIRoot;

end

function ClockAddon:OnUpdateTimerTick()

    self.UIRoot:setText(os.date("%H:%M:%S"));

end