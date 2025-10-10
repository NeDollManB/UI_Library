-- Roblox UI Library
-- Corrected for loadstring usage
-- This is a basic UI library inspired by the provided images and description.
-- It uses Roblox's built-in UI elements.

local Library = {}
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Constants
local UI_THEME = {
    Background = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(255, 0, 0),
    Text = Color3.fromRGB(255, 255, 255),
    Border = Color3.fromRGB(50, 50, 50),
    SectionBackground = Color3.fromRGB(40, 40, 40),
}

-- Main UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomUILib"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Status Bar (when UI is closed)
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 20)
StatusBar.Position = UDim2.new(0, 0, 1, -20)
StatusBar.BackgroundColor3 = UI_THEME.Accent
StatusBar.BorderSizePixel = 0
StatusBar.Parent = ScreenGui
StatusBar.Visible = false

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 1, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextColor3 = UI_THEME.Text
StatusText.Font = Enum.Font.SourceSansBold
StatusText.TextSize = 14
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBar

-- Update Status Bar
local CheatName = "@dLame_sheet"  -- Change this to your cheat name
local function UpdateStatus()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local time = os.date("%H:%M")
    StatusText.Text = CheatName .. " d111 " .. fps .. " fps " .. time
end
RunService.RenderStepped:Connect(UpdateStatus)

