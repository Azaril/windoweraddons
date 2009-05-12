require("common\\common");
require("bar\\bar");

--
-- Register distance resource folder.
--
AddResourceGroupDirectory("DistanceResources", GetAddonDirectoryPath("distance"));

class 'DistanceAddon' (BarAddon)

function DistanceAddon:__init()

    BarAddon.__init(self);
    
    self.UpdateTimer = CTimer();
    self.UpdateTimerOnTickConnection = self.UpdateTimer:GetOnTick():Connect(self.OnUpdateTimerTick, self);

end

function DistanceAddon:__finalize()
    
    self.UpdateTimer:Stop();

end

function DistanceAddon:Load()
    
	self.UIRoot = CEGUI.WindowManager:getSingleton():loadWindowLayout("distanceaddon.layout", "", "DistanceResources");
	
	-- Trigger an immediate update.
	self:OnUpdateTimerTick();
	
	self.UpdateTimer:Start(200);
	
end

function DistanceAddon:Unload()

    self.UpdateTimer:Stop();

end

function DistanceAddon:GetUI()

    return self.UIRoot;

end

function DistanceAddon:OnUpdateTimerTick()

    local GotTarget = false;
    
    local Player = GetPlayer();
    
    if(Player ~= nil) then
        
        local TargetedID = Player:GetTargetedMobID();
        
        if(TargetedID ~= nil) then
      
            local Target = CFFXiHook.Instance():GetGameStateManager():GetMobInformationByLocalID(TargetedID);
            
            if(Target ~= nil) then
            
                local DistanceToMob = GetDistanceToMob(Target);
                
                local TargetName = Target:GetName();
                
                self.UIRoot:setText(
                    string.format("%s - Distance: %.2f", (TargetName ~= "") and TargetName or "Unknown", DistanceToMob)
                );
                
                GotTarget = true;
                
            end
            
        end
        
    end
    
    if(GotTarget == false) then
    
        self.UIRoot:setText("No Target");
        
    end

end