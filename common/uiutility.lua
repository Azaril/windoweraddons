function SafeRemoveDetachChildWindow(Window)

    if(Window ~= nil) then
    
        local Parent = Window:getParent();
        
        if(Parent ~= nil) then
        
            Parent:removeChildWindow(Window);
        
        end
    
    end

end

function AddResourceGroupDirectory(ResourceGroup, Directory)

    CFFXiHook.Instance():GetUIManager():AddResourceGroupDirectory(ResourceGroup, Directory);

end

function StackWindowsVertical(Windows)

    local PaddingX = CEGUI.UDim(0, 0);
    local PaddingY = CEGUI.UDim(0, 0);

    local PositionX = CEGUI.UDim(0, 0) + PaddingX;
    local PositionY = CEGUI.UDim(0, 0) + PaddingY;
    
    for i, Window in ipairs(Windows) do
    
        if(Window ~= nil) then 
    
            Window:setPosition(CEGUI.UVector2(PositionX, PositionY));
            
            PositionY = PositionY + Window:getHeight() + PaddingY;
            
        end
        
    end
    
    return PositionX, PositionY;
    
end