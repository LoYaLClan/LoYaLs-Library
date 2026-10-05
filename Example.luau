-- Load the UI library
local LoYaL_UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LoYaLClan/LoYaLs-Library/refs/heads/main/Library.luau"))()


-- Create the main window
-- Key is required: with a wrong key the library returns an empty stub and no UI is built
local Window = LoYaL_UI:CreateWindow({
    Title = "My Hub",                       -- Main title shown in the top bar
    Description = "My First Roblox Script", -- Accent-colored text next to the title
    ["Tab Width"] = 120,                    -- Width of the left tab list
    SizeUi = UDim2.fromOffset(550, 315),    -- Window size
    Config = "MyConfig",                    -- Config name for this hub
    Key = "kF9Q2R7A6vM4JdPZyXb0mC5nL8sHqE1T3wUoGrIYxKWSVtBeN4yD6J0E5T2PZbCqA7HMWLXv1rVFtQmGUYw3xIOeB9sK8RA2D7M_P5E4RZ0C2W1L8F3H6TBYDVGJNKISUOQX9AR7MP5"
})

-- Create a tab (appears in the left tab list)
local MainTab = Window:CreateTab({
    Name = "Main",                    -- Tab name
    Icon = "rbxassetid://123456789"   -- Tab icon (asset id)
})

-- Create a collapsible section inside the tab
-- Second argument: true = starts expanded, false = starts collapsed
local MainSection = MainTab:AddSection(
    "Main Features",
    true
)

-- Paragraph: static text block
MainSection:AddParagraph({
    Title = "Welcome!",
    Content = "Welcome to my first script using the LoYaL UI library."
})

-- Button: runs the Callback every time it is clicked
MainSection:AddButton({
    Title = "Test Button",
    Content = "Click this button to test the UI.",
    Callback = function()
        -- Put your button code here

        -- Notification: Time = slide animation (seconds), Delay = how long it stays visible
        LoYaL_UI:SetNotification({
            Title = "Button",
            Description = "My Hub",
            Content = "The test button was clicked!",
            Time = 0.5,
            Delay = 2
        })
    end
})

-- Toggle: on/off switch, Callback receives true/false
-- SaveConfig = true: value is stored by the Settings tab config system
-- NOTE: configs are saved by Title, so every element Title must be unique
-- NOTE: Callback also runs once on creation with the Default value
local TestToggle = MainSection:AddToggle({
    Title = "Test Toggle",
    Content = "Turn this feature on or off.",
    Default = false,
    SaveConfig = true,
    Callback = function(Value)
        if Value then
            -- Code to run when the toggle is turned ON

            LoYaL_UI:SetNotification({
                Title = "Toggle",
                Description = "My Hub",
                Content = "Toggle enabled.",
                Time = 0.5,
                Delay = 2
            })
        else
            -- Code to run when the toggle is turned OFF

            LoYaL_UI:SetNotification({
                Title = "Toggle",
                Description = "My Hub",
                Content = "Toggle disabled.",
                Time = 0.5,
                Delay = 2
            })
        end
    end
})

-- Slider: pick a number between Min and Max (snaps to Increment)
local TestSlider = MainSection:AddSlider({
    Title = "Test Slider",
    Content = "Choose a value from 0 to 100.",
    Increment = 1,   -- Step size
    Min = 0,
    Max = 100,
    Default = 50,
    SaveConfig = true,
    Callback = function(Value)
        -- Value = current slider number
    end
})

--[[
    Dropdown guide
    --------------
    Options  = list of choices. To add a choice, add another string to the list:
               Options = { "Option 1", "Option 2", "Option 3", "Option 4" }
    Default  = TABLE of selected choice(s), each one must exist in Options
    Multi    = false -> one choice at a time, true -> several can be selected
    Callback = receives a TABLE of the selected choice(s)
               single select: Value[1] is the choice
               multi select:  loop over Value (for _, v in ipairs(Value) do ... end)

    Changing a dropdown after creation:
        TestDropdown:SetOptions({ "A", "B" })       -- replace all options (clears selection)
        TestDropdown:Refresh({ "A", "B" }, { "A" }) -- replace options AND set the selection
        TestDropdown:AddOption("C")                 -- add one option
        TestDropdown:Clear()                        -- remove all options
        TestDropdown:Set({ "B" })                   -- change the selected choice
]]
local TestDropdown = MainSection:AddDropdown({
    Title = "Test Dropdown",
    Content = "Choose an option.",
    Multi = false,
    Options = {
        "Option 1",
        "Option 2",
        "Option 3"
    },
    Default = {
        "Option 1"
    },
    SaveConfig = true,
    Callback = function(Value)
        if Value and Value[1] then
            local Selected = Value[1] -- The chosen option (string)
            -- Code to run with the selected option
        end
    end
})

-- Input: text box, Callback runs when the box loses focus
local TestInput = MainSection:AddInput({
    Title = "Test Input",
    Content = "Enter some text.",
    Default = "",
    SaveConfig = true,
    Callback = function(Value)
        -- Value = the text the user typed
    end
})

-- Separator: titled divider bar between items
MainSection:AddSeperator({
    Title = "Advanced"
})

-- Line: thin divider line
MainSection:AddLine()

-- Second tab
local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "rbxassetid://123456789"
})

local PlayerSection = PlayerTab:AddSection(
    "Player Settings",
    true
)

-- WalkSpeed slider: applies the value to the local player's Humanoid
local SpeedSlider = PlayerSection:AddSlider({
    Title = "WalkSpeed",
    Content = "Select a WalkSpeed value.",
    Increment = 1,
    Min = 16,
    Max = 100,
    Default = 16,
    SaveConfig = true,
    Callback = function(Value)
        local Player = game:GetService("Players").LocalPlayer
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        -- Only apply if the character is loaded
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
})

-- Example toggle: replace the comments with your own feature code
local PlayerToggle = PlayerSection:AddToggle({
    Title = "Example Feature",
    Content = "Enable or disable your feature.",
    Default = false,
    SaveConfig = true,
    Callback = function(Value)
        if Value then
            -- Feature enabled
        else
            -- Feature disabled
        end
    end
})

PlayerSection:AddParagraph({
    Title = "How This Works",
    Content =
        "The controls above only create the UI. " ..
        "Your actual Roblox functionality goes inside " ..
        "the Callback functions."
})

-- Example dropdown: run different code depending on the selected option
local PlayerDropdown = PlayerSection:AddDropdown({
    Title = "Example Selection",
    Content = "Select a player option.",
    Multi = false,
    Options = {
        "Option A",
        "Option B",
        "Option C"
    },
    Default = {
        "Option A"
    },
    SaveConfig = true,
    Callback = function(Value)
        local Selected = Value[1]

        if Selected == "Option A" then
            -- Code for Option A
        elseif Selected == "Option B" then
            -- Code for Option B
        elseif Selected == "Option C" then
            -- Code for Option C
        end
    end
})

-- Replace the dropdown's options after creation (this also clears the selection)
PlayerDropdown:SetOptions({
    "New Option 1",
    "New Option 2",
    "New Option 3"
})

-- Loaded notification (keep last: SetNotification waits for its Delay before returning)
LoYaL_UI:SetNotification({
    Title = "My Hub",
    Description = "Loaded",
    Content = "The UI has finished loading!",
    Time = 0.5,
    Delay = 3
})
