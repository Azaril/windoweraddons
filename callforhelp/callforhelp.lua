require("common\\utility");

CallForHelp_AllowCallForHelp = true;

-- Enable calling for help through menus.
function EnableCallForHelp()

    CallForHelp_AllowCallForHelp = true;
    
end

-- Disable calling for help through menus.
function DisableCallForHelp()

    CallForHelp_AllowCallForHelp = false;

end

-- Chat input handler.
function CallForHelp_OnChatInput(Text)

    -- Check if this is a call for help custom command.
	if(Text:lower() == "/callforhelp" or Text:lower() == "/cfh") then
	
	    -- Call for help.
		SendInput("/help");
		
		return true;
		
	-- Check if the this is a call for help from the game.
	elseif(Text:lower() == "/help") then
	
	    -- Ignore the call for help if blocking is enabled.
        if(CallForHelp_AllowCallForHelp == false) then
        
            Log("Blocking call for help!");
            
            return true;
        
        end
        
	
	end

	return false;

end

-- Handle initialization for script state.
function CallForHelp_OnInitializeScript()

	Log("Initializing call for help script...");

	-- Connect to chat text entry.
	CallForHelp_OnChatInputConnection = CFFXiHook.Instance():GetGameHooks():GetOnInput():Connect(CallForHelp_OnChatInput);
	
	Log("[Complete]");
	
end

-- Handle finalization of script state.
function CallForHelp_OnFinalizeScript()

	-- Disconnect chat command handler.
	DisconnectConnection(CallForHelp_OnChatInputConnection);

	-- Disconnect script initialization event.
	DisconnectConnection(CallForHelp_InitializeScriptConnection);
	
	-- Disconnect script finalization event.
	DisconnectConnection(CallForHelp_FinalizeScriptConnection);
	
end

-- Connect to script initialization event.
CallForHelp_InitializeScriptConnection = CFFXiHook.Instance():GetOnInitializeScript():Connect(CallForHelp_OnInitializeScript);

-- Connect to script finalization event.
CallForHelp_FinalizeScriptConnection = CFFXiHook.Instance():GetOnFinalizeScript():Connect(CallForHelp_OnFinalizeScript);