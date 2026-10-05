local Global_AddParagraph = nil
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local Custom = {}
do
    Custom.ColorRGB = Color3.fromRGB(138, 43, 226)
    Custom.AccentElements = {}
    Custom.ConditionalAccentCallbacks = {}
    Custom.ConfigElements = {}
    Custom.AutoSaveEnabled = false
    Custom.AutoLoadEnabled = false
    Custom.AutoLoadConfigName = "default"
    Custom.ConfigFolder = "1NFERNO-HUB/"
    Custom.ConfigFileName = "1NFERNO-HUB/1NFERNO-Config.json"
    Custom.ImageFolder = "1NFERNO-HUB/Images/"
    Custom.VideoFolder = "1NFERNO-HUB/Videos/"
    Custom.SettingsFile = "1NFERNO-HUB/settings.json"
    Custom.CurrentBackgroundImage = nil
    Custom.CurrentBackgroundVideo = nil
    Custom.BackgroundType = "none"
    Custom.BackgroundEnabled = false

    function Custom:RegisterAccentElement(element, propertyName)
        table.insert(self.AccentElements, {Element = element, Property = propertyName})
    end

    function Custom:RegisterConditionalAccent(callback)
        table.insert(self.ConditionalAccentCallbacks, callback)
    end

    function Custom:RegisterConfigElement(elementName, elementType, getValue, setValue, saveEnabled)
        self.ConfigElements[elementName] = {
            Type = elementType,
            GetValue = getValue,
            SetValue = setValue,
            SaveEnabled = saveEnabled ~= false
        }
    end

    function Custom:SetConfigSaveEnabled(elementName, enabled)
        if self.ConfigElements[elementName] then
            self.ConfigElements[elementName].SaveEnabled = enabled
        end
    end

    function Custom:SaveConfig()
        local config = {}
        for name, data in pairs(self.ConfigElements) do
            if data.SaveEnabled then
                config[name] = {
                    Type = data.Type,
                    Value = data.GetValue()
                }
            end
        end

        local success, result =
            pcall(
            function()
                local HttpService = game:GetService("HttpService")
                local jsonData = HttpService:JSONEncode(config)
                if makefolder and isfolder and not isfolder(Custom.ConfigFolder) then
                    makefolder(Custom.ConfigFolder)
                end
                if writefile then
                    writefile(Custom.ConfigFileName, jsonData)
                end
            end
        )

        return success
    end

    function Custom:LoadConfig()
        local success, result =
            pcall(
            function()
                if isfile and isfile(Custom.ConfigFileName) then
                    local HttpService = game:GetService("HttpService")
                    local jsonData = readfile(Custom.ConfigFileName)
                    local config = HttpService:JSONDecode(jsonData)

                    for name, data in pairs(config) do
                        if Custom.ConfigElements[name] and Custom.ConfigElements[name].SaveEnabled then
                            Custom.ConfigElements[name].SetValue(data.Value)
                        end
                    end
                    return true
                end
                return false
            end
        )

        return success and result
    end

    function Custom:SaveSettings()
        local settings = {
            AutoLoadEnabled = self.AutoLoadEnabled,
            AutoLoadConfigName = self.AutoLoadConfigName,
            CurrentBackgroundImage = self.CurrentBackgroundImage,
            CurrentBackgroundVideo = self.CurrentBackgroundVideo,
            BackgroundType = self.BackgroundType,
            BackgroundEnabled = self.BackgroundEnabled
        }

        pcall(
            function()
                local HttpService = game:GetService("HttpService")
                local jsonData = HttpService:JSONEncode(settings)
                if makefolder and isfolder then
                    if not isfolder(Custom.ConfigFolder) then
                        makefolder(Custom.ConfigFolder)
                    end
                end
                if writefile then
                    writefile(Custom.SettingsFile, jsonData)
                end
            end
        )
    end

    function Custom:LoadSettings()
        local success =
            pcall(
            function()
                if isfile and isfile(Custom.SettingsFile) then
                    local HttpService = game:GetService("HttpService")
                    local jsonData = readfile(Custom.SettingsFile)
                    local settings = HttpService:JSONDecode(jsonData)

                    if settings.AutoLoadEnabled ~= nil then
                        Custom.AutoLoadEnabled = settings.AutoLoadEnabled
                    end
                    if settings.AutoLoadConfigName then
                        Custom.AutoLoadConfigName = settings.AutoLoadConfigName
                    end
                    if settings.CurrentBackgroundImage then
                        Custom.CurrentBackgroundImage = settings.CurrentBackgroundImage
                    end
                    if settings.CurrentBackgroundVideo then
                        Custom.CurrentBackgroundVideo = settings.CurrentBackgroundVideo
                    end
                    if settings.BackgroundType then
                        Custom.BackgroundType = settings.BackgroundType
                    end
                    if settings.BackgroundEnabled ~= nil then
                        Custom.BackgroundEnabled = settings.BackgroundEnabled
                    end
                end
            end
        )
        return success
    end

    function Custom:DownloadImage(url, fileName)
        local success, result =
            pcall(
            function()
                if makefolder and isfolder then
                    if not isfolder(Custom.ConfigFolder) then
                        makefolder(Custom.ConfigFolder)
                    end
                    if not isfolder(Custom.ImageFolder) then
                        makefolder(Custom.ImageFolder)
                    end
                end

                local imageData = game:HttpGet(url)
                local filePath = Custom.ImageFolder .. fileName

                if writefile then
                    writefile(filePath, imageData)
                end

                return filePath
            end
        )

        return success, result
    end

    function Custom:DownloadVideo(url, fileName)
        local success, result =
            pcall(
            function()
                if makefolder and isfolder then
                    if not isfolder(Custom.ConfigFolder) then
                        makefolder(Custom.ConfigFolder)
                    end
                    if not isfolder(Custom.VideoFolder) then
                        makefolder(Custom.VideoFolder)
                    end
                end

                local videoData = game:HttpGet(url)
                local filePath = Custom.VideoFolder .. fileName

                if writefile then
                    writefile(filePath, videoData)
                end

                return filePath
            end
        )

        return success, result
    end

    function Custom:GetCustomAsset(filePath)
        if getcustomasset then
            return getcustomasset(filePath)
        elseif getsynasset then
            return getsynasset(filePath)
        end
        return nil
    end

    function Custom:GetLocalImages()
        local images = {}
        if listfiles and isfolder and isfolder(Custom.ImageFolder) then
            local success, files =
                pcall(
                function()
                    return listfiles(Custom.ImageFolder)
                end
            )
            if success and files then
                for _, file in ipairs(files) do
                    local name = file:match("([^/\\]+)$")
                    if name then
                        local ext = name:lower():match("%.([^%.]+)$")
                        if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "gif" or ext == "webp" then
                            local relativePath = Custom.ImageFolder .. name
                            table.insert(images, {Name = name, Path = relativePath})
                        end
                    end
                end
            end
        end
        return images
    end

    function Custom:GetLocalVideos()
        local videos = {}
        if listfiles and isfolder and isfolder(Custom.VideoFolder) then
            local success, files =
                pcall(
                function()
                    return listfiles(Custom.VideoFolder)
                end
            )
            if success and files then
                for _, file in ipairs(files) do
                    local name = file:match("([^/\\]+)$")
                    if name then
                        local ext = name:lower():match("%.([^%.]+)$")
                        if ext == "webm" or ext == "mp4" or ext == "ogg" or ext == "webp" or ext == "gif" then
                            local relativePath = Custom.VideoFolder .. name
                            table.insert(videos, {Name = name, Path = relativePath})
                        end
                    end
                end
            end
        end
        return videos
    end

    function Custom:UpdateAllAccentColors(newColor)
        self.ColorRGB = newColor
        for _, data in ipairs(self.AccentElements) do
            if data.Element and data.Element.Parent then
                if data.Property == "ColorSequence" then
                    data.Element.Color =
                        ColorSequence.new {
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 15)),
                        ColorSequenceKeypoint.new(0.5, newColor),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
                    }
                else
                    data.Element[data.Property] = newColor
                end
            end
        end

        for _, callback in ipairs(self.ConditionalAccentCallbacks) do
            pcall(callback, newColor)
        end

        if self.AutoSaveEnabled then
            self:SaveConfig()
        end
    end

    function Custom:Create(Name, Properties, Parent)
        local _instance = Instance.new(Name)

        for i, v in pairs(Properties) do
            _instance[i] = v
        end

        if Parent then
            _instance.Parent = Parent
        end

        return _instance
    end

    function Custom:EnabledAFK()
        Player.Idled:Connect(
            function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        )
    end

    function Custom:GenNumber(Num)
        local List = {}

        for _ = 1, Num do
            table.insert(List, math.random(0, 9))
        end

        return table.concat(List)
    end

    function Custom:Decryption(Enc)
        local List = {}

        for num in string.gmatch(Enc, "[^,]+") do
            local Ori =
                tonumber(num) - 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 + 9e9 +
                9e9 +
                9e9 +
                9e9 +
                9e9 +
                9e9 +
                9e9 +
                9e9 +
                9e9
            table.insert(List, Ori)
        end

        return tonumber(table.concat(List))
    end
end

local function OpenClose()
    local ScreenGui =
        Custom:Create(
        "ScreenGui",
        {
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        },
        RunService:IsStudio() and Player.PlayerGui or
            (gethui() or cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui"))
    )

    local Close_ImageButton =
        Custom:Create(
        "ImageButton",
        {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(255, 0, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.1021, 0, 0.0743, 0),
            Size = UDim2.new(0, 59, 0, 49),
            Image = "rbxassetid://117199988786180",
            Visible = false
        },
        ScreenGui
    )

    local UICorner =
        Custom:Create(
        "UICorner",
        {
            Name = "MainCorner",
            CornerRadius = UDim.new(0, 9)
        },
        Close_ImageButton
    )

    local dragging, dragStart, startPos = false, nil, nil

    local function UpdateDraggable(input)
        local delta = input.Position - dragStart
        Close_ImageButton.Position =
            UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Close_ImageButton.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Close_ImageButton.Position

                input.Changed:Connect(
                    function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end
                )
            end
        end
    )

    Close_ImageButton.InputChanged:Connect(
        function(input)
            if
                dragging and
                    (input.UserInputType == Enum.UserInputType.MouseMovement or
                        input.UserInputType == Enum.UserInputType.Touch)
             then
                UpdateDraggable(input)
            end
        end
    )

    return Close_ImageButton
end

local Open_Close = OpenClose()

local function MakeDraggable(topbarobject, object)
    local dragging, dragStart, startPos = false, nil, nil

    local function UpdatePos(input)
        local delta = input.Position - dragStart
        local newPos =
            UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        object.Position = newPos
    end

    topbarobject.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = object.Position

                input.Changed:Connect(
                    function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end
                )
            end
        end
    )

    topbarobject.InputChanged:Connect(
        function(input)
            if
                dragging and
                    (input.UserInputType == Enum.UserInputType.MouseMovement or
                        input.UserInputType == Enum.UserInputType.Touch)
             then
                UpdatePos(input)
            end
        end
    )
end

function CircleClick(Button, X, Y)
    task.spawn(
        function()
            Button.ClipsDescendants = true

            local Circle = Instance.new("ImageLabel")
            Circle.Image = "rbxassetid://106471194043211"
            Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
            Circle.ImageTransparency = 0.8999999761581421
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.BackgroundTransparency = 1
            Circle.ZIndex = 10
            Circle.Name = "Circle"
            Circle.Parent = Button

            local NewX = X - Button.AbsolutePosition.X
            local NewY = Y - Button.AbsolutePosition.Y
            Circle.Position = UDim2.new(0, NewX, 0, NewY)

            local Size = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5

            local Time = 0.5
            local TweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            local Tween =
                TweenService:Create(
                Circle,
                TweenInfo,
                {
                    Size = UDim2.new(0, Size, 0, Size),
                    Position = UDim2.new(0.5, -Size / 2, 0.5, -Size / 2)
                }
            )

            Tween:Play()

            Tween.Completed:Connect(
                function()
                    for i = 1, 10 do
                        Circle.ImageTransparency = Circle.ImageTransparency + 0.01
                        wait(Time / 10)
                    end
                    Circle:Destroy()
                end
            )
        end
    )
end

local INFERNO_HUB = {}

INFERNO_HUB.Unloaded = false

