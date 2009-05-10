require("utility")
require("gameutility")

class 'SCSet'

function SCSet:__init(Items, BaseSet)

    self.Items = { };

    if(BaseSet ~= nil and BaseSet.Items ~= nil) then

        for k, v in pairs(BaseSet.Items) do
        
            self.Items[k] = v;
        
        end
        
    end
    
    if(Items ~= nil) then
    
        for k, v in pairs(Items) do
        
            self.Items[k:lower()] = v;
        
        end
    
    end

end

function SCSet:GetItems()

    return self.Items;

end