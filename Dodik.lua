-- Library: UI (Advanced Menu System)
-- Author: YourName
-- Version: 2.0

local UI = {}

-- Глобальные стили (под скриншот)
local DEFAULT_STYLE = {
    BackgroundColor3 = Color3.fromRGB(20, 20, 20), -- почти чёрный
    TextColor3 = Color3.fromRGB(255, 255, 255),   -- белый
    AccentColor = Color3.fromRGB(70, 130, 255),   -- синий акцент
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Padding = 8,
    CornerRadius = UDim.new(0, 6),
    TabHeight = 30,
    SectionPadding = 12,
    HeaderHeight = 40
}

-- Вспомогательные функции
local function createFrame(parent, name, size, pos, bgColor)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = bgColor or DEFAULT_STYLE.BackgroundColor3
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = DEFAULT_STYLE.CornerRadius
    corner.Parent = frame

    return frame
end

local function createTextLabel(parent, text, fontSize, textColor)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = DEFAULT_STYLE.Font
    label.TextSize = fontSize or DEFAULT_STYLE.TextSize
    label.TextColor3 = textColor or DEFAULT_STYLE.TextColor3
    label.BackgroundTransparency = 1
    label.Parent = parent
    return label
end

local function createTextButton(parent, text, size, callback)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Font = DEFAULT_STYLE.Font
    button.TextSize = DEFAULT_STYLE.TextSize
    button.TextColor3 = DEFAULT_STYLE.TextColor3
    button.BackgroundColor3 = DEFAULT_STYLE.AccentColor
    button.Size = size
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = DEFAULT_STYLE.CornerRadius
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return button
end

