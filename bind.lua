require("utility");

Bind_KeyDownMap = {};
Bind_KeyUpMap = {};
Bind_KeyDownPreUIMap = {};
Bind_KeyUpPreUIMap = {};

-- Modifier keys that have implied up or down state required.
Bind_ModifierKeys = { Key.LeftShift, 
					  Key.RightShift, 
					  Key.LeftControl, 
					  Key.RightControl, 
					  Key.LeftAlt, 
					  Key.RightAlt, 
					  Key.LeftWindows, 
					  Key.RightWindows };
					  
-- Sort the key table to allow for quick comparison to ensure modifiers are up or down.
table.sort(Bind_ModifierKeys);

-- Character to key mappings for parsing.
Bind_CommandParserKeys = { ["^"] = Key.LeftControl,
						   ["!"] = Key.LeftAlt,
						   ["@"] = Key.LeftWindows,
						   ["#"] = Key.Applications };

function Bind_ParseBindKey(Text)

	local ParseIndex = 1;
	local ModifierKeys = {};
	
	-- Parse the modifier prefix.
	while(ParseIndex <= Text:len()) do
	
		-- Extract the character from the string.
		local ParseChar = Text:sub(ParseIndex, ParseIndex);
		
		-- Lookup the mapped key.
		local MappedModifierKey = Bind_CommandParserKeys[ParseChar];
		
		-- Check if a key was mapped.
		if(MappedModifierKey ~= nil) then
		
			-- Add the key to the modifiers.
			table.insert(ModifierKeys, MappedModifierKey);
			
			-- Move to the next character.
			ParseIndex = ParseIndex + 1;
			
		else
		
			-- A character was not mapped, move on to the key.
			break;
			
		end
	
	end
	
	-- Extract the remaining unparsed text.
	local KeyString = Text:sub(ParseIndex);
	
	-- Map the string to a key.
	local BindKey = Bind_KeyToKeyCode(KeyString);
	
	-- Check that a key was mapped.
	if(BindKey == nil) then
		
		-- Return that parsing failed.
		return false;
		
	end
	
	return true, BindKey, ModifierKeys;

end
					  