function INFERNO_HUB:SetNotification(Config)
    local Notification = {}
    local Title = Config[1] or Config.Title or ""
    local Description = Config[2] or Config.Description or ""
    local Content = Config[3] or Config.Content or ""
    local Time = Config[5] or Config.Time or 0.5
    local Delay = Config[6] or Config.Delay or 5

    local NotificationGui =
        Custom:Create(
        "ScreenGui",
        {
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        },
        RunService:IsStudio() and Player.PlayerGui or
            (gethui() or cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui"))
    )

    local NotificationLayout =
        Custom:Create(
        "Frame",
        {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.999,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(1, -30, 1, -30),
            Size = UDim2.new(0, 320, 1, 0),
            Name = "NotificationLayout"
        },
        NotificationGui
    )

    local Count = 0

    NotificationLayout.ChildRemoved:Connect(
        function()
            Count = 0
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

            for _, v in ipairs(NotificationLayout:GetChildren()) do
                local NewPOS = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count))
                local tween = TweenService:Create(v, tweenInfo, {Position = NewPOS})
                tween:Play()
                Count = Count + 1
            end
        end
    )

    local _Count = 0
    for _, v in ipairs(NotificationLayout:GetChildren()) do
        _Count = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
    end

    local NotificationFrame =
        Custom:Create(
        "Frame",
        {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 150),
            Name = "NotificationFrame",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -(_Count))
        },
        NotificationLayout
    )

    local NotificationFrameReal =
        Custom:Create(
        "Frame",
        {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 400, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Name = "NotificationFrameReal"
        },
        NotificationFrame
    )

    Custom:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 8)
        },
        NotificationFrameReal
    )

    local DropShadowHolder =
        Custom:Create(
        "Frame",
        {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 0,
            Name = "DropShadowHolder",
            Parent = NotificationFrameReal
        }
    )

    local DropShadow =
        Custom:Create(
        "ImageLabel",
        {
            Image = "",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 47, 1, 47),
            ZIndex = 0,
            Name = "DropShadow",
            Parent = DropShadowHolder
        }
    )

    local Top =
        Custom:Create(
        "Frame",
        {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.999,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Name = "Top",
            Parent = NotificationFrameReal
        }
    )

    local TextLabel =
        Custom:Create(
        "TextLabel",
        {
            Font = Enum.Font.GothamBold,
            Text = Title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.999,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = Top
        }
    )

    Custom:Create(
        "UIStroke",
        {
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 0.3,
            Parent = TextLabel
        }
    )

    Custom:Create(
        "UICorner",
        {
            Parent = Top,
            CornerRadius = UDim.new(0, 5)
        }
    )

    local TextLabel1 =
        Custom:Create(
        "TextLabel",
        {
            Font = Enum.Font.GothamBold,
            Text = Description,
            TextColor3 = Custom.ColorRGB,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.999,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Parent = Top
        }
    )

    task.spawn(function()
        while TextLabel1 and TextLabel1.Parent do
            local TargetPos = UDim2.new(0, TextLabel.TextBounds.X + 8, 0, 0)
            TweenService:Create(TextLabel1, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = TargetPos}):Play()
            task.wait(1)
        end
    end)
    Custom:RegisterAccentElement(TextLabel1, "TextColor3")

    local TextLabel1Stroke =
        Custom:Create(
        "UIStroke",
        {
            Color = Custom.ColorRGB,
            Thickness = 0.4,
            Parent = TextLabel1
        }
    )
    Custom:RegisterAccentElement(TextLabel1Stroke, "Color")

    local Close =
        Custom:Create(
        "TextButton",
        {
            Font = Enum.Font.SourceSans,
            Text = "X",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.999,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 25, 0, 25),
            Name = "Close"
        },
        Top
    )

    local TextLabel2 =
        Custom:Create(
        "TextLabel",
        {
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            Text = Content,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.999,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 27),
            Size = UDim2.new(1, -20, 0, 13),
            Parent = NotificationFrameReal
        }
    )

    TextLabel2.Size = UDim2.new(1, -20, 0, 13 + (13 * math.floor(TextLabel2.TextBounds.X / TextLabel2.AbsoluteSize.X)))
    TextLabel2.TextWrapped = true

    if TextLabel2.AbsoluteSize.Y < 27 then
        NotificationFrame.Size = UDim2.new(1, 0, 0, 65)
    else
        NotificationFrame.Size = UDim2.new(1, 0, 0, TextLabel2.AbsoluteSize.Y + 40)
    end

    local Waitted = false

    function Notification:Close()
        if Waitted then
            return false
        end
        Waitted = true

        local tween =
            TweenService:Create(
            NotificationFrameReal,
            TweenInfo.new(tonumber(Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            {Position = UDim2.new(0, 400, 0, 0)}
        )
        tween:Play()

        task.wait(tonumber(Time) / 1.2)

        NotificationFrame:Destroy()

        Waitted = false
    end

    Close.Activated:Connect(
        function()
            Notification:Close()
        end
    )

    TweenService:Create(
        NotificationFrameReal,
        TweenInfo.new(tonumber(Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
        {Position = UDim2.new(0, 0, 0, 0)}
    ):Play()
    task.wait(tonumber(Delay))
    Notification:Close()

    return Notification
end

function INFERNO_HUB:CreateWindow(Config)
local Key1 = "kF9Q2R7A6vM4JdPZ"
local Key2 = "yXb0mC5nL8sHqE1T"
local Key3 = "3wUoGrIYxKWSVtBe"
local Key4 = "N4yD6J0E5T2PZbC"
local Key5 = "qA7HMWLXv1rVFtQm"
local Key6 = "GUYw3xIOeB9sK8R"
local Key7 = "A2D7M_P5E4RZ0C2"
local Key8 = "W1L8F3H6TBYDVGJ"
local Key9 = "NKISUOQX9AR7MP5"


    local Title = Config[1] or Config.Title or ""
    local Description = Config[2] or Config.Description or ""
    local TabWidth = Config[3] or Config["Tab Width"] or 120
    local SizeUi = Config[4] or Config.SizeUi or UDim2.fromOffset(550, 315)
    local DiscordLink = Config.Discord or "discord.gg/1nferno"
    local ConfigFileName = Config.Config or "default"
    local KEY = Config.Key or ""

    if KEY ~= (Key1 .. Key2 .. Key3 .. Key4 .. Key5 .. Key6 .. Key7 .. Key8 .. Key9) then
        return {
            AddTab = function() return { AddSection = function() return { AddButton = function() end, AddToggle = function() end, AddSlider = function() end, AddDropdown = function() end, AddColorpicker = function() end, AddTextbox = function() end, AddLabel = function() end, AddParagraph = function() end } end } end
        }
    end

    Custom:LoadSettings()

    local Funcs = {}

    local InfernoHubGui =
        Custom:Create(
        "ScreenGui",
        {
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        },
        RunService:IsStudio() and Player.PlayerGui or
            (gethui() or cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui"))
    )

    local DropShadowHolder =
        Custom:Create(
        "Frame",
        {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 455, 0, 350),
            ZIndex = 0,
            Name = "DropShadowHolder",
            Position = UDim2.new(
                0,
                (math.floor(InfernoHubGui.AbsoluteSize.X / 2) - math.floor(455 / 2)),
                0,
                (math.floor(InfernoHubGui.AbsoluteSize.Y / 2) - math.floor(350 / 2))
            )
        },
        InfernoHubGui
    )

    local DropShadow =
        Custom:Create(
        "ImageLabel",
        {
            Image = "",
            ImageColor3 = Color3.fromRGB(15, 15, 15),
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = SizeUi,
            ZIndex = 0,
            Name = "DropShadow"
        },
        DropShadowHolder
    )

    local Main =
        Custom:Create(
        "Frame",
        {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            BackgroundTransparency = 0.1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = SizeUi,
            Name = "Main"
        },
        DropShadow
    )

    Custom:Create("UICorner", {}, Main)

    Custom:Create(
        "UIStroke",
        {
            Color = Color3.fromRGB(50, 50, 50),
            Thickness = 1.6
        },
        Main
    )

    local BackgroundGradient =
        Custom:Create(
        "UIGradient",
        {
            Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 15)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
            },
            Rotation = 90,
            Enabled = false,
            Name = "BackgroundGradient"
        },
        Main
    )

    Funcs.Main = Main
    Funcs.BackgroundGradient = BackgroundGradient

    local Top =
        Custom:Create(
        "Frame",
        {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.9990000128746033,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 38),
            Name = "Top"
        },
        Main
    )

    Custom:Create("UICorner", {}, Top)

    local TextLabel =
        Custom:Create(
        "TextLabel",
        {
            Font = Enum.Font.GothamBold,
            Text = Title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.X
        },
        Top
    )

    local TextLabel1 =
        Custom:Create(
        "TextLabel",
        {
            Font = Enum.Font.GothamBold,
            Text = Description,
            TextColor3 = Custom.ColorRGB,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 115, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.X
        },
        Top
    )
    Custom:RegisterAccentElement(TextLabel1, "TextColor3")

    local TextLabel1Stroke =
        Custom:Create(
        "UIStroke",
        {
            Color = Custom.ColorRGB,
            Thickness = 0.4
        },
        TextLabel1
    )
    Custom:RegisterAccentElement(TextLabel1Stroke, "Color")

    local Close =
        Custom:Create(
        "TextButton",
        {
            Font = Enum.Font.GothamBold,
            Text = "X",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 22,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 34, 0, 34),
            Name = "Close"
        },
        Top
    )

    local Min =
        Custom:Create(
        "TextButton",
        {
            Font = Enum.Font.GothamBold,
            Text = "-",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -30, 0.5, 0),
            Size = UDim2.new(0, 34, 0, 34),
            Name = "Min"
        },
        Top
    )

    local TabsVisible = true
    local TabSide = "Left"
    local function UpdateTabLayout()
        if not LayersTab then return end
        local TargetWidth = TabsVisible and TabWidth or 0
        local TargetPos, TargetSize

        if not TabsVisible then
            TargetPos = UDim2.new(0, 9, 0, 50)
            TargetSize = UDim2.new(1, -18, 1, -59)
            LayersTab.Visible = false
        else
            LayersTab.Visible = true
            if TabSide == "Left" then
                LayersTab.Position = UDim2.new(0, 9, 0, 50)
                TargetPos = UDim2.new(0, TabWidth + 18, 0, 50)
                TargetSize = UDim2.new(1, -(TabWidth + 9 + 18), 1, -59)
            else
                LayersTab.Position = UDim2.new(1, -(TabWidth + 9), 0, 50)
                TargetPos = UDim2.new(0, 9, 0, 50)
                TargetSize = UDim2.new(1, -(TabWidth + 9 + 18), 1, -59)
            end
        end

        TweenService:Create(LayersTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, TargetWidth, 1, -59)}):Play()
        if Layers then
            TweenService:Create(Layers, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = TargetPos, Size = TargetSize}):Play()
        end
    end

    local TabToggleBtn =
        Custom:Create(
        "TextButton",
        {
            Font = Enum.Font.SourceSans,
            Text = "≡",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 28,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -105, 0.5, 0),
            Size = UDim2.new(0, 30, 0, 30),
            Name = "TabToggle",
            Visible = false
        },
        Top
    )

    local ResizeHitArea =
        Custom:Create(
        "Frame",
        {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 5, 1, 5),
            Size = UDim2.new(0, 35, 0, 35),
            Name = "ResizeHitArea"
        },
        Main
    )

    local ResizeHandle =
        Custom:Create(
        "Frame",
        {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Custom.ColorRGB,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -5, 1, -5),
            Size = UDim2.new(0, 20, 0, 20),
            Name = "ResizeHandle"
        },
        ResizeHitArea
    )
    Custom:RegisterAccentElement(ResizeHandle, "BackgroundColor3")

    Custom:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 4)
        },
        ResizeHandle
    )

    local ResizeIcon =
        Custom:Create(
        "TextLabel",
        {
            Font = Enum.Font.GothamBold,
            Text = "⋰",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        },
        ResizeHandle
    )

    local ResizeDragging = false
    local ResizeStartPos = nil
    local ResizeStartSize = nil
    local MinSize = Vector2.new(400, 250)

    ResizeHitArea.InputBegan:Connect(
        function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                ResizeDragging = true
                ResizeStartPos = Vector2.new(Input.Position.X, Input.Position.Y)
                ResizeStartSize = Main.AbsoluteSize
            end
        end
    )

    UserInputService.InputEnded:Connect(
        function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                ResizeDragging = false
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(Input)
            if
                ResizeDragging and
                    (Input.UserInputType == Enum.UserInputType.MouseMovement or
                        Input.UserInputType == Enum.UserInputType.Touch)
             then
                local Delta = Vector2.new(Input.Position.X - ResizeStartPos.X, Input.Position.Y - ResizeStartPos.Y)
                local NewSize =
                    Vector2.new(
                    math.max(MinSize.X, ResizeStartSize.X + Delta.X),
                    math.max(MinSize.Y, ResizeStartSize.Y + Delta.Y)
                )

                Main.Size = UDim2.fromOffset(NewSize.X, NewSize.Y)
                DropShadow.Size = UDim2.fromOffset(NewSize.X, NewSize.Y)
            end
        end
    )

    local LayersTab =
        Custom:Create(
        "Frame",
        {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9990000128746033,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 9, 0, 50),
            Size = UDim2.new(0, TabWidth, 1, -59),
            Name = "LayersTab"
        },
        Main
    )

    Custom:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 2)
        },
        LayersTab
    )

    Custom:Create(
        "Frame",
        {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.85,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0, 38),
            Size = UDim2.new(1, 0, 0, 1),
            Name = "DecideFrame"
        },
        Main
    )

    local Layers =
        Custom:Create(
        "Frame",
        {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9990000128746033,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, TabWidth + 18, 0, 50),
            Size = UDim2.new(1, -(TabWidth + 9 + 18), 1, -59),
            Name = "Layers"
        },
        Main
    )

    Custom:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 2)
        },
        Layers
    )

    local NameTab =
        Custom:Create(
        "TextLabel",
        {
            Font = Enum.Font.GothamBold,
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 24,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9990000128746033,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            Name = "NameTab"
        },
        Layers
    )

    local LayersReal =
        Custom:Create(
        "Frame",
        {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9990000128746033,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 1, -33),
            Name = "LayersReal"
        },
        Layers
    )

    local LayersFolder =
        Custom:Create(
        "Folder",
        {
            Name = "LayersFolder"
        },
        LayersReal
    )

    local LayersPageLayout =
        Custom:Create(
        "UIPageLayout",
        {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Name = "LayersPageLayout",
            TweenTime = 0.5,
            EasingDirection = Enum.EasingDirection.InOut,
            EasingStyle = Enum.EasingStyle.Quad
        },
        LayersFolder
    )

    local ScrollTab =
        Custom:Create(
        "ScrollingFrame",
        {
            CanvasSize = UDim2.new(0, 0, 2.10000002, 0),
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
            ScrollBarThickness = 0,
            Active = true,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9990000128746033,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, -10),
            Name = "ScrollTab"
        },
        LayersTab
    )

    local UIListLayout =
        Custom:Create(
        "UIListLayout",
        {
            Padding = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder
        },
        ScrollTab
    )

    local function UpdateSize()
        local _Total = 0

        for _, v in pairs(ScrollTab:GetChildren()) do
            if v.Name ~= "UIListLayout" then
                _Total = _Total + 3 + v.Size.Y.Offset
            end
        end

        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, _Total + 20)
    end

    ScrollTab.ChildAdded:Connect(UpdateSize)
    ScrollTab.ChildRemoved:Connect(UpdateSize)

    Min.Activated:Connect(
        function()
            CircleClick(Min, Player:GetMouse().X, Player:GetMouse().Y)
            DropShadowHolder.Visible = false

            if not Open_Close.Visible then
                Open_Close.Visible = true
            end
        end
    )

    Open_Close.Activated:Connect(
        function()
            DropShadowHolder.Visible = true
            if Open_Close.Visible then
                Open_Close.Visible = false
            end
        end
    )

    Close.Activated:Connect(
        function()
            CircleClick(Close, Player:GetMouse().X, Player:GetMouse().Y)
            if InfernoHubGui then
                InfernoHubGui:Destroy()
            end
            if not INFERNO_HUB.Unloaded then
                INFERNO_HUB.Unloaded = true
            end
        end
    )

    DropShadowHolder.Size = UDim2.new(0, 115 + TextLabel.TextBounds.X + 1 + TextLabel1.TextBounds.X, 0, 350)
    MakeDraggable(Top, DropShadowHolder)

    -- Time Display - Changed to 12-hour format with AM/PM
    local function formatTime12Hour()
        local currentTime = os.date("*t")
        local hour = currentTime.hour
        local min = currentTime.min
        local ampm = "AM"

        if hour >= 12 then
            ampm = "PM"
            if hour > 12 then
                hour = hour - 12
            end
        end
        if hour == 0 then
            hour = 12
        end

        return string.format("%d:%02d %s", hour, min, ampm)
    end

    local TimeDisplay = Custom:Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = formatTime12Hour(),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 11,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 60, 0, 15),
        Name = "TimeDisplay"
    }, Top)

    task.spawn(function()
        while task.wait(30) do
            if TimeDisplay and TimeDisplay.Parent then
                TimeDisplay.Text = formatTime12Hour()
            end
        end
    end)

    local MoreBlur =
        Custom:Create(
        "Frame",
        {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = UDim2.new(1, 8, 1, 8),
            Size = UDim2.new(1, 154, 1, 54),
            Visible = false,
            Name = "MoreBlur"
        },
        Layers
    )

    local DropShadowHolder1 =
        Custom:Create(
        "Frame",
        {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 0,
            Name = "DropShadowHolder"
        },
        MoreBlur
    )

    local DropShadow1 =
        Custom:Create(
        "ImageLabel",
        {
            Image = "",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 35, 1, 35),
            ZIndex = 0,
            Name = "DropShadow"
        },
        DropShadowHolder1
    )

    Custom:Create("UICorner", {}, MoreBlur)

    local ConnectButton =
        Custom:Create(
        "TextButton",
        {
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.999,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Name = "ConnectButton"
        },
        MoreBlur
    )

    local DropdownSelect =
        Custom:Create(
        "Frame",
        {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            LayoutOrder = 1,
            Position = UDim2.new(1, 172, 0.5, 0),
            Size = UDim2.new(0, 160, 1, -16),
            Name = "DropdownSelect",
            ClipsDescendants = true
        },
        MoreBlur
    )

    ConnectButton.Activated:Connect(
        function()
            if MoreBlur.Visible then
                local tweenInfo = TweenInfo.new(0.2)

                local _Hide = TweenService:Create(MoreBlur, tweenInfo, {BackgroundTransparency = 0.999})
                local _Move = TweenService:Create(DropdownSelect, tweenInfo, {Position = UDim2.new(1, 172, 0.5, 0)})

                _Hide:Play()
                _Move:Play()

                task.wait(0.2)
                MoreBlur.Visible = false
            end
        end
    )

    Custom:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 3),
            Parent = DropdownSelect
        }
    )

    Custom:Create(
        "UIStroke",
        {
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 2.5,
            Transparency = 0.8,
            Parent = DropdownSelect
        }
    )

    local DropdownSelectReal =
        Custom:Create(
        "Frame",
        {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.999,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            LayoutOrder = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -10, 1, -10),
            Name = "DropdownSelectReal",
            Parent = DropdownSelect
        }
    )

    local DropdownFolder =
        Custom:Create(
        "Folder",
        {
            Name = "DropdownFolder",
            Parent = DropdownSelectReal
        }
    )

    local DropPageLayout =
        Custom:Create(
        "UIPageLayout",
        {
            EasingDirection = Enum.EasingDirection.InOut,
            EasingStyle = Enum.EasingStyle.Quad,
            TweenTime = 0.01,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Archivable = false,
            Name = "DropPageLayout",
            Parent = DropdownFolder
        }
    )
    local Tabs = {}
    local CountTab = 0
    local CountDropdown = 0
    local SettingsTabFrame = nil
    local SettingsScrolLayers = nil
    local SettingsTabCreated = false
    local SettingsLayoutOrder = 0

    function Tabs:CreateTab(Config)
        local _Name = Config[1] or Config.Name or ""
        local Icon = Config[2] or Config.Icon or ""
        local IsSettingsTab = Config.IsSettingsTab or false

        local tabLayoutOrder

        if not IsSettingsTab and SettingsTabCreated and SettingsTabFrame and SettingsScrolLayers then
            tabLayoutOrder = SettingsLayoutOrder

            SettingsLayoutOrder = CountTab
            SettingsTabFrame.LayoutOrder = SettingsLayoutOrder
            SettingsScrolLayers.LayoutOrder = SettingsLayoutOrder
        else
            tabLayoutOrder = CountTab
            if IsSettingsTab then
                SettingsLayoutOrder = CountTab
            end
        end

        local ScrolLayers =
            Custom:Create(
            "ScrollingFrame",
            {
                ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
                ScrollBarThickness = 0,
                Active = true,
                LayoutOrder = tabLayoutOrder,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.999,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Name = "ScrolLayers",
                Parent = LayersFolder
            }
        )

        Custom:Create(
            "UIListLayout",
            {
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = ScrolLayers
            }
        )

        local Tab =
            Custom:Create(
            "Frame",
            {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = CountTab == 0 and 0.92 or 0.999,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = tabLayoutOrder,
                Size = UDim2.new(1, 0, 0, 30),
                Name = "Tab",
                Parent = ScrollTab
            }
        )

        if IsSettingsTab then
            SettingsTabFrame = Tab
            SettingsScrolLayers = ScrolLayers
            SettingsTabCreated = true
        end

        Custom:Create(
            "UICorner",
            {
                CornerRadius = UDim.new(0, 4),
                Parent = Tab
            }
        )

        local TabButton =
            Custom:Create(
            "TextButton",
            {
                Font = Enum.Font.GothamBold,
                Text = "",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.999,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Name = "TabButton"
            },
            Tab
        )

        Custom:Create(
            "TextLabel",
            {
                Font = Enum.Font.GothamBold,
                Text = _Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.999,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 30, 0, 0),
                Name = "TabName"
            },
            Tab
        )

        Custom:Create(
            "ImageLabel",
            {
                Image = Icon,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.999,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 9, 0, 7),
                Size = UDim2.new(0, 16, 0, 16),
                Name = "FeatureImg"
            },
            Tab
        )

        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = _Name
        end

        TabButton.Activated:Connect(
            function()
                CircleClick(TabButton, Player:GetMouse().X, Player:GetMouse().Y)

                if Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                    for _, TabFrame in pairs(ScrollTab:GetChildren()) do
                        if TabFrame.Name == "Tab" then
                            TweenService:Create(
                                TabFrame,
                                TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                                {BackgroundTransparency = 0.999}
                            ):Play()
                        end
                    end

                    local _TabT =
                        TweenService:Create(
                        Tab,
                        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                        {BackgroundTransparency = 0.92}
                    )
                    _TabT:Play()

                    LayersPageLayout:JumpToIndex(Tab.LayoutOrder)

                    task.wait(0.05)
                    NameTab.Text = _Name

                    task.defer(
                        function()
                            local OffsetY = 0
                            for _, child in pairs(ScrolLayers:GetChildren()) do
                                if child.Name ~= "UIListLayout" then
                                    OffsetY = OffsetY + 3 + child.Size.Y.Offset
                                end
                            end
                            ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY + 20)
                        end
                    )
                end
            end
        )




























        local DirectItem, DirectItemCount = {}, 0

        local DirectSection =
            Custom:Create(
            "Frame",
            {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.999,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                ClipsDescendants = false,
                LayoutOrder = -1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Name = "DirectSection"
            },
            ScrolLayers
        )

        Custom:Create(
            "UIListLayout",
            {
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder
            },
            DirectSection
        )

        local function UpdateDirectSectionSize()
            local SectionSizeY = 0

            for _, v in pairs(DirectSection:GetChildren()) do
                if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                    SectionSizeY = SectionSizeY + v.Size.Y.Offset + 3
                end
            end

            if SectionSizeY > 0 then
                SectionSizeY = SectionSizeY + 5
            end

            DirectSection.Size = UDim2.new(1, 0, 0, SectionSizeY)

            task.defer(
                function()
                    local OffsetY = 0
                    for _, child in pairs(ScrolLayers:GetChildren()) do
                        if child.Name ~= "UIListLayout" then
                            OffsetY = OffsetY + 3 + child.Size.Y.Offset
                        end
                    end
                    ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY + 20)
                end
            )
        end

        DirectSection.ChildAdded:Connect(UpdateDirectSectionSize)
        DirectSection.ChildRemoved:Connect(UpdateDirectSectionSize)

        DirectSection:GetPropertyChangedSignal("Size"):Connect(
            function()
                task.defer(
                    function()
                        local OffsetY = 0
                        for _, child in pairs(ScrolLayers:GetChildren()) do
                            if child.Name ~= "UIListLayout" then
                                OffsetY = OffsetY + 3 + child.Size.Y.Offset
                            end
                        end
                        ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY + 20)
                    end
                )
            end
        )

Global_AddParagraph = function(Config, Parent)
    local Title = Config[1] or Config.Title or ""
    local Content = Config[2] or Config.Content or ""

    local Paragraph =
        Custom:Create(
        "Frame",
        {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.935,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 35),
            Name = "Paragraph"
        },
        Parent
    )

    Custom:Create("UICorner", {CornerRadius = UDim.new(0, 4)}, Paragraph)

    local PTitle =
        Custom:Create(
        "TextLabel",
        {
            Text = Title,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(231, 231, 231),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -16, 0, 13),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        },
        Paragraph
    )

    local PContent =
        Custom:Create(
        "TextLabel",
        {
            Text = Content,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextTransparency = 0.6,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 25),
            Size = UDim2.new(1, -16, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true
        },
        Paragraph
    )

    local function UpdateParagraphSize()
        task.spawn(function()
            -- Wait for the parent to fully render
            task.wait()

            local targetWidth = Paragraph.AbsoluteSize.X - 20
            if targetWidth <= 0 then 
                targetWidth = 380 
            end

            local textService = game:GetService("TextService")
            local textSize = textService:GetTextSize(
                PContent.Text, 
                PContent.TextSize, 
                PContent.Font, 
                Vector2.new(targetWidth, math.huge)
            )

            local finalHeight = math.max(12, textSize.Y)

            PContent.Size = UDim2.new(1, -20, 0, finalHeight)
            Paragraph.Size = UDim2.new(1, 0, 0, finalHeight + 35)
        end)
    end

    -- Initial update with delay
    task.delay(0.1, UpdateParagraphSize)

    -- Update on size changes
    Paragraph:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateParagraphSize)

    -- Update on text changes
    PContent:GetPropertyChangedSignal("Text"):Connect(UpdateParagraphSize)

    return Paragraph
end

function DirectItem:AddParagraph(Config)
    local result = Global_AddParagraph(Config, DirectSection)
    result.LayoutOrder = DirectItemCount
    DirectItemCount = DirectItemCount + 1

    -- Trigger update after adding to parent
    task.delay(0.15, function()
        local PContent = result:FindFirstChild("PContent") or result:GetChildren()[3]
        if PContent and PContent:IsA("TextLabel") then
            local targetWidth = result.AbsoluteSize.X - 20
            if targetWidth <= 0 then targetWidth = 380 end

            local textService = game:GetService("TextService")
            local textSize = textService:GetTextSize(
                PContent.Text, 
                PContent.TextSize, 
                PContent.Font, 
                Vector2.new(targetWidth, math.huge)
            )

            local finalHeight = math.max(12, textSize.Y)
            PContent.Size = UDim2.new(1, -20, 0, finalHeight)
            result.Size = UDim2.new(1, 0, 0, finalHeight + 35)
        end
    end)

    return result
