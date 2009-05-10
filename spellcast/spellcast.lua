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

--
-- Test code
-- 

local IdleSet = SC.Set({
                        Main="IdleMain",
                        Sub="IdleSub",
                        Range="IdleRange",
                        Ammo="IdleAmmo",
                        Head="IdleHead",
                        Neck="IdleNeck",
                        LeftEar="IdleLeftEar",
                        RightEar="IdleRightEar",
                        Body="IdleBody",
                        Hands="IdleHands",
                        LeftRing="IdleLeftRight",
                        RightRing="IdleRightRing",
                        Back="IdleBack",
                        Waist="IdleWaist",
                        Legs="IdleLegs",
                        Feet="IdleFeet"
                    });
                    
local CureSet = SC.Set({
                        Main="CureMain"
                    });
                    
local TestSet1 = SC.Set({
    Range = "Bamboo Fish. Rod"
});

local TestSet2 = SC.Set({
    Range = "Yew Fishing Rod"
});

local TestSet3 = SC.Set({
    Range = "TestSet3"
});
                    
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

--
-- TEST CODE
--

    local Handlers = SC.List({
                                SC.Trace(DumpEvent),
                                
                                SC.IsMagicAbility(
                                {
                                    SC.IsAction("Cure II",
                                    {
                                        SC.Equip(TestSet2)
                                    }),
                                    
                                    SC.IsAction("Cure",
                                    {
                                        SC.Equip(TestSet3)
                                    })
                                }),
                                
                                SC.IsIdle(
                                {
                                    SC.Equip(TestSet1)
                                }),
                            });
    
    self.Handler = Handlers;

end

function Spellcast:__finalize()

end

function Spellcast:Start()

    Log("Start");

    self.ChatInputConnection = CFFXiHook.Instance():GetGameHooks():GetOnInput():Connect(self.OnChatInput, self);
    
    self:EnableIdleTimer();

end

function Spellcast:Stop()

    Log("Stop");
    
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
        
        Log("Not a command");
        
        return nil;
        
    end
        
    -- Ignore console commands.
    if(#InputText >= 2 and string.sub(InputText, 2, 2) == "/") then
    
        Log("Console command");
    
        return nil;
    
    end
    
    local _, CommandEndIndex, CommandText = string.find(InputText, "(%a+)");
    
    -- Check a command was found.
    if(CommandText == nil) then
    
        Log("Failed to find command");
    
        return nil;
    
    end
    
    local SingleActionIndex, SingleActionEndIndex, SingleActionText = string.find(InputText, "(%a+)", CommandEndIndex + 1);
    
    local QuotedActionIndex, QuotedActionEndIndex, QuotedActionText = string.find(InputText, "\"(.*)\"", CommandEndIndex + 1);
    
    if(SingleActionIndex == nil and QuotedActionIndex == nil) then
    
        Log("Failed to find action");
        
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

    Log("Normalized command: " .. NormalizedCommand);

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

    Log("Chat input: " .. tostring(Input));

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