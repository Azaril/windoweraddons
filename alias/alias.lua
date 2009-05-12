require("common\\common");

Alias_Map = {};

-- Command handler.
function Alias_OnCommand(CommandData)

	-- Get the command string.
	local Command = CommandData:GetCommand();
	
	-- Check if this is a command to add a new alias.
	if(Command:lower() == "alias") then
	
		-- Check there are sufficient arguments.
		if(CommandData:GetArgumentCount() >= 2) then
		
			-- Add the new alias.
			Alias(CommandData:GetArgument(0), CommandData:GetArgument(1));
				
		else
		
			Log("Insufficient number of arguments to set an alias.");
		
		end
		
		-- Mark the command as handled.
		return true;		
		
	-- Check if this is a command to clear all the set aliases.
	elseif(Command:lower() == "clearaliases") then
	
		-- Reset the alias map.
		Alias_Map = {};
		
		-- Mark the command as handled.
		return true;
		
	-- Check if this is a command to list the current aliases.
	elseif(Command:lower() == "listaliases") then
	
		-- Pull out all the current aliases.
		for Alias, AliasTarget in pairs(Alias_Map) do
		
			-- Check there is an alias set.
			if(AliasTarget ~= nil) then
			
				-- Check if this is a command alias.
				if(type(AliasTarget) == "string") then
				
					-- Log the alias.
					Log(Alias .. " - \"" .. AliasTarget .. "\"");

				-- Check if this is a function alias.
				elseif(type(AliasTarget) == "function") then
				
					-- Log the alias.
					Log(Alias .. " - function");
				
				end
			
			end
			
		end
		
		-- Mark the command as handled.
		return true;
	
	else
		
		-- Get the mapped alias.
		local AliasTarget = Alias_Map[Command];
	
		-- Check we got a valid alias.
		if(AliasTarget ~= nil) then
	
			-- Check if this is a command string.
			if(type(AliasTarget) == "string") then
			
				-- Execute the alias.
				CFFXiHook.Instance():GetConsole():RunCommand(AliasTarget);

				-- Mark the command as handled.
				return true;
							
			-- Check if this is a function to execute.
			elseif(type(AliasTarget) == "function") then
			
				-- Execute the function.
				AliasTarget();
				
				-- Mark the command as handled.
				return true;
				
			end
		
		end
		
	end
	
	return false;

end

-- Handle initialization for script state.
function Alias_OnInitializeScript()

	Log("Initializing alias script...");

	-- Connect command handler.
	Alias_OnCommandConnection = CFFXiHook.Instance():GetConsole():GetOnCommand():Connect(Alias_OnCommand);
	
	Log("[Complete]");
	
end

-- Handle finalization of script state.
function Alias_OnFinalizeScript()

	-- Disconnect command handler.
	DisconnectConnection(Alias_OnCommandConnection);

	-- Disconnect script initialization event.
	DisconnectConnection(Alias_InitializeScriptConnection);
	
	-- Disconnect script finalization event.
	DisconnectConnection(Alias_FinalizeScriptConnection);
	
end

-- Alias function
function Alias(CommandName, Target)

	if(type(CommandName) == "string" and (Target == nil or type(Target) == "string" or type(Target) == "function")) then
	
		Alias_Map[CommandName] = Target;
		
	end

end

-- Connect to script initialization event.
Alias_InitializeScriptConnection = CFFXiHook.Instance():GetOnInitializeScript():Connect(Alias_OnInitializeScript);

-- Connect to script finalization event.
Alias_FinalizeScriptConnection = CFFXiHook.Instance():GetOnFinalizeScript():Connect(Alias_OnFinalizeScript);