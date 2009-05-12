require("common\\common")
                    
class "SCCore"

function SCCore:__init()

    self.IdleTimer = CTimer();
    self.IdleTimerOnTickConnection = self.IdleTimer:GetOnTick():Connect(self.OnIdleTimerTick, self);

end

function SCCore:__finalize()

end

function SCCore:Start()

    Log("Starting spellcast");

    self.ChatInputConnection = CFFXiHook.Instance():GetGameHooks():GetOnInput():Connect(self.OnChatInput, self);
    
    self:EnableIdleTimer();

end

function SCCore:Stop()

    Log("Stopping spellcast");
    
    self:DisableIdleTimer();

    DisconnectConnection(self.ChatInputConnection);

end

function SCCore:SetHandler(Handler)

    self.Handler = Handler;

end

function SCCore:GetHandler()

    return self.Handler;

end

function SCCore:EnableIdleTimer()

    if(self.IdleTimer:IsStarted() == false) then
    
        self.IdleTimer:Start(5000);
        
    end

end

function SCCore:DisableIdleTimer()

    self.IdleTimer:Stop();

end

function SCCore:OnIdleTimerTick()

    self.IdleTimer:Stop();

    local Event = SC.Event(SC.EventType.Idle);

    self:ForwardEvent(Event);

end

function SCCore:ParseGameCommand(Text)

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

function SCCore:CommandToActionType(NormalizedCommand)

    if(NormalizedCommand == "ja") then
        return SC.EventType.JobAbility;
    elseif(NormalizedCommand == "ma") then
        return SC.EventType.MagicAbility;
    elseif(NormalizedCommand == "ws") then
        return SC.EventType.WeaponSkill;
    else
        return nil;
    end

end

function SCCore:OnChatInput(Input)

    local Cancel = false;
    
    local NormCommandText, NormActionText = self:ParseGameCommand(Input);
    
    if(NormCommandText ~= nil) then
    
        local ActionType = self:CommandToActionType(NormCommandText);
        
        if(ActionType ~= nil) then
        
            local Event = SC.Event(ActionType, { Action = NormActionText });
            
            self:DisableIdleTimer();
        
            self:ForwardEvent(Event);
            
            self:EnableIdleTimer();
        
            Cancel = Event:IsCanceled();
            
        end
    
    end
    
    return Cancel;

end

function SCCore:ForwardEvent(Event)

    if(self.Handler ~= nil) then
    
        self.Handler:HandleEvent(Event);
    
    end

end

--
-- Add to namespace.
--
SC.Spellcast = SCCore;