-- Command handler.
function Bind_OnCommand(CommandData)

	-- Get the command string.
	local Command = CommandData:GetCommand();
	
	-- Check if this is a command to add a new bind.
	if(Command:lower() == "bind") then
	
		-- Set default command interpretation.
		local CommandIndex = 1;
		local IsKeyDownBind = true;		

		-- Check there are sufficient arguments.
		if(CommandData:GetArgumentCount() == 2) then
			
			-- Two argument
			CommandIndex = 1;
			IsKeyDownBind = true;
		
		elseif(CommandData:GetArgumentCount() == 3) then
		
			-- Command index is second argument.
			CommandIndex = 2;
			
			-- Extract the key up or down specifier.
			local UpDownText = CommandData:GetArgument(1);
			local UpDownTextLowered = UpDownText:lower();
			
			-- Check if this is a key up bind.
			if(UpDownTextLowered == "up") then
			
				-- Mark this as a key up bind.
				IsKeyDownBind = false;
			
			-- Check if this is a key down bind.
			elseif(UpDownTextLowered == "down") then
				
				-- Mark this as a key down bind.
				IsKeyDownBind = true;
				
			else
			
				-- Log the failure.
				Log("Failed to interpret bind argument (" .. UpDownText .. ") to valid up or down state.");
				
				-- Abort parsing but mark command as handled.
				return true;
				
			end
		
		else
		
			-- Log the failure.
			Log("Invalid number of arguments (" .. CommandData:GetArgumentCount() .. ") passed to bind command.");
			
			-- Abort parsing but mark command as handled.
			return true;
			
		
		end
		
		-- Parse the key and modifiers from the command.
		local ParseResult, BindKey, Modifiers = Bind_ParseBindKey(CommandData:GetArgument(0));

		-- Check that parsing succeeded.
		if(ParseResult == false) then
		
			Log("Failed to map input text (" .. CommandData:GetArgument(0) .. ") to valid keyboard keys.");
			
			-- Abort parsing but mark command as handled.
			return true;
			
		end
		
		-- Check if this a key up or down event.
		if(IsKeyDownBind == true) then
			
			-- Bind the key down handler.
			BindKeyDown(BindKey, Modifiers, CommandData:GetArgument(CommandIndex));
			
		else
		
			-- Bind the key up handler.
			BindKeyUp(BindKey, Modifiers, CommandData:GetArgument(CommandIndex));
			
		end
		
		-- Mark the command as handled.
		return true;
	
	-- Check if this is a command to clear a bind.
	elseif(Command:lower() == "unbind") then
	
		-- Set default command interpretation.
		local IsKeyDownUnbind = true;		

		-- Check there are sufficient arguments.
		if(CommandData:GetArgumentCount() == 1) then
			
			-- One argument
			IsKeyDownUnbind = true;
		
		elseif(CommandData:GetArgumentCount() == 2) then
		
			-- Extract the key up or down specifier.
			local UpDownText = CommandData:GetArgument(1);
			local UpDownTextLowered = UpDownText:lower();
			
			-- Check if this is a key up unbind.
			if(UpDownTextLowered == "up") then
			
				-- Mark this as a key up unbind.
				IsKeyDownUnbind = false;
			
			-- Check if this is a key down unbind.
			elseif(UpDownTextLowered == "down") then
				
				-- Mark this as a key down unbind.
				IsKeyDownUnbind = true;
				
			else
			
				-- Log the failure.
				Log("Failed to interpret bind argument (" .. UpDownText .. ") to valid up or down state.");
				
				-- Abort parsing but mark command as handled.
				return true;
				
			end
		
		else
			-- Log the failure.
			Log("Invalid number of arguments (" .. CommandData:GetArgumentCount() .. ") passed to unbind command.");
			
			-- Abort parsing but mark command as handled.
			return true;
		
		end
		
		-- Parse the key and modifiers from the command.
		local ParseResult, BindKey, Modifiers = Bind_ParseBindKey(CommandData:GetArgument(0));

		-- Check that parsing succeeded.
		if(ParseResult == false) then
		
			Log("Failed to map input text (" .. CommandData:GetArgument(0) .. ") to valid keyboard keys.");
			
			-- Abort parsing but mark command as handled.
			return true;
			
		end
		
		-- Check if this a key up or down event.
		if(IsKeyDownUnbind == true) then
			
			-- Bind the key down handler.
			UnbindKeyDown(BindKey, Modifiers);
			
		else
		
			-- Bind the key up handler.
			UnbindKeyUp(BindKey, Modifiers);
			
		end
		
		-- Mark the command as handled.
		return true;
	
	end
	
	return false;

end

function Bind_ExecuteBindTarget(BindTarget)

	-- Check the bind target is valid.
	if(BindTarget ~= nil) then
	
		-- Check if this is a command string.
		if(type(BindTarget) == "string") then
		
			-- Execute the bind.
			CFFXiHook.Instance():GetConsole():RunCommand(BindTarget);

		-- Check if this is a function to execute.
		elseif(type(BindTarget) == "function") then
		
			-- Execute the function.
			BindTarget();
			
		end
	end

end

