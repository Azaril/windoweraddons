require("common\\common");

--
-- Register console resource folder.
--
AddResourceGroupDirectory("ConsoleResources", GetAddonDirectoryPath("console"));

-- Visiblity of the console.
Console_Showing = false;

-- Current history item index.
Console_CurrentHistoryItem = nil;

-- Create history buffer.
Console_HistoryBuffer = { };

-- Maximum number of commands to be stored in the history buffer.
Console_MaxHistoryBufferSize = 1000;

-- Handler for text being entered.
function Console_OnTextAccepted(Args)

	-- Get a pointer to the input edit box.
	local InputWindow = this:getWindow();
	
	-- Retrieve the text from the edit box.
	local InputString = InputWindow:getText();
	
	-- Check there is a command to input.
	if(string.len(InputString) > 0) then
		
		-- Clear the input field.
		InputWindow:setText("");
		
		-- Clear the history index.
		Console_CurrentHistoryItem = nil;
		
		-- Add the text to the history buffer.
		table.insert(Console_HistoryBuffer, InputString);
		
		-- Check the history buffer isn't getting too big.
		if(#Console_HistoryBuffer > Console_MaxHistoryBufferSize) then
			table.remove(Console_HistoryBuffer, 1);
		end
	
		-- Add the text to the log.
		CFFXiHook.Instance():GetConsole():AddTextToLog(InputString);
	
		-- Handle the command input.
		CFFXiHook.Instance():GetConsole():RunCommand(InputString);
		
	end
	
	return true;

end

-- Get a text item to be inserted in to the history.
function Console_GetNextTextItem(Text)

	-- Check if the maximum item limit has been reached.
	if(Console_HistoryList:getItemCount() < 100) then
	
		-- Create a new text box.
		return CEGUI.createListboxTextItem(Text);
		
	else
	
		-- Remove the oldest text from the history.
		local TextItem = Console_HistoryList:getListboxItemFromIndex(0);		
		
		-- Make sure the item doesn't get deleted when it's removed.
		TextItem:setAutoDeleted(false);
		
		-- Remove the item from the history.
		Console_HistoryList:removeItem(TextItem);
		
		-- Enable the item being cleaned up.
		TextItem:setAutoDeleted(true);
		
		-- Set the text on the item.
		TextItem:setText(Text);		
		
		-- Return the recycled item.
		return TextItem;
		
	end
	
end

-- Set the input buffer to a history item.
function Console_SetInputToHistory(Index)

	-- Get the current count of items in the history buffer.
	local CurrentItemCount = #Console_HistoryBuffer;

	-- Check the request index is in range.
	if(Index >= 1 and Index <= CurrentItemCount) then
	
		local HistoryText = Console_HistoryBuffer[Index];
	
		-- Set the text on the input buffer.
		Console_Input:setText(HistoryText);
		
		-- Move the carat to the end of the text.
		Console_Input:setCaratIndex(#HistoryText);
		
	end
		
end

-- Set the input text to the previous history item.
function Console_MoveHistoryPreviousInput()

	-- Get the current history count.
	local CurrentItemCount = #Console_HistoryBuffer;

	-- Check there are items in the history.
	if(CurrentItemCount > 0) then
	
		-- Check if the current history index is set.
		if(Console_CurrentHistoryItem ~= nil) then
		
			-- Decrement the index.
			Console_CurrentHistoryItem = Console_CurrentHistoryItem - 1;
			
		else
		
			-- Set the index to the last entered item in the history.
			Console_CurrentHistoryItem = CurrentItemCount;
			
		end
		
		-- The history is circular buffer so go to the newest item if moving before the last item.
		if(Console_CurrentHistoryItem < 1) then
		
			-- Update the index to loop.
			Console_CurrentHistoryItem = Console_CurrentHistoryItem + CurrentItemCount;
			
		end		
		
		-- Update the input buffer.
		Console_SetInputToHistory(Console_CurrentHistoryItem);		
		
	end

end

-- Set the input text to the next history item.
function Console_MoveHistoryNextInput()

	-- Get the current history count.
	local CurrentItemCount = #Console_HistoryBuffer;

	-- Check there are items in the history.
	if(CurrentItemCount > 0) then
	
		-- Check if the current history index is set.
		if(Console_CurrentHistoryItem ~= nil) then
		
			-- Increment the index.
			Console_CurrentHistoryItem = Console_CurrentHistoryItem + 1;
			
		else
		
			-- Set the index to the first entered item in the history.
			Console_CurrentHistoryItem = 1;
			
		end
		
		-- The history is circular buffer so go to the oldest item if moving before the first item.
		if(Console_CurrentHistoryItem > CurrentItemCount) then
		
			-- Update the index to loop.
			Console_CurrentHistoryItem = Console_CurrentHistoryItem - CurrentItemCount;
			
		end		
		
		-- Update the input buffer.
		Console_SetInputToHistory(Console_CurrentHistoryItem);
		
	end

end

-- Handler for the edit box getting a key down.
function Console_EditBoxOnKeyDown(Args)

	local Handled = false;
	
	-- Convert the arguments to the correct event arguments.
	local KeyEvent = CEGUI.toKeyEventArgs(Args);

	-- Check for up arrow.
	if(KeyEvent.scancode == Key.Up) then
	
		-- Move to the previous input in the history buffer.
		Console_MoveHistoryPreviousInput();
		
		-- Consume the key.
		Handled = true;
		
	-- Check for down arrow.
	elseif(KeyEvent.scancode == Key.Down) then
	
		-- Move to the next input in the history buffer.
		Console_MoveHistoryNextInput();
		
		-- Consume the key.
		Handled = true;
	
	-- Check for page up.
	elseif(KeyEvent.scancode == Key.PageUp) then
	
		-- Get the vertical scroll bar.
		local VerticalScrollbar = Console_HistoryList:getVertScrollbar();
		
		-- Check there is a scroll bar active.
		if(VerticalScrollbar ~= nil) then
		
			-- Update the scroll position.
			VerticalScrollbar:setScrollPosition(VerticalScrollbar:getScrollPosition() - VerticalScrollbar:getPageSize());
		
		end
		
		-- Consume the key.
		Handled = true;
	
	-- Check for page down.
	elseif(KeyEvent.scancode == Key.PageDown) then
	
		-- Get the vertical scroll bar.
		local VerticalScrollbar = Console_HistoryList:getVertScrollbar();
		
		-- Check there is a scroll bar active.
		if(VerticalScrollbar ~= nil) then
		
			-- Update the scroll position.
			VerticalScrollbar:setScrollPosition(VerticalScrollbar:getScrollPosition() + VerticalScrollbar:getPageSize());
		
		end
		
		-- Consume the key.
		Handled = true;	
	
	end
	
	return Handled;

end

-- Handler for console output.
function Console_AddToConsole(Text)

	-- Get a new text item.
	local TextItem = Console_GetNextTextItem(Text);
	
	-- Add the new text.
	Console_HistoryList:addItem(TextItem);
		
	-- Ensure that the new text is visible.
	Console_HistoryList:ensureItemIsVisible(Console_HistoryList:getItemCount());
	
end

-- Toggle the visibility of the console.
function Console_Toggle()

	-- Flip the visibility of the console.
	Console_SetVisibility(not Console_Showing);

end

-- Set the visibility of the console window
function Console_SetVisibility(Show)

	-- Cache the visibility of the console.
	Console_Showing = Show;

	-- Check if the console needs to be shown or hidden.
	if(Console_Showing == true) then
	
		-- Show the console.
		Console_Root:setVisible(true);
		
		-- Disable mouse pass through for the console.
		Console_Root:setMousePassThroughEnabled(false);
		
		-- Active the input box.
		Console_Input:activate();
			
	else
	
		-- Hide the console.
		Console_Root:setVisible(false);
		
		-- Enable mouse pass through for the console.
		Console_Root:setMousePassThroughEnabled(true);
		
		-- Deactivate the input box.
		Console_Root:deactivate();
				
	end
	
end

-- Console key handler.
function Console_OnKeyDown(ScanCode)
	
	return false;
	
end

-- Console chat input handler.
function Console_OnChatInput(Text)

	-- Check if the command starts with "//"
	if(#Text >= 2 and Text:sub(1, 2) == "//") then
	
		-- Run the command minus the prefix.
		CFFXiHook.Instance():GetConsole():RunCommand(Text:sub(3));
		
		return true;
		
	end

	return false;

end

-- Handle initialization for script state.
function Console_OnInitializeScript()

	Log("Initializing console script...");

	-- Create single instance of console window.
	Console_Root = CEGUI.WindowManager:getSingleton():loadWindowLayout("Console.layout", "", "ConsoleResources");

	-- Get the input window for the console.
	Console_Input = Console_Root:getChild("Console/Editbox"):toEditbox();

	-- Get the history window for the console.
	Console_HistoryList = Console_Root:getChild("Console/HistoryList"):toListbox();
	
	-- Connect to the event for key down.
	Console_EditBoxOnKeyDownConnection = Console_Input:subscribeEvent("KeyDown", "Console_EditBoxOnKeyDown");

	-- Connect to event for text being entered.
	Console_OnTextAcceptedConnection = Console_Input:subscribeEvent("TextAccepted", "Console_OnTextAccepted");

	-- Add window to the top of the screen.
	AddTopWindow(Console_Root);

	-- Hide the console.
	Console_SetVisibility(false);

	-- Connect to console output.
	Console_OnTextAddedConnection = CFFXiHook.Instance():GetConsole():GetOnTextAdded():Connect(Console_AddToConsole);
	
	-- Connect to key events.
	Console_OnKeyDownConnection = CFFXiHook.Instance():GetUIManager():GetOnKeyDownPreUI():Connect(Console_OnKeyDown);	
	
	-- Connect to chat text entry.
	Console_OnChatInput = CFFXiHook.Instance():GetGameHooks():GetOnInput():Connect(Console_OnChatInput);
	
	Log("[Complete]");
	
end

-- Handle finalization of script state.
function Console_OnFinalizeScript()

	-- Disconnect CEGUI events.
	DisconnectCEGUIConnection(Console_EditBoxOnKeyDownConnection);
	DisconnectCEGUIConnection(Console_OnTextAcceptedConnection);

	-- Disconnect from key events.
	DisconnectConnection(Console_OnKeyDownConnection);

	-- Disconnect from console output.
	DisconnectConnection(Console_OnTextAddedConnection);
	
	-- Disconnect from chat text entry.
	DisconnectConnection(Console_OnChatInput);
	
	-- Disconnect script initialization event.
	DisconnectConnection(Console_InitializeScriptConnection);
	
	-- Disconnect script finalization event.
	DisconnectConnection(Console_FinalizeScriptConnection);	
	
end

-- Connect to script initialization event.
Console_InitializeScriptConnection = CFFXiHook.Instance():GetOnInitializeScript():Connect(Console_OnInitializeScript);

-- Connect to script finalization event.
Console_FinalizeScriptConnection = CFFXiHook.Instance():GetOnFinalizeScript():Connect(Console_OnFinalizeScript);