end

        function DirectItem:AddSeperator(Config)
            local Title = Config[1] or Config.Title or ""
            local Sep_Funcs = {}

            local Seperator =
                Custom:Create(
                "Frame",
                {
                    BackgroundColor3 = Color3.fromRGB(70, 70, 70),
                    BackgroundTransparency = 0.1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 1,
                    LayoutOrder = DirectItemCount,
                    Size = UDim2.new(1, 0, 0, 30),
                    Name = "Seperator"
                },
                DirectSection
            )

            local SeperatorTitle =
                Custom:Create(
                "TextLabel",
                {
                    Font = Enum.Font.GothamBold,
                    Text = Title,
                    TextColor3 = Color3.fromRGB(231, 231, 231),
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                    TextStrokeTransparency = 0.8,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -16, 1, 0),
                    Name = "SeperatorTitle"
                },
                Seperator
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 6)
                },
                Seperator
            )

            Custom:Create(
                "UIGradient",
                {
                    Color = ColorSequence.new {
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 120)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120))
                    },
                    Rotation = 90
                },
                Seperator
            )

            function Sep_Funcs:Set(Config)
                local Title = Config[1] or Config.Title or ""
                SeperatorTitle.Text = Title
            end

            DirectItemCount = DirectItemCount + 1
            return Sep_Funcs
        end

        function DirectItem:AddLine()
            local LineFuncs = {}

            local Line =
                Custom:Create(
                "Frame",
                {
                    BackgroundColor3 = Color3.fromRGB(90, 90, 90),
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0,
                    LayoutOrder = DirectItemCount,
                    Size = UDim2.new(1, 0, 0, 7),
                    Name = "Line"
                },
                DirectSection
            )

            Custom:Create("UICorner", {CornerRadius = UDim.new(0, 3)}, Line)

            Custom:Create(
                "UIGradient",
                {
                    Color = ColorSequence.new {
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 80)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
                    },
                    Rotation = 0
                },
                Line
            )

            DirectItemCount = DirectItemCount + 1
            return LineFuncs
        end

        function DirectItem:AddButton(Config)
            local Title = Config[1] or Config.Title or ""
            local Content = Config[2] or Config.Content or ""
            local Icon =
                Config[3] or Config.Icon or
                "rbxassetid://" ..
                    tostring(
                        Custom:Decryption(
                            "216000000001,216000000006,216000000009,216000000003,216000000002,216000000007,216000000004,216000000000,216000000000,216000000008,216000000002"
                        )
                    )
            local Callback = Config[4] or Config.Callback or function()
                end
            local Funcs_Button = {}

            local Button =
                Custom:Create(
                "Frame",
                {
                    Name = "Button",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.935,
                    BorderSizePixel = 0,
                    LayoutOrder = DirectItemCount,
                    Size = UDim2.new(1, 0, 0, 35)
                },
                DirectSection
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 4)
                },
                Button
            )

            local ButtonTitle =
                Custom:Create(
                "TextLabel",
                {
                    Name = "ButtonTitle",
                    Font = Enum.Font.GothamBold,
                    Text = Title,
                    TextColor3 = Color3.fromRGB(231, 231, 231),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -100, 0, 13)
                },
                Button
            )

            local ButtonContent =
                Custom:Create(
                "TextLabel",
                {
                    Name = "ButtonContent",
                    Font = Enum.Font.GothamBold,
                    Text = Content,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextTransparency = 0.6,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Bottom,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 23),
                    Size = UDim2.new(1, -100, 0, 12)
                },
                Button
            )

            local function UpdateButtonSize()
                local _Height = 12 + (12 * math.floor(ButtonContent.TextBounds.X / ButtonContent.AbsoluteSize.X))
                ButtonContent.Size = UDim2.new(1, -100, 0, _Height)
                Button.Size = UDim2.new(1, 0, 0, ButtonContent.AbsoluteSize.Y + 33)
            end

            ButtonContent.TextWrapped = true
            UpdateButtonSize()

            ButtonContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                function()
                    ButtonContent.TextWrapped = false
                    UpdateButtonSize()
                    ButtonContent.TextWrapped = true
                end
            )

            local ButtonButton =
                Custom:Create(
                "TextButton",
                {
                    Name = "ButtonButton",
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0)
                },
                Button
            )

            local FeatureFrame1 =
                Custom:Create(
                "Frame",
                {
                    Name = "FeatureFrame",
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -15, 0.5, 0),
                    Size = UDim2.new(0, 25, 0, 25)
                },
                Button
            )

            Custom:Create(
                "ImageLabel",
                {
                    Name = "FeatureImg",
                    Image = Icon,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 1, 0)
                },
                FeatureFrame1
            )

            ButtonButton.Activated:Connect(
                function()
                    CircleClick(ButtonButton, Player:GetMouse().X, Player:GetMouse().Y)
                    Callback()
                end
            )

            DirectItemCount = DirectItemCount + 1
            return Funcs_Button
        end

        function DirectItem:AddToggle(Config)
            local Title = Config[1] or Config.Title or ""
            local Content = Config[2] or Config.Content or ""
            local Default = Config[3] or Config.Default or false
            local Callback = Config[4] or Config.Callback or function()
                end
            local SaveConfig = Config.SaveConfig ~= false

            local Funcs_Toggle = {Value = Default}

            local Toggle =
                Custom:Create(
                "Frame",
                {
                    Name = "Toggle",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.935,
                    BorderSizePixel = 0,
                    LayoutOrder = DirectItemCount,
                    Size = UDim2.new(1, 0, 0, 35)
                },
                DirectSection
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 4)
                },
                Toggle
            )

            local ToggleTitle =
                Custom:Create(
                "TextLabel",
                {
                    Name = "ToggleTitle",
                    Font = Enum.Font.GothamBold,
                    Text = Title,
                    TextSize = 13,
                    TextColor3 = Color3.fromRGB(231, 231, 231),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -100, 0, 13)
                },
                Toggle
            )

            local ToggleContent =
                Custom:Create(
                "TextLabel",
                {
                    Name = "ToggleContent",
                    Font = Enum.Font.GothamBold,
                    Text = Content,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextTransparency = 0.6,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Bottom,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 23),
                    Size = UDim2.new(1, -100, 0, 12)
                },
                Toggle
            )

            local function UpdateToggleSize()
                ToggleContent.TextWrapped = false
                local Ratio = ToggleContent.TextBounds.X / ToggleContent.AbsoluteSize.X
                ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * math.ceil(Ratio)))
                Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
                ToggleContent.TextWrapped = true
            end

            UpdateToggleSize()

            ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                function()
                    UpdateToggleSize()
                end
            )

            local ToggleButton =
                Custom:Create(
                "TextButton",
                {
                    Name = "ToggleButton",
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0)
                },
                Toggle
            )

            local FeatureFrame2 =
                Custom:Create(
                "Frame",
                {
                    Name = "FeatureFrame2",
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.92,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -15, 0.5, 0),
                    Size = UDim2.new(0, 30, 0, 15)
                },
                Toggle
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 4)
                },
                FeatureFrame2
            )

            local UIStroke8 =
                Custom:Create(
                "UIStroke",
                {
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 2,
                    Transparency = 0.9
                },
                FeatureFrame2
            )

            local ToggleCircle =
                Custom:Create(
                "Frame",
                {
                    Name = "ToggleCircle",
                    BackgroundColor3 = Color3.fromRGB(230, 230, 230),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 0, 0, 0)
                },
                FeatureFrame2
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 15)
                },
                ToggleCircle
            )

            local function ToggleAnimation(isOn)
                local TitleColor = isOn and Custom.ColorRGB or Color3.fromRGB(230, 230, 230)
                local CirclePosition = isOn and UDim2.new(0, 15, 0, 0) or UDim2.new(0, 0, 0, 0)
                local StrokeColor = isOn and Custom.ColorRGB or Color3.fromRGB(255, 255, 255)
                local StrokeTransparency = isOn and 0 or 0.9
                local FrameColor = isOn and Custom.ColorRGB or Color3.fromRGB(255, 255, 255)
                local FrameTransparency = isOn and 0 or 0.92

                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

                TweenService:Create(ToggleTitle, tweenInfo, {TextColor3 = TitleColor}):Play()
                TweenService:Create(ToggleCircle, tweenInfo, {Position = CirclePosition}):Play()
                TweenService:Create(UIStroke8, tweenInfo, {Color = StrokeColor, Transparency = StrokeTransparency}):Play(

                )
                TweenService:Create(
                    FeatureFrame2,
                    tweenInfo,
                    {BackgroundColor3 = FrameColor, BackgroundTransparency = FrameTransparency}
                ):Play()
            end

            Custom:RegisterConditionalAccent(
                function(newColor)
                    if Funcs_Toggle.Value then
                        ToggleTitle.TextColor3 = newColor
                        UIStroke8.Color = newColor
                        FeatureFrame2.BackgroundColor3 = newColor
                    end
                end
            )

            ToggleButton.Activated:Connect(
                function()
                    CircleClick(ToggleButton, Player:GetMouse().X, Player:GetMouse().Y)
                    Funcs_Toggle.Value = not Funcs_Toggle.Value
                    Funcs_Toggle:Set(Funcs_Toggle.Value)
                    if Custom.AutoSaveEnabled then
                        Custom:SaveConfig()
                    end
                end
            )

            function Funcs_Toggle:Set(Value)
                Funcs_Toggle.Value = Value
                Callback(Value)
                ToggleAnimation(Value)
            end

            function Funcs_Toggle:SetSaveEnabled(enabled)
                Custom:SetConfigSaveEnabled(Title, enabled)
            end

            Custom:RegisterConfigElement(
                Title,
                "Toggle",
                function()
                    return Funcs_Toggle.Value
                end,
                function(value)
                    Funcs_Toggle:Set(value)
                end,
                SaveConfig
            )

            Funcs_Toggle:Set(Funcs_Toggle.Value)

            DirectItemCount = DirectItemCount + 1
            return Funcs_Toggle
        end

        function DirectItem:AddSlider(Config)
            local Title = Config[1] or Config.Title or ""
            local Content = Config[2] or Config.Content or ""
            local Increment = Config[3] or Config.Increment or 1
            local Min = Config[4] or Config.Min or 0
            local Max = Config[5] or Config.Max or 100
            local Default = Config[6] or Config.Default or 50
            local Callback = Config[7] or Config.Callback or function()
                end
            local SaveConfig = Config.SaveConfig ~= false

            local Funcs_Slider = {Value = Default}

            local Slider =
                Custom:Create(
                "Frame",
                {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.935,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    LayoutOrder = DirectItemCount,
                    Size = UDim2.new(1, 0, 0, 35),
                    Name = "Slider"
                },
                DirectSection
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 4)
                },
                Slider
            )

            Custom:Create(
                "TextLabel",
                {
                    Font = Enum.Font.GothamBold,
                    Text = Title,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -180, 0, 13),
                    Name = "SliderTitle"
                },
                Slider
            )

            local SliderContent =
                Custom:Create(
                "TextLabel",
                {
                    Font = Enum.Font.GothamBold,
                    Text = Content,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextTransparency = 0.6,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Bottom,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 23),
                    Size = UDim2.new(1, -180, 0, 12),
                    Name = "SliderContent"
                },
                Slider
            )

            local function UpdateSliderSize()
                SliderContent.TextWrapped = false
                SliderContent.Size =
                    UDim2.new(
                    1,
                    -180,
                    0,
                    12 + (12 * math.floor(SliderContent.TextBounds.X / SliderContent.AbsoluteSize.X))
                )
                Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
                SliderContent.TextWrapped = true
            end

            SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSliderSize)
            UpdateSliderSize()

            local SliderInput =
                Custom:Create(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Custom.ColorRGB,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -155, 0.5, 0),
                    Size = UDim2.new(0, 28, 0, 20),
                    Name = "SliderInput"
                },
                Slider
            )
            Custom:RegisterAccentElement(SliderInput, "BackgroundColor3")

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 2)
                },
                SliderInput
            )

            local TextBox =
                Custom:Create(
                "TextBox",
                {
                    Font = Enum.Font.GothamBold,
                    Text = tostring(Default),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    TextWrapped = true,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0.999,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, -1, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0)
                },
                SliderInput
            )

            local SliderHitArea =
                Custom:Create(
                "Frame",
                {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -15, 0.5, 0),
                    Size = UDim2.new(0, 105, 0, 20),
                    Name = "SliderHitArea"
                },
                Slider
            )

            local SliderFrame =
                Custom:Create(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.92,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 0, 3),
                    Name = "SliderFrame"
                },
                SliderHitArea
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 2)
                },
                SliderFrame
            )

            local SliderBar =
                Custom:Create(
                "Frame",
                {
                    BackgroundColor3 = Custom.ColorRGB,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Name = "SliderBar"
                },
                SliderFrame
            )
            Custom:RegisterAccentElement(SliderBar, "BackgroundColor3")

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 2)
                },
                SliderBar
            )

            local SliderDot =
                Custom:Create(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Custom.ColorRGB,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 10, 0, 10),
                    Name = "SliderDot"
                },
                SliderFrame
            )
            Custom:RegisterAccentElement(SliderDot, "BackgroundColor3")

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(1, 0)
                },
                SliderDot
            )

            local dragging = false

            local function UpdateSlider(input)
                local pos =
                    math.clamp(
                    (input.Position.X - SliderHitArea.AbsolutePosition.X) / SliderHitArea.AbsoluteSize.X,
                    0,
                    1
                )
                local value = math.floor(Min + (Max - Min) * pos)
                value = math.clamp(value, Min, Max)
                value = math.floor(value / Increment + 0.5) * Increment

                Funcs_Slider.Value = value
                TextBox.Text = tostring(value)

                local displayPos = (value - Min) / (Max - Min)
                SliderBar.Size = UDim2.new(displayPos, 0, 1, 0)
                SliderDot.Position = UDim2.new(displayPos, 0, 0.5, 0)

                Callback(value)
            end

            SliderHitArea.InputBegan:Connect(
                function(input)
                    if
                        input.UserInputType == Enum.UserInputType.MouseButton1 or
                            input.UserInputType == Enum.UserInputType.Touch
                     then
                        dragging = true
                        UpdateSlider(input)
                    end
                end
            )

            SliderHitArea.InputEnded:Connect(
                function(input)
                    if
                        input.UserInputType == Enum.UserInputType.MouseButton1 or
                            input.UserInputType == Enum.UserInputType.Touch
                     then
                        dragging = false
                    end
                end
            )

            UserInputService.InputChanged:Connect(
                function(input)
                    if
                        dragging and
                            (input.UserInputType == Enum.UserInputType.MouseMovement or
                                input.UserInputType == Enum.UserInputType.Touch)
                     then
                        UpdateSlider(input)
                    end
                end
            )

            TextBox.FocusLost:Connect(
                function()
                    local value = tonumber(TextBox.Text) or Funcs_Slider.Value
                    value = math.clamp(value, Min, Max)
                    value = math.floor(value / Increment + 0.5) * Increment
                    Funcs_Slider:Set(value)
                end
            )

            local function UpdateSliderVisual(Value)
                local displayPos = (Value - Min) / (Max - Min)
                SliderBar.Size = UDim2.new(displayPos, 0, 1, 0)
                SliderDot.Position = UDim2.new(displayPos, 0, 0.5, 0)
            end

            function Funcs_Slider:Set(Value)
                Value = math.clamp(Value, Min, Max)
                Funcs_Slider.Value = Value
                TextBox.Text = tostring(Value)
                UpdateSliderVisual(Value)
                Callback(Value)
                if Custom.AutoSaveEnabled then
                    Custom:SaveConfig()
                end
            end

            function Funcs_Slider:SetSaveEnabled(enabled)
                Custom:SetConfigSaveEnabled(Title, enabled)
            end

            Custom:RegisterConfigElement(
                Title,
                "Slider",
                function()
                    return Funcs_Slider.Value
                end,
                function(value)
                    Funcs_Slider:Set(value)
                end,
                SaveConfig
            )

            Funcs_Slider:Set(Default)

            DirectItemCount = DirectItemCount + 1
            return Funcs_Slider
        end

        function DirectItem:AddInput(Config)
            local Title = Config[1] or Config.Title or ""
            local Content = Config[2] or Config.Content or ""
            local Default = Config[3] or Config.Default or ""
            local Callback = Config[4] or Config.Callback or function()
                end
            local SaveConfig = Config.SaveConfig ~= false
            local Funcs_Input = {Value = Default}

            local Input =
                Custom:Create(
                "Frame",
                {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.935,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    LayoutOrder = DirectItemCount,
                    Size = UDim2.new(1, 0, 0, 35),
                    Name = "Input"
                },
                DirectSection
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 4)
                },
                Input
            )

            local InputTitle =
                Custom:Create(
                "TextLabel",
                {
                    Font = Enum.Font.GothamBold,
                    Text = Title,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -180, 0, 13),
                    Name = "InputTitle"
                },
                Input
            )

            local InputContent =
                Custom:Create(
                "TextLabel",
                {
                    Font = Enum.Font.GothamBold,
                    Text = Content,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextTransparency = 0.6,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Bottom,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 23),
                    Size = UDim2.new(1, -180, 0, 12),
                    Name = "InputContent",
                    Parent = Input
                }
            )

            local function UpdateInputSize()
                local Ratio = InputContent.TextBounds.X / InputContent.AbsoluteSize.X
                local Calculated = 12 + (12 * math.floor(Ratio))
                InputContent.Size = UDim2.new(1, -180, 0, Calculated)
                Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
            end

            UpdateInputSize()

            InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                function()
                    InputContent.TextWrapped = false
                    UpdateInputSize()
                    InputContent.TextWrapped = true
                end
            )

            local InputFrame =
                Custom:Create(
                "Frame",
                {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.95,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Position = UDim2.new(1, -7, 0.5, 0),
                    Size = UDim2.new(0, 148, 0, 30),
                    Name = "InputFrame"
                },
                Input
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 4)
                },
                InputFrame
            )

            local InputTextBox =
                Custom:Create(
                "TextBox",
                {
                    CursorPosition = -1,
                    Font = Enum.Font.GothamBold,
                    PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
                    PlaceholderText = "Write your input there",
                    Text = "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 5, 0.5, 0),
                    Size = UDim2.new(1, -10, 1, -8),
                    Name = "InputTextBox"
                },
                InputFrame
            )

            function Funcs_Input:Set(Value, skipSave)
                InputTextBox.Text = Value
                Funcs_Input.Value = Value
                Callback(Value)
                if not skipSave and Custom.AutoSaveEnabled then
                    Custom:SaveConfig()
                end
            end

            function Funcs_Input:SetSaveEnabled(enabled)
                Custom:SetConfigSaveEnabled(Title, enabled)
            end

            Custom:RegisterConfigElement(
                Title,
                "Input",
                function()
                    return Funcs_Input.Value
                end,
                function(value)
                    Funcs_Input:Set(value, true)
                end,
                SaveConfig
            )

            InputTextBox.FocusLost:Connect(
                function()
                    Funcs_Input:Set(InputTextBox.Text)
                end
            )

            Funcs_Input:Set(Default, true)

            DirectItemCount = DirectItemCount + 1
            return Funcs_Input
        end

        function DirectItem:AddDropdown(Config)
            warn(
                "DirectItem:AddDropdown is very complex and requires global UI elements. Please use a Section for Dropdowns."
            )
            DirectItemCount = DirectItemCount + 1
            return {Value = {}, Options = {}}
        end

        function DirectItem:AddBackgroundTheme(Config)
            warn("DirectItem:AddBackgroundTheme requires a Section. Please use Section:AddBackgroundTheme instead.")
            DirectItemCount = DirectItemCount + 1
            return {Value = "Dark"}
        end

        function DirectItem:OldAddBackgroundTheme_UNUSED(Config)
            local Title = Config[1] or Config.Title or "Background Theme"
            local Options =
                Config[2] or Config.Options or
                {"Dark", "Blue Gradient", "Purple Gradient", "Sunset", "Ocean", "Forest", "Custom"}
            local Default = Config[3] or Config.Default or "Dark"
            local Callback = Config[4] or Config.Callback or function()
                end

            local Themes = {
                ["Dark"] = {
                    Type = "Solid",
                    Color1 = Color3.fromRGB(15, 15, 15),
                    Color2 = Color3.fromRGB(15, 15, 15),
                    Rotation = 90
                },
                ["Blue Gradient"] = {
                    Type = "Gradient",
                    Color1 = Color3.fromRGB(10, 25, 50),
                    Color2 = Color3.fromRGB(20, 50, 100),
                    Rotation = 45
                },
                ["Purple Gradient"] = {
                    Type = "Gradient",
                    Color1 = Color3.fromRGB(40, 10, 60),
                    Color2 = Color3.fromRGB(80, 20, 120),
                    Rotation = 135
                },
                ["Sunset"] = {
                    Type = "Gradient",
                    Color1 = Color3.fromRGB(60, 20, 40),
                    Color2 = Color3.fromRGB(100, 50, 20),
                    Rotation = 90
                },
                ["Ocean"] = {
                    Type = "Gradient",
                    Color1 = Color3.fromRGB(5, 30, 60),
                    Color2 = Color3.fromRGB(10, 60, 100),
                    Rotation = 180
                },
                ["Forest"] = {
                    Type = "Gradient",
                    Color1 = Color3.fromRGB(10, 30, 15),
                    Color2 = Color3.fromRGB(20, 60, 30),
                    Rotation = 45
                }
            }

            local Funcs_Theme = {Value = Default}

            local ThemeFrame =
                Custom:Create(
                "Frame",
                {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.935,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    LayoutOrder = DirectItemCount,
                    Size = UDim2.new(1, 0, 0, 45),
                    Name = "BackgroundTheme"
                },
                DirectSection
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 4)
                },
                ThemeFrame
            )

            local ThemeTitle =
                Custom:Create(
                "TextLabel",
                {
                    Font = Enum.Font.GothamBold,
                    Text = Title,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -16, 0, 13),
                    Name = "ThemeTitle"
                },
                ThemeFrame
            )

            local CurrentThemeLabel =
                Custom:Create(
                "TextLabel",
                {
                    Font = Enum.Font.GothamBold,
                    Text = "Current: " .. Default,
                    TextColor3 = Custom.ColorRGB,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 26),
                    Size = UDim2.new(1, -16, 0, 11),
                    Name = "CurrentTheme"
                },
                ThemeFrame
            )
            Custom:RegisterAccentElement(CurrentThemeLabel, "TextColor3")

            local ScrollThemes =
                Custom:Create(
                "ScrollingFrame",
                {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -10, 0.5, 5),
                    Size = UDim2.new(0, 180, 0, 35),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = Custom.ColorRGB,
                    ScrollingDirection = Enum.ScrollingDirection.X,
                    Name = "ScrollThemes"
                },
                ThemeFrame
            )
            Custom:RegisterAccentElement(ScrollThemes, "ScrollBarImageColor3")

            Custom:Create("UICorner", {CornerRadius = UDim.new(0, 4)}, ScrollThemes)
            Custom:Create(
                "UIListLayout",
                {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder
                },
                ScrollThemes
            )

            function Funcs_Theme:Set(ThemeName)
                local Theme = Themes[ThemeName]
                if not Theme then
                    return
                end

                Funcs_Theme.Value = ThemeName
                CurrentThemeLabel.Text = "Current: " .. ThemeName

                if Theme.Type == "Gradient" then
                    BackgroundGradient.Enabled = true
                    BackgroundGradient.Color =
                        ColorSequence.new {
                        ColorSequenceKeypoint.new(0, Theme.Color1),
                        ColorSequenceKeypoint.new(1, Theme.Color2)
                    }
                    BackgroundGradient.Rotation = Theme.Rotation
                    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                else
                    BackgroundGradient.Enabled = false
                    Main.BackgroundColor3 = Theme.Color1
                end

                Callback(ThemeName)
            end

            for index, ThemeName in ipairs(Options) do
                local Theme = Themes[ThemeName]
                if Theme then
                    local ThemeButton =
                        Custom:Create(
                        "TextButton",
                        {
                            BackgroundColor3 = Theme.Color1,
                            Text = "",
                            Size = UDim2.new(0, 55, 0, 25),
                            LayoutOrder = index,
                            Name = ThemeName
                        },
                        ScrollThemes
                    )

                    Custom:Create("UICorner", {CornerRadius = UDim.new(0, 3)}, ThemeButton)
                    local ThemeButtonStroke =
                        Custom:Create(
                        "UIStroke",
                        {
                            Color = ThemeName == Default and Custom.ColorRGB or Color3.fromRGB(80, 80, 80),
                            Thickness = ThemeName == Default and 2 or 1
                        },
                        ThemeButton
                    )
                    if ThemeName == Default then
                        Custom:RegisterAccentElement(ThemeButtonStroke, "Color")
                    end

                    if Theme.Type == "Gradient" then
                        Custom:Create(
                            "UIGradient",
                            {
                                Color = ColorSequence.new {
                                    ColorSequenceKeypoint.new(0, Theme.Color1),
                                    ColorSequenceKeypoint.new(1, Theme.Color2)
                                },
                                Rotation = Theme.Rotation
                            },
                            ThemeButton
                        )
                    end

                    local ThemeLabel =
                        Custom:Create(
                        "TextLabel",
                        {
                            Font = Enum.Font.GothamBold,
                            Text = ThemeName,
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextSize = 9,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            TextStrokeTransparency = 0.5
                        },
                        ThemeButton
                    )

                    ThemeButton.Activated:Connect(
                        function()
                            for _, btn in pairs(ScrollThemes:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    local stroke = btn:FindFirstChild("UIStroke")
                                    if stroke then
                                        stroke.Color = Color3.fromRGB(80, 80, 80)
                                        stroke.Thickness = 1
                                    end
                                end
                            end

                            local stroke = ThemeButton:FindFirstChild("UIStroke")
                            if stroke then
                                stroke.Color = Custom.ColorRGB
                                stroke.Thickness = 2
                            end

                            CircleClick(ThemeButton, Player:GetMouse().X, Player:GetMouse().Y)
                            Funcs_Theme:Set(ThemeName)
                        end
                    )
                end
            end

            local totalWidth = (#Options * 60) + ((#Options - 1) * 5)
            ScrollThemes.CanvasSize = UDim2.new(0, totalWidth, 0, 0)

            Funcs_Theme:Set(Default)

            DirectItemCount = DirectItemCount + 1
            return Funcs_Theme
        end

        local CountSection = 1

        function DirectItem:AddSection(Title, OpenSection)
            local Title = Title or ""
            local OpenSection = OpenSection or false

            local Section =
                Custom:Create(
                "Frame",
                {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.999,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    LayoutOrder = CountSection,
                    Size = UDim2.new(1, 0, 0, 30),
                    Name = "Section"
                },
                ScrolLayers
            )

            local SectionReal =
                Custom:Create(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.935,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    LayoutOrder = 1,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(1, 1, 0, 30),
                    Name = "SectionReal"
                },
                Section
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 4)
                },
                SectionReal
            )

            local SectionButton =
                Custom:Create(
                "TextButton",
                {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.9990000128746033,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "SectionButton"
                },
                SectionReal
            )

            local FeatureFrame =
                Custom:Create(
                "Frame",
                {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0.9990000128746033,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -5, 0.5, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    Name = "FeatureFrame"
                },
                SectionReal
            )

            local FeatureImg =
                Custom:Create(
                "ImageLabel",
                {
                    Image = "rbxassetid://125609963478878",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.9990000128746033,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Rotation = -90,
                    Size = UDim2.new(1, 6, 1, 6),
                    Name = "FeatureImg"
                },
                FeatureFrame
            )

            local SectionTitle =
                Custom:Create(
                "TextLabel",
                {
                    Font = Enum.Font.GothamBold,
                    Text = Title,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.9990000128746033,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.new(1, -50, 0, 13),
                    Name = "SectionTitle"
                },
                SectionReal
            )

            local SectionDecideFrame =
                Custom:Create(
                "Frame",
                {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 33),
                    Size = UDim2.new(0, 0, 0, 2),
                    Name = "SectionDecideFrame"
                },
                Section
            )
            Custom:Create("UICorner", {}, SectionDecideFrame)
            local SectionGradient =
                Custom:Create(
                "UIGradient",
                {
                    Color = ColorSequence.new {
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
                        ColorSequenceKeypoint.new(0.5, Custom.ColorRGB),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
                    }
                },
                SectionDecideFrame
            )
            Custom:RegisterAccentElement(SectionGradient, "ColorSequence")

            local SectionAdd =
                Custom:Create(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.9990000128746033,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    LayoutOrder = 1,
                    Position = UDim2.new(0.5, 0, 0, 38),
                    Size = UDim2.new(1, 0, 0, 100),
                    Name = "SectionAdd"
                },
                Section
            )

            Custom:Create(
                "UICorner",
                {
                    CornerRadius = UDim.new(0, 2)
                },
                SectionAdd
            )

            Custom:Create(
                "UIListLayout",
                {
                    Padding = UDim.new(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder
                },
                SectionAdd
            )

            local function UpdateSizeScroll()
                task.defer(
                    function()
                        local OffsetY = 0

                        for _, child in pairs(ScrolLayers:GetChildren()) do
                            if child.Name ~= "UIListLayout" then
                                OffsetY = OffsetY + 3 + child.Size.Y.Offset
                            end
                        end

                        ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY + 20)
                    end
                )
            end

            local function UpdateSizeSection()
                if OpenSection then
                    local SectionSizeYWitdh = 38

                    for _, v in pairs(SectionAdd:GetChildren()) do
                        if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
                            SectionSizeYWitdh = SectionSizeYWitdh + v.Size.Y.Offset + 3
                        end
                    end

                    TweenService:Create(FeatureFrame, TweenInfo.new(0.1), {Rotation = 90}):Play()
                    TweenService:Create(Section, TweenInfo.new(0.1), {Size = UDim2.new(1, 1, 0, SectionSizeYWitdh)}):Play(

                    )
                    TweenService:Create(
                        SectionAdd,
                        TweenInfo.new(0.1),
                        {Size = UDim2.new(1, 0, 0, SectionSizeYWitdh - 38)}
                    ):Play()
                    TweenService:Create(SectionDecideFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 2)}):Play()

                    task.delay(0.15, UpdateSizeScroll)
                end
            end

            local function ToggleSection()
                CircleClick(SectionButton, Player:GetMouse().X, Player:GetMouse().Y)

                if OpenSection then
                    TweenService:Create(FeatureFrame, TweenInfo.new(0.1), {Rotation = 0}):Play()
                    TweenService:Create(Section, TweenInfo.new(0.1), {Size = UDim2.new(1, 1, 0, 30)}):Play()
                    TweenService:Create(SectionAdd, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    TweenService:Create(SectionDecideFrame, TweenInfo.new(0.1), {Size = UDim2.new(0, 0, 0, 2)}):Play()

                    OpenSection = false
                    task.delay(0.15, UpdateSizeScroll)
                else
                    OpenSection = true
                    UpdateSizeSection()
                end
            end

            SectionButton.Activated:Connect(ToggleSection)
            SectionAdd.ChildAdded:Connect(UpdateSizeSection)
            SectionAdd.ChildRemoved:Connect(UpdateSizeSection)

            Section:GetPropertyChangedSignal("Size"):Connect(UpdateSizeScroll)

            UpdateSizeScroll()

            local Item, ItemCount = {}, 0
function Item:AddParagraph(Config)
    local Title = Config[1] or Config.Title or ""
    local Content = Config[2] or Config.Content or ""
    local SettingFuncs = {}

    local Paragraph =
        Custom:Create(
        "Frame",
        {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.935,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            LayoutOrder = ItemCount,
            Size = UDim2.new(1, 0, 0, 35),
            Name = "Paragraph"
        },
        SectionAdd
    )

    Custom:Create(
        "UICorner",
        {
            CornerRadius = UDim.new(0, 4)
        },
        Paragraph
    )

    local ParagraphTitle =
        Custom:Create(
        "TextLabel",
        {
            Font = Enum.Font.GothamBold,
            Text = Title,
            TextColor3 = Color3.fromRGB(231, 231, 231),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.999,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -16, 0, 13),
            Name = "ParagraphTitle"
        },
        Paragraph
    )

    local ParagraphContent =
        Custom:Create(
        "TextLabel",
        {
            Font = Enum.Font.GothamBold,
            Text = Content,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextTransparency = 0.6,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.999,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 23),
            Size = UDim2.new(1, -20, 0, 12),
            Name = "ParagraphContent"
        },
        Paragraph
    )

    local function UpdateParagraphSize()
        task.spawn(function()
            task.wait(0.05)

            local targetWidth = Paragraph.AbsoluteSize.X - 20
            if targetWidth <= 0 then 
                targetWidth = 380 
            end

            local textService = game:GetService("TextService")
            local textSize = textService:GetTextSize(
                ParagraphContent.Text, 
                ParagraphContent.TextSize, 
                ParagraphContent.Font, 
                Vector2.new(targetWidth, math.huge)
            )

            local finalHeight = math.max(12, textSize.Y)

            ParagraphContent.Size = UDim2.new(1, -20, 0, finalHeight)
            Paragraph.Size = UDim2.new(1, 0, 0, finalHeight + 33)

            -- Force section update
            if UpdateSizeSection then
                task.wait(0.05)
                UpdateSizeSection()
            end
        end)
    end

    -- Initial update
    task.wait()
    UpdateParagraphSize()

    -- Listen for changes
    Paragraph:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateParagraphSize)
    ParagraphContent:GetPropertyChangedSignal("Text"):Connect(UpdateParagraphSize)

    function SettingFuncs:Set(Config)
        local Title = Config[1] or Config.Title or ""
        local Content = Config[2] or Config.Content or ""

        ParagraphTitle.Text = Title
        ParagraphContent.Text = Content

        UpdateParagraphSize()
    end

    ItemCount = ItemCount + 1
    return SettingFuncs