function Bind_FindAndExecuteBindTarget(ScanCode, MapTable, ImpliedModifiers, StateTestFunc)

	-- Get the bind table associated with the key.
	local BindTable = MapTable[ScanCode];
	
	-- Check if there is a bind table.
	if(BindTable ~= nil) then
	
		-- Check all the binds for the key.
		for Index, BindData in ipairs(BindTable) do
		
			-- Check there is a valid target for this bind.
			if(BindData.Target ~= nil) then
			
				local ShouldExecuteTarget = true;
			
				-- Check if there are modifiers for the bind.
				if(BindData.Modifiers ~= nil) then
				
					local ImpliedModifierIndex = 1;
					local ImpliedModifierCount = #ImpliedModifiers;
					
					-- Check all the key modifiers.
					for ModifierIndex, ModifierKey in ipairs(BindData.Modifiers) do
					
						local ContinueModifierSearch = true;
						
						-- Begin searching implied modifiers to check the state.
						while(ShouldExecuteTarget == true and ContinueModifierSearch == true) do
						
							-- If there are no more modifiers to search or the next implied modifier is greater than the current modifier key.
							if(ImpliedModifierIndex > ImpliedModifierCount or ImpliedModifiers[ImpliedModifierIndex] > ModifierKey) then
							
								-- Halt searching through modifiers for now.
								ContinueModifierSearch = false;
								
							-- If the current implied modifier is less than the current modifier key.
							elseif(ImpliedModifiers[ImpliedModifierIndex] < ModifierKey) then
							
								-- Check that the implied modifier is not the key that has been pressed and check the modifier is not pressed.
								if(ScanCode ~= ImpliedModifiers[ImpliedModifierIndex] and StateTestFunc(ImpliedModifiers[ImpliedModifierIndex]) == true) then
								
									-- Don't execute the bind target as an implied modifier was pressed.
									ShouldExecuteTarget = false;
								
								end
								
								-- Move to the next implied modifier.
								ImpliedModifierIndex = ImpliedModifierIndex + 1;
							
							-- Check if the current implied modifier is equal to the current modifier.
							elseif(ImpliedModifiers[ImpliedModifierIndex] == ModifierKey) then
							
								-- Skip this implied modifier.
								ImpliedModifierIndex = ImpliedModifierIndex + 1;
							
							end
						
						end
						
						-- Check the key modifier is in the down state if it's not the current key.
						if(ShouldExecuteTarget and ModifierKey ~= ScanCode and StateTestFunc(ModifierKey) == false) then
						
							-- Don't execute the bind if a modifier is not set.
							ShouldExecuteTarget = false;
							
							break;
						
						end
				
					end
					
					-- Finish searching the tail of implied modifiers.
					while(ShouldExecuteTarget == true and ImpliedModifierIndex <= ImpliedModifierCount) do
					
						-- Check that the implied modifier is not the key that has been pressed and check the modifier is not pressed.
						if(ScanCode ~= ImpliedModifiers[ImpliedModifierIndex] and StateTestFunc(ImpliedModifiers[ImpliedModifierIndex]) == true) then
						
							-- Don't execute the bind target as an implied modifier was pressed.
							ShouldExecuteTarget = false;
							
							break;
						
						end							
					
						-- Move to the next implied modifier.
						ImpliedModifierIndex = ImpliedModifierIndex + 1;
					
					end
				
				-- Check all the implied modifiers are not pressed as there are no modifiers for the key.
				else
				
					-- Check all the implied modifiers.
					for ModifierIndex, ModifierKey in ipairs(ImpliedModifiers) do
					
						-- Check the key modifier is in the up state if it's not the current key.
						if(ModifierKey ~= ScanCode and StateTestFunc(ModifierKey) == true) then
						
							-- Don't execute the bind if an implied modifier is set.
							ShouldExecuteTarget = false;
							
							break;
						
						end
											
					end
				
				end
				
				-- Check if the bind target should be executed.
				if(ShouldExecuteTarget == true) then
				
					-- Execute the bind target.
					Bind_ExecuteBindTarget(BindData.Target);
					
					-- Notify that the a bind was executed.
					return true;
				
				end
			
			end
		
		end
	
	end
	
	return false;

end

-- Bind key down handler.
function Bind_OnKeyDown(ScanCode)

	-- Find and execute the bind if it exists.
	return Bind_FindAndExecuteBindTarget(ScanCode, Bind_KeyDownMap, Bind_ModifierKeys, IsKeyDown);
	
end

-- Bind key up handler.
function Bind_OnKeyUp(ScanCode)

	-- Find and execute the bind if it exists.
	return Bind_FindAndExecuteBindTarget(ScanCode, Bind_KeyUpMap, Bind_ModifierKeys, IsKeyDown);

end

-- Bind key down pre-UI handler.
function Bind_OnKeyDownPreUI(ScanCode)

	-- Find and execute the bind if it exists.
	return Bind_FindAndExecuteBindTarget(ScanCode, Bind_KeyDownPreUIMap, Bind_ModifierKeys, IsKeyDown);
	
end

-- Bind key up pre-UI handler.
function Bind_OnKeyUpPreUI(ScanCode)

	-- Find and execute the bind if it exists.
	return Bind_FindAndExecuteBindTarget(ScanCode, Bind_KeyUpPreUIMap, Bind_ModifierKeys, IsKeyDown);
	
end

-- Handle initialization for script state.
function Bind_OnInitializeScript()

	Log("Initializing bind script...");

	-- Connect command handler.
	Bind_OnCommandConnection = CFFXiHook.Instance():GetConsole():GetOnCommand():Connect(Bind_OnCommand);
	
	-- Connect to key down events.
	Bind_OnKeyDownConnection = CFFXiHook.Instance():GetUIManager():GetOnKeyDown():Connect(Bind_OnKeyDown);
	
	-- Connect to key up events.
	Bind_OnKeyUpConnection = CFFXiHook.Instance():GetUIManager():GetOnKeyUp():Connect(Bind_OnKeyUp);	
	
	-- Connect to key down pre-UI events.
	Bind_OnKeyDownPreUIConnection = CFFXiHook.Instance():GetUIManager():GetOnKeyDownPreUI():Connect(Bind_OnKeyDownPreUI);
	
	-- Connect to key up pre-UI events.
	Bind_OnKeyUpPreUIConnection = CFFXiHook.Instance():GetUIManager():GetOnKeyUpPreUI():Connect(Bind_OnKeyUpPreUI);	
	
	Log("[Complete]");
	
