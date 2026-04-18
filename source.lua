local UI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function create(className, properties)
	local obj = Instance.new(className)
	for property, value in pairs(properties) do
		obj[property] = value
	end
	return obj
end

local function tween(object, info, goal)
	local tw = TweenService:Create(object, info, goal)
	tw:Play()
	return tw
end

local function bindDrag(guiObject, handle)
	handle.Active = true

	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		guiObject.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)
end

local function bindCanvas(scrollFrame, layout, padding)
	local function update()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + padding)
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
end

function UI:CreateWindow(options)
	options = options or {}

	local self = {}
	local tabs = {}
	local activeTab = nil
	local openState = false
	local animating = false

	local screenGui = create("ScreenGui", {
		Name = "ArialNeoUi",
		ResetOnSpawn = false,
		Parent = PlayerGui
	})

	local main = create("Frame", {
		Name = "Main",
		Parent = screenGui,
		Visible = false,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.7,
		Size = UDim2.new(0, 590, 0, 330),
		Position = UDim2.new(0, 148, 0, 6)
	})

	create("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = main
	})

	create("ImageLabel", {
		Name = "Dropshadow",
		Parent = main,
		ZIndex = -1,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.7,
		ImageColor3 = Color3.fromRGB(3, 3, 3),
		Image = "rbxassetid://1316045217",
		Size = UDim2.new(0, 670, 0, 392),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -40, 0, -30)
	})

	local title = create("TextLabel", {
		Name = "Title",
		Parent = main,
		BorderSizePixel = 0,
		TextSize = 18,
		BackgroundColor3 = Color3.fromRGB(192, 192, 192),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.4,
		Size = UDim2.new(0, 454, 0, 32),
		Text = options.Title or "Arial Neo Ui test",
		Position = UDim2.new(0, 64, 0, 12)
	})

	create("UICorner", {
		Parent = title,
		CornerRadius = UDim.new(0, 3)
	})

	local iconImg = create("ImageLabel", {
		Name = "IconImg",
		Parent = title,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0, 34, 0, 32),
		BackgroundTransparency = 1,
		Image = options.Icon or "",
		Position = UDim2.new(0, -50, 0, 0)
	})

	create("UICorner", {
		Parent = iconImg,
		CornerRadius = UDim.new(1, 0)
	})

	local closeButton = create("TextButton", {
		Name = "Close",
		Parent = title,
		BorderSizePixel = 0,
		TextSize = 18,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(192, 192, 192),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		BackgroundTransparency = 0.4,
		Size = UDim2.new(0, 42, 0, 32),
		Text = "X",
		Position = UDim2.new(0, 468, 0, 0),
		AutoButtonColor = false
	})

	create("UICorner", {
		Parent = closeButton,
		CornerRadius = UDim.new(0, 3)
	})

	local tabFrame = create("ScrollingFrame", {
		Name = "TabFrame",
		Parent = main,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(192, 192, 192),
		Size = UDim2.new(0, 104, 0, 258),
		Position = UDim2.new(0, 14, 0, 58),
		ScrollBarThickness = 0,
		BackgroundTransparency = 0.4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})

	create("UICorner", {
		Parent = tabFrame,
		CornerRadius = UDim.new(0, 3)
	})

	create("UIPadding", {
		Parent = tabFrame,
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8)
	})

	local tabLayout = create("UIListLayout", {
		Parent = tabFrame,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	})

	local pageHolder = create("Frame", {
		Name = "PageHolder",
		Parent = main,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 446, 0, 258),
		Position = UDim2.new(0, 128, 0, 58),
		ClipsDescendants = true
	})

	local openGui = create("ImageButton", {
		Name = "OpenGui",
		Parent = screenGui,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(192, 192, 192),
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(0, 62, 0, 16),
		Image = options.Icon or "",
		AutoButtonColor = false,
		Visible = true,
		BackgroundTransparency = 0
	})

	create("UICorner", {
		Parent = openGui,
		CornerRadius = UDim.new(0, 3)
	})

	bindDrag(main, title)
	bindDrag(openGui, openGui)

	local function refreshTabs()
		for _, tabData in ipairs(tabs) do
			tabData.Page.Visible = tabData == activeTab
			tabData.Button.BackgroundColor3 = tabData == activeTab and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(206, 206, 206)
		end
	end

	local function setActiveTab(tabData)
		activeTab = tabData
		refreshTabs()
	end

	local function showWindow()
		if animating or openState then
			return
		end

		animating = true
		main.Visible = true
		openGui.Visible = true

		local info = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local t1 = tween(main, info, {
			Size = UDim2.new(0, 590, 0, 330)
		})

		local t2 = tween(openGui, info, {
			Size = UDim2.new(0, 0, 0, 0)
		})

		t1.Completed:Once(function()
			openGui.Visible = false
			openState = true
			animating = false
		end)

		t2.Completed:Once(function()
			openGui.Visible = false
		end)
	end

	local function hideWindow()
		if animating or not openState then
			return
		end

		animating = true
		main.Visible = true
		openGui.Visible = true

		local info = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local t1 = tween(main, info, {
			Size = UDim2.new(0, 0, 0, 0)
		})

		local t2 = tween(openGui, info, {
			Size = UDim2.new(0, 50, 0, 50)
		})

		t1.Completed:Once(function()
			main.Visible = false
			openState = false
			animating = false
		end)

		t2.Completed:Once(function()
			openGui.Visible = true
		end)
	end

	closeButton.MouseButton1Click:Connect(hideWindow)
	openGui.MouseButton1Click:Connect(showWindow)

	function self:AddTab(tabOptions)
		tabOptions = tabOptions or {}

		local tabName = tabOptions.TabName or "Test tab"

		local tabButton = create("TextButton", {
			Name = "TabButton",
			Parent = tabFrame,
			TextWrapped = true,
			BorderSizePixel = 0,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = Color3.fromRGB(206, 206, 206),
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Size = UDim2.new(0, 90, 0, 36),
			Text = tabName,
			AutoButtonColor = false
		})

		create("UICorner", {
			Parent = tabButton,
			CornerRadius = UDim.new(0, 3)
		})

		local pageFrame = create("ScrollingFrame", {
			Name = "PageFrame",
			Parent = pageHolder,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(192, 192, 192),
			Size = UDim2.new(0, 446, 0, 258),
			Position = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 0,
			BackgroundTransparency = 0.4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false
		})

		create("UICorner", {
			Parent = pageFrame,
			CornerRadius = UDim.new(0, 3)
		})

		create("UIPadding", {
			Parent = pageFrame,
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		})

		local pageLayout = create("UIListLayout", {
			Parent = pageFrame,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		})

		bindCanvas(pageFrame, pageLayout, 16)

		local tabData = {
			Button = tabButton,
			Page = pageFrame
		}

		function tabData:AddButton(buttonOptions)
			buttonOptions = buttonOptions or {}

			local buttonName = buttonOptions.Name or "Test button"
			local callback = buttonOptions.Callback

			local button = create("TextButton", {
				Name = "Button",
				Parent = pageFrame,
				TextWrapped = true,
				BorderSizePixel = 0,
				TextSize = 14,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundColor3 = Color3.fromRGB(206, 206, 206),
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				Size = UDim2.new(0, 430, 0, 36),
				Text = buttonName,
				AutoButtonColor = false
			})

			create("UICorner", {
				Parent = button,
				CornerRadius = UDim.new(0, 3)
			})

			button.MouseButton1Click:Connect(function()
				if typeof(callback) == "function" then
					pcall(callback)
				end
			end)

			return button
		end

		tabButton.MouseButton1Click:Connect(function()
			setActiveTab(tabData)
		end)

		table.insert(tabs, tabData)

		if not activeTab then
			setActiveTab(tabData)
		else
			refreshTabs()
		end

		return tabData
	end

	function self:Show()
		showWindow()
	end

	function self:Hide()
		hideWindow()
	end

	function self:SetTitle(text)
		title.Text = tostring(text or "")
	end

	self.ScreenGui = screenGui
	self.Main = main
	self.Title = title
	self.IconImg = iconImg
	self.Close = closeButton
	self.OpenGui = openGui
	self.TabFrame = tabFrame

	return self
end

return UI