-- =========================
-- 📄 Menu (основной контейнер)
-- =========================
function UI.Menu(parent, config)
    local config = config or {}
    local title = config.title or "Menu"
    local size = config.size or UDim2.new(0, 300, 0, 400)
    local position = config.position or UDim2.new(0.5, -150, 0.5, -200)

    local menu = createFrame(parent, "UIMenu", size, position, DEFAULT_STYLE.BackgroundColor3)

    -- Header
    local header = createFrame(menu, "Header", UDim2.new(1, 0, 0, DEFAULT_STYLE.HeaderHeight), UDim2.new(0, 0, 0, 0))
    local titleLabel = createTextLabel(header, title, 18, DEFAULT_STYLE.TextColor3)
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Tabs Container
    local tabsContainer = createFrame(menu, "TabsContainer", UDim2.new(1, 0, 0, DEFAULT_STYLE.TabHeight), UDim2.new(0, 0, 0, DEFAULT_STYLE.HeaderHeight))

    -- Content Area
    local contentArea = createFrame(menu, "ContentArea", UDim2.new(1, 0, 1, -DEFAULT_STYLE.HeaderHeight - DEFAULT_STYLE.TabHeight), UDim2.new(0, 0, 0, DEFAULT_STYLE.HeaderHeight + DEFAULT_STYLE.TabHeight))

    -- Управление табами
    local activeTab = nil
    local tabButtons = {}
    local tabContents = {}

    local function switchTab(tabName)
        for name, content in pairs(tabContents) do
            content.Visible = (name == tabName)
        end
        for _, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = DEFAULT_STYLE.BackgroundColor3
            btn.TextColor3 = DEFAULT_STYLE.TextColor3
        end
        if tabButtons[tabName] then
            tabButtons[tabName].BackgroundColor3 = DEFAULT_STYLE.AccentColor
            tabButtons[tabName].TextColor3 = Color3.fromRGB(0, 0, 0) -- черный текст на синем
        end
        activeTab = tabName
    end

    -- Добавить таб
    local function addTab(name)
        local tabWidth = 100
        local tabIndex = #tabButtons + 1
        local button = createTextButton(tabsContainer, name, UDim2.new(0, tabWidth, 1, 0), UDim2.new(0, (tabIndex - 1) * tabWidth, 0, 0))
        button.BackgroundColor3 = DEFAULT_STYLE.BackgroundColor3
        button.TextColor3 = DEFAULT_STYLE.TextColor3

        local content = createFrame(contentArea, name .. "Content", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
        content.Visible = false
        tabContents[name] = content
        tabButtons[name] = button

        button.MouseButton1Click:Connect(function()
            switchTab(name)
        end)

        if not activeTab then
            switchTab(name)
        end

        return content
    end

    -- Добавить секцию в таб
    local function addSection(tabContent, title)
        local section = createFrame(tabContent, "Section", UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 0))
        section.AutomaticSize = Enum.AutomaticSize.Y

        local sectionTitle = createTextLabel(section, title, 16, DEFAULT_STYLE.TextColor3)
        sectionTitle.Size = UDim2.new(1, 0, 0, 20)
        sectionTitle.Position = UDim2.new(0, 10, 0, 0)
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left

        local contentFrame = createFrame(section, "Content", UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 20))
        contentFrame.AutomaticSize = Enum.AutomaticSize.Y

        -- Автоматически обновляем высоту секции при добавлении компонентов
        local lastY = 0
        local function addComponent(component)
            component.Parent = contentFrame
            component.Position = UDim2.new(0, 10, 0, lastY)
            lastY = lastY + component.Size.Y.Offset + DEFAULT_STYLE.SectionPadding
            contentFrame.Size = UDim2.new(1, 0, 0, lastY)
            section.Size = UDim2.new(1, 0, 0, lastY + 20) -- + заголовок
        end

        return {
            Frame = section,
            AddComponent = addComponent,
            TitleLabel = sectionTitle
        }
    end

    -- Компоненты (как в прошлой версии, но теперь они могут быть добавлены в секцию)
    local components = {}

    -- Button
    function components.Button(config)
        local text = config.text or "Button"
        local size = config.size or UDim2.new(0, 120, 0, 30)
        local callback = config.callback

        local button = createTextButton(nil, text, size, callback)
        button.BackgroundColor3 = DEFAULT_STYLE.AccentColor
        button.TextColor3 = Color3.fromRGB(0, 0, 0)

        return button
    end

    -- Toggle
    function components.Toggle(config)
        local text = config.text or "Toggle"
        local defaultValue = config.default or false
        local onChange = config.onChange

        local frame = createFrame(nil, "UIToggle", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0))

        local label = createTextLabel(frame, text, nil, DEFAULT_STYLE.TextColor3)
        label.Size = UDim2.new(0, 120, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left

        local toggleBox = createFrame(frame, "ToggleBox", UDim2.new(0, 24, 0, 24), UDim2.new(1, -32, 0.5, -12), Color3.fromRGB(60, 60, 60))
        toggleBox.Size = UDim2.new(0, 24, 0, 24)
        toggleBox.Position = UDim2.new(1, -32, 0.5, -12)

        local indicator = Instance.new("ImageLabel")
        indicator.Image = "rbxassetid://10894586714" -- можно заменить на иконку галочки
        indicator.BackgroundTransparency = 1
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = UDim2.new(0.5, -8, 0.5, -8)
        indicator.Parent = toggleBox

        local state = defaultValue
        local function updateToggle()
            if state then
                toggleBox.BackgroundColor3 = DEFAULT_STYLE.AccentColor
                indicator.Visible = true
            else
                toggleBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                indicator.Visible = false
            end
            if onChange then onChange(state) end
        end

        updateToggle()

        toggleBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                updateToggle()
            end
        end)

        return frame
    end

    -- Input
    function components.Input(config)
        local placeholder = config.placeholder or "Enter..."
        local onChange = config.onChange
        local onConfirm = config.onConfirm

        local frame = createFrame(nil, "UIInput", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0))

        local textBox = Instance.new("TextBox")
        textBox.PlaceholderText = placeholder
        textBox.Text = ""
        textBox.Font = DEFAULT_STYLE.Font
        textBox.TextSize = DEFAULT_STYLE.TextSize
        textBox.TextColor3 = DEFAULT_STYLE.TextColor3
        textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        textBox.Size = UDim2.new(1, -20, 1, 0)
        textBox.Position = UDim2.new(0, 10, 0, 0)
        textBox.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = DEFAULT_STYLE.CornerRadius
        corner.Parent = textBox

        textBox.FocusLost:Connect(function(enterPressed)
            if enterPressed and onConfirm then
                onConfirm(textBox.Text)
            end
        end)

        textBox.Changed:Connect(function(prop)
            if prop == "Text" and onChange then
                onChange(textBox.Text)
            end
        end)

        return frame
    end

    -- Slider
    function components.Slider(config)
        local min = config.min or 0
        local max = config.max or 100
        local default = config.default or 50
        local label = config.label or "Slider"
        local onChange = config.onChange

        local frame = createFrame(nil, "UISlider", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0))

        local labelText = createTextLabel(frame, label, 12, DEFAULT_STYLE.TextColor3)
        labelText.Size = UDim2.new(0, 100, 1, 0)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.TextXAlignment = Enum.TextXAlignment.Left

        local track = createFrame(frame, "Track", UDim2.new(1, -120, 0, 4), UDim2.new(0, 110, 0.5, -2), Color3.fromRGB(60, 60, 60))
        track.Size = UDim2.new(1, -120, 0, 4)
        track.Position = UDim2.new(0, 110, 0.5, -2)

        local handle = createFrame(frame, "Handle", UDim2.new(0, 12, 0, 12), UDim2.new(0, 110, 0.5, -6), DEFAULT_STYLE.AccentColor)
        handle.Size = UDim2.new(0, 12, 0, 12)
        handle.Position = UDim2.new(0, 110, 0.5, -6)

        local value = default
        local function updateHandle()
            local percent = (value - min) / (max - min)
            handle.Position = UDim2.new(percent, 110, 0.5, -6)
            if onChange then onChange(value) end
        end

        updateHandle()

        local dragging = false
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local x = input.Position.X - frame.AbsolutePosition.X - 110
                local percent = math.clamp(x / (frame.AbsoluteSize.X - 120), 0, 1)
                value = min + (max - min) * percent
                updateHandle()
            end
        end)

        return frame
    end

    -- Публичный API
    return {
        Frame = menu,
        AddTab = addTab,
        AddSection = addSection,
        Components = components
    }
end

return UI