-- Main Window
function Library:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}
    Window.Visible = true
    Window.Title = title or "Untitled"

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = UI_THEME.Background
    MainFrame.BorderColor3 = UI_THEME.Border
    MainFrame.BorderSizePixel = 1
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = true

    -- Make draggable
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Title Label (top right)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.5, 0, 0, 30)
    TitleLabel.Position = UDim2.new(0.5, 0, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Window.Title
    TitleLabel.TextColor3 = UI_THEME.Text
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Right
    TitleLabel.Parent = MainFrame

    -- Tab Container (right side for tabs)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0.2, 0, 1, -30)
    TabContainer.Position = UDim2.new(0.8, 0, 0, 30)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Vertical
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer

    -- Content Container (left of tabs)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(0.8, 0, 1, -30)
    ContentContainer.Position = UDim2.new(0, 0, 0, 30)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    -- Section Container (top of content, horizontal for sections)
    local SectionContainer = Instance.new("ScrollingFrame")
    SectionContainer.Size = UDim2.new(1, 0, 0, 30)
    SectionContainer.Position = UDim2.new(0, 0, 0, 0)
    SectionContainer.BackgroundTransparency = 1
    SectionContainer.ScrollBarThickness = 0
    SectionContainer.ScrollingDirection = Enum.ScrollingDirection.X
    SectionContainer.Parent = ContentContainer
    SectionContainer.Visible = false

    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.FillDirection = Enum.FillDirection.Horizontal
    SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SectionLayout.Padding = UDim.new(0, 5)
    SectionLayout.Parent = SectionContainer

    -- Element Container (below sections)
    local ElementContainer = Instance.new("ScrollingFrame")
    ElementContainer.Size = UDim2.new(1, 0, 1, -30)
    ElementContainer.Position = UDim2.new(0, 0, 0, 30)
    ElementContainer.BackgroundTransparency = 1
    ElementContainer.ScrollBarThickness = 4
    ElementContainer.Parent = ContentContainer

    local ElementLayout = Instance.new("UIListLayout")
    ElementLayout.FillDirection = Enum.FillDirection.Vertical
    ElementLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ElementLayout.Padding = UDim.new(0, 5)
    ElementLayout.Parent = ElementContainer

    -- Function to show tab content
    local currentTab = nil
    local function ShowTab(tab)
        if currentTab then
            currentTab.Content.Visible = false
        end
        tab.Content.Visible = true
        currentTab = tab

        if #tab.Sections > 0 then
            SectionContainer.Visible = true
            ShowSection(tab.Sections[1])
        else
            SectionContainer.Visible = false
            ElementContainer.Visible = true
        end
    end

    local currentSection = nil
    local function ShowSection(section)
        if currentSection then
            currentSection.ElementContainer.Visible = false
            currentSection.Button.TextColor3 = UI_THEME.Text
        end
        section.ElementContainer.Visible = true
        section.Button.TextColor3 = UI_THEME.Accent
        currentSection = section
    end

    function Window:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Sections = {}
        Tab.Content = Instance.new("Frame")
        Tab.Content.Size = UDim2.new(1, 0, 1, 0)
        Tab.Content.BackgroundTransparency = 1
        Tab.Content.Parent = ContentContainer
        Tab.Content.Visible = false

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = UI_THEME.SectionBackground
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.TextColor3 = UI_THEME.Text
        TabButton.Font = Enum.Font.SourceSans
        TabButton.TextSize = 14
        TabButton.Parent = TabContainer

        TabButton.MouseButton1Click:Connect(function()
            ShowTab(Tab)
        end)

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            ShowTab(Tab)
        end

        function Tab:CreateSection(name)
            local Section = {}
            Section.Name = name
            Section.Elements = {}

            local SectionButton = Instance.new("TextButton")
            SectionButton.Size = UDim2.new(0, 100, 1, 0)
            SectionButton.BackgroundTransparency = 1
            SectionButton.Text = name
            SectionButton.TextColor3 = UI_THEME.Text
            SectionButton.Font = Enum.Font.SourceSansBold
            SectionButton.TextSize = 16
            SectionButton.Parent = SectionContainer
            Section.Button = SectionButton

            SectionButton.MouseButton1Click:Connect(function()
                ShowSection(Section)
            end)

            local SecElementContainer = Instance.new("ScrollingFrame")
            SecElementContainer.Size = UDim2.new(1, 0, 1, -30)
            SecElementContainer.Position = UDim2.new(0, 0, 0, 30)
            SecElementContainer.BackgroundTransparency = 1
            SecElementContainer.ScrollBarThickness = 4
            SecElementContainer.Parent = Tab.Content
            SecElementContainer.Visible = false

            local SecElementLayout = Instance.new("UIListLayout")
            SecElementLayout.FillDirection = Enum.FillDirection.Vertical
            SecElementLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SecElementLayout.Padding = UDim.new(0, 5)
            SecElementLayout.Parent = SecElementContainer

            Section.ElementContainer = SecElementContainer

            table.insert(Tab.Sections, Section)

            if #Tab.Sections == 1 then
                ShowSection(Section)
            end

            SectionButton.Size = UDim2.new(0, SectionButton.TextBounds.X + 20, 1, 0)

            function Section:CreateButton(name, callback)
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 30)
                Button.BackgroundColor3 = UI_THEME.SectionBackground
                Button.BorderSizePixel = 0
                Button.Text = name
                Button.TextColor3 = UI_THEME.Text
                Button.Font = Enum.Font.SourceSans
                Button.TextSize = 14
                Button.Parent = SecElementContainer

                Button.MouseButton1Click:Connect(callback or function() end)
            end

            function Section:CreateToggle(name, default, callback)
                local enabled = default or false

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = SecElementContainer

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(0.8, 0, 1, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = name
                ToggleLabel.TextColor3 = UI_THEME.Text
                ToggleLabel.Font = Enum.Font.SourceSans
                ToggleLabel.TextSize = 14
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(0, 20, 0, 20)
                ToggleButton.Position = UDim2.new(1, -30, 0.5, -10)
                ToggleButton.BackgroundColor3 = enabled and UI_THEME.Accent or UI_THEME.Border
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame

                ToggleButton.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = enabled and UI_THEME.Accent or UI_THEME.Border}):Play()
                    callback(enabled)
                end)
            end

            function Section:CreateInput(name, placeholder, callback)
                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, 0, 0, 30)
                InputFrame.BackgroundTransparency = 1
                InputFrame.Parent = SecElementContainer

                local InputLabel = Instance.new("TextLabel")
                InputLabel.Size = UDim2.new(0.5, 0, 1, 0)
                InputLabel.BackgroundTransparency = 1
                InputLabel.Text = name
                InputLabel.TextColor3 = UI_THEME.Text
                InputLabel.Font = Enum.Font.SourceSans
                InputLabel.TextSize = 14
                InputLabel.TextXAlignment = Enum.TextXAlignment.Left
                InputLabel.Parent = InputFrame

                local TextBox = Instance.new("TextBox")
                TextBox.Size = UDim2.new(0.5, 0, 1, 0)
                TextBox.Position = UDim2.new(0.5, 0, 0, 0)
                TextBox.BackgroundColor3 = UI_THEME.SectionBackground
                TextBox.BorderSizePixel = 0
                TextBox.Text = ""
                TextBox.PlaceholderText = placeholder or ""
                TextBox.TextColor3 = UI_THEME.Text
                TextBox.Font = Enum.Font.SourceSans
                TextBox.TextSize = 14
                TextBox.Parent = InputFrame

                TextBox.FocusLost:Connect(function(enter)
                    if enter then
                        callback(TextBox.Text)
                    end
                end)
            end

            function Section:CreateColorPicker(name, default, callback)
                local color = default or Color3.fromRGB(255, 255, 255)

                local PickerFrame = Instance.new("Frame")
                PickerFrame.Size = UDim2.new(1, 0, 0, 30)
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Parent = SecElementContainer

                local PickerLabel = Instance.new("TextLabel")
                PickerLabel.Size = UDim2.new(0.5, 0, 1, 0)
                PickerLabel.BackgroundTransparency = 1
                PickerLabel.Text = name
                PickerLabel.TextColor3 = UI_THEME.Text
                PickerLabel.Font = Enum.Font.SourceSans
                PickerLabel.TextSize = 14
                PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                PickerLabel.Parent = PickerFrame

                local ColorPreview = Instance.new("Frame")
                ColorPreview.Size = UDim2.new(0, 20, 0, 20)
                ColorPreview.Position = UDim2.new(0.5, 0, 0.5, -10)
                ColorPreview.BackgroundColor3 = color
                ColorPreview.BorderSizePixel = 0
                ColorPreview.Parent = PickerFrame

                local HexBox = Instance.new("TextBox")
                HexBox.Size = UDim2.new(0.4, 0, 1, 0)
                HexBox.Position = UDim2.new(0.6, 0, 0, 0)
                HexBox.BackgroundColor3 = UI_THEME.SectionBackground
                HexBox.BorderSizePixel = 0
                HexBox.Text = string.format("#%02X%02X%02X", color.R*255, color.G*255, color.B*255)
                HexBox.TextColor3 = UI_THEME.Text
                HexBox.Font = Enum.Font.SourceSans
                HexBox.TextSize = 14
                HexBox.Parent = PickerFrame

                HexBox.FocusLost:Connect(function()
                    local r, g, b = HexBox.Text:match("#(%x%x)(%x%x)(%x%x)")
                    if r and g and b then
                        color = Color3.fromRGB(tonumber(r,16), tonumber(g,16), tonumber(b,16))
                        ColorPreview.BackgroundColor3 = color
                        callback(color)
                    end
                end)
            end

            function Section:CreateSlider(name, min, max, default, callback)
                local value = default or min

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 30)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = SecElementContainer

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(0.5, 0, 1, 0)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = name .. ": " .. value
                SliderLabel.TextColor3 = UI_THEME.Text
                SliderLabel.Font = Enum.Font.SourceSans
                SliderLabel.TextSize = 14
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame

                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(0.5, 0, 0, 4)
                SliderBar.Position = UDim2.new(0.5, 0, 0.5, -2)
                SliderBar.BackgroundColor3 = UI_THEME.Border
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame

                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                SliderFill.BackgroundColor3 = UI_THEME.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBar

                local SliderButton = Instance.new("TextButton")
                SliderButton.Size = UDim2.new(0, 10, 0, 10)
                SliderButton.Position = UDim2.new((value - min) / (max - min), -5, 0.5, -5)
                SliderButton.BackgroundColor3 = UI_THEME.Text
                SliderButton.BorderSizePixel = 0
                SliderButton.Text = ""
                SliderButton.Parent = SliderFrame

                local draggingSlider = false
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                    end
                end)
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)
                UIS.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        value = min + (max - min) * relativeX
                        value = math.floor(value)
                        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                        SliderButton.Position = UDim2.new(relativeX, -5, 0.5, -5)
                        SliderLabel.Text = name .. ": " .. value
                        callback(value)
                    end
                end)
            end

            function Section:CreateDropdown(name, options, default, callback)
                local selected = default or options[1]

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Parent = SecElementContainer

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = UI_THEME.Text
                DropdownLabel.Font = Enum.Font.SourceSans
                DropdownLabel.TextSize = 14
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownFrame

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(0.5, 0, 1, 0)
                DropdownButton.Position = UDim2.new(0.5, 0, 0, 0)
                DropdownButton.BackgroundColor3 = UI_THEME.SectionBackground
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = selected
                DropdownButton.TextColor3 = UI_THEME.Text
                DropdownButton.Font = Enum.Font.SourceSans
                DropdownButton.TextSize = 14
                DropdownButton.Parent = DropdownFrame

                local DropdownList = Instance.new("ScrollingFrame")
                DropdownList.Size = UDim2.new(0.5, 0, 0, 100)
                DropdownList.Position = UDim2.new(0.5, 0, 1, 0)
                DropdownList.BackgroundColor3 = UI_THEME.Background
                DropdownList.BorderSizePixel = 1
                DropdownList.BorderColor3 = UI_THEME.Border
                DropdownList.ScrollBarThickness = 4
                DropdownList.Visible = false
                DropdownList.Parent = DropdownFrame

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.FillDirection = Enum.FillDirection.Vertical
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = DropdownList

                for _, opt in ipairs(options) do
                    local OptButton = Instance.new("TextButton")
                    OptButton.Size = UDim2.new(1, 0, 0, 20)
                    OptButton.BackgroundColor3 = UI_THEME.SectionBackground
                    OptButton.BorderSizePixel = 0
                    OptButton.Text = opt
                    OptButton.TextColor3 = UI_THEME.Text
                    OptButton.Font = Enum.Font.SourceSans
                    OptButton.TextSize = 14
                    OptButton.Parent = DropdownList

                    OptButton.MouseButton1Click:Connect(function()
                        selected = opt
                        DropdownButton.Text = selected
                        DropdownList.Visible = false
                        callback(selected)
                    end)
                end

                DropdownButton.MouseButton1Click:Connect(function()
                    DropdownList.Visible = not DropdownList.Visible
                end)
            end

            return Section
        end

        return Tab
    end

    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            Window.Visible = not Window.Visible
            MainFrame.Visible = Window.Visible
            StatusBar.Visible = not Window.Visible
        end
    end)

    return Window
end

return Library