end

-- Handle finalization of script state.
function Bind_OnFinalizeScript()

	-- Disconnect key up pre-UI handler.
	DisconnectConnection(Bind_OnKeyUpPreUIConnection);
	
	-- Disconnect key down pre-UI handler.
	DisconnectConnection(Bind_OnKeyDownPreUIConnection);	
	
	-- Disconnect key up handler.
	DisconnectConnection(Bind_OnKeyUpConnection);
	
	-- Disconnect key down handler.
	DisconnectConnection(Bind_OnKeyDownConnection);		

	-- Disconnect command handler.
	DisconnectConnection(Bind_OnCommandConnection);

	-- Disconnect script initialization event.
	DisconnectConnection(Bind_InitializeScriptConnection);
	
	-- Disconnect script finalization event.
	DisconnectConnection(Bind_FinalizeScriptConnection);
	
end

-- Take an input string or number and map it to a key string.
function Bind_KeyToString(Key)

	local RealKey = Key;

	-- Convert from a string to a key if the input was a string.
	if(type(RealKey) == "string") then
	
		-- Attempt to map the string to a key code.
		local KeyVal = StringToKey(RealKey);
		
		-- Check if a key was mapped.
		if(KeyVal ~= -1) then
		
			-- Set the mapped key.
			RealKey = KeyVal;
		
		else
			
			-- Unable to map the key so clear the value.
			-- TODO: Print an error message here?
			Realkey = nil
		
		end
	
	end
	
	-- Convert from a key value to the string equivalent.
	if(type(RealKey) == "number") then
	
		-- Attempt to convert the string to a key.
		RealKey = KeyToString(RealKey);
		
		-- Check if the key was not mapped.
		if(RealKey == nil or string.len(RealKey) == 0) then
		
			-- Unable to map the key so clear the value.
			-- TODO: Print an error message here?
			RealKey = nil;
		
		end
	
	end
	
	return RealKey;
	
end

-- Take an input string or number and convert it to a key code.
function Bind_KeyToKeyCode(Number)

	-- Attempt to map the input to a key string.
	local KeyString = Bind_KeyToString(Number);
	
	-- Check if a key string was found.
	if(KeyString ~= nil) then
	
		-- Map the validated string to a key code.
		local MappedKey = StringToKey(KeyString);
		
		-- Check if a key was mapped.
		if(MappedKey ~= -1) then
		
			-- Return the mapped key.
			return MappedKey;
			
		end
	
	end
	
	return nil;

end

-- Comparison function for comparing bind data.
function CompareBindData(a, b)

	local ModifierACount = 0
	
	if(a.Modifiers ~= nil) then
		ModifierACount = #(a.Modifiers);
	end
	
	local ModifierBCount = 0
	
	if(b.Modifiers ~= nil) then
		ModifierBCount = #(b.Modifiers);
	end	
	
	if(ModifierACount > ModifierBCount) then
	
		return true;
		
	elseif(ModifierACount < ModifierBCount) then
	
		return false;
		
	end	
	
	return a < b;
	
end

