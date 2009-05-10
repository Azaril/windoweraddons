--
-- User variables
--

-- Bind the console key.
BindKeyDownPreUI(Key.Grave, nil, Console_Toggle);
BindKeyDownPreUI(Key.Insert, nil, Console_Toggle);

--
-- Auxilary script setup.
--

-- Load cancel script.
require("cancel");

-- Load call for help script.
require("callforhelp");

--
-- Bar setup
--

-- Load the bar scripts.
require("bar\\bar");
require("bar\\baraddon");
require("bar\\clock");
require("bar\\distance");
require("bar\\position");
require("bar\\inventory");

-- Create the top bar.
TopBar = AddonBar();

-- Create addons.
TopBar:AddAddon(PositionAddon(), BarAlignment_Left);
TopBar:AddAddon(ClockAddon(), BarAlignment_Right);
TopBar:AddAddon(InventoryAddon(), BarAlignment_Right);
TopBar:AddAddon(DistanceAddon(), BarAlignment_Center);

--
-- Event handlers
--

-- Default key handler.
function Default_OnKeyDown(ScanCode)
	
	return false;
	
end

-- Command handler.
function Default_OnCommand(CommandData)

	-- Get the command string.
	local Command = CommandData:GetCommand();
	
	Log(Command);
	
	if(Command:lower() == "sc") then
	
	    Log("Loading spellcast...");
	
	    if(Default_SC ~= nil) then
	    
	        Default_SC:Stop();
	        Default_SC = nil;
	        	        
	    end
	    
	    RunScriptFile(GetScriptFilePath("spellcast\\namespace.lua"));
	    RunScriptFile(GetScriptFilePath("spellcast\\util.lua"));
        RunScriptFile(GetScriptFilePath("spellcast\\set.lua"));
        RunScriptFile(GetScriptFilePath("spellcast\\eventtype.lua"));
        RunScriptFile(GetScriptFilePath("spellcast\\event.lua"));
        RunScriptFile(GetScriptFilePath("spellcast\\eventhandler.lua"));
        RunScriptFile(GetScriptFilePath("spellcast\\eventtest.lua"));        
        RunScriptFile(GetScriptFilePath("spellcast\\singlechildeventhandler.lua"));
        RunScriptFile(GetScriptFilePath("spellcast\\listeventhandler.lua"));
        RunScriptFile(GetScriptFilePath("spellcast\\conditioneventhandler.lua"));        
        RunScriptFile(GetScriptFilePath("spellcast\\traceeventhandler.lua"));
        RunScriptFile(GetScriptFilePath("spellcast\\equipeventhandler.lua"));        
        RunScriptFile(GetScriptFilePath("spellcast\\spellcast.lua"));
        
        Default_SC = Spellcast();
        Default_SC:Start();
        
        Log("Finished loading spellcast.");
        
        return true;	    
	
	end
	
	return false;

end

-- Handle initialization for script state.
function Default_OnInitializeScript()

	Log("Initializing default script...");

	-- Connect command handler.
	Default_OnCommandConnection = CFFXiHook.Instance():GetConsole():GetOnCommand():Connect(Default_OnCommand);
	
	-- Connect key handler.
	Default_OnKeyDownConnection = CFFXiHook.Instance():GetUIManager():GetOnKeyDownPreUI():Connect(Default_OnKeyDown);
	
	Log("[Complete]");
	
end

-- Handle finalization of script state.
function Default_OnFinalizeScript()

	-- Disconnect command handler.
	DisconnectConnection(Default_OnCommandConnection);
	
	-- Disconnect key handler.
	DisconnectConnection(Default_OnKeyDownConnection);

	-- Disconnect script initialization event.
	DisconnectConnection(Default_InitializeScriptConnection);
	
	-- Disconnect script finalization event.
	DisconnectConnection(Default_FinalizeScriptConnection);
	
end

-- Connect to script initialization event.
Default_InitializeScriptConnection = CFFXiHook.Instance():GetOnInitializeScript():Connect(Default_OnInitializeScript);

-- Connect to script finalization event.
Default_FinalizeScriptConnection = CFFXiHook.Instance():GetOnFinalizeScript():Connect(Default_OnFinalizeScript);