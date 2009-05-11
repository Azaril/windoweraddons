require("common\\utility");

-- Load the UI scheme file.
CEGUI.SchemeManager:getSingleton():loadScheme("Windower.scheme");

-- Set the mouse pointer.
CEGUI.System:getSingleton():setDefaultMouseCursor("Windower", "MouseArrow");

-- Hide the mouse cursor.
CEGUI.MouseCursor:getSingleton():hide();

-- Create the root window.
RootWindow = CEGUI.WindowManager:getSingleton():createWindow("DefaultWindow", "Root");

-- Set the root window.
CEGUI.System:getSingleton():setGUISheet(RootWindow);

-- Set the Tooltip type
CEGUI.System:getSingleton():setDefaultTooltip("Windower/Tooltip");

TopWindow_WindowList = { };

-- Create the top root window.
TopRootWindow = CEGUI.WindowManager:getSingleton():createWindow("DefaultWindow", "TopRootWindow");

-- Make the window transparent.
TopRootWindow:setAlpha(0);

-- Enable mouse pass through for the window.
TopRootWindow:setMousePassThroughEnabled(true);

-- Set the window size to 0 height and full width.
TopRootWindow:setSize(CEGUI.UVector2(CEGUI.UDim(1, 0), CEGUI.UDim(0, 0)));

-- Add the top root window to the desktop.
RootWindow:addChildWindow(TopRootWindow);

function RearrangeTopWindows()

    local PositionX = CEGUI.UDim(0, 0);
    local PositionY = CEGUI.UDim(0, 0);
    local Width = CEGUI.UDim(1, 0);
    local Height = CEGUI.UDim(0, 0);
    
    for i, Window in ipairs(TopWindow_WindowList) do
    
        Window:setPosition(CEGUI.UVector2(PositionX, PositionY));
                
        local WindowHeight = Window:getHeight();
        PositionY = PositionY + WindowHeight;
        Height = Height + WindowHeight;
    
    end
    
    TopRootWindow:setSize(CEGUI.UVector2(Width, Height));

end

-- Add a window to the top of the window.
function AddTopWindow(Window, InsertPosition)

    if(Window ~= nil) then
    
        TopRootWindow:addChildWindow(Window);
        
        if(InsertPosition ~= nil) then
            table.insert(TopWindow_WindowList, InsertPosition, Window);
        else
            table.insert(TopWindow_WindowList, Window);
        end       
        
        RearrangeTopWindows();
    
    end

end

function RemoveTopWindow(Window)

    if(Window ~= nil) then
    
        TopRootWindow:removeChildWindow(Window);
        
        for i, v in ipairs(TopWindow_WindowList) do
        
            if(v == Window) then
            
                table.remove(TopWindow_WindowList, i);
                
                break;
            
            end
        
        end
        
        RearrangeTopWindow();
    
    end

end

-- Title used for the game window.
UI_NormalTitle = "FINAL FANTASY XI";

-- Handler for the local player being created.
function UI_OnLocalPlayerCreated(Player)

	-- Get the local players name.
	local PlayerName = Player:GetName();

	-- Set the window title.
	CFFXiHook.Instance():SetWindowTitle(PlayerName .. " - " .. UI_NormalTitle);

end

-- Handle for leaving a zone.
function UI_OnExitZone()

	-- Set the window title.
	CFFXiHook.Instance():SetWindowTitle(UI_NormalTitle);
	
end

-- Handler for the mouse moving
function UI_OnMouseMove(X, Y)

	-- Check if the cursor is over an actual window and not the root window.
	if(CFFXiHook.Instance():GetUIManager():IsCursorOverWindow()) then
		-- Show the cursor.
		CEGUI.MouseCursor:getSingleton():show();	
	else
		-- Hide the cursor.
		CEGUI.MouseCursor:getSingleton():hide();	
	end
	
	return false;
	
end

-- UI command handler.
function UI_OnCommand(CommandData)

	local Handled = false;

	-- Get the command string.
	local Command = CommandData:GetCommand();
	
	if(Command:lower() == "showborder") then
	
		CFFXiHook.Instance():ShowWindowBorders();
	
		Handled = true;
	
	elseif(Command:lower() == "hideborder") then
	
		CFFXiHook.Instance():HideWindowBorders();
	
		Handled = true;
			
	end
	
	return Handled;

end

-- Handle initialization for script state.
function UI_OnInitializeScript()

	Log("Initializing user interface script...");
	
	-- Connect command handler.
	UI_OnCommandConnection = CFFXiHook.Instance():GetConsole():GetOnCommand():Connect(UI_OnCommand);	

	-- Connect to mouse move events.
	UI_OnMouseMoveConnection = CFFXiHook.Instance():GetUIManager():GetOnMouseMove():Connect(UI_OnMouseMove);	
	
	-- Connect to player created events.
	UI_OnLocalPlayerCreatedConnection = CFFXiHook.Instance():GetGameStateManager():GetOnLocalPlayerCreated():Connect(UI_OnLocalPlayerCreated);
	
	-- Connect to zone exit events.
	UI_OnExitZoneConnection = CFFXiHook.Instance():GetGameStateManager():GetOnExitZone():Connect(UI_OnExitZone);
	
	Log("[Complete]");
	
end

-- Handle finalization of script state.
function UI_OnFinalizeScript()

	-- Disconnect from the exit zone event.
	DisconnectConnection(UI_OnExitZoneConnection);

	-- Disconnect the player created event.
	DisconnectConnection(UI_OnLocalPlayerCreatedConnection);

	-- Disconnect mouse move event.
	DisconnectConnection(UI_OnMouseMoveConnection);
	
	-- Disconnect command event.
	DisconnectConnection(UI_OnCommandConnection);

	-- Disconnect script initialization event.
	DisconnectConnection(UI_InitializeScriptConnection);
	
	-- Disconnect script finalization event.
	DisconnectConnection(UI_FinalizeScriptConnection);
	
end

-- Connect to script initialization event.
UI_InitializeScriptConnection = CFFXiHook.Instance():GetOnInitializeScript():Connect(UI_OnInitializeScript);

-- Connect to script finalization event.
UI_FinalizeScriptConnection = CFFXiHook.Instance():GetOnFinalizeScript():Connect(UI_OnFinalizeScript);