require("utility")
require("gameutility")

--require("spellcast\\namespace");
--require("spellcast\\eventtype");
--require("spellcast\\conditioneventhandler");
--require("spellcast\\equipeventhandler");
--require("spellcast\\event");
--require("spellcast\\eventhandler");
--require("spellcast\\listeventhandler");
--require("spellcast\\set");
--require("spellcast\\singlechildeventhandler");
--require("spellcast\\eventtest");
--require("spellcast\\traceeventhandler");

--
-- Set
--
SC.Set = SCSet;
    
--
-- Actions
--
SC.Trace = SCTraceEventHandler;
SC.Equip = SCEquipEventHandler;
    
--
-- Containers
--
SC.List         = SCListEventHandler;
SC.Condition    = SCConditionEventHandler;

--    
-- Conditions
--
SC.IsEvent =   
    function(EventType, Children)
        return SCConditionEventHandler(SCIsEventTypeFunc(EventType), Children);
    end
    
SC.IsAction =  
    function(Action, Children) 
        return SCConditionEventHandler(SCIsActionFunc(Action), Children);
    end
                
SC.IsIdle =    
    function(Children)
        return SCConditionEventHandler(SCIsIdle, Children);
    end

SC.IsJobAbility =    
    function(Children)
        return SCConditionEventHandler(SCIsMagicAbility, Children);
    end
    
SC.IsMagicAbility =    
    function(Children)
        return SCConditionEventHandler(SCIsMagicAbility, Children);
    end
    
SC.IsWeaponSkill =    
    function(Children)
        return SCConditionEventHandler(SCIsWeaponSkill, Children);
    end    
                    
function DumpEvent(Event)

    local EventType = Event:GetType();

    if (EventType == SC.Event.Idle) then
        return "Idle event";
    end
    
    if (EventType == SC.Event.JobAbility) then
        return "Job ability event - " .. tostring(Event:GetArguments().Action);
    end
    
    if (EventType == SC.Event.MagicAbility) then
        return "Magic ability event - " .. tostring(Event:GetArguments().Action);
    end
    
    if (EventType == SC.Event.WeaponSkill) then
        return "Weapon skill event - " .. tostring(Event:GetArguments().Action);
    end

    return "Unknown event";

end
                    
class "Spellcast"

function Spellcast:__init()

    self.IdleTimer = CTimer();
    self.IdleTimerOnTickConnection = self.IdleTimer:GetOnTick():Connect(self.OnIdleTimerTick, self);

end

function Spellcast:__finalize()

end

function Spellcast:Start()

    Log("Starting spellcast");

    self.ChatInputConnection = CFFXiHook.Instance():GetGameHooks():GetOnInput():Connect(self.OnChatInput, self);
    
    self:EnableIdleTimer();

end

function Spellcast:Stop()

    Log("Stopping spellcast");
    
    self:DisableIdleTimer();

    DisconnectConnection(self.ChatInputConnection);

end

function Spellcast:SetHandler(Handler)

    self.Handler = Handler;

end

function Spellcast:GetHandler()

    return self.Handler;

end

function Spellcast:EnableIdleTimer()

    if(self.IdleTimer:IsStarted() == false) then
    
        self.IdleTimer:Start(5000);
        
    end

end

function Spellcast:DisableIdleTimer()

    self.IdleTimer:Stop();

end

function Spellcast:OnIdleTimerTick()

    self.IdleTimer:Stop();

    local Event = SCEvent(SC.Event.Idle);

    self:ForwardEvent(Event);

end

function Spellcast:ParseGameCommand(Text)

    local InputText = Trim(Text);
    
    local ParseIndex = 0;
    
    -- Check this is actually a command.
    if(#InputText >= 1 and string.sub(InputText, 1, 1) ~= "/") then
        
        return nil;
        
    end
        
    -- Ignore console commands.
    if(#InputText >= 2 and string.sub(InputText, 2, 2) == "/") then
    
        return nil;
    
    end
    
    local _, CommandEndIndex, CommandText = string.find(InputText, "(%a+)");
    
    -- Check a command was found.
    if(CommandText == nil) then
    
        return nil;
    
    end
    
    local SingleActionIndex, SingleActionEndIndex, SingleActionText = string.find(InputText, "(%a+)", CommandEndIndex + 1);
    
    local QuotedActionIndex, QuotedActionEndIndex, QuotedActionText = string.find(InputText, "\"(.*)\"", CommandEndIndex + 1);
    
    if(SingleActionIndex == nil and QuotedActionIndex == nil) then
    
        return nil;
    
    end
    
    local NormalizedActionText = nil;
    local EndActionIndex = 1;
    
    if(SingleActionIndex == nil) then
        NormalizedActionText = QuotedActionText:lower();
        EndActionIndex = QuotedActionEndIndex;
    elseif(QuotedActionIndex == nil) then
        NormalizedActionText = SingleActionText:lower();
        EndActionIndex = SingleActionEndIndex;        
    else
        if(QuotedActionIndex <= SingleActionIndex) then
            NormalizedActionText = QuotedActionText:lower();
            EndActionIndex = QuotedActionEndIndex;
        else
            NormalizedActionText = SingleActionText:lower();
            EndActionIndex = SingleActionEndIndex;
        end
    end

    local NormalizedCommand = CommandText:lower();
    
    return NormalizedCommand, NormalizedActionText;

end

function Spellcast:CommandToActionType(NormalizedCommand)

    if(NormalizedCommand == "ja") then
        return SC.Event.JobAbility;
    elseif(NormalizedCommand == "ma") then
        return SC.Event.MagicAbility;
    elseif(NormalizedCommand == "ws") then
        return SC.Event.WeaponSkill;
    else
        return nil;
    end

end

function Spellcast:OnChatInput(Input)

    local Cancel = false;
    
    local NormCommandText, NormActionText = self:ParseGameCommand(Input);
    
    if(NormCommandText ~= nil) then
    
        local ActionType = self:CommandToActionType(NormCommandText);
        
        if(ActionType ~= nil) then
        
            local Event = SCEvent(ActionType, { Action = NormActionText });
            
            self:DisableIdleTimer();
        
            self:ForwardEvent(Event);
            
            self:EnableIdleTimer();
        
            Cancel = Event:IsCanceled();
            
        end
    
    end
    
    return Cancel;

end

function Spellcast:ForwardEvent(Event)

    if(self.Handler ~= nil) then
    
        self.Handler:HandleEvent(Event);
    
    end

end