-- Common bind function for key up and down.
function Bind_InternalBind(Table, Key, Modifiers, BindTarget)

	-- Attempt to map the input key and validate it.
	local RealKey = Bind_KeyToKeyCode(Key);
	
	-- Check if the key failed to map.
	if(RealKey == -1) then
	
		Log("Failed to map input key (" .. Key .. ") to valid keyboard key.");
		
		return;
	
	end
	
	local KeyModifiers = Modifiers;
	
	-- Check if the modifiers is a single number or string
	if(KeyModifiers ~= nil and (type(KeyModifiers) == "number" or type(KeyModifiers) == "string")) then
	
		-- Try and map the modifier to a key code.
		local MappedModifierKey = Bind_KeyToKeyCode(KeyModifiers);
		
		-- Check if the key was not mapped.
		if(MappedModifierKey == nil) then
		
			Log("Failed to map input key (" .. KeyModifiers .. ") to valid keyboard key. Aborting bind operation.");
			
			return;
		
		end
		
		-- Set the key modifier table to the mapped key.
		KeyModifiers = { MappedModifierKey };
	
	-- Check if the modifiers passed is a table of modifiers.	
	elseif(KeyModifiers == nil or type(KeyModifiers) == "table") then
	
		-- Remove duplicates from the modifier table.
		local UniqueKeyModifiers = table_unique(KeyModifiers);
		
		-- Clear the key modifier table.
		KeyModifiers = {};
		
		-- Validate each of the items in the table.
		for Index, ModifierKey in ipairs(UniqueKeyModifiers) do
		
			-- Check the table value is not null.
			if(ModifierKey == nil) then
			
				Log("Null key in modifier key table, aborting bind operation.");

				return;
			
			end
		
			-- Try and map the modifier to a key code.
			local MappedModifierKey = Bind_KeyToKeyCode(ModifierKey);
			
			-- Check if the key was not mapped.
			if(MappedModifierKey == nil) then
			
				Log("Failed to map input key (" .. ModifierKey .. ") to valid keyboard key. Aborting bind operation.");
				
				return;
			
			end
			
			-- Append the modifier key to the table.
			table.insert(KeyModifiers, MappedModifierKey);
		
		end
		
	end
	
	-- Make sure the key modifiers are sorted.
	if(KeyModifiers ~= nil) then
	
		-- Sort the table.
		table.sort(KeyModifiers);
	
	end
	
	-- Ensure there is a table for the key.
	if(BindTarget ~= nil) then
	
		-- Check if the table is not yet created.
		if(Table[RealKey] == nil) then
		
			-- Create the table.
			Table[RealKey] = {};
			
		end
		
	end

	-- Set the bind.
	if(BindTarget == nil or type(BindTarget) == "string" or type(BindTarget) == "function") then

		local UpdatedBind = false;
		
		-- Search the current binds for the key.
		for Index, BindData in ipairs(Table[RealKey]) do
		
			-- Compare the modifiers for the key.
			if(table_compare_sorted(BindData.Modifiers, KeyModifiers)) then
			
				-- Update the bind target.
				BindData.Target = BindTarget;
				
				-- Track that the bind was updated.
				UpdatedBind = true;			
				
				break;
				
			end
		
		end
		
		-- Check if the bind wasn't updated.
		if(UpdatedBind == false) then
		
			-- Create the bind data.
			table.insert(Table[RealKey], { Modifiers = KeyModifiers, Target = BindTarget });
		
		end
		
		-- Update and sort the binds for the key for priority.
		table.sort(Table[RealKey], CompareBindData);
		
	end
	
end

-- Bind key down function
function BindKeyDown(Key, Modifiers, BindTarget)

	Bind_InternalBind(Bind_KeyDownMap, Key, Modifiers, BindTarget);

end

-- Unbind key down function
function UnbindKeyDown(Key, Modifiers)

	BindKeyDown(Key, Modifiers, nil);

end

-- Bind key up function
function BindKeyUp(Key, Modifiers, BindTarget)

	Bind_InternalBind(Bind_KeyUpMap, Key, Modifiers, BindTarget);

end

-- Unbind key up function
function UnbindKeyUp(Key, Modifiers)

	BindKeyUp(Key, Modifiers, nil);

end

-- Bind key down pre-UI function
function BindKeyDownPreUI(Key, Modifiers, BindTarget)

	Bind_InternalBind(Bind_KeyDownPreUIMap, Key, Modifiers, BindTarget);

end

-- Unbind key down pre-UI function
function UnbindKeyDownPreUI(Key, Modifiers)

	BindKeyDownPreUI(Key, Modifiers, nil);

end

-- Bind key up pre-UI function
function BindKeyUpPreUI(Key, Modifiers, BindTarget)

	Bind_InternalBind(Bind_KeyUpPreUIMap, Key, Modifiers, BindTarget);

end

-- Bind key up pre-UI function
function UnbindKeyUpPreUI(Key, Modifiers)

	BindKeyUpPreUI(Key, Modifiers, nil);

end

-- Connect to script initialization event.
Bind_InitializeScriptConnection = CFFXiHook.Instance():GetOnInitializeScript():Connect(Bind_OnInitializeScript);

-- Connect to script finalization event.
Bind_FinalizeScriptConnection = CFFXiHook.Instance():GetOnFinalizeScript():Connect(Bind_OnFinalizeScript);