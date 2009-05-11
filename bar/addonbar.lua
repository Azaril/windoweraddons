require("common\\utility");
require("common\\ui");

require("bar\\barresources");

BarAlignment_Left = 0;
BarAlignment_Right = 1;
BarAlignment_Center = 2;

BarPaddingX = 10;

class "AddonBar"

function AddonBar:__init()

    self.Addons = { };
    self.NextIndex = 1;

	self.BarRoot = CEGUI.WindowManager:getSingleton():loadWindowLayout("addonbar.layout", "", "AddonBarResources");
	
	AddTopWindow(self.BarRoot, 1);
	
end

function AddonBar:__finalize()

    --TODO: Fix cleanup.
    --RemoveTopWindow(self.BarRoot);

end

function AddonBar:AddAddon(NewAddon, BarAlignment)

    local InitialAlignment = BarAlignment;
    
    if(InitialAlignment == nil) then
        InitialAlignment = 0;
    end

    if(NewAddon ~= nil) then
    
        local AddonInfo = { 
                            Addon = NewAddon,
                            Alignment = InitialAlignment,
                            Index = self.NextIndex
                          };
                          
        self.NextIndex = self.NextIndex + 1;
    
        table.insert(self.Addons, AddonInfo);
        
        NewAddon:Load();
    
        self.BarRoot:addChildWindow(NewAddon:GetUI());
        
        self:ArrangeAddons();
        
    end
    
end

function AddonBar:RemoveAddon(Addon)

    --TODO: Implement.

end

function Bar_AddonSortFunc(Addon1, Addon2)

    if(Addon1.Alignment ~= Addon2.Alignment) then
    
        return Addon1.Alignment < Addon2.Alignment;
        
    end
    
    return Addon1.Index < Addon2.Index;

end

function AddonBar:SortAddons()

    table.sort(self.Addons, Bar_AddonSortFunc);

end

function AddonBar:ArrangeAddons()

    self:SortAddons();
    
    self:ArrangeLeftAlignedAddons();
    self:ArrangeRightAlignedAddons();
    self:ArrangeCenterAlignedAddons();

end

function AddonBar:ArrangeLeftAlignedAddons()

    local PaddingX = CEGUI.UDim(0, BarPaddingX);

    local PositionX = CEGUI.UDim(0, 0) + PaddingX;
    local PositionY = CEGUI.UDim(0, 0);
    
    for i, AddonInfo in ipairs(self.Addons) do
    
        if(AddonInfo.Alignment == 0) then
        
            local Window = AddonInfo.Addon:GetUI();
   
            if(Window ~= nil) then 
        
                Window:setPosition(CEGUI.UVector2(PositionX, PositionY));
                
                PositionX = PositionX + Window:getWidth() + PaddingX;
                
            end
            
        end
    
    end
        
end

function AddonBar:ArrangeRightAlignedAddons()

    local PaddingX = CEGUI.UDim(0, BarPaddingX);

    local PositionX = CEGUI.UDim(1, 0) - PaddingX;
    local PositionY = CEGUI.UDim(0, 0);
    
    for i, AddonInfo in ipairs(self.Addons) do
    
        if(AddonInfo.Alignment == 1) then
        
            local Window = AddonInfo.Addon:GetUI();
   
            if(Window ~= nil) then 
        
                PositionX = PositionX - Window:getWidth();
                
                Window:setPosition(CEGUI.UVector2(PositionX, PositionY));
                
                PositionX = PositionX - PaddingX;
                
            end
            
        end
    
    end
    
end

function AddonBar:ArrangeCenterAlignedAddons()

    local PaddingX = CEGUI.UDim(0, BarPaddingX);
    
    local TotalWidth = CEGUI.UDim(0, 0) + PaddingX;
    
    for i, AddonInfo in ipairs(self.Addons) do
    
        if(AddonInfo.Alignment == 2) then
        
            local Window = AddonInfo.Addon:GetUI();
   
            if(Window ~= nil) then 
        
                TotalWidth = TotalWidth + Window:getWidth() + PaddingX;
                
            end
            
        end
    
    end
    
    local PositionX = (CEGUI.UDim(0.5, 0) - CEGUI.UDim(TotalWidth.scale / 2, TotalWidth.offset / 2)) + PaddingX;
    local PositionY = CEGUI.UDim(0, 0);
    
    for i, AddonInfo in ipairs(self.Addons) do
    
        if(AddonInfo.Alignment == 2) then
        
            local Window = AddonInfo.Addon:GetUI();
   
            if(Window ~= nil) then 
            
                Window:setPosition(CEGUI.UVector2(PositionX, PositionY));
                
                PositionX = PositionX + Window:getWidth() + PaddingX;
                
            end
            
        end
    
    end    
    
end