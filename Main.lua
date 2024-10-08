Main = {
	Services = {
		tweenService = game:GetService("TweenService"),
		UIS = game:GetService("UserInputService"),
		runService = game:GetService("RunService"),
		coreGui = game:GetService("CoreGui")
	},

	Vars = {
		localPlayer = game:GetService("Players").LocalPlayer,
		Mouse = nil,
		viewPort = workspace.CurrentCamera.ViewportSize,
		Camera = workspace.CurrentCamera,
		DynamicSize = nil,
		stop = false,
		stopforce = false
	},

	TweenTypes = {
		Drag = {Enum.EasingStyle.Sine, Enum.EasingDirection.Out},
		Hover = {Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut},
		Click = {Enum.EasingStyle.Back, Enum.EasingDirection.Out}
	},

	Utilities = {
		Settings = function(Defaults, Options)
			for i, v in pairs(Defaults) do
				Options[i] = Options[i] or v
			end
			return Options
		end,

		Tween = function(Object, Goal, Duration, TweenType, Callback)
			local Tween = Main.Services.tweenService:Create(Object, TweenInfo.new(Duration, TweenType[1], TweenType[2]), Goal)
			Tween:Play()
			if Callback then
				Tween.Completed:Once(Callback)
			end
			return Tween
		end,

		Dragify = function(Frame)
			local dragging, dragInput, mousePos, framePos
			local UIS, Camera = Main.Services.UIS, Main.Vars.Camera

			local function update(input)
				local delta = input.Position - mousePos
				local newPosition = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
				Main.Utilities.Tween(Frame, {Position = newPosition}, 0.2, Main.TweenTypes.Drag)
			end

			Frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if not Main.Vars.stop and not Main.Vars.stopforce then
						dragging = true
						mousePos = input.Position
						framePos = Frame.Position

						if UIS.TouchEnabled then
							UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
							UIS.ModalEnabled = true
							Camera.CameraType = Enum.CameraType.Scriptable
						end

						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								dragging = false
								if UIS.TouchEnabled then
									UIS.MouseBehavior = Enum.MouseBehavior.Default
									UIS.ModalEnabled = false
									Camera.CameraType = Enum.CameraType.Custom
								end
							end
						end)
					end
				end
			end)

			Frame.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)

			UIS.InputChanged:Connect(function(input)
				if input == dragInput and dragging and not Main.Vars.stop and not Main.Vars.stopforce then
					update(input)
				end
			end)
		end,

		NewObj = function(className, properties)
			local instance = Instance.new(className)
			for prop, value in pairs(properties) do
				instance[prop] = value
			end
			return instance
		end,

		CheckDevice = function()
			local UIS = Main.Services.UIS
			Main.Vars.DynamicSize = UIS.TouchEnabled and UDim2.new(0, 370, 0, 220) or UDim2.new(0, 470, 0, 320)
			return UIS.TouchEnabled
		end,

		Cursor = function(frame, rbxassetid)
			if not frame or not rbxassetid then
				warn("Invalid parameters. Please provide a valid frame and rbxassetid.")
				return
			end

			local customCursor = Instance.new("ImageLabel")
			customCursor.Name = "CustomCursor"
			customCursor.Size = UDim2.new(0, 20, 0, 20)
			customCursor.BackgroundTransparency = 1
			customCursor.Image = "rbxassetid://" .. rbxassetid
			customCursor.Parent = frame

			local UIS, runService = Main.Services.UIS, Main.Services.runService

			runService.RenderStepped:Connect(function()
				local mouse = Main.Vars.localPlayer:GetMouse()
				local mouseX, mouseY = mouse.X, mouse.Y
				local framePosition, frameSize = frame.AbsolutePosition, frame.AbsoluteSize

				if mouseX >= framePosition.X and mouseX <= framePosition.X + frameSize.X and
					mouseY >= framePosition.Y and mouseY <= framePosition.Y + frameSize.Y then
					customCursor.Position = UDim2.new(0, mouseX - framePosition.X - 2, 0, mouseY - framePosition.Y - 2)
					customCursor.Visible = true
					UIS.MouseIconEnabled = false
				else
					customCursor.Visible = false
					UIS.MouseIconEnabled = true
				end
			end)
		end
	}
}

startTime = tick()

Main.Vars.Mouse = Main.Vars.localPlayer:GetMouse()
Main.Utilities.CheckDevice()

Azuma = {
	LoadTime = math.floor((tick() - startTime) * 1000)
}

AzumaUI = {
	Gui = Main.Utilities.NewObj("ScreenGui", {
		Parent = Main.Services.runService:IsStudio() and Main.Vars.localPlayer:WaitForChild("PlayerGui") or Main.Services.coreGui,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		Name = "Azuma - By Azuma.wtf",
		ResetOnSpawn = false
	}),

	NotificationsFrame = Main.Utilities.NewObj("Frame", {
		Parent = nil,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0, 180, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Name = "Notifications",
		BackgroundTransparency = 1,
		SelectionGroup = true
	}),

	NotificationsListLayout = Main.Utilities.NewObj("UIListLayout", {
		Parent = nil,
		Padding = UDim.new(0, 5),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder
	}),

	NotificationsPadding = Main.Utilities.NewObj("UIPadding", {
		Parent = nil,
		PaddingTop = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5)
	})
}

