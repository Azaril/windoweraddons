require("utility")
require("gameutility")

--require("spellcast\\eventhandler");

class 'SCSingleChildEventHandler' (SCEventHandler)

function SCSingleChildEventHandler:__init(Child)

    SCEventHandler.__init(self);

    self.Child = Child;

end

function SCSingleChildEventHandler:HandleEvent(Event)

    return false;

end

function SCSingleChildEventHandler:SetChild(Child)

    self.Child = Child;

end

function SCSingleChildEventHandler:GetChild(Child)

    return self.Child;

end

function SCSingleChildEventHandler:ForwardEvent(Event)

    if(self.Child ~= nil) then
    
        return self.Child:HandleEvent(Event);
    
    end
    
    return false;

end