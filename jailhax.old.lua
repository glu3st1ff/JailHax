--> [[ Load UI ]] <--

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Eazvy/UILibs/main/Librarys/Splix/Example"))()

do
	local Window = Library:AddWindow("Jailhax - V3 - discord.gg/jailhax", {
		main_color = Color3.fromRGB(0, 225, 0),
		min_size = Vector2.new(350, 400),
		toggle_key = Enum.KeyCode.RightShift,
		can_resize = true
	})

	local MainTab = Window:AddTab("Main")
	local RobberiesTab = Window:AddTab("Robberies")
	local SettingsTab = Window:AddTab("Settings")
	local CreditsTab = Window:AddTab("Credits")

	do
		local StatusLabel = MainTab:AddLabel("Loading.")

		local EnabledSwitch = MainTab:AddSwitch("Enabled", function(bool)
			Settings.Enabled = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end) 

		EnabledSwitch:Set(Settings.Enabled)

		local SkipBasicCratesSwitch = MainTab:AddSwitch("Skip Basic Crates", function(bool)
			Settings.SkipBasicCrates = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end) 

		SkipBasicCratesSwitch:Set(Settings.SkipBasicCrates)

		local SmallServersSwitch = MainTab:AddSwitch("Small Servers", function(bool)
			Settings.SmallServers = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end) 

		SmallServersSwitch:Set(Settings.SmallServers)

		local PickUpCashSwitch = MainTab:AddSwitch("Pick Up Cash", function(bool)
			Settings.PickUpCash = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end) 

		PickUpCashSwitch:Set(Settings.PickUpCash)

		MainTab:AddButton("Copy Discord Invite", function()
			StarterGui:SetCore("SendNotification", {
				Title = "Jailhax Discord Invite";
				Text = "The Jailhax Discord invite has been copied to your clipboard.";
				Duration = 5;
			})

			setclipboard("https://discord.gg/jailhax")
		end)

		local MoneyEarnedLabel = MainTab:AddLabel("Money Earned: $0")
		local ElapsedTimeLabel = MainTab:AddLabel("Elapsed Time: 0h/0m")
		local EstimatedHourlyLabel = MainTab:AddLabel("Estimated Hourly: $0")

		MainTab:AddLabel("\n\n\n\n\n\n\n\n\n\n\n  ⚠️ To speed up the farming, purchase helicopters!")

		local RobCargoShipSwitch = RobberiesTab:AddSwitch("Rob Cargoship", function(bool)
			Settings.RobCargoShip = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end)

		RobCargoShipSwitch:Set(Settings.RobCargoShip)

		local RobAirdropSwitch = RobberiesTab:AddSwitch("Rob Airdrop", function(bool)
			Settings.RobAirdrop = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end)

		RobAirdropSwitch:Set(Settings.RobAirdrop)

		local RobMansionSwitch = RobberiesTab:AddSwitch("Rob Mansion", function(bool)
			Settings.RobMansion = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end)

		RobMansionSwitch:Set(Settings.RobMansion)

		local AutoOpenSafesSwitch = SettingsTab:AddSwitch("Auto Open Safes", function(bool)
			Settings.AutoOpenSafes = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end)

		AutoOpenSafesSwitch:Set(Settings.AutoOpenSafes)

		local LogWebhookSwitch = SettingsTab:AddSwitch("Log Webhook", function(bool)
			Settings.LogWebhook = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end)

		LogWebhookSwitch:Set(Settings.LogWebhook)

		local FpsBoosterSwitch = SettingsTab:AddSwitch("Fps Booster", function(bool)
			Settings.FpsBooster = bool
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end)
		
		FpsBoosterSwitch:Set(Settings.FpsBooster)

		SettingsTab:AddButton("Open All Safes", function()
			local SafeAmount = #Modules.Store._state.safesInventoryItems
			if SafeAmount ~= 0 then
				Spawn(function()
					for _ = 1, SafeAmount do
						local CurrentSafe = Modules.Store._state.safesInventoryItems[1]

						ReplicatedStorage[Modules.SafesConsts.SAFE_OPEN_REMOTE_NAME]:FireServer(CurrentSafe.itemOwnedId)
						Wait(3)
					end
				end)
			end
		end)

		SettingsTab:AddButton("Buy Littlebird", function()
			ReplicatedStorage:WaitForChild("GaragePurchaseVehicle"):FireServer("LittleBird")			
		end)

		SettingsTab:AddButton("Buy Blackhawk", function()
			ReplicatedStorage:WaitForChild("GaragePurchaseVehicle"):FireServer("BlackHawk")	
		end)

		SettingsTab:AddSlider("Heli Speed", function(int)
			Settings.HeliSpeed = int
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end, {
			["min"] = 550,
			["max"] = 5000, 
			["readonly"] = false,
			["start"] = Settings.HeliSpeed
		})

		SettingsTab:AddSlider("Flight Speed", function(int)
			Settings.FlightSpeed = int
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end, {
			["min"] = 155,
			["max"] = 175, 
			["readonly"] = false,
			["start"] = Settings.FlightSpeed
		})

		local WebhookTextBox = SettingsTab:AddTextBox("Webhook Url", function(string)
			Settings.WebhookUrl = string
			SaveFile("AutoCratePaid.json", HttpService:JSONEncode(Settings))
		end)

		WebhookTextBox.Text = Tostring(Settings.WebhookUrl)

		CreditsTab:AddLabel("justravens: Scripting")

		function UpdateStatus(text) 
			Spawn(function()
				local function StatusFix()
					StatusLabel.Text = Tostring(text)
				end

				while not pcall(StatusFix) do
					Wait(0.01)
				end
			end)
		end

		function UpdateStats(money, time) 
			Spawn(function()
				local function FixStats()
					ElapsedTimeLabel.Text = "Elapsed Time: " .. FormatTime(time)
					MoneyEarnedLabel.Text = "Money Earned: $" .. FormatMoney(money)
				end

				while not pcall(FixStats) do
					Wait(0.01)
				end
			end)

			Spawn(function()
				local function FixEstimation()
					EstimatedHourlyLabel.Text = "Estimated Hourly: $" .. FormatMoney(MathFloor(money / time * 3600))
				end

				while not pcall(FixEstimation) do
					Wait(0.01)
				end
			end)
		end
	end

	MainTab:Show()
	Library:FormatWindows()
end
