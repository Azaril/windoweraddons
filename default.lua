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