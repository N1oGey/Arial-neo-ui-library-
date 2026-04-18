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

local function tween(object, tweenInfo, goal)
	local tw = TweenService:Create(object, tweenInfo, goal)
	tw:Play()
	return tw
end

local function bindDrag(guiObject, handle)
	handle.Active = true
	handle.Selectable = false

	local dragging = false
	local dragStart
	local startPos
	local dragInput

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

local function bindCanvas(scrollFrame, layout, extra)
	local function update()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + extra)
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
end

function UI:CreateWindow(options)
	options = options or {}

	local window = {}
	local tabs = {}
	local activeTab = nil
	local isOpen = false
	local animating = false

	local windowName = options.Name or "ArialNeoUi"
	local titleText = options.Title or "Title"
	local iconImage = options.Icon or ""

	local mainSize = UDim2.new(0, 590, 0, 330)
	local mainPos = UDim2.new(0, 443, 0, 171)
	local openSize = UDim2.new(0, 50, 0, 50)
	local openPos = UDim2.new(0, 87, 0, 41)
	local hiddenSize = UDim2.new(0, 0, 0, 0)

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
		Size = mainSize,
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
		ImageTransparency = 0,
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
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = main
	})

	create("UICorner", {
		CornerRadius = UDim.new(0, 3),
		Parent = tabFrame
	})

	local tabPadding = create("UIPadding", {
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

	bindCanvas(tabFrame, tabLayout, 16)

	local pageFrameHolder = create("Frame", {
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
		Size = openSize,
		Position = openPos,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = iconImage,
		ImageTransparency = 0,
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

	local function setTabActive(tabData)
		activeTab = tabData

		for _, item in ipairs(tabs) do
			item.Button.BackgroundColor3 = item == tabData and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(206, 206, 206)
			item.Page.Visible = item == tabData
		end
	end

	local function openWindow()
		if animating or isOpen then
			return
		end

		animating = true

		openGui.Visible = true
		openGui.Size = hiddenSize
		openGui.Position = openPos

		main.Visible = true
		main.Size = hiddenSize
		main.Position = mainPos

		local info = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local mainTween = tween(main, info, {
			Size = mainSize,
			Position = mainPos
		})

		local openTween = tween(openGui, info, {
			Size = hiddenSize
		})

		mainTween.Completed:Once(function()
			openGui.Visible = false
			isOpen = true
			animating = false
		end)

		openTween.Completed:Once(function()
			openGui.Visible = false
		end)
	end

	local function closeWindow()
		if animating or not isOpen then
			return
		end

		animating = true

		openGui.Visible = true
		openGui.Size = hiddenSize
		openGui.Position = openPos

		main.Visible = true

		local info = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local mainTween = tween(main, info, {
			Size = hiddenSize,
			Position = mainPos
		})

		local openTween = tween(openGui, info, {
			Size = openSize
		})

		mainTween.Completed:Once(function()
			main.Visible = false
			isOpen = false
			animating = false
		end)

		openTween.Completed:Once(function()
			openGui.Visible = true
		end)
	end

	closeButton.MouseButton1Click:Connect(closeWindow)
	openGui.MouseButton1Click:Connect(openWindow)

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
			BackgroundColor3 = Color3.fromRGB(192, 192, 192),
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 446, 0, 258),
			Position = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
			Parent = pageFrameHolder
		})

		create("UICorner", {
			CornerRadius = UDim.new(0, 3),
			Parent = page
		})

		local pagePadding = create("UIPadding", {
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

		bindCanvas(page, pageLayout, 16)

		local tabData = {
			Button = tabButton,
			Page = page,
			Name = tabName
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
				if type(callback) == "function" then
					pcall(callback)
				end
			end)

			return button
		end

		tabButton.MouseButton1Click:Connect(function()
			setTabActive(tabData)
		end)

		table.insert(tabs, tabData)

		if not activeTab then
			setTabActive(tabData)
		end

		return tabData
	end

	function window:Show()
		openWindow()
	end

	function window:Hide()
		closeWindow()
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
	window.PagesHolder = pageFrameHolder

	return window
end

return UI