end
            function Item:AddSeperator(Config)
                local Title = Config[1] or Config.Title or ""
                local Sep_Funcs = {}

                local Seperator =
                    Custom:Create(
                    "Frame",
                    {
                        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
                        BackgroundTransparency = 0.1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 1,
                        LayoutOrder = ItemCount,
                        Size = UDim2.new(1, 0, 0, 30),
                        Name = "Seperator"
                    },
                    SectionAdd
                )

                local SeperatorTitle =
                    Custom:Create(
                    "TextLabel",
                    {
                        Font = Enum.Font.GothamBold,
                        Text = Title,
                        TextColor3 = Color3.fromRGB(231, 231, 231),
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                        TextStrokeTransparency = 0.8,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -16, 1, 0),
                        Name = "SeperatorTitle"
                    },
                    Seperator
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 6)
                    },
                    Seperator
                )

                local Gradient =
                    Custom:Create(
                    "UIGradient",
                    {
                        Color = ColorSequence.new {
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 120)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120))
                        },
                        Rotation = 90
                    },
                    Seperator
                )

                function Sep_Funcs:Set(Config)
                    local Title = Config[1] or Config.Title or ""

                    SeperatorTitle.Text = Title
                end

                ItemCount = ItemCount + 1
                return Sep_Funcs
            end

            function Item:AddLine()
                local LineFuncs = {}

                local Line =
                    Custom:Create(
                    "Frame",
                    {
                        BackgroundColor3 = Color3.fromRGB(90, 90, 90),
                        BackgroundTransparency = 0.2,
                        BorderSizePixel = 0,
                        LayoutOrder = ItemCount,
                        Size = UDim2.new(1, 0, 0, 7),
                        Name = "Line"
                    },
                    SectionAdd
                )

                Custom:Create("UICorner", {CornerRadius = UDim.new(0, 3)}, Line)

                Custom:Create(
                    "UIGradient",
                    {
                        Color = ColorSequence.new {
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 80)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
                        },
                        Rotation = 0
                    },
                    Line
                )

                ItemCount = ItemCount + 1
                return LineFuncs
            end

            function Item:AddButton(Config)
                local Title = Config[1] or Config.Title or ""
                local Content = Config[2] or Config.Content or ""
                local Icon =
                    Config[3] or Config.Icon or
                    "rbxassetid://" ..
                        tostring(
                            Custom:Decryption(
                                "216000000001,216000000006,216000000009,216000000003,216000000002,216000000007,216000000004,216000000000,216000000000,216000000008,216000000002"
                            )
                        )
                local Callback = Config[4] or Config.Callback or function()
                    end
                local Funcs_Button = {}

                local Button =
                    Custom:Create(
                    "Frame",
                    {
                        Name = "Button",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.935,
                        BorderSizePixel = 0,
                        LayoutOrder = ItemCount,
                        Size = UDim2.new(1, 0, 0, 35)
                    },
                    SectionAdd
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    Button
                )

                local ButtonTitleLabel =
                    Custom:Create(
                    "TextLabel",
                    {
                        Name = "ButtonTitle",
                        Font = Enum.Font.GothamBold,
                        Text = Title,
                        TextColor3 = Color3.fromRGB(231, 231, 231),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 10),
                        Size = UDim2.new(1, -100, 0, 13)
                    },
                    Button
                )

                local ButtonContent =
                    Custom:Create(
                    "TextLabel",
                    {
                        Name = "ButtonContent",
                        Font = Enum.Font.GothamBold,
                        Text = Content,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        TextTransparency = 0.6,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Bottom,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 23),
                        Size = UDim2.new(1, -100, 0, 12)
                    },
                    Button
                )

                local function UpdateButtonSize()
                    local _Height = 12 + (12 * math.floor(ButtonContent.TextBounds.X / ButtonContent.AbsoluteSize.X))
                    ButtonContent.Size = UDim2.new(1, -100, 0, _Height)

                    Button.Size = UDim2.new(1, 0, 0, ButtonContent.AbsoluteSize.Y + 33)
                end

                ButtonContent.TextWrapped = true
                UpdateButtonSize()

                ButtonContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                    function()
                        ButtonContent.TextWrapped = false
                        UpdateButtonSize()
                        ButtonContent.TextWrapped = true
                        UpdateSizeSection()
                    end
                )

                local ButtonButton =
                    Custom:Create(
                    "TextButton",
                    {
                        Name = "ButtonButton",
                        Font = Enum.Font.SourceSans,
                        Text = "",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextSize = 14,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 0.999,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0)
                    },
                    Button
                )

                local FeatureFrame1 =
                    Custom:Create(
                    "Frame",
                    {
                        Name = "FeatureFrame",
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 0.999,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -15, 0.5, 0),
                        Size = UDim2.new(0, 25, 0, 25)
                    },
                    Button
                )

                Custom:Create(
                    "ImageLabel",
                    {
                        Name = "FeatureImg",
                        Image = Icon,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 1, 0)
                    },
                    FeatureFrame1
                )

                ButtonButton.Activated:Connect(
                    function()
                        CircleClick(ButtonButton, Player:GetMouse().X, Player:GetMouse().Y)

                        Callback()
                    end
                )

                ItemCount = ItemCount + 1
                return Funcs_Button
            end

            function Item:AddLinkButton(Config)
                local Title = Config[1] or Config.Title or "Link"
                local URL = Config[2] or Config.URL or ""
                local Icon = Config[3] or Config.Icon or "rbxassetid://10723434711"
                local Callback = Config[4] or Config.Callback or function()
                    end
                local Funcs_LinkButton = {}

                local LinkButton =
                    Custom:Create(
                    "Frame",
                    {
                        Name = "LinkButton",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.935,
                        BorderSizePixel = 0,
                        LayoutOrder = ItemCount,
                        Size = UDim2.new(1, 0, 0, 35)
                    },
                    SectionAdd
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    LinkButton
                )

                Custom:Create(
                    "TextLabel",
                    {
                        Name = "LinkTitle",
                        Font = Enum.Font.GothamBold,
                        Text = Title,
                        TextColor3 = Custom.ColorRGB,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 42, 0, 0),
                        Size = UDim2.new(1, -90, 1, 0)
                    },
                    LinkButton
                )
                Custom:RegisterAccentElement(LinkButton:FindFirstChild("LinkTitle"), "TextColor3")

                local LinkIcon =
                    Custom:Create(
                    "ImageLabel",
                    {
                        Name = "LinkIcon",
                        Image = Icon,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0.5, -12),
                        Size = UDim2.new(0, 24, 0, 24)
                    },
                    LinkButton
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    LinkIcon
                )

                local LinkArrow =
                    Custom:Create(
                    "TextLabel",
                    {
                        Name = "LinkArrow",
                        Font = Enum.Font.GothamBold,
                        Text = "→",
                        TextColor3 = Custom.ColorRGB,
                        TextSize = 18,
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -10, 0.5, 0),
                        Size = UDim2.new(0, 20, 0, 20)
                    },
                    LinkButton
                )
                Custom:RegisterAccentElement(LinkArrow, "TextColor3")

                local LinkClickButton =
                    Custom:Create(
                    "TextButton",
                    {
                        Name = "LinkClickButton",
                        Text = "",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0)
                    },
                    LinkButton
                )

                LinkClickButton.Activated:Connect(
                    function()
                        CircleClick(LinkClickButton, Player:GetMouse().X, Player:GetMouse().Y)

                        if setclipboard then
                            setclipboard(URL)
                        end

                        Callback(URL)
                    end
                )

                function Funcs_LinkButton:SetURL(NewURL)
                    URL = NewURL
                end

                ItemCount = ItemCount + 1
                return Funcs_LinkButton
            end

            function Item:AddToggle(Config)
                local Title = Config[1] or Config.Title or ""
                local Content = Config[2] or Config.Content or ""
                local Default = Config[3] or Config.Default or false
                local Callback = Config[4] or Config.Callback or function()
                    end
                local SaveConfig = Config.SaveConfig ~= false

                local Funcs_Toggle = {Value = Default}

                local Toggle =
                    Custom:Create(
                    "Frame",
                    {
                        Name = "Toggle",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.935,
                        BorderSizePixel = 0,
                        LayoutOrder = ItemCount,
                        Size = UDim2.new(1, 0, 0, 35)
                    },
                    SectionAdd
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    Toggle
                )

                local ToggleTitle =
                    Custom:Create(
                    "TextLabel",
                    {
                        Name = "ToggleTitle",
                        Font = Enum.Font.GothamBold,
                        Text = Title,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(231, 231, 231),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 10),
                        Size = UDim2.new(1, -100, 0, 13)
                    },
                    Toggle
                )

                local ToggleContent =
                    Custom:Create(
                    "TextLabel",
                    {
                        Name = "ToggleContent",
                        Font = Enum.Font.GothamBold,
                        Text = Content,
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextTransparency = 0.6,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Bottom,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 23),
                        Size = UDim2.new(1, -100, 0, 12)
                    },
                    Toggle
                )

                local function UpdateToggleSize()
                    ToggleContent.TextWrapped = false
                    local Ratio = ToggleContent.TextBounds.X / ToggleContent.AbsoluteSize.X

                    ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * math.ceil(Ratio)))
                    Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
                    ToggleContent.TextWrapped = true
                end

                UpdateToggleSize()

                ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                    function()
                        UpdateToggleSize()
                        UpdateSizeSection()
                    end
                )

                local ToggleButton =
                    Custom:Create(
                    "TextButton",
                    {
                        Name = "ToggleButton",
                        Font = Enum.Font.SourceSans,
                        Text = "",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextSize = 14,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 0.999,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0)
                    },
                    Toggle
                )

                local FeatureFrame2 =
                    Custom:Create(
                    "Frame",
                    {
                        Name = "FeatureFrame2",
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.92,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -15, 0.5, 0),
                        Size = UDim2.new(0, 30, 0, 15)
                    },
                    Toggle
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    FeatureFrame2
                )

                local UIStroke8 =
                    Custom:Create(
                    "UIStroke",
                    {
                        Color = Color3.fromRGB(255, 255, 255),
                        Thickness = 2,
                        Transparency = 0.9
                    },
                    FeatureFrame2
                )

                local ToggleCircle =
                    Custom:Create(
                    "Frame",
                    {
                        Name = "ToggleCircle",
                        BackgroundColor3 = Color3.fromRGB(230, 230, 230),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = UDim2.new(0, 0, 0, 0)
                    },
                    FeatureFrame2
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 15)
                    },
                    ToggleCircle
                )

                local function ToggleAnimation(isOn)
                    local TitleColor = isOn and Custom.ColorRGB or Color3.fromRGB(230, 230, 230)
                    local CirclePosition = isOn and UDim2.new(0, 15, 0, 0) or UDim2.new(0, 0, 0, 0)
                    local StrokeColor = isOn and Custom.ColorRGB or Color3.fromRGB(255, 255, 255)
                    local StrokeTransparency = isOn and 0 or 0.9
                    local FrameColor = isOn and Custom.ColorRGB or Color3.fromRGB(255, 255, 255)
                    local FrameTransparency = isOn and 0 or 0.92

                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

                    TweenService:Create(ToggleTitle, tweenInfo, {TextColor3 = TitleColor}):Play()
                    TweenService:Create(ToggleCircle, tweenInfo, {Position = CirclePosition}):Play()
                    TweenService:Create(UIStroke8, tweenInfo, {Color = StrokeColor, Transparency = StrokeTransparency}):Play(

                    )
                    TweenService:Create(
                        FeatureFrame2,
                        tweenInfo,
                        {BackgroundColor3 = FrameColor, BackgroundTransparency = FrameTransparency}
                    ):Play()
                end

                Custom:RegisterConditionalAccent(
                    function(newColor)
                        if Funcs_Toggle.Value then
                            ToggleTitle.TextColor3 = newColor
                            UIStroke8.Color = newColor
                            FeatureFrame2.BackgroundColor3 = newColor
                        end
                    end
                )

                ToggleButton.Activated:Connect(
                    function()
                        CircleClick(ToggleButton, Player:GetMouse().X, Player:GetMouse().Y)
                        Funcs_Toggle.Value = not Funcs_Toggle.Value
                        Funcs_Toggle:Set(Funcs_Toggle.Value)
                        if Custom.AutoSaveEnabled then
                            Custom:SaveConfig()
                        end
                    end
                )

                function Funcs_Toggle:Set(Value)
                    Funcs_Toggle.Value = Value
                    Callback(Value)
                    ToggleAnimation(Value)
                end

                function Funcs_Toggle:SetSaveEnabled(enabled)
                    Custom:SetConfigSaveEnabled(Title, enabled)
                end

                Custom:RegisterConfigElement(
                    Title,
                    "Toggle",
                    function()
                        return Funcs_Toggle.Value
                    end,
                    function(value)
                        Funcs_Toggle:Set(value)
                    end,
                    SaveConfig
                )

                Funcs_Toggle:Set(Funcs_Toggle.Value)

                ItemCount = ItemCount + 1
                return Funcs_Toggle
            end

            function Item:AddSlider(Config)
                local Title = Config[1] or Config.Title or ""
                local Content = Config[2] or Config.Content or ""
                local Increment = Config[3] or Config.Increment or 1
                local Min = Config[4] or Config.Min or 0
                local Max = Config[5] or Config.Max or 100
                local Default = Config[6] or Config.Default or 50
                local Callback = Config[7] or Config.Callback or function()
                    end
                local SaveConfig = Config.SaveConfig ~= false

                local Funcs_Slider = {Value = Default}

                local Slider =
                    Custom:Create(
                    "Frame",
                    {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.9350000023841858,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        LayoutOrder = ItemCount,
                        Size = UDim2.new(1, 0, 0, 35),
                        Name = "Slider"
                    },
                    SectionAdd
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    Slider
                )

                Custom:Create(
                    "TextLabel",
                    {
                        Font = Enum.Font.GothamBold,
                        Text = Title,
                        TextColor3 = Color3.fromRGB(230, 230, 230),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.9990000128746033,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 10),
                        Size = UDim2.new(1, -180, 0, 13),
                        Name = "SliderTitle"
                    },
                    Slider
                )

                local SliderContent =
                    Custom:Create(
                    "TextLabel",
                    {
                        Font = Enum.Font.GothamBold,
                        Text = Content,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        TextTransparency = 0.6000000238418579,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Bottom,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.9990000128746033,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 23),
                        Size = UDim2.new(1, -180, 0, 12),
                        Name = "SliderContent"
                    },
                    Slider
                )

                local function UpdateSliderSize()
                    SliderContent.TextWrapped = false
                    SliderContent.Size =
                        UDim2.new(
                        1,
                        -180,
                        0,
                        12 + (12 * math.floor(SliderContent.TextBounds.X / SliderContent.AbsoluteSize.X))
                    )
                    Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
                    SliderContent.TextWrapped = true
                end

                SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                    function()
                        UpdateSliderSize()
                        UpdateSizeSection()
                    end
                )
                UpdateSliderSize()

                local SliderInput =
                    Custom:Create(
                    "Frame",
                    {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Custom.ColorRGB,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -155, 0.5, 0),
                        Size = UDim2.new(0, 28, 0, 20),
                        Name = "SliderInput"
                    },
                    Slider
                )
                Custom:RegisterAccentElement(SliderInput, "BackgroundColor3")

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 2)
                    },
                    SliderInput
                )

                local TextBox =
                    Custom:Create(
                    "TextBox",
                    {
                        Font = Enum.Font.GothamBold,
                        Text = "90",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 13,
                        TextWrapped = true,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 0.9990000128746033,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, -1, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0)
                    },
                    SliderInput
                )

                local SliderHitArea =
                    Custom:Create(
                    "Frame",
                    {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -20, 0.5, 0),
                        Size = UDim2.new(0, 100, 0, 20),
                        Name = "SliderHitArea"
                    },
                    Slider
                )

                local SliderFrame =
                    Custom:Create(
                    "Frame",
                    {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.800000011920929,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 0, 3),
                        Name = "SliderFrame"
                    },
                    SliderHitArea
                )

                Custom:Create("UICorner", {}, SliderFrame)

                local SliderDraggable =
                    Custom:Create(
                    "Frame",
                    {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Custom.ColorRGB,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.new(0.899999976, 0, 0, 1),
                        Name = "SliderDraggable"
                    },
                    SliderFrame
                )
                Custom:RegisterAccentElement(SliderDraggable, "BackgroundColor3")

                Custom:Create("UICorner", {}, SliderDraggable)

                local SliderCircle =
                    Custom:Create(
                    "Frame",
                    {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Custom.ColorRGB,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 4, 0.5, 0),
                        Size = UDim2.new(0, 10, 0, 10),
                        Name = "SliderCircle"
                    },
                    SliderDraggable
                )
                Custom:RegisterAccentElement(SliderCircle, "BackgroundColor3")

                Custom:Create("UICorner", {}, SliderCircle)

                local UIStroke_SliderCircle =
                    Custom:Create(
                    "UIStroke",
                    {
                        Color = Custom.ColorRGB
                    },
                    SliderCircle
                )
                Custom:RegisterAccentElement(UIStroke_SliderCircle, "Color")

                local Dragging = false

                local function Round(Number, Factor)
                    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
                    if Result < 0 then
                        Result = Result + Factor
                    end
                    return Result
                end

                function Funcs_Slider:Set(Value)
                    Value = math.clamp(Round(Value, Increment), Min, Max)
                    Funcs_Slider.Value = Value
                    TextBox.Text = tostring(Value)

                    TweenService:Create(
                        SliderDraggable,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Size = UDim2.fromScale((Value - Min) / (Max - Min), 1)}
                    ):Play()
                end

                function Funcs_Slider:SetSaveEnabled(enabled)
                    Custom:SetConfigSaveEnabled(Title, enabled)
                end

                Custom:RegisterConfigElement(
                    Title,
                    "Slider",
                    function()
                        return Funcs_Slider.Value
                    end,
                    function(value)
                        Funcs_Slider:Set(value)
                    end,
                    SaveConfig
                )

                SliderHitArea.InputBegan:Connect(
                    function(Input)
                        if
                            Input.UserInputType == Enum.UserInputType.MouseButton1 or
                                Input.UserInputType == Enum.UserInputType.Touch
                         then
                            Dragging = true
                        end
                    end
                )

                SliderHitArea.InputEnded:Connect(
                    function(Input)
                        if
                            Input.UserInputType == Enum.UserInputType.MouseButton1 or
                                Input.UserInputType == Enum.UserInputType.Touch
                         then
                            Dragging = false
                            Callback(Funcs_Slider.Value)
                            if Custom.AutoSaveEnabled then
                                Custom:SaveConfig()
                            end
                        end
                    end
                )

                local _LastX = nil
                UserInputService.InputChanged:Connect(
                    function(Input)
                        if Dragging then
                            local CurrPosX = Input.Position.X
                            if CurrPosX ~= _LastX then
                                _LastX = CurrPosX

                                local SizeScale =
                                    math.clamp(
                                    (CurrPosX - SliderHitArea.AbsolutePosition.X) / SliderHitArea.AbsoluteSize.X,
                                    0,
                                    1
                                )
                                Funcs_Slider:Set(Min + ((Max - Min) * SizeScale))
                                Callback(Funcs_Slider.Value)
                            end
                        end
                    end
                )

                TextBox.FocusLost:Connect(
                    function()
                        local text = TextBox.Text:gsub("[^%d%.]", "")
                        local num = tonumber(text)
                        if num then
                            num = math.clamp(num, Min, Max)
                            Funcs_Slider:Set(num)
                            Callback(Funcs_Slider.Value)
                            if Custom.AutoSaveEnabled then
                                Custom:SaveConfig()
                            end
                        else
                            Funcs_Slider:Set(Min)
                            Callback(Funcs_Slider.Value)
                        end
                    end
                )

                Funcs_Slider:Set(tonumber(Default))
                Callback(Funcs_Slider.Value)

                ItemCount = ItemCount + 1
                return Funcs_Slider
            end

            function Item:AddInput(Config)
                local Title = Config[1] or Config.Title or ""
                local Content = Config[2] or Config.Content or ""
                local Default = Config[3] or Config.Default or ""
                local Callback = Config[4] or Config.Callback or function()
                    end
                local SaveConfig = Config.SaveConfig ~= false
                local Funcs_Input = {Value = Default}

                local Input =
                    Custom:Create(
                    "Frame",
                    {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.935,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        LayoutOrder = ItemCount,
                        Size = UDim2.new(1, 0, 0, 35),
                        Name = "Input"
                    },
                    SectionAdd
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    Input
                )

                local InputTitle =
                    Custom:Create(
                    "TextLabel",
                    {
                        Font = Enum.Font.GothamBold,
                        Text = Title,
                        TextColor3 = Color3.fromRGB(230, 230, 230),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 10),
                        Size = UDim2.new(1, -180, 0, 13),
                        Name = "InputTitle"
                    },
                    Input
                )

                local InputContent =
                    Custom:Create(
                    "TextLabel",
                    {
                        Font = Enum.Font.GothamBold,
                        Text = Content,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        TextTransparency = 0.6,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Bottom,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 23),
                        Size = UDim2.new(1, -180, 0, 12),
                        Name = "InputContent",
                        Parent = Input
                    }
                )

                local function UpdateInputSize()
                    local Ratio = InputContent.TextBounds.X / InputContent.AbsoluteSize.X
                    local Calculated = 12 + (12 * math.floor(Ratio))

                    InputContent.Size = UDim2.new(1, -180, 0, Calculated)
                    Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
                end

                UpdateInputSize()

                InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                    function()
                        InputContent.TextWrapped = false
                        UpdateInputSize()
                        InputContent.TextWrapped = true
                        UpdateSizeSection()
                    end
                )

                local InputFrame =
                    Custom:Create(
                    "Frame",
                    {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.95,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Position = UDim2.new(1, -7, 0.5, 0),
                        Size = UDim2.new(0, 148, 0, 30),
                        Name = "InputFrame"
                    },
                    Input
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    InputFrame
                )

                local InputTextBox =
                    Custom:Create(
                    "TextBox",
                    {
                        CursorPosition = -1,
                        Font = Enum.Font.GothamBold,
                        PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
                        PlaceholderText = "Write your input there",
                        Text = "",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 5, 0.5, 0),
                        Size = UDim2.new(1, -10, 1, -8),
                        Name = "InputTextBox"
                    },
                    InputFrame
                )

                function Funcs_Input:Set(Value, skipSave)
                    InputTextBox.Text = Value
                    Funcs_Input.Value = Value
                    Callback(Value)
                    if not skipSave and Custom.AutoSaveEnabled then
                        Custom:SaveConfig()
                    end
                end

                function Funcs_Input:SetSaveEnabled(enabled)
                    Custom:SetConfigSaveEnabled(Title, enabled)
                end

                Custom:RegisterConfigElement(
                    Title,
                    "Input",
                    function()
                        return Funcs_Input.Value
                    end,
                    function(value)
                        Funcs_Input:Set(value, true)
                    end,
                    SaveConfig
                )

                InputTextBox.FocusLost:Connect(
                    function()
                        Funcs_Input:Set(InputTextBox.Text)
                    end
                )

                Funcs_Input:Set(Default, true)

                ItemCount = ItemCount + 1
                return Funcs_Input
            end

            function Item:AddDropdown(Config)
                local Title = Config[1] or Config.Title or ""
                local Content = Config[2] or Config.Content or ""
                local Multi = Config[3] or Config.Multi or false
                local Options = Config[4] or Config.Options or {}
                local Default = Config[5] or Config.Default or {}
                local Callback = Config[6] or Config.Callback or function()
                    end
                local SaveConfig = Config.SaveConfig ~= false

                local Funcs_Dropdown = {Value = Default, Options = Options}

                local Dropdown =
                    Custom:Create(
                    "Frame",
                    {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.935,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        LayoutOrder = ItemCount,
                        Size = UDim2.new(1, 0, 0, 35),
                        Name = "Dropdown"
                    },
                    SectionAdd
                )

                local DropdownButton =
                    Custom:Create(
                    "TextButton",
                    {
                        Font = Enum.Font.SourceSans,
                        Text = "",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextSize = 14,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 0.999,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        Name = "ToggleButton"
                    },
                    Dropdown
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    Dropdown
                )

                local DropdownTitle =
                    Custom:Create(
                    "TextLabel",
                    {
                        Font = Enum.Font.GothamBold,
                        Text = Title,
                        TextColor3 = Color3.fromRGB(230, 230, 230),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 10),
                        Size = UDim2.new(1, -180, 0, 13),
                        Name = "DropdownTitle",
                        Parent = Dropdown
                    }
                )

                local DropdownContent =
                    Custom:Create(
                    "TextLabel",
                    {
                        Font = Enum.Font.GothamBold,
                        Text = Content,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        TextTransparency = 0.6,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Bottom,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 10, 0, 23),
                        Size = UDim2.new(1, -180, 0, 12),
                        Name = "DropdownContent",
                        Parent = Dropdown
                    }
                )

                DropdownContent.Size =
                    UDim2.new(
                    1,
                    -180,
                    0,
                    12 + (12 * math.floor(DropdownContent.TextBounds.X / DropdownContent.AbsoluteSize.X))
                )
                DropdownContent.TextWrapped = true
                Dropdown.Size = UDim2.new(1, 0, 0, DropdownContent.AbsoluteSize.Y + 33)

                DropdownContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                    function()
                        DropdownContent.TextWrapped = false

                        DropdownContent.Size =
                            UDim2.new(
                            1,
                            -180,
                            0,
                            12 + (12 * math.floor(DropdownContent.TextBounds.X / DropdownContent.AbsoluteSize.X))
                        )
                        Dropdown.Size = UDim2.new(1, 0, 0, DropdownContent.AbsoluteSize.Y + 33)

                        DropdownContent.TextWrapped = true

                        UpdateSizeSection()
                    end
                )

                local SelectOptionsFrame =
                    Custom:Create(
                    "Frame",
                    {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.95,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -7, 0.5, 0),
                        Size = UDim2.new(0, 148, 0, 30),
                        Name = "SelectOptionsFrame",
                        LayoutOrder = CountDropdown
                    },
                    Dropdown
                )

                Custom:Create(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 4)
                    },
                    SelectOptionsFrame
                )

                DropdownButton.Activated:Connect(
                    function()
                        if not MoreBlur.Visible then
                            MoreBlur.Visible = true

                            local tweenInfo = TweenInfo.new(0.1)

                            DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)

                            local BlurTween = TweenService:Create(MoreBlur, tweenInfo, {BackgroundTransparency = 0.7})
                            local DropdownTween =
                                TweenService:Create(DropdownSelect, tweenInfo, {Position = UDim2.new(1, -11, 0.5, 0)})

                            BlurTween:Play()
                            DropdownTween:Play()
                        end
                    end
                )

                local OptionSelecting =
                    Custom:Create(
                    "TextLabel",
                    {
                        Font = Enum.Font.GothamBold,
                        Text = "",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        TextTransparency = 0.6,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 5, 0.5, 0),
                        Size = UDim2.new(1, -30, 1, -8),
                        Name = "OptionSelecting"
                    },
                    SelectOptionsFrame
                )

                local OptionImg =
                    Custom:Create(
                    "ImageLabel",
                    {
                        Image = "rbxassetid://90200523188815",
                        ImageColor3 = Color3.fromRGB(231, 231, 231),
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.new(0, 25, 0, 25),
                        Name = "OptionImg"
                    },
                    SelectOptionsFrame
                )

                local ScrollSelect =
                    Custom:Create(
                    "ScrollingFrame",
                    {
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
                        ScrollBarThickness = 0,
                        Active = true,
                        LayoutOrder = CountDropdown,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.999,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        Name = "ScrollSelect"
                    },
                    DropdownFolder
                )

                Custom:Create(
                    "UIListLayout",
                    {
                        Padding = UDim.new(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    },
                    ScrollSelect
                )

                local SearchBar =
                    Custom:Create(
                    "TextBox",
                    {
                        Font = Enum.Font.GothamBold,
                        PlaceholderText = "Search",
                        PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
                        Text = "",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 0.9,
                        BorderColor3 = Color3.fromRGB(255, 0, 0),
                        BorderSizePixel = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        Name = "SearchBar"
                    },
                    ScrollSelect
                )

                SearchBar:GetPropertyChangedSignal("Text"):Connect(
                    function()
                        local SearchText = string.lower(SearchBar.Text)

                        for _, v in pairs(ScrollSelect:GetChildren()) do
                            if v:IsA("Frame") and v.Name == "Option" then
                                local OptionText = v:FindFirstChild("OptionText")
                                if OptionText then
                                    local matches = string.find(string.lower(OptionText.Text), SearchText) ~= nil
                                    v.Visible = matches
                                end
                            end
                        end
                    end
                )

                local DropCount = 0

                function Funcs_Dropdown:Clear()
                    for _, DropFrame in pairs(ScrollSelect:GetChildren()) do
                        if DropFrame.Name == "Option" then
                            Funcs_Dropdown.Value = {}
                            Funcs_Dropdown.Options = {}
                            OptionSelecting.Text = "Select Options"
                            DropFrame:Destroy()
                        end
                    end
                end

                function Funcs_Dropdown:Set(Value, skipSave)
                    Funcs_Dropdown.Value = Value or Funcs_Dropdown.Value

                    for _, Drop in pairs(ScrollSelect:GetChildren()) do
                        if Drop.Name ~= "UIListLayout" and Drop.Name ~= "SearchBar" then
                            local isTextFound = table.find(Funcs_Dropdown.Value, Drop.OptionText.Text)
                            local tweenInfoInOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

                            local Size = isTextFound and UDim2.new(0, 1, 0, 12) or UDim2.new(0, 0, 0, 0)
                            local BackgroundTransparency = isTextFound and 0.935 or 0.999
                            local Transparency = isTextFound and 0 or 0.999

                            TweenService:Create(Drop.ChooseFrame, tweenInfoInOut, {Size = Size}):Play()
                            TweenService:Create(
                                Drop.ChooseFrame.UIStroke,
                                tweenInfoInOut,
                                {Transparency = Transparency}
                            ):Play()
                            TweenService:Create(Drop, tweenInfoInOut, {BackgroundTransparency = BackgroundTransparency}):Play(

                            )
                        end
                    end

                    local DropdownValueTable = table.concat(Funcs_Dropdown.Value, ", ")
                    OptionSelecting.Text = DropdownValueTable ~= "" and DropdownValueTable or "Select Options"
                    Callback(Funcs_Dropdown.Value)

                    if not skipSave and Custom.AutoSaveEnabled then
                        Custom:SaveConfig()
                    end
                end

                function Funcs_Dropdown:AddOption(OptionName)
                    OptionName = OptionName or "Option"

                    local Option =
                        Custom:Create(
                        "Frame",
                        {
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 0.999,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            LayoutOrder = DropCount,
                            Size = UDim2.new(1, 0, 0, 30),
                            Name = "Option"
                        },
                        ScrollSelect
                    )

                    Custom:Create(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(0, 3)
                        },
                        Option
                    )

                    local OptionButton =
                        Custom:Create(
                        "TextButton",
                        {
                            Font = Enum.Font.GothamBold,
                            Text = "",
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 0.999,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 1, 0),
                            Name = "OptionButton"
                        },
                        Option
                    )

                    Custom:Create(
                        "TextLabel",
                        {
                            Font = Enum.Font.GothamBold,
                            Text = OptionName,
                            TextSize = 13,
                            TextColor3 = Color3.fromRGB(230, 230, 230),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Top,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 0.999,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 8, 0, 8),
                            Size = UDim2.new(1, -100, 0, 13),
                            Name = "OptionText"
                        },
                        Option
                    )

                    local ChooseFrame =
                        Custom:Create(
                        "Frame",
                        {
                            AnchorPoint = Vector2.new(0, 0.5),
                            BackgroundColor3 = Custom.ColorRGB,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 2, 0.5, 0),
                            Size = UDim2.new(0, 0, 0, 0),
                            Name = "ChooseFrame"
                        },
                        Option
                    )
                    Custom:RegisterAccentElement(ChooseFrame, "BackgroundColor3")

                    local ChooseFrameStroke =
                        Custom:Create(
                        "UIStroke",
                        {
                            Color = Custom.ColorRGB,
                            Thickness = 1.6,
                            Transparency = 0.999
                        },
                        ChooseFrame
                    )
                    Custom:RegisterAccentElement(ChooseFrameStroke, "Color")

                    Custom:Create("UICorner", {}, ChooseFrame)

                    OptionButton.Activated:Connect(
                        function()
                            CircleClick(OptionButton, Player:GetMouse().X, Player:GetMouse().Y)

                            local isOptionSelected = Option.BackgroundTransparency > 0.95

                            if Multi then
                                if isOptionSelected then
                                    if not table.find(Funcs_Dropdown.Value, OptionName) then
                                        table.insert(Funcs_Dropdown.Value, OptionName)
                                    end
                                else
                                    for i, value in ipairs(Funcs_Dropdown.Value) do
                                        if value == OptionName then
                                            table.remove(Funcs_Dropdown.Value, i)
                                            break
                                        end
                                    end
                                end
                            else
                                Funcs_Dropdown.Value = {OptionName}
                            end

                            Funcs_Dropdown:Set(Funcs_Dropdown.Value)
                        end
                    )

                    local function UpdateCanvasSize()
                        local OffsetY = 0

                        for _, child in ipairs(ScrollSelect:GetChildren()) do
                            if child.Name ~= "UIListLayout" and child.Name ~= "SearchBar" then
                                OffsetY = OffsetY + 5 + child.Size.Y.Offset
                            end
                        end

                        ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
                    end

                    UpdateCanvasSize()

                    DropCount = DropCount + 1
                end

                function Funcs_Dropdown:Refresh(RefreshList, Selecting)
                    RefreshList = RefreshList or {}
                    Selecting = Selecting or {}

                    Funcs_Dropdown:Clear()

                    for _, Drop in ipairs(RefreshList) do
                        Funcs_Dropdown:AddOption(Drop)
                    end

                    Funcs_Dropdown.Options = RefreshList
                    Funcs_Dropdown:Set(Selecting)
                end

                function Funcs_Dropdown:SetOptions(NewOptions)
                    Funcs_Dropdown:Refresh(NewOptions, {})
                end

                Funcs_Dropdown:Refresh(Funcs_Dropdown.Options, Funcs_Dropdown.Value)

                function Funcs_Dropdown:SetSaveEnabled(enabled)
                    Custom:SetConfigSaveEnabled(Title, enabled)
                end

                Custom:RegisterConfigElement(
                    Title,
                    "Dropdown",
                    function()
                        return Funcs_Dropdown.Value
                    end,
                    function(value)
                        Funcs_Dropdown:Set(value, true)
                    end,
                    SaveConfig
                )

                ItemCount = ItemCount + 1
                CountDropdown = CountDropdown + 1
                return Funcs_Dropdown
            end

            function Item:AddBackgroundTheme(Config)
                local Title = Config[1] or Config.Title or "Background & Color"
                local Content = Config[2] or Config.Content or "Pick UI theme and color"
                local Default = Config[3] or Config.Default or {"Dark Gray"}
                local Callback = Config[4] or Config.Callback or function()
                    end

                local Themes = {
                    ["Pure Black"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(0, 0, 0),
                        AccentColor = Color3.fromRGB(255, 255, 255)
                    },
                    ["Jet Black"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(5, 5, 5),
                        AccentColor = Color3.fromRGB(255, 215, 0)
                    },
                    ["Obsidian"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(8, 8, 8),
                        AccentColor = Color3.fromRGB(180, 180, 180)
                    },
                    ["Onyx"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 10, 10),
                        AccentColor = Color3.fromRGB(255, 100, 100)
                    },
                    ["Dark Gray"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(15, 15, 15),
                        AccentColor = Color3.fromRGB(255, 140, 0)
                    },
                    ["Charcoal"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(25, 25, 25),
                        AccentColor = Color3.fromRGB(200, 200, 200)
                    },
                    ["Graphite"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(30, 30, 30),
                        AccentColor = Color3.fromRGB(100, 200, 255)
                    },
                    ["Steel Gray"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(28, 30, 32),
                        AccentColor = Color3.fromRGB(150, 160, 170)
                    },
                    ["Gunmetal"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(35, 38, 42),
                        AccentColor = Color3.fromRGB(255, 80, 80)
                    },
                    ["Dark Slate"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(20, 22, 25),
                        AccentColor = Color3.fromRGB(120, 140, 160)
                    },
                    ["Ash Gray"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(40, 40, 40),
                        AccentColor = Color3.fromRGB(255, 200, 100)
                    },
                    ["Shadow"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(18, 18, 20),
                        AccentColor = Color3.fromRGB(150, 100, 255)
                    },
                    ["Smoke"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(45, 45, 48),
                        AccentColor = Color3.fromRGB(80, 200, 255)
                    },
                    ["Iron"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(38, 40, 45),
                        AccentColor = Color3.fromRGB(255, 150, 50)
                    },
                    ["Slate"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(50, 55, 60),
                        AccentColor = Color3.fromRGB(100, 255, 200)
                    },
                    ["Dark Blue"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 20, 40),
                        AccentColor = Color3.fromRGB(50, 150, 255)
                    },
                    ["Navy"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(15, 25, 45),
                        AccentColor = Color3.fromRGB(30, 60, 150)
                    },
                    ["Midnight Blue"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(12, 12, 30),
                        AccentColor = Color3.fromRGB(100, 150, 255)
                    },
                    ["Royal Blue"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(20, 30, 60),
                        AccentColor = Color3.fromRGB(100, 180, 255)
                    },
                    ["Cobalt"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(15, 25, 50),
                        AccentColor = Color3.fromRGB(80, 160, 255)
                    },
                    ["Sapphire"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 15, 45),
                        AccentColor = Color3.fromRGB(60, 120, 255)
                    },
                    ["Electric Blue"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(8, 20, 45),
                        AccentColor = Color3.fromRGB(0, 200, 255)
                    },
                    ["Steel Blue"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(25, 35, 55),
                        AccentColor = Color3.fromRGB(100, 180, 220)
                    },
                    ["Prussian Blue"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(5, 15, 35),
                        AccentColor = Color3.fromRGB(40, 100, 200)
                    },
                    ["Oxford Blue"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(8, 12, 28),
                        AccentColor = Color3.fromRGB(80, 140, 255)
                    },
                    ["Denim"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(20, 35, 60),
                        AccentColor = Color3.fromRGB(150, 200, 255)
                    },
                    ["Azure"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(15, 30, 55),
                        AccentColor = Color3.fromRGB(0, 180, 255)
                    },
                    ["Dark Purple"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(25, 10, 40),
                        AccentColor = Color3.fromRGB(150, 70, 255)
                    },
                    ["Dark Violet"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(22, 8, 30),
                        AccentColor = Color3.fromRGB(180, 80, 255)
                    },
                    ["Dark Indigo"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(18, 10, 35),
                        AccentColor = Color3.fromRGB(100, 80, 255)
                    },
                    ["Dark Magenta"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(30, 10, 30),
                        AccentColor = Color3.fromRGB(255, 100, 255)
                    },
                    ["Plum"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(35, 15, 40),
                        AccentColor = Color3.fromRGB(200, 100, 200)
                    },
                    ["Eggplant"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(28, 10, 32),
                        AccentColor = Color3.fromRGB(180, 120, 255)
                    },
                    ["Grape"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(40, 18, 50),
                        AccentColor = Color3.fromRGB(220, 140, 255)
                    },
                    ["Amethyst"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(30, 15, 45),
                        AccentColor = Color3.fromRGB(160, 90, 255)
                    },
                    ["Orchid"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(38, 20, 48),
                        AccentColor = Color3.fromRGB(200, 130, 255)
                    },
                    ["Mauve"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(35, 22, 40),
                        AccentColor = Color3.fromRGB(180, 140, 200)
                    },
                    ["Lavender"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(32, 25, 45),
                        AccentColor = Color3.fromRGB(200, 180, 255)
                    },
                    ["Iris"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(25, 18, 42),
                        AccentColor = Color3.fromRGB(140, 110, 255)
                    },
                    ["Dark Red"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(40, 10, 10),
                        AccentColor = Color3.fromRGB(255, 70, 70)
                    },
                    ["Dark Crimson"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(35, 8, 12),
                        AccentColor = Color3.fromRGB(220, 50, 70)
                    },
                    ["Maroon"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(45, 12, 15),
                        AccentColor = Color3.fromRGB(255, 100, 100)
                    },
                    ["Burgundy"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(50, 15, 20),
                        AccentColor = Color3.fromRGB(255, 120, 130)
                    },
                    ["Wine"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(42, 10, 18),
                        AccentColor = Color3.fromRGB(255, 80, 100)
                    },
                    ["Blood Red"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(55, 8, 8),
                        AccentColor = Color3.fromRGB(255, 50, 50)
                    },
                    ["Cherry"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(48, 12, 15),
                        AccentColor = Color3.fromRGB(255, 90, 110)
                    },
                    ["Mahogany"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(40, 18, 15),
                        AccentColor = Color3.fromRGB(200, 100, 80)
                    },
                    ["Scarlet"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(50, 10, 12),
                        AccentColor = Color3.fromRGB(255, 60, 60)
                    },
                    ["Ruby"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(45, 8, 18),
                        AccentColor = Color3.fromRGB(255, 50, 80)
                    },
                    ["Carmine"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(52, 12, 20),
                        AccentColor = Color3.fromRGB(255, 70, 90)
                    },
                    ["Garnet"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(38, 10, 15),
                        AccentColor = Color3.fromRGB(200, 60, 80)
                    },
                    ["Dark Green"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 30, 15),
                        AccentColor = Color3.fromRGB(50, 200, 100)
                    },
                    ["Dark Emerald"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(8, 28, 18),
                        AccentColor = Color3.fromRGB(40, 220, 120)
                    },
                    ["Forest Green"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(12, 35, 18),
                        AccentColor = Color3.fromRGB(60, 180, 100)
                    },
                    ["Hunter Green"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(15, 40, 20),
                        AccentColor = Color3.fromRGB(80, 200, 120)
                    },
                    ["Jungle"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 32, 22),
                        AccentColor = Color3.fromRGB(50, 220, 140)
                    },
                    ["Dark Lime"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(18, 28, 10),
                        AccentColor = Color3.fromRGB(150, 255, 80)
                    },
                    ["Moss"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(25, 38, 18),
                        AccentColor = Color3.fromRGB(120, 200, 80)
                    },
                    ["Olive"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(32, 35, 15),
                        AccentColor = Color3.fromRGB(180, 200, 60)
                    },
                    ["Pine"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(8, 25, 15),
                        AccentColor = Color3.fromRGB(40, 160, 100)
                    },
                    ["Fern"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(15, 35, 20),
                        AccentColor = Color3.fromRGB(80, 220, 100)
                    },
                    ["Jade"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 30, 25),
                        AccentColor = Color3.fromRGB(50, 200, 150)
                    },
                    ["Sage"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(28, 38, 25),
                        AccentColor = Color3.fromRGB(140, 180, 120)
                    },
                    ["Dark Orange"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(35, 20, 10),
                        AccentColor = Color3.fromRGB(255, 150, 50)
                    },
                    ["Dark Amber"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(30, 22, 8),
                        AccentColor = Color3.fromRGB(255, 180, 50)
                    },
                    ["Rust"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(45, 22, 12),
                        AccentColor = Color3.fromRGB(255, 120, 60)
                    },
                    ["Bronze"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(40, 28, 15),
                        AccentColor = Color3.fromRGB(220, 160, 80)
                    },
                    ["Copper"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(45, 25, 15),
                        AccentColor = Color3.fromRGB(255, 140, 80)
                    },
                    ["Burnt Orange"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(50, 25, 10),
                        AccentColor = Color3.fromRGB(255, 130, 40)
                    },
                    ["Terracotta"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(48, 28, 18),
                        AccentColor = Color3.fromRGB(220, 120, 80)
                    },
                    ["Caramel"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(42, 30, 15),
                        AccentColor = Color3.fromRGB(255, 180, 100)
                    },
                    ["Honey"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(40, 32, 12),
                        AccentColor = Color3.fromRGB(255, 200, 80)
                    },
                    ["Mustard"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(45, 38, 10),
                        AccentColor = Color3.fromRGB(255, 220, 60)
                    },
                    ["Gold"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(38, 30, 8),
                        AccentColor = Color3.fromRGB(255, 215, 0)
                    },
                    ["Ochre"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(50, 35, 15),
                        AccentColor = Color3.fromRGB(200, 160, 60)
                    },
                    ["Deep Brown"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(25, 18, 12),
                        AccentColor = Color3.fromRGB(200, 120, 60)
                    },
                    ["Chocolate"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(35, 20, 12),
                        AccentColor = Color3.fromRGB(180, 100, 50)
                    },
                    ["Coffee"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(30, 22, 15),
                        AccentColor = Color3.fromRGB(200, 140, 80)
                    },
                    ["Espresso"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(28, 18, 12),
                        AccentColor = Color3.fromRGB(180, 120, 70)
                    },
                    ["Walnut"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(32, 22, 15),
                        AccentColor = Color3.fromRGB(160, 100, 60)
                    },
                    ["Chestnut"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(38, 20, 15),
                        AccentColor = Color3.fromRGB(200, 110, 80)
                    },
                    ["Cocoa"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(30, 20, 18),
                        AccentColor = Color3.fromRGB(180, 130, 100)
                    },
                    ["Mocha"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(35, 25, 20),
                        AccentColor = Color3.fromRGB(200, 150, 110)
                    },
                    ["Umber"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(40, 25, 18),
                        AccentColor = Color3.fromRGB(180, 120, 80)
                    },
                    ["Sepia"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(42, 28, 20),
                        AccentColor = Color3.fromRGB(200, 140, 90)
                    },
                    ["Dark Teal"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 30, 30),
                        AccentColor = Color3.fromRGB(50, 180, 160)
                    },
                    ["Dark Cyan"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 25, 30),
                        AccentColor = Color3.fromRGB(50, 200, 200)
                    },
                    ["Dark Turquoise"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(8, 28, 28),
                        AccentColor = Color3.fromRGB(60, 220, 200)
                    },
                    ["Peacock"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(8, 32, 35),
                        AccentColor = Color3.fromRGB(40, 180, 180)
                    },
                    ["Petrol"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(12, 28, 32),
                        AccentColor = Color3.fromRGB(60, 160, 180)
                    },
                    ["Aegean"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 30, 38),
                        AccentColor = Color3.fromRGB(50, 180, 200)
                    },
                    ["Aquamarine"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(8, 32, 32),
                        AccentColor = Color3.fromRGB(100, 255, 220)
                    },
                    ["Cerulean"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(10, 28, 35),
                        AccentColor = Color3.fromRGB(80, 200, 255)
                    },
                    ["Dark Coral"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(30, 15, 15),
                        AccentColor = Color3.fromRGB(255, 120, 100)
                    },
                    ["Dark Rose"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(35, 15, 22),
                        AccentColor = Color3.fromRGB(255, 100, 130)
                    },
                    ["Dark Pink"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(38, 15, 28),
                        AccentColor = Color3.fromRGB(255, 120, 180)
                    },
                    ["Raspberry"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(40, 12, 25),
                        AccentColor = Color3.fromRGB(255, 80, 140)
                    },
                    ["Magenta Dark"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(38, 10, 32),
                        AccentColor = Color3.fromRGB(255, 80, 200)
                    },
                    ["Fuchsia"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(42, 12, 35),
                        AccentColor = Color3.fromRGB(255, 100, 220)
                    },
                    ["Cerise"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(45, 10, 30),
                        AccentColor = Color3.fromRGB(255, 60, 160)
                    },
                    ["Blush"] = {
                        Type = "Solid",
                        Color1 = Color3.fromRGB(40, 25, 30),
                        AccentColor = Color3.fromRGB(255, 180, 200)
                    },
                    ["Blue Gradient"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 20, 45),
                        Color2 = Color3.fromRGB(25, 60, 120),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(80, 180, 255)
                    },
                    ["Ocean"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(5, 25, 55),
                        Color2 = Color3.fromRGB(15, 70, 110),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(60, 220, 255)
                    },
                    ["Deep Sea"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(3, 18, 45),
                        Color2 = Color3.fromRGB(12, 50, 90),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(80, 200, 255)
                    },
                    ["Arctic"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 25, 40),
                        Color2 = Color3.fromRGB(20, 55, 75),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(140, 220, 255)
                    },
                    ["Sapphire Dream"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(5, 15, 50),
                        Color2 = Color3.fromRGB(20, 45, 100),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 160, 255)
                    },
                    ["Navy Depths"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 15, 35),
                        Color2 = Color3.fromRGB(25, 40, 80),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(60, 120, 255)
                    },
                    ["Cobalt Rush"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 20, 55),
                        Color2 = Color3.fromRGB(30, 60, 120),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(80, 200, 255)
                    },
                    ["Ice Storm"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 30, 50),
                        Color2 = Color3.fromRGB(35, 70, 100),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(180, 230, 255)
                    },
                    ["Midnight Ocean"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(5, 10, 30),
                        Color2 = Color3.fromRGB(15, 35, 70),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(50, 150, 255)
                    },
                    ["Pacific"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 25, 50),
                        Color2 = Color3.fromRGB(20, 65, 110),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 200, 255)
                    },
                    ["Azure Sky"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 28, 55),
                        Color2 = Color3.fromRGB(30, 70, 120),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(120, 200, 255)
                    },
                    ["Steel Wave"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(18, 25, 40),
                        Color2 = Color3.fromRGB(40, 55, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 180, 220)
                    },
                    ["Purple Gradient"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(35, 8, 55),
                        Color2 = Color3.fromRGB(90, 30, 140),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 100, 255)
                    },
                    ["Cosmic"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 8, 40),
                        Color2 = Color3.fromRGB(60, 30, 100),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(200, 140, 255)
                    },
                    ["Twilight"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(20, 12, 45),
                        Color2 = Color3.fromRGB(70, 35, 100),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 130, 255)
                    },
                    ["Vaporwave"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(25, 8, 45),
                        Color2 = Color3.fromRGB(70, 30, 100),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 120, 255)
                    },
                    ["Galaxy"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 10, 35),
                        Color2 = Color3.fromRGB(30, 20, 60),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(200, 150, 255)
                    },
                    ["Nebula"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(20, 8, 50),
                        Color2 = Color3.fromRGB(60, 25, 100),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(220, 120, 255)
                    },
                    ["Violet Storm"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(25, 10, 45),
                        Color2 = Color3.fromRGB(80, 40, 120),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(200, 100, 255)
                    },
                    ["Amethyst Cave"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(18, 12, 40),
                        Color2 = Color3.fromRGB(55, 35, 95),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(160, 120, 255)
                    },
                    ["Grape Crush"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(30, 12, 50),
                        Color2 = Color3.fromRGB(80, 35, 110),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(220, 140, 255)
                    },
                    ["Mystic"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(22, 15, 42),
                        Color2 = Color3.fromRGB(65, 40, 100),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 160, 255)
                    },
                    ["Ultraviolet"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(28, 8, 55),
                        Color2 = Color3.fromRGB(75, 25, 130),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 80, 255)
                    },
                    ["Lavender Fields"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(30, 25, 50),
                        Color2 = Color3.fromRGB(70, 55, 100),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(200, 180, 255)
                    },
                    ["Sunset"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 15, 50),
                        Color2 = Color3.fromRGB(120, 50, 30),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 150, 50)
                    },
                    ["Fire"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 8, 5),
                        Color2 = Color3.fromRGB(140, 50, 15),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 120, 40)
                    },
                    ["Lava"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 10, 8),
                        Color2 = Color3.fromRGB(100, 40, 20),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 100, 50)
                    },
                    ["Magma"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(40, 10, 8),
                        Color2 = Color3.fromRGB(95, 35, 20),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 140, 70)
                    },
                    ["Volcano"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 10, 5),
                        Color2 = Color3.fromRGB(90, 20, 10),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(255, 80, 30)
                    },
                    ["Amber Glow"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(35, 22, 8),
                        Color2 = Color3.fromRGB(90, 60, 20),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 200, 100)
                    },
                    ["Inferno"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(55, 8, 5),
                        Color2 = Color3.fromRGB(150, 45, 10),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 100, 20)
                    },
                    ["Ember"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 15, 10),
                        Color2 = Color3.fromRGB(110, 45, 25),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(255, 140, 60)
                    },
                    ["Crimson Tide"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 8, 12),
                        Color2 = Color3.fromRGB(120, 25, 35),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 60, 80)
                    },
                    ["Blood Moon"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 5, 10),
                        Color2 = Color3.fromRGB(100, 15, 25),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(255, 50, 70)
                    },
                    ["Mars"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(55, 15, 10),
                        Color2 = Color3.fromRGB(130, 40, 25),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 120, 80)
                    },
                    ["Phoenix"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 10, 5),
                        Color2 = Color3.fromRGB(140, 60, 20),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(255, 180, 60)
                    },
                    ["Rust Belt"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(40, 18, 12),
                        Color2 = Color3.fromRGB(90, 45, 30),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(220, 140, 80)
                    },
                    ["Autumn"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 20, 10),
                        Color2 = Color3.fromRGB(100, 55, 25),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(255, 180, 80)
                    },
                    ["Forest"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 30, 18),
                        Color2 = Color3.fromRGB(25, 75, 40),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(80, 230, 130)
                    },
                    ["Emerald Dream"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(5, 35, 25),
                        Color2 = Color3.fromRGB(20, 80, 50),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(80, 255, 160)
                    },
                    ["Toxic"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 30, 10),
                        Color2 = Color3.fromRGB(35, 70, 25),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 255, 120)
                    },
                    ["Jungle"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 35, 20),
                        Color2 = Color3.fromRGB(25, 80, 45),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(100, 255, 140)
                    },
                    ["Matrix"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(5, 25, 8),
                        Color2 = Color3.fromRGB(15, 60, 20),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(0, 255, 65)
                    },
                    ["Neon Green"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 30, 10),
                        Color2 = Color3.fromRGB(30, 80, 30),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 255, 100)
                    },
                    ["Rainforest"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 32, 22),
                        Color2 = Color3.fromRGB(22, 75, 50),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(60, 220, 140)
                    },
                    ["Moss Garden"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 30, 15),
                        Color2 = Color3.fromRGB(40, 70, 40),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(140, 200, 100)
                    },
                    ["Poison"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 35, 8),
                        Color2 = Color3.fromRGB(45, 90, 20),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(160, 255, 80)
                    },
                    ["Swamp"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 28, 18),
                        Color2 = Color3.fromRGB(35, 65, 45),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(100, 180, 120)
                    },
                    ["Envy"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 30, 20),
                        Color2 = Color3.fromRGB(25, 70, 50),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(80, 200, 140)
                    },
                    ["Mint Fresh"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 35, 30),
                        Color2 = Color3.fromRGB(30, 85, 75),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(120, 255, 220)
                    },
                    ["Mint"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 40, 38),
                        Color2 = Color3.fromRGB(25, 90, 85),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(80, 230, 220)
                    },
                    ["Aurora"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 35, 50),
                        Color2 = Color3.fromRGB(30, 90, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 255, 220)
                    },
                    ["Cyber"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 25, 35),
                        Color2 = Color3.fromRGB(20, 60, 70),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(0, 255, 220)
                    },
                    ["Teal Wave"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 30, 35),
                        Color2 = Color3.fromRGB(22, 75, 85),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(60, 220, 220)
                    },
                    ["Aqua Dream"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 35, 40),
                        Color2 = Color3.fromRGB(28, 85, 95),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 255, 240)
                    },
                    ["Lagoon"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 28, 32),
                        Color2 = Color3.fromRGB(20, 70, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(80, 200, 220)
                    },
                    ["Oasis"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 32, 38),
                        Color2 = Color3.fromRGB(25, 80, 90),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(120, 240, 255)
                    },
                    ["Turquoise Sea"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 35, 38),
                        Color2 = Color3.fromRGB(22, 85, 90),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(80, 255, 240)
                    },
                    ["Frost"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 30, 40),
                        Color2 = Color3.fromRGB(40, 70, 90),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(160, 220, 255)
                    },
                    ["Glacier"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 28, 38),
                        Color2 = Color3.fromRGB(35, 65, 85),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(140, 210, 255)
                    },
                    ["Atlantis"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 30, 45),
                        Color2 = Color3.fromRGB(20, 75, 100),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(60, 200, 255)
                    },
                    ["Mermaid"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 35, 40),
                        Color2 = Color3.fromRGB(30, 90, 85),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 255, 230)
                    },
                    ["Rose"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 10, 35),
                        Color2 = Color3.fromRGB(120, 40, 75),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 130, 200)
                    },
                    ["Neon Pink"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(40, 5, 35),
                        Color2 = Color3.fromRGB(100, 20, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 80, 220)
                    },
                    ["Candy"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 10, 40),
                        Color2 = Color3.fromRGB(100, 30, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 120, 230)
                    },
                    ["Sakura"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(40, 15, 25),
                        Color2 = Color3.fromRGB(70, 25, 45),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 150, 200)
                    },
                    ["Flamingo"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 12, 35),
                        Color2 = Color3.fromRGB(110, 35, 70),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 120, 180)
                    },
                    ["Hot Pink"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 8, 38),
                        Color2 = Color3.fromRGB(110, 25, 85),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(255, 80, 200)
                    },
                    ["Blush Pink"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 20, 35),
                        Color2 = Color3.fromRGB(90, 50, 70),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(255, 180, 210)
                    },
                    ["Magenta Madness"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 8, 42),
                        Color2 = Color3.fromRGB(120, 25, 95),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 100, 240)
                    },
                    ["Cherry Blossom"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 18, 30),
                        Color2 = Color3.fromRGB(85, 40, 60),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 160, 200)
                    },
                    ["Bubblegum"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 15, 45),
                        Color2 = Color3.fromRGB(100, 40, 90),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 150, 255)
                    },
                    ["Valentine"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(55, 10, 30),
                        Color2 = Color3.fromRGB(130, 30, 65),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(255, 100, 150)
                    },
                    ["Raspberry Rush"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 8, 32),
                        Color2 = Color3.fromRGB(120, 25, 70),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 80, 160)
                    },
                    ["Synthwave"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(20, 5, 50),
                        Color2 = Color3.fromRGB(80, 20, 100),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(255, 100, 255)
                    },
                    ["Retrowave"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(25, 8, 45),
                        Color2 = Color3.fromRGB(100, 30, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 150, 200)
                    },
                    ["Cyberpunk"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 8, 35),
                        Color2 = Color3.fromRGB(60, 25, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 255, 0)
                    },
                    ["Neon Nights"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 5, 30),
                        Color2 = Color3.fromRGB(40, 15, 70),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(0, 255, 255)
                    },
                    ["Electric"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 15, 35),
                        Color2 = Color3.fromRGB(25, 45, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(0, 200, 255)
                    },
                    ["Plasma"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(30, 5, 45),
                        Color2 = Color3.fromRGB(90, 20, 100),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(200, 80, 255)
                    },
                    ["Storm"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 18, 30),
                        Color2 = Color3.fromRGB(45, 50, 75),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(150, 180, 255)
                    },
                    ["Thunder"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 15, 28),
                        Color2 = Color3.fromRGB(40, 45, 70),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 255, 150)
                    },
                    ["Lightning"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 12, 25),
                        Color2 = Color3.fromRGB(35, 40, 65),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(255, 255, 100)
                    },
                    ["Shadow Realm"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 8, 15),
                        Color2 = Color3.fromRGB(25, 25, 45),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(180, 150, 255)
                    },
                    ["Void"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(5, 5, 10),
                        Color2 = Color3.fromRGB(20, 20, 35),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(150, 100, 255)
                    },
                    ["Abyss"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(3, 5, 15),
                        Color2 = Color3.fromRGB(15, 20, 45),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(100, 150, 255)
                    },
                    ["Eclipse"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 8, 20),
                        Color2 = Color3.fromRGB(35, 28, 55),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 200, 100)
                    },
                    ["Starlight"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 15, 35),
                        Color2 = Color3.fromRGB(35, 45, 80),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(255, 255, 200)
                    },
                    ["Moonlight"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 18, 30),
                        Color2 = Color3.fromRGB(40, 48, 70),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(200, 220, 255)
                    },
                    ["Northern Lights"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 25, 35),
                        Color2 = Color3.fromRGB(25, 70, 60),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(100, 255, 200)
                    },
                    ["Southern Cross"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 15, 40),
                        Color2 = Color3.fromRGB(35, 40, 90),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 255, 150)
                    },
                    ["Supernova"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(35, 10, 45),
                        Color2 = Color3.fromRGB(100, 40, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 150, 200)
                    },
                    ["Black Hole"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(5, 3, 10),
                        Color2 = Color3.fromRGB(20, 15, 35),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(180, 100, 255)
                    },
                    ["Wormhole"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 8, 35),
                        Color2 = Color3.fromRGB(50, 30, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(150, 255, 200)
                    },
                    ["Quantum"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 15, 30),
                        Color2 = Color3.fromRGB(35, 50, 75),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(100, 200, 255)
                    },
                    ["Dimension"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 10, 28),
                        Color2 = Color3.fromRGB(40, 35, 70),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(200, 150, 255)
                    },
                    ["Spectrum"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(30, 15, 45),
                        Color2 = Color3.fromRGB(70, 40, 90),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 180, 255)
                    },
                    ["Prism"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(20, 15, 40),
                        Color2 = Color3.fromRGB(55, 45, 85),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(255, 200, 255)
                    },
                    ["Crystal"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 20, 35),
                        Color2 = Color3.fromRGB(40, 55, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(200, 230, 255)
                    },
                    ["Diamond"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(18, 22, 38),
                        Color2 = Color3.fromRGB(50, 60, 90),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(220, 240, 255)
                    },
                    ["Ruby Glow"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 8, 15),
                        Color2 = Color3.fromRGB(100, 25, 40),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 80, 120)
                    },
                    ["Emerald Shine"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 35, 25),
                        Color2 = Color3.fromRGB(25, 85, 60),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 255, 180)
                    },
                    ["Sapphire Glow"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 18, 50),
                        Color2 = Color3.fromRGB(25, 50, 110),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 180, 255)
                    },
                    ["Topaz"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(40, 28, 10),
                        Color2 = Color3.fromRGB(95, 70, 30),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 200, 100)
                    },
                    ["Opal"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(20, 25, 35),
                        Color2 = Color3.fromRGB(55, 65, 85),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(200, 220, 255)
                    },
                    ["Jade Garden"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 35, 28),
                        Color2 = Color3.fromRGB(30, 85, 65),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(100, 255, 200)
                    },
                    ["Obsidian Night"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 8, 12),
                        Color2 = Color3.fromRGB(25, 25, 38),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(150, 150, 200)
                    },
                    ["Onyx Depths"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(5, 5, 8),
                        Color2 = Color3.fromRGB(18, 18, 28),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(200, 200, 255)
                    },
                    ["Pearl"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(30, 32, 38),
                        Color2 = Color3.fromRGB(70, 75, 85),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(255, 255, 255)
                    },
                    ["Titanium"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(25, 28, 35),
                        Color2 = Color3.fromRGB(60, 68, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 200, 255)
                    },
                    ["Chrome"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(30, 32, 38),
                        Color2 = Color3.fromRGB(75, 80, 90),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(220, 230, 255)
                    },
                    ["Platinum"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(28, 30, 36),
                        Color2 = Color3.fromRGB(68, 72, 82),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(240, 245, 255)
                    },
                    ["Bronze Age"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(35, 25, 15),
                        Color2 = Color3.fromRGB(85, 60, 40),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(220, 160, 100)
                    },
                    ["Golden Hour"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(40, 30, 12),
                        Color2 = Color3.fromRGB(95, 75, 35),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 215, 100)
                    },
                    ["Silver Moon"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(22, 25, 32),
                        Color2 = Color3.fromRGB(55, 60, 72),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(200, 210, 230)
                    },
                    ["Copper Sunset"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(45, 28, 15),
                        Color2 = Color3.fromRGB(100, 65, 40),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 160, 100)
                    },
                    ["Iron Forge"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(25, 22, 20),
                        Color2 = Color3.fromRGB(60, 55, 50),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 150, 80)
                    },
                    ["Steel Night"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(20, 25, 32),
                        Color2 = Color3.fromRGB(50, 58, 70),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(150, 180, 220)
                    },
                    ["Dark Matter"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(5, 5, 12),
                        Color2 = Color3.fromRGB(18, 18, 35),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 120, 255)
                    },
                    ["Anti-Matter"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 5, 18),
                        Color2 = Color3.fromRGB(28, 18, 50),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(255, 180, 255)
                    },
                    ["Event Horizon"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(3, 3, 8),
                        Color2 = Color3.fromRGB(12, 12, 28),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 150, 100)
                    },
                    ["Solar Flare"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(50, 20, 5),
                        Color2 = Color3.fromRGB(120, 55, 20),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 200, 80)
                    },
                    ["Lunar Eclipse"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 12, 25),
                        Color2 = Color3.fromRGB(45, 38, 65),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(255, 180, 120)
                    },
                    ["Comet Trail"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 15, 35),
                        Color2 = Color3.fromRGB(35, 48, 85),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 220, 255)
                    },
                    ["Asteroid Belt"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(18, 18, 25),
                        Color2 = Color3.fromRGB(48, 48, 62),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(200, 180, 150)
                    },
                    ["Meteor Shower"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 10, 22),
                        Color2 = Color3.fromRGB(38, 32, 58),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 200, 150)
                    },
                    ["Stardust"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 18, 32),
                        Color2 = Color3.fromRGB(45, 52, 78),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 220, 200)
                    },
                    ["Cosmic Dust"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(18, 15, 28),
                        Color2 = Color3.fromRGB(50, 42, 70),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(220, 180, 255)
                    },
                    ["Space Dust"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 12, 22),
                        Color2 = Color3.fromRGB(35, 35, 55),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 200, 255)
                    },
                    ["Interstellar"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(8, 10, 25),
                        Color2 = Color3.fromRGB(28, 35, 65),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(150, 200, 255)
                    },
                    ["Galactic Core"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(20, 15, 35),
                        Color2 = Color3.fromRGB(55, 45, 85),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 200, 255)
                    },
                    ["Milky Way"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 15, 28),
                        Color2 = Color3.fromRGB(38, 45, 72),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(220, 230, 255)
                    },
                    ["Andromeda"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 12, 32),
                        Color2 = Color3.fromRGB(45, 38, 80),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(200, 180, 255)
                    },
                    ["Orion"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(10, 18, 35),
                        Color2 = Color3.fromRGB(32, 55, 90),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(150, 220, 255)
                    },
                    ["Centauri"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 15, 30),
                        Color2 = Color3.fromRGB(45, 45, 75),
                        Rotation = 180,
                        AccentColor = Color3.fromRGB(200, 200, 255)
                    },
                    ["Sirius"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 18, 38),
                        Color2 = Color3.fromRGB(38, 55, 95),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 230, 255)
                    },
                    ["Polaris"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(15, 20, 35),
                        Color2 = Color3.fromRGB(45, 58, 85),
                        Rotation = 90,
                        AccentColor = Color3.fromRGB(220, 240, 255)
                    },
                    ["Vega"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(18, 15, 35),
                        Color2 = Color3.fromRGB(52, 45, 85),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(200, 180, 255)
                    },
                    ["Betelgeuse"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(40, 15, 12),
                        Color2 = Color3.fromRGB(95, 40, 32),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 140, 100)
                    },
                    ["Rigel"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(12, 20, 45),
                        Color2 = Color3.fromRGB(35, 58, 105),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(180, 220, 255)
                    },
                    ["Arcturus"] = {
                        Type = "Gradient",
                        Color1 = Color3.fromRGB(38, 22, 12),
                        Color2 = Color3.fromRGB(88, 55, 35),
                        Rotation = 135,
                        AccentColor = Color3.fromRGB(255, 180, 120)
                    }
                }

                local ThemeOptions = {}
                for themeName, _ in pairs(Themes) do
                    table.insert(ThemeOptions, themeName)
                end
                table.sort(ThemeOptions)

                local defaultThemeName = Default[1]
                local defaultTheme = Themes[defaultThemeName]
                if defaultTheme then
                    if defaultTheme.Type == "Gradient" then
                        Funcs.BackgroundGradient.Enabled = true
                        Funcs.BackgroundGradient.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0, defaultTheme.Color1),
                            ColorSequenceKeypoint.new(1, defaultTheme.Color2)
                        }
                        Funcs.BackgroundGradient.Rotation = defaultTheme.Rotation
                        Funcs.Main.BackgroundColor3 = defaultTheme.Color1
                    else
                        Funcs.BackgroundGradient.Enabled = false
                        Funcs.Main.BackgroundColor3 = defaultTheme.Color1
                    end
                    Custom:UpdateAllAccentColors(defaultTheme.AccentColor)
                end

                local ThemeDropdown =
                    Item:AddDropdown(
                    {
                        Title = Title,
                        Content = Content,
                        Multi = false,
                        Options = ThemeOptions,
                        Default = Default,
                        Callback = function(selected)
                            local themeName = selected[1]
                            local theme = Themes[themeName]

                            if not theme then
                                return
                            end

                            if theme.Type == "Gradient" then
                                Funcs.BackgroundGradient.Enabled = true
                                Funcs.BackgroundGradient.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0, theme.Color1),
                                    ColorSequenceKeypoint.new(1, theme.Color2)
                                }
                                Funcs.BackgroundGradient.Rotation = theme.Rotation
                                Funcs.Main.BackgroundColor3 = theme.Color1
                            else
                                Funcs.BackgroundGradient.Enabled = false
                                Funcs.Main.BackgroundColor3 = theme.Color1
                            end

                            Custom:UpdateAllAccentColors(theme.AccentColor)
                            Callback(themeName, theme.AccentColor)
                        end
                    }
                )

                return ThemeDropdown
            end

            function Item:AddTransparencySlider(Config)
                local Title = Config[1] or Config.Title or "UI Transparency"
                local Content = Config[2] or Config.Content or "Adjust transparency"
                local Default = Config[3] or Config.Default or 0.1
                local Callback = Config[4] or Config.Callback or function()
                    end

                if Funcs.Main then
                    Funcs.Main.BackgroundTransparency = Default
                end

                local TransparencySlider =
                    Item:AddSlider(
                    {
                        Title = Title,
                        Content = Content,
                        Increment = 0.01,
                        Min = 0,
                        Max = 0.95,
                        Default = Default,
                        Callback = function(value)
                            if Funcs.Main then
                                Funcs.Main.BackgroundTransparency = value
                                Callback(value)
                            end
                        end
                    }
                )

                return TransparencySlider
            end

            function Item:AddFontSelector(Config)
                local Title = Config[1] or Config.Title or "Font Style"
                local Content = Config[2] or Config.Content or "Change UI font"
                local Default = Config[3] or Config.Default or {"GothamBold"}
                local Callback = Config[4] or Config.Callback or function()
                    end

                if not Funcs.AllTextElements then
                    Funcs.AllTextElements = {}
                end

                local Fonts = {
                    ["GothamBold"] = Enum.Font.GothamBold,
                    ["Gotham"] = Enum.Font.Gotham,
                    ["Ubuntu"] = Enum.Font.Ubuntu,
                    ["SourceSansBold"] = Enum.Font.SourceSansBold,
                    ["SourceSans"] = Enum.Font.SourceSans,
                    ["ArialBold"] = Enum.Font.ArialBold,
                    ["Arial"] = Enum.Font.Arial,
                    ["FredokaOne"] = Enum.Font.FredokaOne,
                    ["Cartoon"] = Enum.Font.Cartoon,
                    ["Code"] = Enum.Font.Code,
                    ["Fantasy"] = Enum.Font.Fantasy,
                    ["Arcade"] = Enum.Font.Arcade
                }

                local FontOptions = {
                    "GothamBold",
                    "Gotham",
                    "Ubuntu",
                    "SourceSansBold",
                    "SourceSans",
                    "ArialBold",
                    "Arial",
                    "FredokaOne",
                    "Cartoon",
                    "Code",
                    "Fantasy",
                    "Arcade"
                }

                local function RegisterAllTextElements(parent)
                    for _, descendant in ipairs(parent:GetDescendants()) do
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                            if not table.find(Funcs.AllTextElements, descendant) then
                                table.insert(Funcs.AllTextElements, descendant)
                            end
                        end
                    end
                end

                RegisterAllTextElements(Funcs.Main)

                local defaultFontName = Default[1]
                local defaultFont = Fonts[defaultFontName]
                if defaultFont then
                    for _, textElement in ipairs(Funcs.AllTextElements) do
                        if textElement and textElement.Parent then
                            textElement.Font = defaultFont
                        end
                    end
                end

                local FontDropdown =
                    Item:AddDropdown(
                    {
                        Title = Title,
                        Content = Content,
                        Multi = false,
                        Options = FontOptions,
                        Default = Default,
                        Callback = function(selected)
                            local fontName = selected[1]
                            local newFont = Fonts[fontName]

                            if newFont then
                                RegisterAllTextElements(Funcs.Main)

                                for _, textElement in ipairs(Funcs.AllTextElements) do
                                    if textElement and textElement.Parent then
                                        textElement.Font = newFont
                                    end
                                end
                                Callback(fontName, newFont)
                            end
                        end
                    }
                )

                return FontDropdown
            end

            function Item:AddTextColorSelector(Config)
                local Title = Config[1] or Config.Title or "Text Color"
                local Content = Config[2] or Config.Content or "Change text color"
                local Default = Config[3] or Config.Default or {"White"}
                local Callback = Config[4] or Config.Callback or function()
                    end

                if not Funcs.AllTextElements then
                    Funcs.AllTextElements = {}
                end

                local TextColors = {
                    ["White"] = Color3.fromRGB(255, 255, 255),
                    ["Light Gray"] = Color3.fromRGB(200, 200, 200),
                    ["Silver"] = Color3.fromRGB(180, 180, 180),
                    ["Gray"] = Color3.fromRGB(150, 150, 150),
                    ["Red"] = Color3.fromRGB(255, 80, 80),
                    ["Light Red"] = Color3.fromRGB(255, 120, 120),
                    ["Dark Red"] = Color3.fromRGB(200, 60, 60),
                    ["Orange"] = Color3.fromRGB(255, 150, 50),
                    ["Light Orange"] = Color3.fromRGB(255, 180, 100),
                    ["Yellow"] = Color3.fromRGB(255, 255, 100),
                    ["Gold"] = Color3.fromRGB(255, 215, 0),
                    ["Light Green"] = Color3.fromRGB(150, 255, 150),
                    ["Green"] = Color3.fromRGB(80, 255, 80),
                    ["Lime"] = Color3.fromRGB(180, 255, 80),
                    ["Cyan"] = Color3.fromRGB(80, 255, 255),
                    ["Light Blue"] = Color3.fromRGB(150, 200, 255),
                    ["Blue"] = Color3.fromRGB(80, 150, 255),
                    ["Purple"] = Color3.fromRGB(180, 100, 255),
                    ["Light Purple"] = Color3.fromRGB(200, 150, 255),
                    ["Magenta"] = Color3.fromRGB(255, 100, 255),
                    ["Pink"] = Color3.fromRGB(255, 150, 200),
                    ["Light Pink"] = Color3.fromRGB(255, 200, 220),
                    ["Peach"] = Color3.fromRGB(255, 200, 180),
                    ["Cream"] = Color3.fromRGB(255, 250, 230),
                    ["Mint"] = Color3.fromRGB(180, 255, 220),
                    ["Coral"] = Color3.fromRGB(255, 130, 120),
                    ["Salmon"] = Color3.fromRGB(255, 160, 140),
                    ["Lavender"] = Color3.fromRGB(220, 200, 255),
                    ["Sky Blue"] = Color3.fromRGB(135, 206, 250),
                    ["Turquoise"] = Color3.fromRGB(64, 224, 208)
                }

                local ColorOptions = {}
                for colorName, _ in pairs(TextColors) do
                    table.insert(ColorOptions, colorName)
                end
                table.sort(ColorOptions)

                local function RegisterAllTextElements(parent)
                    for _, descendant in ipairs(parent:GetDescendants()) do
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                            if not table.find(Funcs.AllTextElements, descendant) then
                                table.insert(Funcs.AllTextElements, descendant)
                            end
                        end
                    end
                end

                RegisterAllTextElements(Funcs.Main)

                local defaultColorName = Default[1]
                local defaultColor = TextColors[defaultColorName]
                if defaultColor then
                    for _, textElement in ipairs(Funcs.AllTextElements) do
                        if textElement and textElement.Parent then
                            textElement.TextColor3 = defaultColor
                        end
                    end
                end

                local ColorDropdown =
                    Item:AddDropdown(
                    {
                        Title = Title,
                        Content = Content,
                        Multi = false,
                        Options = ColorOptions,
                        Default = Default,
                        Callback = function(selected)
                            local colorName = selected[1]
                            local newColor = TextColors[colorName]

                            if newColor then
                                RegisterAllTextElements(Funcs.Main)

                                for _, textElement in ipairs(Funcs.AllTextElements) do
                                    if textElement and textElement.Parent then
                                        textElement.TextColor3 = newColor
                                    end
                                end
                                Callback(colorName, newColor)
                            end
                        end
                    }
                )

                return ColorDropdown
            end

            function Item:AddTextSizeSelector(Config)
                local Title = Config[1] or Config.Title or "Text Size"
                local Content = Config[2] or Config.Content or "Adjust text size"
                local Default = Config[3] or Config.Default or 0
                local Callback = Config[4] or Config.Callback or function()
                    end

                if not Funcs.AllTextElements then
                    Funcs.AllTextElements = {}
                end

                if not Funcs.OriginalTextSizes then
                    Funcs.OriginalTextSizes = {}
                end

                local function RegisterAllTextElements(parent)
                    for _, descendant in ipairs(parent:GetDescendants()) do
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                            if not table.find(Funcs.AllTextElements, descendant) then
                                table.insert(Funcs.AllTextElements, descendant)
                                Funcs.OriginalTextSizes[descendant] = descendant.TextSize
                            end
                        end
                    end
                end

                RegisterAllTextElements(Funcs.Main)

                local function ApplyTextSizeOffset(offset)
                    RegisterAllTextElements(Funcs.Main)

                    for _, textElement in ipairs(Funcs.AllTextElements) do
                        if textElement and textElement.Parent then
                            local originalSize = Funcs.OriginalTextSizes[textElement] or textElement.TextSize
                            local newSize = math.max(8, math.min(36, originalSize + offset))
                            textElement.TextSize = newSize
                        end
                    end
                end

                if Default ~= 0 then
                    ApplyTextSizeOffset(Default)
                end

                local TextSizeSlider =
                    Item:AddSlider(
                    {
                        Title = Title,
                        Content = Content,
                        Increment = 1,
                        Min = -6,
                        Max = 12,
                        Default = Default,
                        Callback = function(value)
                            ApplyTextSizeOffset(value)
                            Callback(value)
                        end
                    }
                )

                return TextSizeSlider
            end

            ItemCount = ItemCount + 1
            return Item
        end

        CountTab = CountTab + 1
        return DirectItem
    end

    local SettingsTab =
        Tabs:CreateTab(
        {
            Name = "Settings",
            Icon = "rbxassetid://10734950309",
            IsSettingsTab = true
        }
    )

    SettingsTab:AddParagraph(
        {
            Title = "UI Settings",
            Content = "Customize the look and behavior of this UI"
        }
    )

    local ThemeSection = SettingsTab:AddSection("Theme Settings", false)

    ThemeSection:AddBackgroundTheme(
        {
            Title = "Background Theme",
            Content = "Select UI theme and accent color",
            Default = {"Dark Gray"},
            Callback = function(theme, color)
            end
        }
    )

    ThemeSection:AddTransparencySlider(
        {
            Title = "UI Transparency",
            Content = "Adjust window transparency",
            Default = 0.1,
            Callback = function(value)
            end
        }
    )

    ThemeSection:AddFontSelector(
        {
            Title = "Font Style",
            Content = "Change UI font",
            Default = {"GothamBold"},
            Callback = function(fontName)
            end
        }
    )

    local BackgroundSection = SettingsTab:AddSection("Custom Background", false)

    local bgState = {
        enabled = Custom.BackgroundEnabled or false,
        imagePath = Custom.CurrentBackgroundImage,
        videoPath = Custom.CurrentBackgroundVideo,
        bgType = Custom.BackgroundType or "none",
        imageOptions = {},
        videoOptions = {}
    }

    local function ClearBackground()
        if Funcs.BackgroundImage then
            Funcs.BackgroundImage:Destroy()
            Funcs.BackgroundImage = nil
        end
        if Funcs.BackgroundVideo then
            Funcs.BackgroundVideo:Destroy()
            Funcs.BackgroundVideo = nil
        end
    end

    local function ApplyBGImage(filePath, forceApply)
        if not Funcs.Main then return false end

        local assetId = Custom:GetCustomAsset(filePath)
        if not assetId then return false end

        bgState.imagePath = filePath
        bgState.bgType = "image"
        Custom.CurrentBackgroundImage = filePath
        Custom.BackgroundType = "image"
        Custom:SaveSettings()

        if bgState.enabled or forceApply then
            ClearBackground()
            Funcs.BackgroundImage = Custom:Create(
                "ImageLabel",
                {
                    Image = assetId,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    ScaleType = Enum.ScaleType.Crop,
                    ImageTransparency = 0.4,
                    ZIndex = -10,
                    Name = "BackgroundImage"
                },
                Funcs.Main
            )
        end
        return true
    end

    local function ApplyBGVideo(filePath, forceApply)
        if not Funcs.Main then return false end

        local assetId = Custom:GetCustomAsset(filePath)
        if not assetId then return false end

        bgState.videoPath = filePath
        bgState.bgType = "video"
        Custom.CurrentBackgroundVideo = filePath
        Custom.BackgroundType = "video"
        Custom:SaveSettings()

        if bgState.enabled or forceApply then
            ClearBackground()
            local ext = filePath:lower():match("%.([^%.]+)$") or ""
            if ext == "webp" or ext == "gif" then
                Funcs.BackgroundImage = Custom:Create(
                    "ImageLabel",
                    {
                        Image = assetId,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        ScaleType = Enum.ScaleType.Crop,
                        ImageTransparency = 0.4,
                        ZIndex = -10,
                        Name = "BackgroundImage"
                    },
                    Funcs.Main
                )
            else
                local vf = Custom:Create(
                    "VideoFrame",
                    {
                        Video = assetId,
                        Looped = true,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        ZIndex = -10,
                        Name = "BackgroundVideo"
                    },
                    Funcs.Main
                )
                Funcs.BackgroundVideo = vf
                vf:Play()
            end
        end
        return true
    end

    local function GetImageOptions()
        local images = Custom:GetLocalImages()
        local options = {}
        bgState.imageOptions = {}
        for _, img in ipairs(images) do
            table.insert(options, img.Name)
            bgState.imageOptions[img.Name] = img.Path
        end
        if #options == 0 then
            table.insert(options, "No images/GIFs found")
        end
        return options
    end

    local function GetVideoOptions()
        local videos = Custom:GetLocalVideos()
        local options = {}
        bgState.videoOptions = {}
        for _, vid in ipairs(videos) do
            table.insert(options, vid.Name)
            bgState.videoOptions[vid.Name] = vid.Path
        end
        if #options == 0 then
            table.insert(options, "No videos found")
        end
        return options
    end

    local BGToggle =
        BackgroundSection:AddToggle(
        {
            Title = "Enable Background",
            Content = "Show custom image or video behind UI",
            Default = bgState.enabled,
            SaveConfig = false,
            Callback = function(enabled)
                bgState.enabled = enabled
                Custom.BackgroundEnabled = enabled
                Custom:SaveSettings()

                if enabled then
                    if bgState.bgType == "video" and bgState.videoPath then
                        ApplyBGVideo(bgState.videoPath, true)
                    elseif bgState.bgType == "image" and bgState.imagePath then
                        ApplyBGImage(bgState.imagePath, true)
                    end
                else
                    if Funcs.BackgroundVideo then
                        Funcs.BackgroundVideo:Pause()
                        Funcs.BackgroundVideo.Visible = false
                    end
                    if Funcs.BackgroundImage then
                        Funcs.BackgroundImage.Visible = false
                    end
                end
            end
        }
    )

    local BGImageDropdown =
        BackgroundSection:AddDropdown(
        {
            Title = "Select Image / GIF",
            Content = "Choose a local image or GIF as background",
            Multi = false,
            Options = GetImageOptions(),
            Default = {},
            SaveConfig = false,
            Callback = function(selected)
                local name = selected[1]
                if name and bgState.imageOptions[name] then
                    ApplyBGImage(bgState.imageOptions[name], true)
                    BGToggle:Set(true)
                end
            end
        }
    )

    local BGVideoDropdown =
        BackgroundSection:AddDropdown(
        {
            Title = "Select Video",
            Content = "Choose a local .webm video as background",
            Multi = false,
            Options = GetVideoOptions(),
            Default = {},
            SaveConfig = false,
            Callback = function(selected)
                local name = selected[1]
                if name and bgState.videoOptions[name] then
                    ApplyBGVideo(bgState.videoOptions[name], true)
                    BGToggle:Set(true)
                end
            end
        }
    )

    local BGImageInput =
        BackgroundSection:AddInput(
        {
            Title = "Download Image / GIF URL",
            Content = "Paste a direct URL and press Enter to download",
            Default = "",
            SaveConfig = false,
            Callback = function(url)
                if url == "" then return end

                local fileName = url:match("([^/\\]+)$") or ("image_" .. os.time() .. ".png")
                if not fileName:match("%.%w+$") then
                    fileName = fileName .. ".png"
                end

                local fullURL = url
                if url:match("^github%.com") or url:match("^raw%.githubusercontent%.com") then
                    fullURL = "https://" .. url
                elseif not url:match("^https?://") then
                    fullURL = "https://raw.githubusercontent.com/" .. url
                end

                local success, filePath = Custom:DownloadImage(fullURL, fileName)
                if success and filePath then
                    BGImageDropdown:Refresh(GetImageOptions())
                    ApplyBGImage(filePath, true)
                    BGToggle:Set(true)
                end
            end
        }
    )

    local BGVideoInput =
        BackgroundSection:AddInput(
        {
            Title = "Download Video URL",
            Content = "Paste a direct .webm URL and press Enter to download",
            Default = "",
            SaveConfig = false,
            Callback = function(url)
                if url == "" then return end

                local fileName = url:match("([^/\\]+)$") or ("video_" .. os.time() .. ".webm")
                if not fileName:match("%.%w+$") then
                    fileName = fileName .. ".webm"
                end

                local fullURL = url
                if url:match("^github%.com") or url:match("^raw%.githubusercontent%.com") then
                    fullURL = "https://" .. url
                elseif not url:match("^https?://") then
                    fullURL = "https://raw.githubusercontent.com/" .. url
                end

                local success, filePath = Custom:DownloadVideo(fullURL, fileName)
                if success and filePath then
                    BGVideoDropdown:Refresh(GetVideoOptions())
                    ApplyBGVideo(filePath, true)
                    BGToggle:Set(true)
                end
            end
        }
    )

    task.defer(
        function()
            Custom:LoadSettings()
            bgState.enabled = Custom.BackgroundEnabled or false
            bgState.imagePath = Custom.CurrentBackgroundImage
            bgState.videoPath = Custom.CurrentBackgroundVideo
            bgState.bgType = Custom.BackgroundType or "none"

            BGToggle:Set(bgState.enabled, true)
            BGImageDropdown:Refresh(GetImageOptions())
            BGVideoDropdown:Refresh(GetVideoOptions())

            if bgState.enabled then
                if bgState.bgType == "video" and bgState.videoPath then
                    ApplyBGVideo(bgState.videoPath, true)
                elseif bgState.bgType == "image" and bgState.imagePath then
                    ApplyBGImage(bgState.imagePath, true)
                end
            end
        end
    )

    local ConfigSection = SettingsTab:AddSection("Configuration", false)

    ConfigSection:AddToggle(
        {
            Title = "Auto Save Configs",
            Content = "Automatically save settings when changed",
            Default = false,
            SaveConfig = false,
            Callback = function(value)
                Custom.AutoSaveEnabled = value
                if value then
                    Custom:SaveConfig()
                end
            end
        }
    )

    ConfigSection:AddToggle(
        {
            Title = "Auto Load Config",
            Content = "Automatically load selected config on script execution",
            Default = Custom.AutoLoadEnabled,
            SaveConfig = false,
            Callback = function(value)
                Custom.AutoLoadEnabled = value
                Custom:SaveSettings()
            end
        }
    )

    local ConfigNameInput =
        ConfigSection:AddInput(
        {
            Title = "Config Name",
            Content = "Name for your config file",
            Default = "default",
            SaveConfig = false,
            Callback = function(value)
                if value and value ~= "" then
                    Custom.ConfigFileName = Custom.ConfigFolder .. value .. ".json"
                end
            end
        }
    )

    ConfigSection:AddButton(
        {
            Title = "Save Config",
            Content = "Save current settings to file",
            Callback = function()
                local success = Custom:SaveConfig()
                if success and INFERNO_HUB.SetNotification then
                    INFERNO_HUB:SetNotification(
                        {
                            Title = "Config Saved",
                            Description = "Settings",
                            Content = "Configuration saved successfully",
                            Time = 0.5,
                            Delay = 2
                        }
                    )
                end
            end
        }
    )

    local function GetConfigFiles()
        local files = {}
        if listfiles then
            local success, result =
                pcall(
                function()
                    if makefolder and isfolder and not isfolder(Custom.ConfigFolder) then
                        makefolder(Custom.ConfigFolder)
                    end
                    return listfiles(Custom.ConfigFolder)
                end
            )
            if success and result then
                for _, file in ipairs(result) do
                    local name = file:match("([^/\\]+)%.json$")
                    if name then
                        table.insert(files, name)
                    end
                end
            end
        end
        if #files == 0 then
            table.insert(files, "default")
        end
        return files
    end

    local ConfigDropdown
    ConfigDropdown =
        ConfigSection:AddDropdown(
        {
            Title = "Load Config",
            Content = "Select a config to load (also sets auto-load target)",
            Multi = false,
            Options = GetConfigFiles(),
            Default = {Custom.AutoLoadConfigName or "default"},
            SaveConfig = false,
            Callback = function(selected)
                local configName = selected[1]
                if configName then
                    Custom.ConfigFileName = Custom.ConfigFolder .. configName .. ".json"
                    Custom.AutoLoadConfigName = configName
                    Custom:SaveSettings()
                    local success = Custom:LoadConfig()
                    if INFERNO_HUB.SetNotification then
                        INFERNO_HUB:SetNotification(
                            {
                                Title = success and "Config Loaded" or "Load Failed",
                                Description = "Settings",
                                Content = success and ("Loaded: " .. configName) or "Could not load config",
                                Time = 0.5,
                                Delay = 2
                            }
                        )
                    end
                end
            end
        }
    )

    ConfigSection:AddButton(
        {
            Title = "Refresh Config List",
            Content = "Update the list of available configs",
            Callback = function()
                if ConfigDropdown and ConfigDropdown.SetOptions then
                    ConfigDropdown:SetOptions(GetConfigFiles())
                end
                if INFERNO_HUB.SetNotification then
                    INFERNO_HUB:SetNotification(
                        {
                            Title = "List Refreshed",
                            Description = "Settings",
                            Content = "Config list updated",
                            Time = 0.5,
                            Delay = 1
                        }
                    )
                end
            end
        }
    )

    ConfigSection:AddButton(
        {
            Title = "Delete Current Config",
            Content = "Remove the selected config file",
            Callback = function()
                if delfile and isfile and isfile(Custom.ConfigFileName) then
                    local success =
                        pcall(
                        function()
                            delfile(Custom.ConfigFileName)
                        end
                    )
                    if success and INFERNO_HUB.SetNotification then
                        INFERNO_HUB:SetNotification(
                            {
                                Title = "Config Deleted",
                                Description = "Settings",
                                Content = "Config file removed",
                                Time = 0.5,
                                Delay = 2
                            }
                        )
                    end
                    if ConfigDropdown and ConfigDropdown.SetOptions then
                        ConfigDropdown:SetOptions(GetConfigFiles())
                    end
                end
            end
        }
    )

    task.defer(
        function()
            Custom:LoadSettings()

            if Custom.AutoLoadEnabled and Custom.AutoLoadConfigName then
                Custom.ConfigFileName = Custom.ConfigFolder .. Custom.AutoLoadConfigName .. ".json"
                local success = Custom:LoadConfig()
                if success and INFERNO_HUB.SetNotification then
                    INFERNO_HUB:SetNotification(
                        {
                            Title = "Auto-Loaded",
                            Description = "Config",
                            Content = "Loaded: " .. Custom.AutoLoadConfigName,
                            Time = 0.5,
                            Delay = 2
                        }
                    )
                end
            end

            if Custom.BackgroundEnabled and Funcs.Main then
                local bgType = Custom.BackgroundType or "none"
                if bgType == "video" and Custom.CurrentBackgroundVideo then
                    local assetId = Custom:GetCustomAsset(Custom.CurrentBackgroundVideo)
                    if assetId then
                        local vf = Custom:Create(
                            "VideoFrame",
                            {
                                Video = assetId,
                                Looped = true,
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, 0, 1, 0),
                                Position = UDim2.new(0, 0, 0, 0),
                                ZIndex = -10,
                                Name = "BackgroundVideo"
                            },
                            Funcs.Main
                        )
                        Funcs.BackgroundVideo = vf
                        vf:Play()
                    end
                elseif bgType == "image" and Custom.CurrentBackgroundImage then
                    local assetId = Custom:GetCustomAsset(Custom.CurrentBackgroundImage)
                    if assetId then
                        Funcs.BackgroundImage = Custom:Create(
                            "ImageLabel",
                            {
                                Image = assetId,
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, 0, 1, 0),
                                Position = UDim2.new(0, 0, 0, 0),
                                ScaleType = Enum.ScaleType.Crop,
                                ImageTransparency = 0.4,
                                ZIndex = -10,
                                Name = "BackgroundImage"
                            },
                            Funcs.Main
                        )
                    end
                end
            end
        end
    )

    return Tabs
end

return INFERNO_HUB