function Azuma:Window(options)
	options = Main.Utilities.Settings({
		Title = "Azuma UI Library",
		Bind = "RightControl",
		NavigationPosition = "Right",
		DiscordLink = "https://discord.gg/ReSXkjdjQR",
		YoutubeLink = "Not Set",
	}, options or {})

	_Azuma = {
		CurrentTab = nil,
		UIBind = options.Bind
	}

	-- Main
	do
		-- Rendering
		do
			_Azuma.MainFrame = Main.Utilities.NewObj("Frame", {
				Parent = nil,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(13, 13, 13),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = Main.Vars.DynamicSize,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Name = "Main"
			})

			_Azuma.TransitionFrame = Main.Utilities.NewObj("Frame", {
				Parent = _Azuma.MainFrame,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 0),
				AnchorPoint = Vector2.new(0, 0),
				BackgroundColor3 = Color3.fromRGB(12, 12, 12),
				ZIndex = 79420
			})

			_Azuma.TransitionCorner = Main.Utilities.NewObj("UICorner", {
				Parent = _Azuma.TransitionFrame,
				CornerRadius = UDim.new(0, 6)
			})

			_Azuma.MainCorner = Main.Utilities.NewObj("UICorner", {
				Parent = _Azuma.MainFrame,
				CornerRadius = UDim.new(0, 6)
			})

			_Azuma.ShadowFrame = Main.Utilities.NewObj("Frame", {
				Parent = _Azuma.MainFrame,
				ZIndex = 0,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Name = "Shadow",
				BackgroundTransparency = 1
			})

			_Azuma.ShadowImage = Main.Utilities.NewObj("ImageLabel", {
				Parent = _Azuma.ShadowFrame,
				ZIndex = 0,
				BorderSizePixel = 0,
				SliceCenter = Rect.new(49, 49, 450, 450),
				ScaleType = Enum.ScaleType.Slice,
				ImageTransparency = 0.2,
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://6014261993",
				Size = UDim2.new(1, 47, 1, 47),
				BackgroundTransparency = 1,
				Name = "Shadow",
				Position = UDim2.new(0.5, 0, 0.5, 0)
			})

			_Azuma.Divider = Main.Utilities.NewObj("Frame", {
				Parent = _Azuma.MainFrame,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(19, 19, 19),
				Size = UDim2.new(0, 1, 1, 0),
				Position = UDim2.new(0, 120, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Name = "Divider"
			})

			_Azuma.NavigationFrame = Main.Utilities.NewObj("Frame", {
				Parent = _Azuma.MainFrame,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(0, 120, 1, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Name = "Navigation",
				BackgroundTransparency = 1
			})

			_Azuma.TitleLabel = Main.Utilities.NewObj("TextLabel", {
				Parent = _Azuma.NavigationFrame,
				TextWrapped = true,
				BorderSizePixel = 0,
				TextYAlignment = Enum.TextYAlignment.Top,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 24,
				FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0),
				Size = UDim2.new(1, 0, 0, 60),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = options.Title,
				Name = "Title",
				Position = UDim2.new(0.5, 0, 0, 15)
			})

			_Azuma.TabButtons = Main.Utilities.NewObj("ScrollingFrame", {
				Parent = _Azuma.NavigationFrame,
				Active = true,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Name = "TabButtons",
				Size = UDim2.new(1, 0, 1, -76),
				ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
				Position = UDim2.new(0, 0, 0, 76),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				ScrollBarThickness = 0,
				BackgroundTransparency = 1
			})

			_Azuma.TabButtonsLayout = Main.Utilities.NewObj("UIListLayout", {
				Parent = _Azuma.TabButtons,
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder
			})

			_Azuma.TabArea = Main.Utilities.NewObj("Frame", {
				Parent = _Azuma.MainFrame,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(1, -120, 1, 0),
				Position = UDim2.new(0, 120, 0, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Name = "TabArea",
				BackgroundTransparency = 1
			})
		end
		-- Tab/Logic
		do
			-- Tab
			function _Azuma:Tab(options)
				options = Main.Utilities.Settings({
					Title = "Preview Tab"
				}, options or {})
				local Tab = {
					Hover = false,
					Active = false
				}

				-- Rendering
				do
					Tab.CurrentTabLabel = Main.Utilities.NewObj("TextLabel", {
						Parent = _Azuma.TabArea,
						BorderSizePixel = 0,
						Visible = false,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 16,
						FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 90, 0, 10),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = options.Title,
						Name = "CurrentTabLabel",
						Position = UDim2.new(0, 15, 0, 25)
					})

					Tab.Tab = Main.Utilities.NewObj("ScrollingFrame", {
						Parent = _Azuma.TabArea,
						Visible = false,
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Name = "Tab",
						AnchorPoint = Vector2.new(0, 1),
						Size = UDim2.new(1, -10, 1, -55),
						CanvasSize = UDim2.new(0, 0, 69420, 0),
						ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
						Position = UDim2.new(0, 5, 1, -5),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						ScrollBarThickness = 0,
						BackgroundTransparency = 1
					})

					Tab.TabLayout = Main.Utilities.NewObj("UIListLayout", {
						Parent = Tab.Tab,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder
					})

					Tab.TabButton = Main.Utilities.NewObj("TextLabel", {
						Parent = _Azuma.TabButtons,
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 13,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(101, 101, 101),
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 25),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = options.Title,
						Name = "Tab"
					})

					Tab.TabButtonActivated = Main.Utilities.NewObj("Frame", {
						Parent = Tab.TabButton,
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0, -1, 0.5, 0),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Name = "Activated"
					})

					Tab.TabButtonActivatedCorner = Main.Utilities.NewObj("UICorner", {
						Parent = Tab.TabButtonActivated,
						CornerRadius = UDim.new(0, 6)
					})

					Tab.UIPadding = Main.Utilities.NewObj("UIPadding", {
						Parent = Tab.Tab,
						PaddingLeft = UDim.new(0, 20);
					})
				end
				-- Logic
				do
					Tab.Logic = {
						Methods = {
							DeactivateTab = function(self)
								if Tab.Active then
									Tab.Active = false
									Tab.Hover = false
									Main.Utilities.Tween(Tab.TabButton, {TextColor3 = Color3.fromRGB(101, 101, 101)}, 0.8, Main.TweenTypes.Click)
									Main.Utilities.Tween(Tab.TabButtonActivated, {Size = UDim2.new(0, 0, 0, 0)}, 0.4, Main.TweenTypes.Click)
									Tab.Tab.Visible = false
									Tab.CurrentTabLabel.Visible = false
								end
							end,

							ActivateTab = function(self)
								if not Tab.Active then
									if _Azuma.CurrentTab and _Azuma.CurrentTab.Logic and _Azuma.CurrentTab.Logic.Methods then
										_Azuma.CurrentTab.Logic.Methods.DeactivateTab()
									end
									Tab.Active = true
									Main.Utilities.Tween(Tab.TabButton, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.8, Main.TweenTypes.Click)
									Main.Utilities.Tween(Tab.TabButtonActivated, {Size = UDim2.new(0, 7, 1, 0)}, 0.8, Main.TweenTypes.Click)
									Tab.Tab.Visible = true
									Tab.CurrentTabLabel.Visible = true
									_Azuma.CurrentTab = Tab
								end
							end
						},

						Events = {
							MouseEnter = function()
								Tab.Hover = true
								if not Tab.Active then
									Main.Utilities.Tween(Tab.TabButton, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.8, Main.TweenTypes.Hover)
									Main.Utilities.Tween(Tab.TabButtonActivated, {Size = UDim2.new(0, 7, 0.3, 0)}, 0.8, Main.TweenTypes.Hover)
								end
							end,

							MouseLeave = function()
								Tab.Hover = false
								if not Tab.Active then
									Main.Utilities.Tween(Tab.TabButton, {TextColor3 = Color3.fromRGB(101, 101, 101)}, 0.8, Main.TweenTypes.Hover)
									Main.Utilities.Tween(Tab.TabButtonActivated, {Size = UDim2.new(0, 0, 0, 0)}, 0.1, Main.TweenTypes.Hover)
								end
							end,

							InputBegan = function(input)
								if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Tab.Hover then
									Tab.Logic.Methods:ActivateTab()
								end
							end
						},

						Setup = function()
							Tab.TabButton.MouseEnter:Connect(Tab.Logic.Events.MouseEnter)
							Tab.TabButton.MouseLeave:Connect(Tab.Logic.Events.MouseLeave)
							Main.Services.UIS.InputBegan:Connect(Tab.Logic.Events.InputBegan)

							if not _Azuma.CurrentTab then
								Tab.Logic.Methods:ActivateTab()
							end
						end
					}

					Tab.Logic.Setup()

					-- Tab Elements
					do
						function Tab:Label(options)
							options = Main.Utilities.Settings({
								Text = "Preview Label"
							}, options or {})

							local Label = {}

							-- Rendering
							do
								Label.MainText = Main.Utilities.NewObj("TextLabel", {
									Parent = Tab.Tab,
									BorderSizePixel = 0,
									TextWrapped = true,
									TextXAlignment = Enum.TextXAlignment.Left,
									BackgroundColor3 = Color3.fromRGB(200, 200, 200),
									TextSize = 12,
									FontFace = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(201, 201, 201),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(1, 0, 0, 30),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Name = "Label",
									Text = options.Text,
								})
							end

							Label.Logic = {
								Methods = {
									SetText = function(text)
										options.Text = text
										self.Update()
									end,

									Update = function()
										Label.MainText.Text = options.Text
										Label.MainText.Size = UDim2.new(1, 0, 0, math.huge) -- Temporarily set to huge for text height calculation
										Label.MainText.Size = UDim2.new(1, 0, 0, Label.MainText.TextBounds.Y) -- Set to actual text height
										Main.Utilities.Tween(Label.MainText, {Size = UDim2.new(1, 0, 0, Label.MainText.TextBounds.Y + 20)}, 0.2, Main.TweenTypes.Click)
									end
								},

								Events = {
									MouseEnter = function()
										Main.Utilities.Tween(Label.MainText, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
									end,

									MouseLeave = function()
										Main.Utilities.Tween(Label.MainText, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
									end,
								},

								Setup = function()
									Label.MainText.MouseEnter:Connect(Label.Logic.Events.MouseEnter)
									Label.MainText.MouseLeave:Connect(Label.Logic.Events.MouseLeave)
								end
							}

							Label.Logic.Methods.Update()
							Label.Logic.Setup()

							return Label
						end

						function Tab:Warning(options)
							options = Main.Utilities.Settings({
								Text = "Preview Warning"
							}, options or {})

							local Warning = {}

							-- Rendering
							do
								Warning.MainText = Main.Utilities.NewObj("TextLabel", {
									Parent = Tab.Tab,
									BorderSizePixel = 0,
									TextWrapped = true,
									TextXAlignment = Enum.TextXAlignment.Left,
									BackgroundColor3 = Color3.fromRGB(200, 200, 200),
									TextSize = 12,
									FontFace = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(255, 221, 67),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(1, 0, 0, 30),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Name = "Label",
									Text = options.Text,
								})
							end

							Warning.Logic = {
								Methods = {
									SetText = function(self, text)
										options.Text = text
										self:Update()
									end,

									Update = function(self)
										Warning.MainText.Text = options.Text
										Warning.MainText.Size = UDim2.new(1, 0, 0, math.huge) -- Temporarily set to huge for text height calculation
										Warning.MainText.Size = UDim2.new(1, 0, 0, Warning.MainText.TextBounds.Y) -- Set to actual text height
										Main.Utilities.Tween(Warning.MainText, {Size = UDim2.new(1, 0, 0, Warning.MainText.TextBounds.Y + 20)}, 0.2, Main.TweenTypes.Click)
									end
								},

								Events = {
									MouseEnter = function()
										Main.Utilities.Tween(Warning.MainText, {TextColor3 = Color3.fromRGB(255, 221, 67)}, 0.4, Main.TweenTypes.Hover)
									end,

									MouseLeave = function()
										Main.Utilities.Tween(Warning.MainText, {TextColor3 = Color3.fromRGB(195, 169, 51)}, 0.4, Main.TweenTypes.Hover)
									end
								},

								Setup = function()
									Warning.MainText.MouseEnter:Connect(Warning.Logic.Events.MouseEnter)
									Warning.MainText.MouseLeave:Connect(Warning.Logic.Events.MouseLeave)

								end
							}

							Warning.Logic.Methods:Update()
							Warning.Logic.Setup()

							return Warning
						end

						function Tab:Bind(options)
							options = Main.Utilities.Settings({
								Title = "Preview Bind",
								DefaultBind = "E",
								Callback = function(v) print(v) end
							}, options or {})

							local Bind = {
								Hover = false,
								CurrentBind = options.DefaultBind:sub(1, 1)
							}

							-- Rendering
							do
								Bind.BindLabel = Main.Utilities.NewObj("TextLabel", {
									Parent = Tab.Tab,
									BorderSizePixel = 0,
									TextXAlignment = Enum.TextXAlignment.Left,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 12,
									FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(201, 201, 201),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(1, 0, 0, 30),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Text = options.Title,
									Name = "Bind",
									Position = UDim2.new(1, 0, 0, 0)
								})

								Bind.IconHolder = Main.Utilities.NewObj("Frame", {
									Parent = Bind.BindLabel,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(19, 19, 19),
									AnchorPoint = Vector2.new(1, 0.5),
									Size = UDim2.new(0, 20, 0, 20),
									Position = UDim2.new(1, -2, 0.5, 0),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Name = "IconHolder"
								})

								Bind.IconHolderCorner = Main.Utilities.NewObj("UICorner", {
									Parent = Bind.IconHolder,
									CornerRadius = UDim.new(0, 4)
								})

								Bind.ValueLabel = Main.Utilities.NewObj("TextLabel", {
									Parent = Bind.IconHolder,
									TextSize = 10,
									FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Size = UDim2.new(1, 0, 1, 0),
									Text = options.DefaultBind,
									Name = "Value",
									Position = UDim2.new(0.5, 0, 0.5, 0)
								})

								Bind.ValuePadding = Main.Utilities.NewObj("UIPadding", {
									Parent = Bind.ValueLabel,
									PaddingLeft = UDim.new(0, 1)
								})
							end
							Bind.Logic = {
								Methods = {
									SetupHoverEvents = function()
										Bind.BindLabel.MouseEnter:Connect(function()
											Bind.Hover = true
											Main.Utilities.Tween(Bind.BindLabel, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
										end)

										Bind.BindLabel.MouseLeave:Connect(function()
											Bind.Hover = false
											Main.Utilities.Tween(Bind.BindLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
										end)
									end,

									StartListening = function()
										Bind.BindLabel.Text = "Listening..."
										Main.Utilities.Tween(Bind.BindLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.4, Main.TweenTypes.Click)

										local inputConnection
										inputConnection = Main.Services.UIS.InputBegan:Connect(function(input)
											if input.UserInputType == Enum.UserInputType.Keyboard then
												if Bind.Hover then
													Main.Utilities.Tween(Bind.BindLabel, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Click)
												else
													Main.Utilities.Tween(Bind.BindLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Click)
												end
												Bind.BindLabel.Text = options.Title
												Bind.ValueLabel.Text = input.KeyCode.Name
												Bind.CurrentBind = input.KeyCode.Name:sub(1, 1)
												inputConnection:Disconnect()
											end
										end)
									end
								},

								Events = {
									InputBegan = function(input)
										if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Bind.Hover then
											Bind.Logic.Methods.StartListening()
										end

										if (input.KeyCode == Enum.KeyCode[Bind.CurrentBind]) then
											options.Callback(Bind.CurrentBind)
										end
									end
								},

								Setup = function()
									Bind.Logic.Methods.SetupHoverEvents()
									Main.Services.UIS.InputBegan:Connect(Bind.Logic.Events.InputBegan)
								end
							}

							Bind.Logic.Setup()

							return Bind
						end

						function Tab:Button(options)
							options = Main.Utilities.Settings({
								Title = "Preview Button",
								Callback = function() end
							}, options or {})

							local Button = {
								Hover = false,
								MouseDown = false
							}

							-- Rendering
							do
								Button.Button = Main.Utilities.NewObj("TextLabel", {
									Parent = Tab.Tab,
									BorderSizePixel = 0,
									TextXAlignment = Enum.TextXAlignment.Left,
									BackgroundColor3 = Color3.fromRGB(200, 200, 200),
									TextSize = 12,
									FontFace = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(201, 201, 201),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(1, 0, 0, 30),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Text = options.Title,
									Name = "Button",
									Position = UDim2.new(1, 0, 0, 0)
								})

								Button.IconHolder = Main.Utilities.NewObj("Frame", {
									Parent = Button.Button,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(19, 19, 19),
									AnchorPoint = Vector2.new(1, 0.5),
									Size = UDim2.new(0, 20, 0, 20),
									Position = UDim2.new(1, 0, 0.5, 0),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Name = "IconHolder",
									BackgroundTransparency = 1
								})

								Button.IconHolderCorner = Main.Utilities.NewObj("UICorner", {
									Parent = Button.IconHolder,
									CornerRadius = UDim.new(0, 4)
								})

								Button.ButtonIcon = Main.Utilities.NewObj("ImageLabel", {
									Parent = Button.IconHolder,
									Image = "rbxassetid://13859307670",
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundTransparency = 1,
									Name = "Button",
									Position = UDim2.new(0, -2, 0, 0)
								})
							end
							Button.Logic = {
								Methods = {
									SetText = function(self, text)
										Button.Button.Title = text
										options.name = text
									end,

									SetCallback = function(self, fn)
										options.callback = fn
									end
								},

								Events = {
									InputBegan = function()
										Button.Hover = true
										if not Button.MouseDown then
											Main.Utilities.Tween(Button.Button, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									InputEnded = function()
										Button.Hover = false
										if not Button.MouseDown then
											Main.Utilities.Tween(Button.Button, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									MouseInputBegan = function(input)
										if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Button.Hover then
											Button.MouseDown = true
											Main.Utilities.Tween(Button.Button, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.4, Main.TweenTypes.Click)
											options.Callback()
										end
									end,

									MouseInputEnded = function(input)
										if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
											Button.MouseDown = false
											if Button.Hover then
												Main.Utilities.Tween(Button.Button, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
											else
												Main.Utilities.Tween(Button.Button, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
											end
										end
									end
								},

								Setup = function()
									Button.Button.InputBegan:Connect(Button.Logic.Events.InputBegan)
									Button.Button.InputEnded:Connect(Button.Logic.Events.InputEnded)
									Main.Services.UIS.InputBegan:Connect(Button.Logic.Events.MouseInputBegan)
									Main.Services.UIS.InputEnded:Connect(Button.Logic.Events.MouseInputEnded)
								end
							}

							Button.Logic.Setup()

							return Button	
						end

						function Tab:Toggle(options)
							options = Main.Utilities.Settings({
								Title = "Preview Toggle",
								State = false,
								Callback = function(v) print(v) end
							}, options or {})

							local Toggle = {
								Hover = false,
								MouseDown = false,
								State = options.State
							}

							-- Rendering
							do
								Toggle.Toggle = Main.Utilities.NewObj("TextLabel", {
									Parent = Tab.Tab,
									BorderSizePixel = 0,
									TextXAlignment = Enum.TextXAlignment.Left,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 12,
									FontFace = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(201, 201, 201),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(1, 0, 0, 30),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Text = options.Title,
									Name = "Toggle",
									Position = UDim2.new(1, 0, 0, 0)
								})

								Toggle.Check = Main.Utilities.NewObj("Frame", {
									Parent = Toggle.Toggle,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(19, 19, 19),
									AnchorPoint = Vector2.new(1, 0.5),
									Size = UDim2.new(0, 15, 0, 15),
									Position = UDim2.new(1, -5, 0.5, 0),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Name = "Check"
								})

								Toggle.CheckCorner = Main.Utilities.NewObj("UICorner", {
									Parent = Toggle.Check,
									CornerRadius = UDim.new(0, 4)
								})

								Toggle.CheckIcon = Main.Utilities.NewObj("ImageLabel", {
									Parent = Toggle.Check,
									ImageColor3 = Color3.fromRGB(19, 19, 19),
									Image = "rbxassetid://14950021853",
									Size = UDim2.new(1, 0, 1, 0),
									ImageTransparency = 1,
									BackgroundTransparency = 1,
									Name = "check"
								})

								Toggle.CheckIconCorner = Main.Utilities.NewObj("UICorner", {
									Parent = Toggle.Check,
									CornerRadius = UDim.new(0, 4)
								})
							end
							Toggle.Logic = {
								Methods = {
									ToggleState = function(Bool, self)
										if Bool == nil then
											Toggle.State = not Toggle.State
										else
											Toggle.State = Bool
										end

										if Toggle.State then
											Main.Utilities.Tween(Toggle.Check, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.4, Main.TweenTypes.Click)
											Main.Utilities.Tween(Toggle.CheckIcon, {ImageTransparency = 0}, 0.4, Main.TweenTypes.Click)
										else
											Main.Utilities.Tween(Toggle.Check, {BackgroundColor3 = Color3.fromRGB(19, 19, 19)}, 0.4, Main.TweenTypes.Click)
											Main.Utilities.Tween(Toggle.CheckIcon, {ImageTransparency = 1}, 0.4, Main.TweenTypes.Click)
										end

										options.Callback(Toggle.State)	
									end,

									InitializeState = function(self)
										self:ToggleState(options.State)
									end
								},

								Events = {
									InputBegan = function()
										Toggle.Hover = true
										if not Toggle.MouseDown and Toggle.State then
											Main.Utilities.Tween(Toggle.Toggle, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									InputEnded = function()
										Toggle.Hover = false
										if not Toggle.MouseDown and Toggle.State then
											Main.Utilities.Tween(Toggle.Toggle, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									MouseInputBegan = function(input)
										if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Toggle.Hover then
											Toggle.MouseDown = true
											Toggle.Logic.Methods.ToggleState()
										end
									end,

									MouseInputEnded = function(input)
										if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
											Toggle.MouseDown = false
											if Toggle.Hover and Toggle.State then
												Main.Utilities.Tween(Toggle.Toggle, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
											else
												Main.Utilities.Tween(Toggle.Toggle, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
											end
										end
									end
								},

								Setup = function()
									Toggle.Toggle.InputBegan:Connect(Toggle.Logic.Events.InputBegan)
									Toggle.Toggle.InputEnded:Connect(Toggle.Logic.Events.InputEnded)
									Main.Services.UIS.InputBegan:Connect(Toggle.Logic.Events.MouseInputBegan)
									Main.Services.UIS.InputEnded:Connect(Toggle.Logic.Events.MouseInputEnded)

									Toggle.Logic.Methods:InitializeState()
								end
							}

							Toggle.Logic.Setup()

							return Toggle
						end

						function Tab:Slider(options)
							options = Main.Utilities.Settings({
								Title = "Preview Slider",
								Default = 50,
								Min = 0,
								Max = 100,
								Callback = function(v) print(v) end
							}, options or {})

							local Slider = {
								MouseDown = false,
								Hover = false,
								Connection = nil
							}

							-- Rendering
							do
								Slider.Slider = Main.Utilities.NewObj("TextLabel", {
									Parent = Tab.Tab,
									BorderSizePixel = 0,
									TextXAlignment = Enum.TextXAlignment.Left,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 12,
									FontFace = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(201, 201, 201),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(1, 0, 0, 40),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Text = options.Title,
									Name = "Slider",
									Position = UDim2.new(1, 0, 0, 0)
								})

								Slider.IconHolder = Main.Utilities.NewObj("Frame", {
									Parent = Slider.Slider,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(19, 19, 19),
									AnchorPoint = Vector2.new(1, 0.5),
									Size = UDim2.new(0, 20, 0, 20),
									Position = UDim2.new(1, 0, 0.5, 0),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Name = "IconHolder",
									BackgroundTransparency = 1
								})

								Slider.IconHolderCorner = Main.Utilities.NewObj("UICorner", {
									Parent = Slider.IconHolder,
									CornerRadius = UDim.new(0, 4)
								})

								Slider.Value = Main.Utilities.NewObj("TextLabel", {
									Parent = Slider.IconHolder,
									TextSize = 10,
									FontFace = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = 1,
									Size = UDim2.new(1, 0, 1, 0),
									Text = "100",
									Name = "Value",
									Position = UDim2.new(0, -2, 0, 2)
								})

								Slider.UIPadding = Main.Utilities.NewObj("UIPadding", {
									Parent = Slider.Slider,
									PaddingBottom = UDim.new(0, 10)
								})

								Slider.SliderBG = Main.Utilities.NewObj("Frame", {
									Parent = Slider.Slider,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(19, 19, 19),
									AnchorPoint = Vector2.new(0, 1),
									Size = UDim2.new(1, -5, 0, 4),
									Position = UDim2.new(0, 0, 1, 5),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Name = "SliderBG"
								})

								Slider.SliderBGCorner = Main.Utilities.NewObj("UICorner", {
									Parent = Slider.SliderBG,
									CornerRadius = UDim.new(0, 12)
								})

								Slider.Drag = Main.Utilities.NewObj("Frame", {
									Parent = Slider.SliderBG,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									Size = UDim2.new(0.5, 0, 1, 0),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Name = "Drag"
								})

								Slider.DragCorner = Main.Utilities.NewObj("UICorner", {
									Parent = Slider.Drag,
									CornerRadius = UDim.new(0, 12)
								})
							end

							Slider.Logic = {
								Methods = {
									SetValue = function(self, v)
										if v == nil then
											local percentage = math.clamp((Main.Vars.Mouse.X - Slider.Slider.AbsolutePosition.X) / Slider.Slider.AbsoluteSize.X, 0, 1)
											local value = math.floor(((options.Max - options.Min) * percentage) + options.Min)

											Slider.Value.Text = tostring(value)
											Main.Utilities.Tween(Slider.Drag, {Size = UDim2.fromScale(percentage, 1)}, 0.4, Main.TweenTypes.Drag)
										else
											local clampedValue = math.clamp(v, options.Min, options.Max)
											local percentage = (clampedValue - options.Min) / (options.Max - options.Min)

											Slider.Value.Text = tostring(clampedValue)
											Main.Utilities.Tween(Slider.Drag, {Size = UDim2.fromScale(percentage, 1)}, 0.4, Main.TweenTypes.Drag)
										end

										options.Callback(Slider.Logic.Methods:GetValue())
									end,

									GetValue = function(self)
										return tonumber(Slider.Value.Text)
									end,

									Initialize = function(self)
										self:SetValue(options.Default)
									end
								},

								Events = {
									MouseEnter = function()
										Slider.Hover = true
										if not Slider.MouseDown then
											Main.Utilities.Tween(Slider.Slider, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									MouseLeave = function()
										Slider.Hover = false
										if not Slider.MouseDown then
											Main.Utilities.Tween(Slider.Slider, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									InputBegan = function(input)
										if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Slider.Hover then
											Main.Vars.stop = true
											Slider.MouseDown = true
											Main.Utilities.Tween(Slider.Slider, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.4, Main.TweenTypes.Hover)

											if not Slider.Connection then
												Slider.Connection = Main.Services.runService.RenderStepped:Connect(function()
													Slider.Logic.Methods:SetValue()
												end)
											end
										end
									end,

									InputEnded = function(input)
										if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
											Main.Vars.stop = false
											Slider.MouseDown = false

											if Slider.Hover then
												Main.Utilities.Tween(Slider.Slider, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
											else
												Main.Utilities.Tween(Slider.Slider, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
											end

											if Slider.Connection then 
												Slider.Connection:Disconnect() 
											end
											Slider.Connection = nil
										end
									end
								},

								Setup = function()
									Slider.Slider.MouseEnter:Connect(Slider.Logic.Events.MouseEnter)
									Slider.Slider.MouseLeave:Connect(Slider.Logic.Events.MouseLeave)
									Main.Services.UIS.InputBegan:Connect(Slider.Logic.Events.InputBegan)
									Main.Services.UIS.InputEnded:Connect(Slider.Logic.Events.InputEnded)

									Slider.Logic.Methods:Initialize()
								end
							}

							Slider.Logic.Setup()

							return Slider
						end	

						function Tab:Dropdown(options)
							options = Main.Utilities.Settings({
								Title = "Preview Dropdown",
								Items = {},
								Selectmode = false
							}, options or {})

							local Dropdown = {
								Items = {
									["id"] = { 
										"value"
									}
								},
								Open = false,
								MouseDown = false,
								Hover = false,
								HoveringItem = false,
								SelectedItems = {}
							}

							-- Rendering
							do
								Dropdown.Dropdown = Main.Utilities.NewObj("TextLabel", {
									Parent = Tab.Tab,
									BorderSizePixel = 0,
									TextXAlignment = Enum.TextXAlignment.Left,
									TextYAlignment = Enum.TextYAlignment.Top,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 12,
									FontFace = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(201, 201, 201),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(1, 0, 0, 30),
									ClipsDescendants = true,
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Text = options.Title,
									Name = "Dropdown",
									Position = UDim2.new(1, 0, 0, 0),
								})

								Dropdown.IconHolder = Main.Utilities.NewObj("Frame", {
									Parent = Dropdown.Dropdown,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(19, 19, 19),
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(0, 20, 0, 20),
									Position = UDim2.new(1, 0, 0, -3),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Name = "IconHolder",
									BackgroundTransparency = 1,
								})

								Dropdown.IconHolderCorner = Main.Utilities.NewObj("UICorner", {
									Parent = Dropdown.IconHolder,
									CornerRadius = UDim.new(0, 4),
								})

								Dropdown.IconValue = Main.Utilities.NewObj("ImageLabel", {
									Parent = Dropdown.IconHolder,
									Image = [[rbxassetid://14951833548]],
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundTransparency = 1,
									Name = "Value",
									Position = UDim2.new(0, -2, 0, 0),
								})

								Dropdown.UIPadding = Main.Utilities.NewObj("UIPadding", {
									Parent = Dropdown.Dropdown,
									PaddingTop = UDim.new(0, 5),
								})

								Dropdown.DropdownItems = Main.Utilities.NewObj("ScrollingFrame", {
									Parent = Dropdown.Dropdown,
									Visible = false,
									Active = true,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									Name = "DropdownItems",
									Size = UDim2.new(1, -5, 1, -22),
									ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
									Position = UDim2.new(0, 0, 0, 17),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									ScrollBarThickness = 0,
									BackgroundTransparency = 1,
								})

								Dropdown.DropdownItemsCorner = Main.Utilities.NewObj("UICorner", {
									Parent = Dropdown.DropdownItems,
									CornerRadius = UDim.new(0, 4),
								})

								Dropdown.UIListLayout = Main.Utilities.NewObj("UIListLayout", {
									Parent = Dropdown.DropdownItems,
									Padding = UDim.new(0, 5),
									SortOrder = Enum.SortOrder.LayoutOrder,
								})

							end

							Dropdown.Logic = {
								Methods = {
									Add = function(Id, Title, Callback, self)
										Callback = Callback or function(Id, Title) print(Id, Title) end

										local Item = {
											Hover = false,
											MouseDown = false,
											Selected = false
										}

										if Dropdown.Items[Id] ~= nil then
											return
										end

										Dropdown.Items[Id] = {
											instance = {},
											value = Title
										}

										-- Rendering
										Dropdown.Items[Id].instance.Item = Main.Utilities.NewObj("TextLabel", {
											Parent = Dropdown.DropdownItems,
											BorderSizePixel = 0,
											TextXAlignment = Enum.TextXAlignment.Left,
											BackgroundColor3 = Color3.fromRGB(19, 19, 19),
											TextSize = 10,
											FontFace = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
											TextColor3 = Color3.fromRGB(255, 255, 255),
											Size = UDim2.new(1, 0, 0, 20),
											Text = Title,
											Name = "Item",
										})

										Main.Utilities.NewObj("UICorner", {
											Parent = Dropdown.Items[Id].instance.Item,
											CornerRadius = UDim.new(0, 4),
										})

										Main.Utilities.NewObj("UIPadding", {
											Parent = Dropdown.Items[Id].instance.Item,
											PaddingLeft = UDim.new(0, 5),
										})

										local function setHoverAppearance()
											if Item.MouseDown then return end

											local bgColor, textColor
											if options.Selectmode then
												if Item.Selected then
													bgColor = Color3.fromRGB(255, 255, 255)
													textColor = Color3.fromRGB(0, 0, 0)
												else
													bgColor = Color3.fromRGB(30, 30, 30)
													textColor = Color3.fromRGB(255, 255, 255)
												end
											else
												bgColor = Color3.fromRGB(30, 30, 30)
												textColor = Color3.fromRGB(255, 255, 255)
											end

											Main.Utilities.Tween(Dropdown.Items[Id].instance.Item, {BackgroundColor3 = bgColor}, 0.2, Main.TweenTypes.Hover)
											Main.Utilities.Tween(Dropdown.Items[Id].instance.Item, {TextColor3 = textColor}, 0.2, Main.TweenTypes.Hover)
										end

										local function resetAppearance()
											if Item.MouseDown then return end

											local bgColor, textColor
											if options.Selectmode then
												if Item.Selected then
													bgColor = Color3.fromRGB(230, 230, 230)
													textColor = Color3.fromRGB(0, 0, 0)
												else
													bgColor = Color3.fromRGB(19, 19, 19)
													textColor = Color3.fromRGB(255, 255, 255)
												end
											else
												bgColor = Color3.fromRGB(19, 19, 19)
												textColor = Color3.fromRGB(255, 255, 255)
											end

											Main.Utilities.Tween(Dropdown.Items[Id].instance.Item, {BackgroundColor3 = bgColor}, 0.2, Main.TweenTypes.Hover)
											Main.Utilities.Tween(Dropdown.Items[Id].instance.Item, {TextColor3 = textColor}, 0.2, Main.TweenTypes.Hover)
										end

										local function connectEvents()
											Dropdown.Items[Id].instance.Item.MouseEnter:Connect(function()
												Item.Hover = true
												Dropdown.HoveringItem = true
												setHoverAppearance()
											end)

											Dropdown.Items[Id].instance.Item.MouseLeave:Connect(function()
												Item.Hover = false
												Dropdown.HoveringItem = false
												resetAppearance()
											end)

											Main.Services.UIS.InputBegan:Connect(function(input)
												if Dropdown.Items[Id] == nil then return end

												if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Item.Hover then
													Item.MouseDown = true

													if options.Selectmode then
														Item.Selected = not Item.Selected
														Dropdown.SelectedItems[Id] = Item.Selected and Title or nil
														Main.Utilities.Tween(Dropdown.Items[Id].instance.Item, {TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.2, Main.TweenTypes.Hover)
														Main.Utilities.Tween(Dropdown.Items[Id].instance.Item, {BackgroundColor3 = Item.Hover and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(230, 230, 230)}, 0.2, Main.TweenTypes.Click)
													else
														for _, v in pairs(Dropdown.Items) do
															if v.instance then
																v.instance.Item.BackgroundColor3 = Color3.fromRGB(19, 19, 19)
															end
														end
														Main.Utilities.Tween(Dropdown.Items[Id].instance.Item, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.2, Main.TweenTypes.Click)
														Dropdown.SelectedItems = { [Id] = Title }
														Dropdown.Logic.Methods.Toggle()
													end
													Callback(Id, Title)
												end
											end)

											Main.Services.UIS.InputEnded:Connect(function(input)
												if Dropdown.Items[Id] == nil then return end

												if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
													Item.MouseDown = false
													resetAppearance()
												end
											end)
										end

										connectEvents()
										Dropdown.Items[Id].Callback = Callback 
									end,

									GetSelectedItems = function(self)
										local selectedText = ""

										for id, title in pairs(Dropdown.SelectedItems) do
											if title then
												selectedText = selectedText .. title .. ", "
											end
										end

										return selectedText == "" and "No items selected" or selectedText:sub(1, -3)
									end,

									Remove = function(id, self)
										if Dropdown.Items[id] then
											if Dropdown.Items[id].instance then
												for _, v in pairs(Dropdown.Items[id].instance) do
													v:Destroy()
												end
											end
											Dropdown.Items[id] = nil
										end
									end,

									Clear = function(self)
										for i in pairs(Dropdown.Items) do
											Dropdown.Logic.Methods.Remove(i)
										end
									end,

									Toggle = function(self)
										Dropdown.Open = not Dropdown.Open

										if not Dropdown.Open and not Dropdown.HoveringItem then
											Main.Utilities.Tween(Dropdown.Dropdown, {Size = UDim2.new(1, 0, 0, 30)}, 0.4, Main.TweenTypes.Click, function()
												Dropdown.DropdownItems.Visible = false
											end)
										else
											local count = 0
											for _ in pairs(Dropdown.Items) do
												count += 1
											end

											Dropdown.DropdownItems.Visible = true
											Main.Utilities.Tween(Dropdown.Dropdown, {Size = UDim2.new(1, 0, 0, 7 + (count * 20) + 1)}, 0.4, Main.TweenTypes.Click)
										end
									end,

									Refresh = function(options, self)
										local oldCallback
										if Dropdown.SelectedItems then
											for id, item in pairs(Dropdown.SelectedItems) do
												if Dropdown.Items[id] then
													oldCallback = Dropdown.Items[id].Callback
													break
												end
											end
										end

										Dropdown.Logic.Methods.Clear()
										for _, object in pairs(options) do
											Dropdown:Add(object, object.Name, oldCallback)
										end
									end
								},

								Events = {
									MouseEnter = function()
										Dropdown.Hover = true
										Main.Utilities.Tween(Dropdown.Dropdown, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
									end,

									MouseLeave = function()
										Dropdown.Hover = false
										if not Dropdown.MouseDown then
											Main.Utilities.Tween(Dropdown.Dropdown, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									InputBegan = function(input)
										if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Dropdown.Hover then
											Dropdown.MouseDown = true
											Main.Utilities.Tween(Dropdown.Dropdown, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.4, Main.TweenTypes.Click)
											if not Dropdown.HoveringItem then
												Dropdown.Logic.Methods.Toggle()
											end
										end
									end,

									InputEnded = function(input)
										if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
											Dropdown.MouseDown = false
											if Dropdown.Hover then
												Main.Utilities.Tween(Dropdown.Dropdown, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Click)
											else
												Main.Utilities.Tween(Dropdown.Dropdown, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Click)
											end
										end
									end
								},

								Setup = function(self)
									Dropdown.Dropdown.MouseEnter:Connect(Dropdown.Logic.Events.MouseEnter)
									Dropdown.Dropdown.MouseLeave:Connect(Dropdown.Logic.Events.MouseLeave)
									Main.Services.UIS.InputBegan:Connect(Dropdown.Logic.Events.InputBegan)
									Main.Services.UIS.InputEnded:Connect(Dropdown.Logic.Events.InputEnded)
								end
							}

							Dropdown.Logic.Setup()
							function Dropdown:Add(Id, Title, Callback) 
								Dropdown.Logic.Methods.Add(Id, Title, Callback)	
							end

							function Dropdown:Refresh(options)
								Dropdown.Logic.Methods.Refresh(options)
							end

							function Dropdown:Clear()
								Dropdown.Logic.Methods.Clear()
							end

							return Dropdown
						end	

						function Tab:ColorPicker(options)
							options = Main.Utilities.Settings({
								Title = "Preview Color Picker",
								Callback = function(v) print(v) end,
								DefaultColor = Color3.fromRGB(255, 255, 255),
								DefaultDarkness = 0
							}, options or {})

							local ColorPicker = {
								State = true,
								Hover = false,
								HoverColor = false,
								HoverDarkness = false,
								ChangingColor = false,
								ChangingDarkness = false
							}

							-- UI Elements Setup
							do
								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker
								ColorPicker.Label = Main.Utilities.NewObj("TextLabel", {
									Parent = Tab.Tab,
									BorderSizePixel = 0,
									TextXAlignment = Enum.TextXAlignment.Left,
									TextYAlignment = Enum.TextYAlignment.Top,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 12,
									FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(201, 201, 201),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(1, 0, 0, 65),
									ClipsDescendants = true,
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Text = options.Title,
									Name = "ColorPicker",
									Position = UDim2.new(1, 0, 0, 0)
								})

								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker.UIPadding
								ColorPicker.Padding = Main.Utilities.NewObj("UIPadding", {
									Parent = ColorPicker.Label,
									PaddingTop = UDim.new(0, 5)
								})

								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker.ColorGrad
								ColorPicker.ColorGrad = Main.Utilities.NewObj("Frame", {
									Parent = ColorPicker.Label,
									Active = true,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									Selectable = true,
									Size = UDim2.new(1, -40, 0, 15),
									Position = UDim2.new(0, 0, 0, 25),
									BorderColor3 = Color3.fromRGB(28, 43, 54),
									Name = "ColorGrad"
								})

								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker.ColorGrad.Grad
								ColorPicker.ColorGradGradient = Main.Utilities.NewObj("UIGradient", {
									Parent = ColorPicker.ColorGrad,
									Name = "Grad",
									Color = ColorSequence.new{
										ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 5)),
										ColorSequenceKeypoint.new(0.200, Color3.fromRGB(255, 255, 0)),
										ColorSequenceKeypoint.new(0.400, Color3.fromRGB(0, 255, 0)),
										ColorSequenceKeypoint.new(0.600, Color3.fromRGB(0, 255, 255)),
										ColorSequenceKeypoint.new(0.800, Color3.fromRGB(0, 0, 255)),
										ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 255))
									}
								})

								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker.ColorGrad.UICorner
								ColorPicker.ColorGradCorner = Main.Utilities.NewObj("UICorner", {
									Parent = ColorPicker.ColorGrad,
									CornerRadius = UDim.new(0, 4)
								})

								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker.Color
								ColorPicker.Color = Main.Utilities.NewObj("Frame", {
									Parent = ColorPicker.Label,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(255, 0, 5),
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(0, 35, 0, 35),
									Position = UDim2.new(1, 0, 0, 25),
									BorderColor3 = Color3.fromRGB(28, 43, 54),
									Name = "Color"
								})

								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker.Color.UICorner
								ColorPicker.ColorCorner = Main.Utilities.NewObj("UICorner", {
									Parent = ColorPicker.Color,
									CornerRadius = UDim.new(0, 4)
								})

								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker.DarkGrad
								ColorPicker.DarkGrad = Main.Utilities.NewObj("Frame", {
									Parent = ColorPicker.Label,
									Active = true,
									BorderSizePixel = 0,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									Selectable = true,
									Size = UDim2.new(1, -40, 0, 15),
									Position = UDim2.new(0, 0, 0, 45),
									BorderColor3 = Color3.fromRGB(28, 43, 54),
									Name = "DarkGrad"
								})

								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker.DarkGrad.DarkGrad
								ColorPicker.DarkGradGradient = Main.Utilities.NewObj("UIGradient", {
									Parent = ColorPicker.DarkGrad,
									Name = "DarkGrad",
									Color = ColorSequence.new{
										ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
										ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 0, 0))
									}
								})

								-- StarterGui.Suno man.Main.TabArea.Tab.Color Picker.DarkGrad.UICorner
								ColorPicker.DarkGradCorner = Main.Utilities.NewObj("UICorner", {
									Parent = ColorPicker.DarkGrad,
									CornerRadius = UDim.new(0, 4)
								})
							end

							ColorPicker.Logic = {
								Methods = {
									returnColor = function(percentage, gradientKeyPoints)
										for i = 1, #gradientKeyPoints - 1 do
											local currentPoint = gradientKeyPoints[i]
											local nextPoint = gradientKeyPoints[i + 1]
											if currentPoint.Time <= percentage and nextPoint.Time >= percentage then
												local lerpFactor = (percentage - currentPoint.Time) / (nextPoint.Time - currentPoint.Time)
												return currentPoint.Value:Lerp(nextPoint.Value, lerpFactor)
											end
										end
										return gradientKeyPoints[#gradientKeyPoints].Value
									end,

									calculatePercentage = function(frame, lastX)
										local mousePosition = Main.Services.UIS:GetMouseLocation()
										local xPosition = lastX or mousePosition.X

										if frame.AbsolutePosition and frame.AbsoluteSize then
											return math.clamp(
												(xPosition - frame.AbsolutePosition.X) / frame.AbsoluteSize.X,
												0,
												1
											)
										end
										return 0
									end,

									updateColorPreview = function()
										local colorPercentage, darknessPercentage

										if ColorPicker.ChangingColor then
											colorPercentage = ColorPicker.Logic.Methods.calculatePercentage(ColorPicker.ColorGrad)
											ColorPicker.LastColorX = Main.Services.UIS:GetMouseLocation().X
											darknessPercentage = ColorPicker.Logic.Methods.calculatePercentage(ColorPicker.DarkGrad, ColorPicker.LastDarknessX)
										elseif ColorPicker.ChangingDarkness then
											colorPercentage = ColorPicker.Logic.Methods.calculatePercentage(ColorPicker.ColorGrad, ColorPicker.LastColorX)
											darknessPercentage = ColorPicker.Logic.Methods.calculatePercentage(ColorPicker.DarkGrad)
											ColorPicker.LastDarknessX = Main.Services.UIS:GetMouseLocation().X
										else
											colorPercentage = ColorPicker.Logic.Methods.calculatePercentage(ColorPicker.ColorGrad, ColorPicker.LastColorX)
											darknessPercentage = ColorPicker.Logic.Methods.calculatePercentage(ColorPicker.DarkGrad, ColorPicker.LastDarknessX)
										end

										local baseColor = ColorPicker.Logic.Methods.returnColor(colorPercentage, ColorPicker.ColorGradGradient.Color.Keypoints)
										local finalColor = baseColor:Lerp(Color3.new(0, 0, 0), darknessPercentage)

										ColorPicker.Color.BackgroundColor3 = finalColor
										ColorPicker.CurrentColor = finalColor
										ColorPicker.CurrentDarkness = darknessPercentage

										if ColorPicker.ColorIndicator then
											ColorPicker.ColorIndicator.Position = UDim2.new(colorPercentage, 0, 0.5, 0)
										end
										if ColorPicker.DarknessIndicator then
											ColorPicker.DarknessIndicator.Position = UDim2.new(darknessPercentage, 0, 0.5, 0)
										end

										options.Callback(finalColor)
									end,

									setDefaultColor = function(options)
										local h, s, v = options.DefaultColor:ToHSV()
										ColorPicker.LastColorX = h * ColorPicker.ColorGrad.AbsoluteSize.X + ColorPicker.ColorGrad.AbsolutePosition.X
										ColorPicker.LastDarknessX = options.DefaultDarkness * ColorPicker.DarkGrad.AbsoluteSize.X + ColorPicker.DarkGrad.AbsolutePosition.X
										ColorPicker.CurrentColor = options.DefaultColor
										ColorPicker.CurrentDarkness = options.DefaultDarkness
										ColorPicker.Color.BackgroundColor3 = options.DefaultColor:Lerp(Color3.new(0, 0, 0), options.DefaultDarkness)

										if ColorPicker.ColorIndicator then
											ColorPicker.ColorIndicator.Position = UDim2.new(h, 0, 0.5, 0)
										end
										if ColorPicker.DarknessIndicator then
											ColorPicker.DarknessIndicator.Position = UDim2.new(options.DefaultDarkness, 0, 0.5, 0)
										end
									end,

									toggleColorPicker = function()
										ColorPicker.State = not ColorPicker.State
										if ColorPicker.State then
											Main.Utilities.Tween(ColorPicker.Label, {Size = UDim2.new(1, 0, 0, 65)}, 0.4, Main.TweenTypes.Click)
										else
											Main.Utilities.Tween(ColorPicker.Label, {Size = UDim2.new(1, 0, 0, 30)}, 0.4, Main.TweenTypes.Click)
										end
									end
								},

								Events = {
									MouseEnter = function()
										ColorPicker.Hover = true
										if not ColorPicker.ChangingColor or ColorPicker.ChangingDarkness then
											Main.Utilities.Tween(ColorPicker.Label, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									MouseLeave = function()
										ColorPicker.Hover = false
										if not ColorPicker.ChangingColor or ColorPicker.ChangingDarkness then
											Main.Utilities.Tween(ColorPicker.Label, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									MouseEnterColor = function()
										ColorPicker.HoverColor = true
									end,

									MouseLeaveColor = function()
										ColorPicker.HoverColor = false
									end,

									MouseEnterDarkness = function()
										ColorPicker.HoverDarkness = true
									end,

									MouseLeaveDarkness = function()
										ColorPicker.HoverDarkness = false
									end,

									InputBegan = function(input)
										if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
											if ColorPicker.Hover and not (ColorPicker.HoverDarkness or ColorPicker.HoverColor) then
												ColorPicker.Logic.Methods.toggleColorPicker()
											elseif ColorPicker.State then
												if ColorPicker.HoverColor then
													ColorPicker.ChangingColor = true
													ColorPicker.LastColorX = Main.Services.UIS:GetMouseLocation().X
												end

												if ColorPicker.HoverDarkness then
													ColorPicker.ChangingDarkness = true
													ColorPicker.LastDarknessX = Main.Services.UIS:GetMouseLocation().X
												end

												if (ColorPicker.ChangingColor or ColorPicker.ChangingDarkness) and not ColorPicker.Connection then
													ColorPicker.Connection = Main.Services.runService.RenderStepped:Connect(function()
														ColorPicker.Logic.Methods.updateColorPreview()
														Main.Vars.stopforce = true
													end)
												end
											end
											Main.Utilities.Tween(ColorPicker.Label, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									InputEnded = function(input)
										if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
											ColorPicker.ChangingColor = false
											ColorPicker.ChangingDarkness = false

											if ColorPicker.Connection then
												ColorPicker.Connection:Disconnect()
												ColorPicker.Connection = nil
												Main.Vars.stopforce = false
											end

											if ColorPicker.Hover then
												Main.Utilities.Tween(ColorPicker.Label, {TextColor3 = Color3.fromRGB(230, 230, 230)}, 0.4, Main.TweenTypes.Hover)
											else
												Main.Utilities.Tween(ColorPicker.Label, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4, Main.TweenTypes.Hover)
											end
										end
									end
								},

								Setup = function(options)
									ColorPicker.Label.MouseEnter:Connect(ColorPicker.Logic.Events.MouseEnter)
									ColorPicker.Label.MouseLeave:Connect(ColorPicker.Logic.Events.MouseLeave)
									ColorPicker.ColorGrad.MouseEnter:Connect(ColorPicker.Logic.Events.MouseEnterColor)
									ColorPicker.ColorGrad.MouseLeave:Connect(ColorPicker.Logic.Events.MouseLeaveColor)
									ColorPicker.DarkGrad.MouseEnter:Connect(ColorPicker.Logic.Events.MouseEnterDarkness)
									ColorPicker.DarkGrad.MouseLeave:Connect(ColorPicker.Logic.Events.MouseLeaveDarkness)

									Main.Services.UIS.InputBegan:Connect(ColorPicker.Logic.Events.InputBegan)
									Main.Services.UIS.InputEnded:Connect(ColorPicker.Logic.Events.InputEnded)

									ColorPicker.Logic.Methods.setDefaultColor(options)
									ColorPicker.State = false
									ColorPicker.Label.Size = UDim2.new(1, 0, 0, 30)
								end,
							}

							ColorPicker.Logic.Setup({
								DefaultColor = options.DefaultColor,
								DefaultDarkness = options.DefaultDarkness
							})

							return ColorPicker
						end

						function Tab:TextBox(options)
							options = Main.Utilities.Settings({
								Title = "Preview Textbox",
								Callback = function(v) print(v) end
							}, options or {})

							local TextBox = {
								Hover = false,
								InputHover = false,
								MouseDown = false,
								State = false
							}

							do
								TextBox.MainLabel = Main.Utilities.NewObj("TextLabel", {
									Parent = Tab.Tab,
									BorderSizePixel = 0,
									TextXAlignment = Enum.TextXAlignment.Left,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									TextSize = 12,
									FontFace = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									TextColor3 = Color3.fromRGB(201, 201, 201),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(1, 0, 0, 30),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Text = options.Title,
									LayoutOrder = -1,
									Name = [[TextBox]],
									Position = UDim2.new(1, 0, 0, 0)
								});

								TextBox.InputField = Main.Utilities.NewObj("TextBox", {
									Parent = TextBox.MainLabel,
									CursorPosition = -1,
									TextColor3 = Color3.fromRGB(200, 200, 200),
									PlaceholderColor3 = Color3.fromRGB(255, 255, 255),
									BorderSizePixel = 0,
									TextSize = 14,
									BackgroundColor3 = Color3.fromRGB(19, 19, 19),
									FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
									AnchorPoint = Vector2.new(1, 0.5),
									ClipsDescendants = true,
									PlaceholderText = [[...]],
									Size = UDim2.new(0, 20, 0, 20),
									Position = UDim2.new(1, -2, 0.5, 0),
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									Text = [[]]
								});

								TextBox.InputCorner = Main.Utilities.NewObj("UICorner", {
									Parent = TextBox.InputField,
									CornerRadius = UDim.new(0, 4)
								});
							end

							TextBox.Logic = {
								Methods = {
									GetInputField = function()
										return TextBox.InputField.Text
									end,

									SetInputField = function(Text)
										TextBox.InputField.Text = Text
									end
								},

								Events = {
									HoverState = function(Element, isHovering)
										local color = isHovering and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(200, 200, 200)
										if Element == TextBox.MainLabel then
											TextBox.Hover = isHovering
											Main.Utilities.Tween(TextBox.MainLabel, {TextColor3 = color}, 0.4, Main.TweenTypes.Hover)
										elseif Element == TextBox.InputField then
											TextBox.InputHover = isHovering
											Main.Utilities.Tween(TextBox.InputField, {TextColor3 = color}, 0.4, Main.TweenTypes.Hover)
										end
									end,

									InputBegan = function(input)
										if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and TextBox.InputHover then
											TextBox.MouseDown = true
											TextBox.State = true
											Main.Utilities.Tween(TextBox.InputField, {Size = UDim2.new(0, 120, 0, 20)}, 0.4, Main.TweenTypes.Click)
											TextBox.InputField:CaptureFocus()
										end
									end,

									InputEnded = function(input)
										if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and TextBox.InputHover then
											TextBox.MouseDown = false
										end

										if input.KeyCode == Enum.KeyCode.Return and TextBox.State then
											TextBox.State = false
											Main.Utilities.Tween(TextBox.InputField, {Size = UDim2.new(0, 20, 0, 20)}, 0.4, Main.TweenTypes.Click)
											TextBox.InputField:ReleaseFocus()
											options.Callback(TextBox.InputField.Text)
										end
									end,

									FocusLost = function()
										if TextBox.State then
											TextBox.State = false
											Main.Utilities.Tween(TextBox.InputField, {Size = UDim2.new(0, 20, 0, 20)}, 0.4, Main.TweenTypes.Click)
											options.Callback(TextBox.InputField.Text)
										end
									end
								},

								Setup = function(options)
									TextBox.MainLabel.MouseEnter:Connect(function() TextBox.Logic.Events.HoverState(TextBox.MainLabel, true) end)
									TextBox.MainLabel.MouseLeave:Connect(function() TextBox.Logic.Events.HoverState(TextBox.MainLabel, false) end)

									TextBox.InputField.MouseEnter:Connect(function() TextBox.Logic.Events.HoverState(TextBox.InputField, true) end)
									TextBox.InputField.MouseLeave:Connect(function() TextBox.Logic.Events.HoverState(TextBox.InputField, false) end)

									TextBox.MainLabel.TouchTap:Connect(function() TextBox.Logic.Events.HoverState(TextBox.MainLabel, true) end)
									TextBox.InputField.TouchTap:Connect(function() TextBox.Logic.Events.HoverState(TextBox.InputField, true) end)

									Main.Services.UIS.InputBegan:Connect(TextBox.Logic.Events.InputBegan)
									Main.Services.UIS.InputEnded:Connect(TextBox.Logic.Events.InputEnded)

									TextBox.InputField.FocusLost:Connect(TextBox.Logic.Events.FocusLost)  -- Handle focus loss
								end,
							}

							TextBox.Logic.Setup(options)

							return TextBox
						end	
					end
				end	
				return Tab	
			end
		end
	end
	-- Actions
	do
		local Actions = {
			Close = false,
			Open = true,
			ExitHover = false,
			OpenHover = false,
			DiscordHover = false,
			YoutubeHover = false
		}

		-- Rendering
		do
			Actions.Frame = Main.Utilities.NewObj("Frame", {
				Parent = _Azuma.Gui,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(13, 13, 13),
				AnchorPoint = Vector2.new(0.5, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Name = "Actions"
			})

			Actions.UICorner = Main.Utilities.NewObj("UICorner", {
				Parent = Actions.Frame,
				CornerRadius = UDim.new(0, 6)
			})

			Actions.UICorner = Main.Utilities.NewObj("UICorner", {
				Parent = Actions.Frame,
				CornerRadius = UDim.new(0, 6)
			})

			Actions.DropShadowHolder = Main.Utilities.NewObj("Frame", {
				Parent = Actions.Frame,
				ZIndex = 0,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Name = "DropShadowHolder",
				BackgroundTransparency = 1
			})

			Actions.DropShadow = Main.Utilities.NewObj("ImageLabel", {
				Parent = Actions.DropShadowHolder,
				ZIndex = 0,
				BorderSizePixel = 0,
				SliceCenter = Rect.new(49, 49, 450, 450),
				ScaleType = Enum.ScaleType.Slice,
				ImageTransparency = 0.5,
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://6014261993",
				Size = UDim2.new(1, 31, 1, 31),
				BackgroundTransparency = 1,
				Name = "DropShadow",
				Position = UDim2.new(0.5, 0, 0.5, 0)
			})

			Actions.YoutubeIcon = Main.Utilities.NewObj("ImageLabel", {
				Parent = Actions.Frame,
				AnchorPoint = Vector2.new(0, 0.5),
				Image = "rbxassetid://15199293149",
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundTransparency = 1,
				Name = "Youtube",
				Position = UDim2.new(0, 5, 0.5, 0)
			})

			Actions.DiscordIcon = Main.Utilities.NewObj("ImageLabel", {
				Parent = Actions.Frame,
				AnchorPoint = Vector2.new(1, 0.5),
				Image = "rbxassetid://127970682686597",
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundTransparency = 1,
				Name = "Discord",
				Position = UDim2.new(1, -5, 0.5, 0)
			})

			Actions.OpenIcon = Main.Utilities.NewObj("ImageLabel", {
				Parent = Actions.Frame,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://13868576811",
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundTransparency = 1,
				Name = "Open",
				Position = UDim2.new(0.5, 13, 0.5, 0)
			})

			Actions.ExitIcon = Main.Utilities.NewObj("ImageLabel", {
				Parent = Actions.Frame,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = "rbxassetid://13857933221",
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundTransparency = 1,
				Name = "Exit",
				Position = UDim2.new(0.5, -13, 0.5, 0)
			})
		end

		Actions.Logic = {
			Methods = {
				SetHoverState = function(icon, hoverStateVar)
					icon.MouseEnter:Connect(function()
						Actions[hoverStateVar] = true
					end)

					icon.MouseLeave:Connect(function()
						Actions[hoverStateVar] = false
					end)
				end,

				CloseFrame = function()
					if Actions.Open then
						Actions.Close = true
						Actions.Open = false
						Main.Utilities.Tween(_Azuma.TransitionFrame, {Size = UDim2.new(1, 0, 1, 0)}, 0.8, Main.TweenTypes.Drag, coroutine.wrap(function()
							for _, child in ipairs(_Azuma.MainFrame:GetChildren()) do
								if not (child:IsA("UICorner") or child:IsA("UIPadding") or child:IsA("UIListLayout")) then
									if child.Name ~= "Shadow" then
										child.Visible = false
									end
								end
							end

							_Azuma.MainFrame.AnchorPoint = Vector2.new(0.5, 1)
							_Azuma.MainFrame.Position = UDim2.new(0.5, _Azuma.MainFrame.Position.X.Offset, 0.5, _Azuma.MainFrame.Position.Y.Offset + (_Azuma.MainFrame.Size.Y.Offset / 2))
							_Azuma.TransitionFrame.AnchorPoint = Vector2.new(0, 1)
							_Azuma.TransitionFrame.Position = UDim2.new(0, 0, 1, 0)

							task.wait(0.1)

							Main.Utilities.Tween(_Azuma.MainFrame, {Size = UDim2.new(0, _Azuma.MainFrame.Size.X.Offset, 0, 0)}, 0.8, Main.TweenTypes.Drag)

							coroutine.wrap(function()
								task.wait(0.51)
								_Azuma.ShadowImage.Visible = false
							end)()

							Main.Utilities.Tween(_Azuma.TransitionFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.8, Main.TweenTypes.Drag)
						end))
					end
				end,

				OpenFrame = function()
					coroutine.wrap(function()
						task.wait(0.29)
						_Azuma.ShadowImage.Visible = true
						_Azuma.ShadowFrame.Visible = true
					end)()
					Main.Utilities.Tween(_Azuma.MainFrame, {Size = Main.Vars.DynamicSize}, 0.8, Main.TweenTypes.Drag, function()
						if Actions.Close then
							Actions.Close = false
							Actions.Open = true
							Main.Utilities.Tween(_Azuma.TransitionFrame, {Size = UDim2.new(1, 0, 1, 0)}, 0.8, Main.TweenTypes.Drag, coroutine.wrap(function()
								Main.Utilities.Tween(_Azuma.MainFrame, {Size = Main.Vars.DynamicSize}, 0.8, Main.TweenTypes.Drag)

								for _, child in ipairs(_Azuma.MainFrame:GetChildren()) do
									if not (child:IsA("UICorner") or child:IsA("UIPadding") or child:IsA("UIListLayout")) then
										child.Visible = true
									end
								end

								task.wait(0.1)

								_Azuma.TransitionFrame.AnchorPoint = Vector2.new(0, 0)
								_Azuma.TransitionFrame.Position = UDim2.new(0, 0, 0, 0)
								_Azuma.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
								_Azuma.MainFrame.Position = UDim2.new(0.5, _Azuma.MainFrame.Position.X.Offset, 0.5, _Azuma.MainFrame.Position.Y.Offset - (_Azuma.MainFrame.Size.Y.Offset / 2))

								Main.Utilities.Tween(_Azuma.TransitionFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.8, Main.TweenTypes.Drag)
							end))
						end
					end)
				end,

				HandleInput = function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if Actions.ExitHover and Actions.Open then
							Actions.Logic.Methods.CloseFrame()
						elseif Actions.OpenHover and Actions.Close then
							Actions.Logic.Methods.OpenFrame()
						elseif Actions.DiscordHover then
							setclipboard(options.DiscordLink)
						elseif Actions.YoutubeHover then
							setclipboard(options.YoutubeLink)
						end
					elseif input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode == Enum.KeyCode[_Azuma.UIBind] and Actions.Open then
							Actions.Logic.Methods.CloseFrame()
						elseif input.KeyCode == Enum.KeyCode[_Azuma.UIBind] and Actions.Close then
							Actions.Logic.Methods.OpenFrame()
						end
					end
				end,

				SetupNavigationPosition = function(navigationPosition)
					if navigationPosition == "Top" then
						Actions.Frame.AnchorPoint = Vector2.new(0.5, 0);
						Actions.Frame.Position = UDim2.new(0.5, 0, 0, 5)
						Actions.Frame.Size = UDim2.new(0, 115, 0, 30)

						Actions.DiscordIcon.AnchorPoint = Vector2.new(1, 0.5);
						Actions.YoutubeIcon.AnchorPoint = Vector2.new(0, 0.5);
						Actions.YoutubeIcon.Position = UDim2.new(0, 5, 0.5, 0)
						Actions.DiscordIcon.Position = UDim2.new(1, -5, 0.5, 0)
						Actions.OpenIcon.Position = UDim2.new(0.5, 13, 0.5, 0)
						Actions.ExitIcon.Position = UDim2.new(0.5, -13, 0.5, 0)
					elseif navigationPosition == "Right" then
						Actions.Frame.AnchorPoint = Vector2.new(1, 0.5);
						Actions.Frame.Position = UDim2.new(1, -5, 0.5, 0)
						Actions.Frame.Size = UDim2.new(0, 30, 0, 115)

						Actions.DiscordIcon.AnchorPoint = Vector2.new(0.5, 0.5);
						Actions.YoutubeIcon.AnchorPoint = Vector2.new(0.5, 0.5);
						Actions.YoutubeIcon.Position = UDim2.new(0.5, 0, 0.5, 41)
						Actions.DiscordIcon.Position = UDim2.new(0.5, 0, 0.5, -41)
						Actions.OpenIcon.Position = UDim2.new(0.5, 0, 0.5, 13)
						Actions.ExitIcon.Position = UDim2.new(0.5, 0, 0.5, -13)
					end
				end


			},

			Setup = function()
				Actions.Logic.Methods.SetHoverState(Actions.ExitIcon, "ExitHover")
				Actions.Logic.Methods.SetHoverState(Actions.OpenIcon, "OpenHover")
				Actions.Logic.Methods.SetHoverState(Actions.DiscordIcon, "DiscordHover")
				Actions.Logic.Methods.SetHoverState(Actions.YoutubeIcon, "YoutubeHover")

				Main.Services.UIS.InputBegan:Connect(Actions.Logic.Methods.HandleInput)

				Actions.Logic.Methods.SetupNavigationPosition(options.NavigationPosition)
			end
		}

		Actions.Logic.Setup()
	end	
	Main.Utilities.Dragify(_Azuma.MainFrame)
	Main.Utilities.Cursor(_Azuma.MainFrame, 83884515509675)
	return _Azuma
end

function _NotificationBase(Options, frameName, iconId)
	local Base = {}

	-- Rendering
	do
		Base.NotificationFrame = Main.Utilities.NewObj("Frame", {
			Parent = nil,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(13, 13, 13),
			Size = UDim2.new(1, 0, 0, 60),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = frameName
		})

		Base.NotificationCorner = Main.Utilities.NewObj("UICorner", {
			Parent = Base.NotificationFrame,
			CornerRadius = UDim.new(0, 6)
		})

		Base.DropShadowHolder = Main.Utilities.NewObj("Frame", {
			Parent = Base.NotificationFrame,
			ZIndex = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Name = "DropShadowHolder",
			BackgroundTransparency = 1
		})

		Base.DropShadow = Main.Utilities.NewObj("ImageLabel", {
			Parent = Base.DropShadowHolder,
			ZIndex = 0,
			BorderSizePixel = 0,
			SliceCenter = Rect.new(49, 49, 450, 450),
			ScaleType = Enum.ScaleType.Slice,
			ImageTransparency = 0.5,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://6014261993",
			Size = UDim2.new(1, 47, 1, 47),
			BackgroundTransparency = 1,
			Name = "DropShadow",
			Position = UDim2.new(0.5, 0, 0.5, 0)
		})

		Base.Icon = Main.Utilities.NewObj("ImageLabel", {
			Parent = Base.NotificationFrame,
			AnchorPoint = Vector2.new(0, 0.5),
			Image = iconId,
			Size = UDim2.new(0, 32, 0, 32),
			BackgroundTransparency = 1,
			Name = frameName .. "_icon",
			Position = UDim2.new(0, 14, 0.5, 0)
		})

		Base.NotifTypeLabel = Main.Utilities.NewObj("TextLabel", {
			Parent = Base.NotificationFrame,
			BorderSizePixel = 0,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(1, -60, 0, 14),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = Options.Title,
			Name = "NotifType",
			Position = UDim2.new(1, 0, 0, 14)
		})

		Base.DescLabel = Main.Utilities.NewObj("TextLabel", {
			Parent = Base.NotificationFrame,
			BorderSizePixel = 0,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 9,
			FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(81, 81, 81),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(1, -60, 0, 28),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = Options.Description,
			Name = "Desc",
			Position = UDim2.new(1, 1, 0, 33)
		})

		Base.DescPadding = Main.Utilities.NewObj("UIPadding", {
			Parent = Base.DescLabel,
			PaddingRight = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5)
		})
	end

	Base.Logic = {
		Methods = {
			UpdateSizesAndPositions = function()
				Base.DescLabel.Size = UDim2.new(Base.DescLabel.Size.X.Scale, Base.DescLabel.Size.X.Offset, 0, Base.DescLabel.TextBounds.Y)
				Base.NotifTypeLabel.Size = UDim2.new(Base.NotifTypeLabel.Size.X.Scale, Base.NotifTypeLabel.Size.X.Offset, 0, Base.NotifTypeLabel.TextBounds.Y)
				Base.DescLabel.Position = UDim2.new(Base.NotifTypeLabel.Position.X.Scale, Base.NotifTypeLabel.Position.X.Offset, 0, Base.NotifTypeLabel.TextBounds.Y + 19)

				Main.Utilities.Tween(Base.NotificationFrame, {
					Size = UDim2.new(Base.NotificationFrame.Size.X.Scale, Base.NotificationFrame.Size.X.Offset, 0, Base.DescLabel.TextBounds.Y + Base.NotifTypeLabel.TextBounds.Y + 34)
				}, 0.2, Main.TweenTypes.Hover)
			end,

			FadeOutNotification = function(duration)
				coroutine.wrap(function()
					task.wait(duration)

					Main.Utilities.Tween(Base.NotificationFrame, {BackgroundTransparency = 1}, 0.6, Main.TweenTypes.Drag)

					for _, v in pairs(Base.NotificationFrame:GetDescendants()) do
						if v:IsA("ImageLabel") then
							Main.Utilities.Tween(v, {ImageTransparency = 1}, 0.6, Main.TweenTypes.Drag)
						elseif v:IsA("TextLabel") then
							Main.Utilities.Tween(v, {TextTransparency = 1}, 1.2, Main.TweenTypes.Drag)
						end
					end

					task.wait(0.8)
					Base.NotificationFrame:Destroy()
				end)()
			end
		},

		Setup = function(self, options)
			Base.Logic.Methods.UpdateSizesAndPositions()
			Base.Logic.Methods.FadeOutNotification(Options.Duration or options.duration or 69420)
		end
	}

	Base.Logic.Setup(Options)

	return Base	
end

function Azuma:Notify(options)
	options = Main.Utilities.Settings({
		Title = "Preview Notification",
		Description = "Preview Description",
		Duration = 2
	}, options or {})

	-- Rendering/Logic
	local Notify = _NotificationBase(options, "Notification", "rbxassetid://14957911417")
	return Notify
end

function Azuma:Warn(options)
	options = Main.Utilities.Settings({
		Title = "Preview Warning",
		Description = "Preview Warning",
		Duration = 2
	}, options or {})

	-- Rendering/Logic
	local Warn = _NotificationBase(options, "Warning", "rbxassetid://14966839736")
	return Warn
end

function Azuma:Init()
	AzumaUI.NotificationsFrame.Parent = AzumaUI.Gui
	AzumaUI.NotificationsListLayout.Parent = AzumaUI.NotificationsFrame
	AzumaUI.NotificationsPadding.Parent = AzumaUI.NotificationsFrame
	_Azuma.MainFrame.Parent = AzumaUI.Gui
end

print("Loaded Tone Ui Libary That Took " .. Azuma.LoadTime)

return Azuma
