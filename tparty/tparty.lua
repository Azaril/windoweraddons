require("common\\common");

if(TPartyWindowPrefix == nil) then
    TPartyWindowPrefix = 0;
end

function GetNewWindowPrefix()

    local Output = tostring(TPartyWindowPrefix) .. "__";
    
    TPartyWindowPrefix = TPartyWindowPrefix + 1;
    
    return Output;

end

--
-- Register TParty resource folder.
--
AddResourceGroupDirectory("TPartyResources", GetAddonDirectoryPath("tparty"));

class 'TParty'

function TParty:__init()

    self.Players = { };

    self.PlayerAddedConnection = CFFXiHook.Instance():GetGameStateManager():GetOnAlliancePlayerAdded():Connect(self.OnAlliancePlayerAdded, self);
    self.PlayerRemovedConnection = CFFXiHook.Instance():GetGameStateManager():GetOnAlliancePlayerRemoved():Connect(self.OnAlliancePlayerRemoved, self);
    
    self.UpdateTimer = CTimer();
    self.UpdateTimerConnection = self.UpdateTimer:GetOnTick():Connect(self.OnUpdateTick, self);
    
    self.UpdateTimer:Start(500);
    
    self.RootWindow = CEGUI.WindowManager:getSingleton():loadWindowLayout("tpartywindow.layout", GetNewWindowPrefix(), "TPartyResources");
    
    self.RootWindow:setDestroyedByParent(false);
        
    self.PlayerDockWindow = self.RootWindow:getChildRecursive("TPartyPlayerDock");
    
    RootWindow:addChildWindow(self.RootWindow);
    
    for i = 0, CFFXiHook.Instance():GetGameStateManager():GetAllianceMemberMaxIndex() do
    
        local Player = CFFXiHook.Instance():GetGameStateManager():GetAllianceMemberInformation(i);
        
        if(Player ~= nil) then
        
            self:OnAlliancePlayerAdded(i, Player);
        
        end
    
    end

end

function TParty:__finalize()

    SafeRemoveDetachChildWindow(self.RootWindow);

end

function TParty:OnAlliancePlayerAdded(Index, Player)

    Log("Player added - Index: " .. tostring(Index) .. " - Name: " .. Player:GetName());
    
    local PlayerInfo = { };
    
    -- Create the member window.
    PlayerInfo.Window = CEGUI.WindowManager:getSingleton():loadWindowLayout("tpartymember.layout", GetNewWindowPrefix(), "TPartyResources");
    
    -- Take ownership for the window.
    PlayerInfo.Window:setDestroyedByParent(false);
    
    --
    -- Find windows for layout.
    --
    PlayerInfo.MemberNameText = PlayerInfo.Window:getChildRecursive("MemberNameText");
    
    PlayerInfo.HPText = PlayerInfo.Window:getChildRecursive("HPText");
    PlayerInfo.HPProgressBar = CEGUI.toProgressBar(PlayerInfo.Window:getChildRecursive("HPProgressBar"));
    
    PlayerInfo.MPText = PlayerInfo.Window:getChildRecursive("MPText");
    PlayerInfo.MPProgressBar = CEGUI.toProgressBar(PlayerInfo.Window:getChildRecursive("MPProgressBar"));    
    
    PlayerInfo.TPText = PlayerInfo.Window:getChildRecursive("TPText");
    PlayerInfo.TPProgressBar = CEGUI.toProgressBar(PlayerInfo.Window:getChildRecursive("TPProgressBar"));    
    
    --
    -- Initial information setup.
    --
    PlayerInfo.MemberNameText:setText(Player:GetName());
    
    -- Add window to window.
    self.PlayerDockWindow:addChildWindow(PlayerInfo.Window);
    
    -- Cache the information for the player.
    self.Players[Index + 1] = PlayerInfo;
    
    self:ArrangeWindows();

end

function TParty:OnAlliancePlayerRemoved(Index)

    Log("Player removed - Index: " .. tostring(Index));
    
    local PlayerInfo = self.Players[Index + 1];
    
    SafeRemoveDetachChildWindow(PlayerInfo.Window);
    
    self.Players[Index + 1] = nil;
    
    self:ArrangeWindows();

end

function TParty:OnUpdateTick()

    for Index, PlayerInfo in pairs(self.Players) do
    
        local Player = GetAlliancePlayer(Index - 1);
        
        PlayerInfo.HPText:setText(string.format("%u - %u%%", Player:GetHitPoints(), Player:GetHitPointPercentage()));
        PlayerInfo.HPProgressBar:setProgress(Player:GetHitPointPercentage() / 100.0);
        
        PlayerInfo.MPText:setText(string.format("%u - %u%%", Player:GetMagicPoints(), Player:GetMagicPointPercentage()));
        PlayerInfo.MPProgressBar:setProgress(Player:GetMagicPointPercentage() / 100.0);
        
        PlayerInfo.TPText:setText(string.format("%u%%", Player:GetTechniquePoints()));
        PlayerInfo.TPProgressBar:setProgress(Player:GetTechniquePointPercentage() / 100.0);
    
    end

end

function TParty:ArrangeWindows()

    local Windows = { };

    for Index, PlayerInfo in pairs(self.Players) do
    
        table.insert(Windows, PlayerInfo.Window);
    
    end
    
    --TODO: Sort by alliance index?
    
    StackWindowsVertical(Windows);
    
end