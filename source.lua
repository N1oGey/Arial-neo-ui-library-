local UI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props) do
		obj[k] = v
	end
	return obj
end

local function tween(obj, info, goal)
	local tw = TweenService:Create(obj, info, goal)
	tw:Play()
	return tw
end

local function bindDrag(guiObject, dragHandle)
	dragHandle.Active = true

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

	dragHandle.InputBegan:Connect(function(input)
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

	dragHandle.InputChanged:Connect(function(input)
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

	local window = {}
	local tabs = {}
	local activeTab
	local open = false
	local animating = false

	local windowName = options.Name or "ArialNeoUi"
	local titleText = options.Title or "Title"
	local iconImage = options.Icon or ""

	local mainSize = UDim2.new(0, 590, 0, 330)
	local mainPos = UDim2.new(0.5, 0, 0.5, 0)
	local openSize = UDim2.new(0, 50, 0, 50)
	local openPos = UDim2.new(0, 87, 0, 41)
	local zeroSize = UDim2.new(0, 0, 0, 0)

	local screenGui = create("ScreenGui", {
		Name = windowName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		Parent = PlayerGui
	})

	local main = create("Frame", {
		Name = "Main",
		Visible = false,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.7,
		Size = zeroSize,
		Position = mainPos,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = true,
		Parent = screenGui
	})

	create("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = main
	})

	create("ImageLabel", {
		Name = "Dropshadow",
		ZIndex = 0,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ImageTransparency = 0.7,
		ImageColor3 = Color3.fromRGB(3, 3, 3),
		Image = "rbxassetid://1316045217",
		Size = UDim2.new(0, 670, 0, 392),
		Position = UDim2.new(0, -40, 0, -30),
		Parent = main
	})

	local title = create("TextLabel", {
		Name = "Title",
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(192, 192, 192),
		BackgroundTransparency = 0.4,
		Size = UDim2.new(0, 454, 0, 32),
		Position = UDim2.new(0, 64, 0, 12),
		Text = titleText,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 18,
		FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
		Parent = main
	})

	create("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = title
	})

	local icon = create("ImageLabel", {
		Name = "IconImg",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 34, 0, 32),
		Position = UDim2.new(0, -50, 0, 0),
		Image = iconImage,
		ScaleType = Enum.ScaleType.Stretch,
		Parent = title
	})

	create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = icon
	})

	local closeButton = create("TextButton", {
		Name = "Close",
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(192, 192, 192),
		BackgroundTransparency = 0.4,
		Size = UDim2.new(0, 42, 0, 32),
		Position = UDim2.new(0, 468, 0, 0),
		Text = "X",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 18,
		FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
		AutoButtonColor = false,
		Parent = title
	})

	create("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = closeButton
	})

	local tabFrame = create("ScrollingFrame", {
		Name = "TabFrame",
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(192, 192, 192),
		BackgroundTransparency = 0.4,
		Size = UDim2.new(0, 104, 0, 258),
		Position = UDim2.new(0, 14, 0, 58),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = main
	})

	create("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = tabFrame
	})

	create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = tabFrame
	})

	local tabLayout = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = tabFrame
	})

	local pagesHolder = create("Frame", {
		Name = "PagesHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 446, 0, 258),
		Position = UDim2.new(0, 128, 0, 58),
		ClipsDescendants = true,
		Parent = main
	})

	local openGui = create("ImageButton", {
		Name = "OpenGui",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = zeroSize,
		Position = openPos,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = iconImage,
		ScaleType = Enum.ScaleType.Stretch,
		AutoButtonColor = false,
		Visible = true,
		Parent = screenGui
	})

	create("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = openGui
	})

	bindDrag(main, title)
	bindDrag(openGui, openGui)

	local function refreshTabs()
		for _, tab in ipairs(tabs) do
			tab.Page.Visible = tab == activeTab
			tab.Button.BackgroundColor3 = tab == activeTab and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(206, 206, 206)
		end
	end

	local function setActiveTab(tabData)
		activeTab = tabData
		refreshTabs()
	end

	local function showMain()
		if animating or open then
			return
		end

		animating = true
		main.Visible = true
		main.Size = zeroSize
		main.Position = mainPos

		openGui.Visible = true
		openGui.Size = openSize

		local info = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local mainTween = tween(main, info, {
			Size = mainSize,
			Position = mainPos
		})
		local openTween = tween(openGui, info, {
			Size = zeroSize
		})

		mainTween.Completed:Once(function()
			openGui.Visible = false
			open = true
			animating = false
		end)

		openTween.Completed:Once(function()
			openGui.Visible = false
		end)
	end

	local function hideMain()
		if animating or not open then
			return
		end

		animating = true
		main.Visible = true

		openGui.Visible = true
		openGui.Size = zeroSize

		local info = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local mainTween = tween(main, info, {
			Size = zeroSize,
			Position = mainPos
		})
		local openTween = tween(openGui, info, {
			Size = openSize
		})

		mainTween.Completed:Once(function()
			main.Visible = false
			open = false
			animating = false
		end)

		openTween.Completed:Once(function()
			openGui.Visible = true
		end)
	end

	closeButton.MouseButton1Click:Connect(hideMain)
	openGui.MouseButton1Click:Connect(showMain)

	function window:AddTab(tabOptions)
		tabOptions = tabOptions or {}

		local tabName = tabOptions.TabName or "Tab"

		local tabButton = create("TextButton", {
			Name = "TabButton",
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(206, 206, 206),
			Size = UDim2.new(0, 90, 0, 36),
			Text = tabName,
			TextWrapped = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
			AutoButtonColor = false,
			Parent = tabFrame
		})

		create("UICorner", {
			CornerRadius = UDim.new(0, 3),
			Parent = tabButton
		})

		local page = create("ScrollingFrame", {
			Name = "PageFrame",
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(192, 192, 192),
			BackgroundTransparency = 0.4,
			Size = UDim2.new(0, 446, 0, 258),
			Position = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			Visible = false,
			Parent = pagesHolder
		})

		create("UICorner", {
			CornerRadius = UDim.new(0, 3),
			Parent = page
		})

		create("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			Parent = page
		})

		local pageLayout = create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Parent = page
		})

		local tabData = {
			Button = tabButton,
			Page = page
		}

		function tabData:AddButton(buttonOptions)
			buttonOptions = buttonOptions or {}

			local buttonName = buttonOptions.Name or "Button"
			local callback = buttonOptions.Callback

			local button = create("TextButton", {
				Name = "Button",
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(206, 206, 206),
				Size = UDim2.new(0, 430, 0, 36),
				Text = buttonName,
				TextWrapped = true,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
				AutoButtonColor = false,
				Parent = page
			})

			create("UICorner", {
				CornerRadius = UDim.new(0, 3),
				Parent = button
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

	function window:Show()
		showMain()
	end

	function window:Hide()
		hideMain()
	end

	function window:SetTitle(text)
		title.Text = tostring(text or "")
	end

	window.ScreenGui = screenGui
	window.Main = main
	window.Title = title
	window.IconImg = icon
	window.OpenGui = openGui
	window.TabFrame = tabFrame
	window.PagesHolder = pagesHolder

	return window
end

return UI