require("common\\common");

-- Command handler.
function Cancel_OnCommand(CommandData)

	-- Get the command string.
	local Command = CommandData:GetCommand();
	
	-- Check if this is a command to add a new alias.
	if(Command:lower() == "cancel") then
	
		-- Check there are sufficient arguments.
		if(CommandData:GetArgumentCount() >= 1) then
		
		    -- Get the effect ID from the argument.
		    local EffectID = tonumber(CommandData:GetArgument(0));
		    
		    -- Check the argument could be converted.
		    if(EffectID ~= nil) then
		    
			    -- Cancel the effect by ID.
			    CancelStatusEffect(EffectID);
			    
			else
			
			    Log("Unable to convert argument to effect ID: " .. CommandData:GetArgument(0));
			    
			end
		
		else
		
			Log("Insufficient number of arguments to cancel a buff.");
		
		end
		
		-- Mark the command as handled.
		return true;
		
	end
	
	return false;
	
end

-- Handle initialization for script state.
function Cancel_OnInitializeScript()

	Log("Initializing cancel script...");

	-- Connect command handler.
	Cancel_OnCommandConnection = CFFXiHook.Instance():GetConsole():GetOnCommand():Connect(Cancel_OnCommand);
	
	Log("[Complete]");
	
end

-- Handle finalization of script state.
function Cancel_OnFinalizeScript()

	-- Disconnect command handler.
	DisconnectConnection(Cancel_OnCommandConnection);

	-- Disconnect script initialization event.
	DisconnectConnection(Cancel_InitializeScriptConnection);
	
	-- Disconnect script finalization event.
	DisconnectConnection(Cancel_FinalizeScriptConnection);
	
end

-- Cancel function
function CancelStatusEffect(EffectID)
    
    -- Get the local player.
    local Player = GetPlayer();
    
    -- Lookup the effect.
    local Effect = Player:GetStatusEffectByEffectID(EffectID);
    
    -- Check if the player has the effect.
    if(Effect ~= nil) then
    
        -- Try and cancel the effect.
        Effect:Cancel();
    
    end

end

-- Connect to script initialization event.
Cancel_InitializeScriptConnection = CFFXiHook.Instance():GetOnInitializeScript():Connect(Cancel_OnInitializeScript);

-- Connect to script finalization event.
Cancel_FinalizeScriptConnection = CFFXiHook.Instance():GetOnFinalizeScript():Connect(Cancel_OnFinalizeScript);