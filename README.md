# LoYaL UI

A clean, modern, mobile-friendly UI library for Roblox scripts. Build a full hub with tabs, sections, toggles, sliders, dropdowns and more in just a few lines, with a built-in Settings tab for themes, configs and custom backgrounds.

> **Note:** A full recode is planned for the future, with a cleaner, more modern UI and more readable code.

---

## Installation

```lua
local LoYaL_UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LoYaLClan/LoYaLs-Library/refs/heads/main/Library.luau"))()
```

---

## Quick Start

```lua
local LoYaL_UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LoYaLClan/LoYaLs-Library/refs/heads/main/Library.luau"))()

-- Create the window
local Window = LoYaL_UI:CreateWindow({
    Title = "My Hub",
    Description = "My First Roblox Script",
    ["Tab Width"] = 120,
    SizeUi = UDim2.fromOffset(550, 315),
    Config = "MyConfig",
    Key = "YOUR_KEY_HERE"
})

-- Create a tab and a section
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "rbxassetid://123456789"
})

local MainSection = MainTab:AddSection("Main Features", true)

-- Add elements
MainSection:AddButton({
    Title = "Test Button",
    Content = "Click this button to test the UI.",
    Callback = function()
        LoYaL_UI:SetNotification({
            Title = "Button",
            Description = "My Hub",
            Content = "The test button was clicked!",
            Time = 0.5,
            Delay = 2
        })
    end
})
```

---

## Window

| Option | Type | Description |
| --- | --- | --- |
| `Title` | string | Main title in the top bar |
| `Description` | string | Accent-colored text next to the title |
| `Tab Width` | number | Width of the left tab list |
| `SizeUi` | UDim2 | Window size |
| `Config` | string | Config name for the hub |
| `Key` | string | Required key. A wrong key returns an empty stub and no UI is built |

---

## Tabs and Sections

```lua
local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "rbxassetid://123456789"
})

-- Second argument: true = starts expanded, false = starts collapsed
local Section = Tab:AddSection("Main Features", true)
```

Elements can be added to a **section** (collapsible) or directly to a **tab**.

---

## Elements

### Paragraph
```lua
Section:AddParagraph({
    Title = "Welcome!",
    Content = "Some text."
})
```

### Button
```lua
Section:AddButton({
    Title = "Button",
    Content = "Description.",
    Callback = function()
        -- Runs on click
    end
})
```

### Toggle
```lua
local Toggle = Section:AddToggle({
    Title = "Toggle",
    Content = "Turn this on or off.",
    Default = false,
    SaveConfig = true,
    Callback = function(Value)
        -- Value = true / false
    end
})
```

### Slider
```lua
local Slider = Section:AddSlider({
    Title = "Slider",
    Content = "Choose a value.",
    Increment = 1,
    Min = 0,
    Max = 100,
    Default = 50,
    SaveConfig = true,
    Callback = function(Value)
        -- Value = current number
    end
})
```

### Input
```lua
local Input = Section:AddInput({
    Title = "Input",
    Content = "Enter some text.",
    Default = "",
    SaveConfig = true,
    Callback = function(Value)
        -- Value = typed text
    end
})
```

### Dropdown
```lua
local Dropdown = Section:AddDropdown({
    Title = "Dropdown",
    Content = "Choose an option.",
    Multi = false,
    Options = { "Option 1", "Option 2", "Option 3" },
    Default = { "Option 1" },
    SaveConfig = true,
    Callback = function(Value)
        local Selected = Value[1]
    end
})
```

| Option | Description |
| --- | --- |
| `Options` | List of choices. Add another string to add a choice |
| `Default` | Table of selected choice(s). Each must exist in `Options` |
| `Multi` | `false` = one choice, `true` = multiple choices |
| `Callback` | Receives a **table** of the selected choice(s) |

**Changing a dropdown after creation**

```lua
Dropdown:SetOptions({ "A", "B" })       -- Replace all options (clears selection)
Dropdown:Refresh({ "A", "B" }, { "A" }) -- Replace options and set the selection
Dropdown:AddOption("C")                 -- Add one option
Dropdown:Clear()                        -- Remove all options
Dropdown:Set({ "B" })                   -- Change the selected choice
```

### Separator and Line
```lua
Section:AddSeperator({ Title = "Advanced" })
Section:AddLine()
```

---

## Notifications

```lua
LoYaL_UI:SetNotification({
    Title = "Title",
    Description = "Description",
    Content = "Notification text.",
    Time = 0.5,  -- Slide animation length (seconds)
    Delay = 3    -- How long it stays visible (seconds)
})
```

> `SetNotification` waits for its `Delay` before returning, so keep it last in your script when possible.

---

## Configs

Elements with `SaveConfig = true` are stored by the built-in **Settings** tab (save, load, delete, auto-save and auto-load).

> Configs are saved by element `Title`, so every element needs a **unique title**.

---

## Credits

Created by **Havoc**.
Continued by **Faith**.

---

## License

Released under the [MIT License](LICENSE).
