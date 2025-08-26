--> [[ Load Luraph Macros ]] <--

if not LPH_OBFUSCATED then
	getfenv().LPH_JIT_MAX         = function(...) return ... end;
	getfenv().LPH_NO_VIRTUALIZE   = function(...) return ... end;
	getfenv().LPH_ENCSTR          = function(...) return ... end;

	script_key          		  = "ee";
	LRM_UserNote        		  = "Fast Render"

	NO_RE_EXECUTE                 = true;
end

--> [[ Load Game ]] <--

while not game:IsLoaded() do
	task.wait()
end

--> [[ Execution Check ]] <--

if getgenv().Jailhax then
	return
else
	getgenv().Jailhax = true
end

--> [[ Load Services ]] <--

local CloneRef                    = cloneref or function(...) return ... end

local Services                    = {
	Workspace                     = CloneRef(game:GetService("Workspace")),
	Players                       = CloneRef(game:GetService("Players")),
	ReplicatedStorage             = CloneRef(game:GetService("ReplicatedStorage")),
	RunService                    = CloneRef(game:GetService("RunService")),
	HttpService                   = CloneRef(game:GetService("HttpService")),
	TweenService                  = CloneRef(game:GetService("TweenService")),
	TeleportService               = CloneRef(game:GetService("TeleportService")),
	Lighting                      = CloneRef(game:GetService("Lighting")),
	StarterGui                    = CloneRef(game:GetService("StarterGui")),
	CoreGui                       = CloneRef(game:GetService("CoreGui")),
	CollectionService             = CloneRef(game:GetService("CollectionService"))
}

local Workspace                   = Services.Workspace
local Players                     = Services.Players
local ReplicatedStorage           = Services.ReplicatedStorage
local RunService                  = Services.RunService
local HttpService                 = Services.HttpService
local TweenService                = Services.TweenService
local TeleportService             = Services.TeleportService
local Lighting                    = Services.Lighting
local StarterGui                  = Services.StarterGui
local CoreGui                     = Services.CoreGui
local CollectionService           = Services.CollectionService

--> [[ Load Modules ]] <--

local Modules                     = {
	VehicleUtils                  = require(ReplicatedStorage.Vehicle.VehicleUtils),
	UI                            = require(ReplicatedStorage.Module.UI),
	TagUtils                      = require(ReplicatedStorage.Tag.TagUtils),
	RobberyConsts                 = require(ReplicatedStorage.Robbery.RobberyConsts),
	CharacterUtil                 = require(ReplicatedStorage.Game.CharacterUtil),
	TeamChooseUI                  = require(ReplicatedStorage.TeamSelect.TeamChooseUI),
	MansionRobberyUtils           = require(ReplicatedStorage.MansionRobbery.MansionRobberyUtils),
	GunShopUI                     = require(ReplicatedStorage.Game.GunShop.GunShopUI),
	GunShopUtils                  = require(ReplicatedStorage.Game.GunShop.GunShopUtils),
	NPC                           = require(ReplicatedStorage.NPC.NPC),
	RayCast                       = require(ReplicatedStorage.Module.RayCast),
	BulletEmitter                 = require(ReplicatedStorage.Game.ItemSystem.BulletEmitter),
	GunItem                       = require(ReplicatedStorage.Game.Item.Gun),
	InventoryItem                 = require(ReplicatedStorage.Inventory.InventoryItem),
	ItemSystem                    = require(ReplicatedStorage.Game.ItemSystem.ItemSystem),
	Store                         = require(ReplicatedStorage.App.store),
	SafesConsts                   = require(ReplicatedStorage.Safes.SafesConsts),
}

local RayIgnore                   = Modules.RayCast.RayIgnoreNonCollideWithIgnoreList

--> [[ Load Misc ]] <--

local Wait                        = task.wait
local Delay                       = task.delay
local Spawn                       = task.spawn
local MathFloor                   = math.floor
local Tostring                    = tostring
local CFrameNew                   = CFrame.new
local Vector3New                  = Vector3.new
local TableInsert                 = table.insert
local TableFind                   = table.find
local UpVector2Point5             = Vector3New(0, 2.5, 0)
local Camera                      = Workspace.CurrentCamera

local FormatTime = LPH_JIT_MAX(function(seconds)
    local Hours = MathFloor(seconds / 3600)
    local Minutes = MathFloor((seconds % 3600) / 60)

    return Hours .. "h/" .. Minutes .. "m"
end)

local FormatMoney = LPH_JIT_MAX(function(number)
	local Numbers = tostring(number):split("")

    if #Numbers >= 10 then
		return Numbers[1] .. "." .. Numbers[2] .. "B"
	elseif #Numbers == 9 then
		return Numbers[1] .. Numbers[2] .. Numbers[3] .. "M"
	elseif #Numbers == 8 then
		return Numbers[1] .. Numbers[2] .. "." .. Numbers[3] .. "M"
	elseif #Numbers == 7 then
		return Numbers[1] .. "." .. Numbers[2] .. "M"
	elseif #Numbers == 6 then
		return Numbers[1] .. Numbers[2] .. Numbers[3] .. "k"
	elseif #Numbers == 5 then
		return Numbers[1] .. Numbers[2] .. "." .. Numbers[3] .. "k"
	elseif #Numbers == 4 and #Numbers[2] == 0 then
		return Numbers[1] .. "k"
	elseif #Numbers == 4 then
		return Numbers[1] .. "." .. Numbers[2] .. "k"
	end	

	return number
end)

--> [[ Load Script Directory ]] <--

local function GetDirectory()
	local Directory = "Jailhax"
	
	if not isfolder(Directory) then
		makefolder(Directory)
	end

	return Directory
end

local function SaveFile(name, data)
	local success, _ = pcall(function()
		writefile(GetDirectory() .. "\\" .. name, data)
	end)

	return success
end

local function LoadFile(name)
	local success, data = pcall(function()
		return readfile(GetDirectory() .. "\\" .. name)
	end)

	return (success and data) or nil
end

--> [[ Load Settings ]] <--

local Settings                    = {
	Enabled                       = true,
	SkipBasicCrates               = false,
	SmallServers                  = true,
	PickUpCash                    = true,
	RobCargoShip                  = true,
	RobAirdrop                    = true,
	RobMansion                    = true,
	AutoOpenSafes                 = true,
	LogWebhook                    = false,
	FpsBooster                    = false,
	HeliSpeed                     = 5000,
	FlightSpeed                   = 175,
	WebhookUrl                    = "",
}

local SettingsFile = LoadFile("AutoCratePaid.json")

if SettingsFile then
	local Success, Data = pcall(function()
		return HttpService:JSONDecode(SettingsFile)
	end)

	if Success then
		for i, v in Data do
			Settings[i] = v
		end
	end
end

--> [[ Load Player ]] <--

local Player                      = Players.LocalPlayer
local Character                   = nil
local Humanoid                    = nil
local Root                        = nil
local Vehicle                     = nil
local VehicleRoot                 = nil
local PlayerGui                   = Player:WaitForChild("PlayerGui")
local Backpack                    = Player:WaitForChild("Folder")
local Leaderstats                 = Player:WaitForChild("leaderstats")

PlayerGui:WaitForChild("RobberyMoneyGui")

local function GetPlayer(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")

	Humanoid.Died:Connect(function()
		Character, Root, Humanoid = nil, nil, nil
	end)
end

local function GetVehicle()
	local VehicleModel = Modules.VehicleUtils.GetLocalVehicleModel()

	if not VehicleModel then
		Vehicle = nil
		VehicleRoot = nil
	else
		Vehicle = VehicleModel
		VehicleRoot = Vehicle.PrimaryPart
	end
end

if Player.Character then
	GetPlayer(Player.Character)
end

Player.CharacterAdded:Connect(GetPlayer)

GetVehicle()

Modules.VehicleUtils.OnVehicleEntered:Connect(GetVehicle)
Modules.VehicleUtils.OnVehicleExited:Connect(GetVehicle)

--> [[ Load Bypass ]] <--

LPH_NO_VIRTUALIZE(function()
	for _, v in getgc() do
		if typeof(v) == "function" then
			local DebugInfo = debug.info(v, "n")

			if DebugInfo:match("CheatCheck") then
				hookfunction(v, function() end)
			end

			if DebugInfo:match("CheatCheck0") then
				hookfunction(v, function() end)
			end
		end
	end
end)()

--> [[ Load Object Remover ]] <--

LPH_NO_VIRTUALIZE(function()
	for _, v in Workspace:GetChildren() do
		if v.Name == "Bench" then
			v:Destroy()
		end
	end
end)()

--> [[ Load Client Statistics ]] <--

if getgenv().StartingTime == nil then
	getgenv().StartingTime = tick()
end

if getgenv().StartingMoney == nil then
	getgenv().StartingMoney = Leaderstats.Money.Value 
end

--> [[ Server Hop ]] <--

local CanServerHop                = true
local Serverhopping               = false
local Queue                       = ""
local Success                     = false

local function ServerHop()
	if Serverhopping then return end
	if not CanServerHop then repeat Wait(0.1) until CanServerHop end

	Serverhopping = true

	local ScriptFile = GetDirectory() .. "/AutoCratePaid.lua"
	local ScriptSaved = game:HttpGet("https://jailhax.lol/scripts/AutoCratePaid.lua")
	
	writefile(ScriptFile, ScriptSaved)

	if NO_RE_EXECUTE then
		Queue = [[
			getgenv().StartingMoney = ]] .. getgenv().StartingMoney .. [[
			getgenv().StartingTime = ]] .. getgenv().StartingTime .. [[
			script_key = "]] .. script_key .. [["

			while not game:IsLoaded() do
				task.wait()
			end
		]]
	else
		Queue = [[
			getgenv().StartingMoney = ]] .. getgenv().StartingMoney .. [[
			getgenv().StartingTime = ]] .. getgenv().StartingTime .. [[
			script_key = "]] .. script_key .. [["

			while not game:IsLoaded() do
				task.wait()
			end

			local success, _ = pcall(function()
				loadfile("]] .. ScriptFile .. [[")();
			end)
	
			if not success then
				loadstring(game:HttpGet("https://jailhax.lol/scripts/AutoCratePaid.lua"))()	
			end
		]]
	end

	queue_on_teleport(Queue)
	
	Player.OnTeleport:Connect(function(state)
		if state == Enum.TeleportState.Started then
			Success = true
		end
	end)

	while not Success do
		pcall(function()
			local Server, Servers = nil, nil

			repeat
				Servers = HttpService:JSONDecode((game:HttpGet("https://api.jailhax.lol/servers" .. ((Settings.SmallServers and "") or "?type=big"))))
				Server = Servers.Data[math.random(1, #Servers.Data)]
			until Server and Servers["Success"] == true

			if Server.playing < (Server.maxPlayers - 2) and Server.id ~= game.JobId then
				pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, Player)
					TeleportService.TeleportInitFailed:Wait()
				end)
			end

			if Success then
				Wait(math.huge)
			end
		end)
	end
end

--> [[ Load Fail Safe ]] <--

local Loaded = false

Delay(10, function()
	if not Loaded then
		Wait(2)
		ServerHop()
	end
end)

--> [[ Load UI ]] <--

local Library = loadstring(game:HttpGet("https://jailhax.lol/misc/Gui.lua"))()

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

--> [[ Load Teleportation ]] <--

local BlacklistedCars             = {}
local CanDeathFree                = false
local InHeli                      = function() return (Vehicle and (Vehicle.Name == "Heli" or Vehicle.Name == "LittleBird" or Vehicle.Name == "BlackHawk" or Vehicle.Name == "EscapeBot") and true) or false end

local function IsArrested()
	return (PlayerGui.MainGui.CellTime.Visible or Backpack:FindFirstChild("Cuffed") and true) or false
end

local function ExitVehicle()
	if not Character or not Root or not Humanoid or IsArrested() or Humanoid.Health == 0 or not Vehicle then
		return error()
	end

	Modules.CharacterUtil.OnJump()

	repeat 
		Wait()
	until not Vehicle or Humanoid.Health <= 0
end

local function InstantTeleport(cframe)
	if not Character or not Root or not Humanoid or IsArrested() or Humanoid.Health == 0 then
		return error()
	end

	CanDeathFree = true

	pcall(ExitVehicle)

	Humanoid.Health = 0
	Player.CharacterAdded:Wait()

	repeat
		Wait()
	until Character and Root

	Root.CFrame = cframe
	Wait(0.75)

	if (Root.Position - cframe.Position).Magnitude > 30 then
		return InstantTeleport(cframe)
	end
end

local GetClosestVehicle = LPH_JIT_MAX(function()
	if not Character or not Root or not Humanoid or IsArrested() or Humanoid.Health == 0 then
		return false
	end
	
	local ClosestDistance = math.huge
	local ClosestVehicle = nil
	
	local OwnedHelis = {"Heli"}
	local OtherHelis = {"LittleBird", "BlackHawk", "Escape Bot"}

	for i, _ in Modules.Store._state.garageOwned.Vehicles do
		if TableFind(OtherHelis, i) then
			TableInsert(OwnedHelis, i)
		end
	end
	
	for _, v in Workspace.Vehicles:GetChildren() do
		if not TableFind(OwnedHelis, v.Name) then
			continue
		end
		
		if TableFind(BlacklistedCars, v) then
			continue
		end

		if not v:FindFirstChild("Seat") then
			continue
		end
		
		if v.Seat.Player.Value then
			continue
		end

		if v.Seat.Position.Y > 300 then
			continue
		end

		local MagnitudedResponse = (Root.Position - v.PrimaryPart.Position).Magnitude

		if MagnitudedResponse > ClosestDistance then
			continue
		end

		ClosestDistance = MagnitudedResponse
		ClosestVehicle = v
	end
	
	return ClosestVehicle
end)

local GetHelicopter = LPH_JIT_MAX(function()
	while not Vehicle do
		local TargetVehicle = GetClosestVehicle()

		if TargetVehicle then
			InstantTeleport(TargetVehicle.Seat.CFrame + UpVector2Point5)
		else
			return false
		end

		if TargetVehicle and TargetVehicle.PrimaryPart and TargetVehicle:FindFirstChild("Seat") and not TargetVehicle.Seat.Player.Value and (TargetVehicle.PrimaryPart.Position - Root.Position).Magnitude < 30 and not TableFind(BlacklistedCars, TargetVehicle) then
			for i = 1, 100 do
				if Vehicle then
					return
				end

				for _, v in Modules.UI.CircleAction.Specs do
					if v.Part and v.Part == TargetVehicle:FindFirstChild("Seat") then
						v:Callback(true)
					end

					if Vehicle then
						break
					end
				end

				if Vehicle then
					for _, v in TargetVehicle:GetDescendants() do
						if v:IsA("Part") or v:IsA("MeshPart") then
							v.CanCollide = false
						end
					end
					return
				end

				if TargetVehicle:GetAttribute("Locked") and i == 10 then
					TableInsert(BlacklistedCars, TargetVehicle)
					break
				end

				if (TargetVehicle.PrimaryPart.Position - Root.Position).Magnitude > 30 then
					break
				end

				Wait(0.01)
			end
		elseif TargetVehicle and TargetVehicle.PrimaryPart and TargetVehicle:FindFirstChild("Seat") and not TargetVehicle.Seat.Player.Value and (TargetVehicle.PrimaryPart.Position - Root.Position).Magnitude > 30 and not TableFind(BlacklistedCars, TargetVehicle) then
			InstantTeleport(TargetVehicle.Seat.CFrame + UpVector2Point5)	

			if TargetVehicle then
				for _, v in TargetVehicle:GetDescendants() do
					if v:IsA("Part") or v:IsA("MeshPart") then
						v.CanCollide = false
					end
				end
			end
		elseif not GetClosestVehicle() and not TargetVehicle then
			return false
		end

		if Vehicle then
			return
		end

		Wait()
	end
end)

--> [[ Load Robbery Checks ]] <--

local RobberyState = ReplicatedStorage.RobberyState
local RobberyConsts = Modules.RobberyConsts

local Robberies = {
	Mansion = {
		Open = false,
		HasRobbed = false
	},

	Ship = {
		Open = false,
		HasRobbed = false
	},

	Airdrop = {
		Open = false,
		HasRobbed = false
	}
}

local function UpdateRobberyStatus(robbery, name, check, special)
	local RobberyStatus = RobberyState:FindFirstChild(robbery)

	if not RobberyStatus then
		Robberies[name].Open = false
		return
	end

	local RobberyStatusValue = RobberyStatus.Value

	Robberies[name].Open = ((RobberyStatusValue == 1 and not check) and true) or ((RobberyStatusValue == 2 and not special) and true) or false

	if Robberies[name].Open == false then
		Robberies[name]["HasRobbed"] = false
	end
end

Spawn(LPH_NO_VIRTUALIZE(function()
	while Wait(0.01) do
		UpdateRobberyStatus(RobberyConsts.ENUM_ROBBERY.CARGO_SHIP, "Ship")
		UpdateRobberyStatus(RobberyConsts.ENUM_ROBBERY.MANSION, "Mansion", false, true)
		Robberies["Airdrop"].Open = (Workspace:FindFirstChild("Drop") and true) or false
	end
end))

--> [[ Load Antifall ]] <--

local OldPointTag = Modules.TagUtils.isPointInTag

Modules.TagUtils.isPointInTag = LPH_NO_VIRTUALIZE(function(pos, tag)
	if tag == "NoRagdoll" then
		return true
	elseif tag == "NoFallDamage" then
		return true
	elseif tag == "NoParachute" then
		return true
	end 

	return OldPointTag(pos, tag)
end)

--> [[ Load Map Setup ]] <--

local function ScanMap()
    Camera.CameraType = Enum.CameraType.Scriptable

	if not string.find(LRM_UserNote, "$Fast Render") then
		for i, v in {
			Vector3New(-846, 39, -6231), 
			Vector3New(-1541, 39, 3311), 
			Vector3New(-363, 39, -6340), 
			Vector3New(-820, 39, 3306), 
			Vector3New(44, 39, -6409), 
			Vector3New(811, 39, 3206), 
			Vector3New(308, 39, -6350), 
			Vector3New(979, 39, 3173), 
			Vector3New(683, 39, -6267), 
			Vector3New(1303, 39, 3150), 
			Vector3New(1350, 39, -5764), 
			Vector3New(1976, 39, 3028), 
			Vector3New(2698, 39, -5365) 
		} do
			local TweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	
			pcall(function()
				UpdateStatus("Scanning map [" .. Tostring(i) .. "/13]...")
	
				local Tween = TweenService:Create(Camera, TweenInfo, {CFrame = CFrameNew(v)})
				Tween:Play() 
	
				Tween.Completed:Wait()
			end)
		end
	else
		for i, v in {
			CFrameNew(882, 92, -638),
			CFrameNew(1284, 133, -344),
			CFrameNew(896, 129, 122),
			CFrameNew(-395, 147, -3244),
			CFrameNew(761, 125, -3306),
			CFrameNew(156, 170, -4152),
			CFrameNew(555, 103, -4710),
			CFrameNew(1112, 116, -3900)
		} do
			local TweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	
			pcall(function()
				UpdateStatus("Scanning map [" .. Tostring(i) .. "/8]...")
	
				local Tween = TweenService:Create(Camera, TweenInfo, {CFrame = v})
				Tween:Play() 
	
				Tween.Completed:Wait()
			end)
		end
	end

    Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = Humanoid
end

--> [[ Load Misc Functions ]] <--

local SetIdentity = setidentity or set_thread_identity or setcontext or setthreadcontext or set_thread_context or setthreadidentity

local function FireTouchInterest(part)
	if Root then
		firetouchinterest(Root, part, 0)
		Wait()
		firetouchinterest(Root, part, 1)
	end
end

local function GetPistol(bool)
	SetIdentity(2)

	pcall(Modules.GunShopUI.open)

	repeat
		firesignal(PlayerGui.GunShopGui.Container.Container.Main.Container.Slider.Pistol.Bottom.Action.MouseButton1Down)
		Wait()
	until (bool and Backpack:FindFirstChild("Pistol")) or not Backpack:FindFirstChild("Pistol")

	SetIdentity(8)

	pcall(Modules.GunShopUI.close)
end

local function EquipGun(bool)
	if not Backpack:FindFirstChild("Pistol") then GetPistol(true) end

	if not Backpack:FindFirstChild("Pistol") then
		return
	end

	Modules.InventoryItem.AttemptSetEquipped({ obj = Backpack.Pistol }, bool)
end

local function ShootGun()
	local CurrentGun = Modules.ItemSystem.GetLocalEquipped
	
	if Backpack:FindFirstChild("Pistol") and Backpack.Pistol:GetAttribute("AmmoCurrent") and Backpack.Pistol:GetAttribute("AmmoCurrent") == 0 then
		GetPistol(false)
	end

	if not CurrentGun() then
		GetPistol(true)
	end

	Modules.GunItem._attemptShoot(CurrentGun())
end

local function WaitForReward()
	if PlayerGui.AppUI:FindFirstChild("RewardSpinner") then
		CanServerHop = false
		repeat 
			Wait() 
		until not PlayerGui.AppUI:FindFirstChild("RewardSpinner")
		CanServerHop = true
	end
end

--> [[ Load Webhooking ]] <--

local Request = (http and http.request) or (syn and syn.request) or request or HttpPost or http_request

local function LogWebhook(text)
	pcall(function()
		local MoneyMade = Leaderstats.Money.Value - getgenv().StartingMoney
		local RunTime = tick() - getgenv().StartingTime
		local ClockTime = os.date("!%Y-%m-%dT%H:%M:%SZ")

		local Headers = {
			["Content-Type"] =  "application/json"
		}

		local data = {
			["content"] = nil,
			["embeds"] = {
				{
					["title"] = "Jailhax Dropfarm",
					["description"] = "``👨‍💼`` **Username**: " .. Tostring(Player.Name) .. "\n``💲`` **Money Earned**: $" .. FormatMoney(MoneyMade) .. "\n" .. "``💲`` **Money**: " .. FormatMoney(Leaderstats.Money.Value) .. "\n" .. "``❓`` **Estimated Hourly**: $" .. FormatMoney(MathFloor(MoneyMade / RunTime * 3600)) .. "\n" .. "``⌛`` **Elapsed Time**: " .. FormatTime(RunTime) .. "\n" .. "```" .. Tostring(text) .. "```",
					["color"] = 16711680,
					["thumbnail"] = {
						["url"] = "https://jailhax.lol/assets/Jailhax.png"
					},
					["footer"] = {
						["text"] = "discord.gg/jailhax"
					},
					["timestamp"] = ClockTime
				}
			},
			["attachments"] = {}
		}		

		local PlayerData = HttpService:JSONEncode(data)

		Request({ Url = Tostring(Settings.WebhookUrl), Body = PlayerData, Method = "POST", Headers = Headers })
	end)
end

--> [[ Load Robberies ]] <--

local function RobShip()
	if not Character or not Root or not Humanoid or IsArrested() or Humanoid.Health == 0 then
		return error()
	end

	if not Settings.RobCargoShip then return end

	if not Robberies.Ship.Open then
		return
	end

	if not InHeli() then
		if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
			Spawn(LogWebhook, "Getting a helicopter...")
		end

		UpdateStatus("Getting a helicopter...")
		
		if GetClosestVehicle() then
			GetHelicopter()
		else
			Robberies.Ship.HasRobbed = true
			return
		end
	end

	if not Robberies.Ship.Open then
		return
	end

	if not Vehicle then
		Robberies.Ship.HasRobbed = true
		return
	end
	
	Robberies.Ship.HasRobbed = true

	UpdateStatus("Moving heli up...")

	Character:PivotTo(CFrameNew(Root.Position.X, 600, Root.Position.Z))
	Wait(0.1)

	if not Vehicle.Preset:FindFirstChild("RopePull") then
		if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
			Spawn(LogWebhook, "Deploying the rope...")
		end

		UpdateStatus("Deploying the rope...")

		local TickTimeout = tick()

		repeat
			Modules.VehicleUtils.Classes.Heli.attemptDropRope()
			Wait(1)
		until Vehicle.Preset:FindFirstChild("RopePull") or tick() - TickTimeout > 5

		if not Vehicle.Preset:FindFirstChild("RopePull") then
			return
		end
	end

	local RopeConstraint = Vehicle.Winch:FindFirstChild("RopeConstraint")
	local RopePull = Vehicle.Preset:FindFirstChild("RopePull")

	if not RopeConstraint or not RopePull then
		return
	else
		RopeConstraint.Length = 999
		RopeConstraint.WinchEnabled = true
		RopePull.CanCollide = false
		RopePull.Massless = true
	end

	Wait(1.95)

	if not Robberies.Ship.Open then
		return
	end

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Collecting & robbing crates...")
	end

	UpdateStatus("Collecting & robbing crates...")

	for _ = 1, 2 do
		if not Robberies.Ship.Open then
			return
		end

		local Crate = Workspace.CargoShip.Crates:GetChildren()[1]

		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = Crate.MeshPart.CFrame

		Wait(1)
		
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = Humanoid

		local TickTimeout1 = tick()

		repeat
			RopePull:PivotTo(Crate.MeshPart.CFrame)
			RopePull:FindFirstChild("ReqLink"):FireServer(Crate, Vector3.zero)
			Wait()
		until RopePull.AttachedTo.Value ~= nil or not Robberies.Ship.Open or not RopePull:FindFirstChild("ReqLink") or not Crate or not Crate:FindFirstChild("MeshPart") or tick() - TickTimeout1 > 5

		if not RopePull:FindFirstChild("ReqLink") then
			return
		end

		if not Robberies.Ship.Open then
			return
		end

		if not Crate:FindFirstChild("MeshPart") and tick() - TickTimeout1 > 5 then
			return
		end

		WaitForReward()
		Wait(0.1)

		local TickTimeout2 = tick()

		repeat
			RopePull:PivotTo(CFrameNew(-471, -50, 1906))
			Crate:PivotTo(CFrameNew(-471, -50, 1906))
			Wait()
		until RopePull.AttachedTo.Value == nil or not Crate:FindFirstChild("MeshPart") or not RopePull:FindFirstChild("ReqLink") or not Crate or not Crate:FindFirstChild("MeshPart") or tick() - TickTimeout2 > 5

		if not RopePull:FindFirstChild("ReqLink") then
			return
		end
		
		if not Crate:FindFirstChild("MeshPart") and tick() - TickTimeout2 > 5 then
			return
		end
	end

	if RopeConstraint and RopePull then
		RopeConstraint.Length = 30
		RopeConstraint.WinchEnabled = false
		RopePull.CanCollide = true
		RopePull.Massless = false
	end

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Robbed cargoship!")
	end

	UpdateStatus("Robbed cargoship!")
	Wait(0.1)
end

local function RobAirdrop(drop)
	if not Character or not Root or not Humanoid or IsArrested() or Humanoid.Health == 0 then
		return error()
	end

	if not Settings.RobAirdrop then return end

	if not drop or not drop.PrimaryPart then
		return 
	end

	if not InHeli() then
		if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
			Spawn(LogWebhook, "Getting a helicopter...")
		end

		UpdateStatus("Getting a helicopter...")
	end

	if not drop or not drop.PrimaryPart then
		return 
	end

	if not drop:GetAttribute("BriefcaseLanded") then
		if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
			Spawn(LogWebhook, "Waiting for the airdrop...")
		end

		UpdateStatus("Waiting for the airdrop...")

		repeat
			Wait()
		until drop:GetAttribute("BriefcaseLanded") == true or not drop or not drop.PrimaryPart
	end

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Teleporting to the airdrop...")
	end

	UpdateStatus("Teleporting to the airdrop...")

	InstantTeleport(drop.PrimaryPart.CFrame * CFrameNew(0, 6, 0))

	UpdateStatus("Collecting the airdrop...")

	if not drop or not drop.PrimaryPart then
		return 
	end

	if (Root.Position - drop.PrimaryPart.Position).Magnitude > 50 then
		return 
	end

	Spawn(function()
		pcall(function()
			while drop and drop:FindFirstChild("NPCs") == nil do
				Wait(0.1)
			end
			
			drop:FindFirstChild("NPCs"):Destroy() 
		end)
	end)

	if Player.Team.Name ~= "Criminal" then
		repeat
			Wait(0.1)
		until Player.Team.Name == "Criminal"
	end

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Collecting the airdrop...")
	end

	repeat
		drop.BriefcasePress:FireServer(false)
		Wait(0.1)
		drop.BriefcasePress:FireServer(true)
		drop.BriefcaseCollect:FireServer()
	until drop:GetAttribute("BriefcaseCollected") == true or not drop.PrimaryPart or (Root.Position - drop.PrimaryPart.Position).Magnitude > 15 

	if (Root.Position - drop.PrimaryPart.Position).Magnitude > 15 then
		return
	end

	if Settings.PickUpCash then
		if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
			Spawn(LogWebhook, "Collecting airdrop cash...")
		end

		UpdateStatus("Collecting airdrop cash...")

		for _ = 1, 3 do
			pcall(function()
				for _, v in Modules.UI.CircleAction.Specs do
					if v.Name:sub(1, 9) == "Collect $" then
						v:Callback(true)
					end
				end
			end)
			Wait(0.25)
		end
	else
		Wait(0.45)
	end

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Waiting for the reward...")
	end

	UpdateStatus("Waiting for the reward...")
	WaitForReward()

	if drop then drop:Destroy() end

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Robbed airdrop!")
	end

	UpdateStatus("Robbed airdrop!")
	Wait(0.1)
end

local function RobMansion()
	if not Character or not Root or not Humanoid or IsArrested() or Humanoid.Health == 0 then
		return error()
	end

	if not Settings.RobMansion then return end

	if not Robberies.Mansion.Open then
		return
	end

	if Vehicle then
		ExitVehicle()
	end

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Going inside elevator...")
	end

	UpdateStatus("Going inside elevator...")

	local MansionRobbery = Workspace.MansionRobbery
	local TouchToEnter = MansionRobbery.Lobby.EntranceElevator.TouchToEnter
	local TriggerCutcene = MansionRobbery.TriggerFoundBossRoom
	local ElevatorDoor = MansionRobbery.ArrivalElevator.Floors:GetChildren()[1].DoorLeft.InnerModel.Door
	local MansionTeleportCFrame = TouchToEnter.CFrame - Vector3New(0, TouchToEnter.Size.Y / 2 - Humanoid.HipHeight * 2, -TouchToEnter.Size.Z)
	local MansionActivateDoor = CFrameNew(3154, -205, -4558)
	local FailedMansion = false
	local FailedStart = false

	Delay(12.5, function()
		FailedMansion = true
	end)
	
	repeat
		Root.CFrame = MansionTeleportCFrame
		FireTouchInterest(TouchToEnter)
	until Modules.MansionRobberyUtils.isPlayerInElevator(MansionRobbery, Player) or FailedMansion or not Robberies.Mansion.Open

	if FailedMansion or not Robberies.Mansion.Open then
		Humanoid.Health = 0
		return
	end

	Wait(0.25)
	Root.CFrame = CFrameNew(3198, 63, -4659)

	GetPistol(true)

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Waiting for elevator to drop...")
	end

	UpdateStatus("Waiting for elevator to drop...")

	repeat
		Wait(0.1)
	until ElevatorDoor.Position.X > 3208

	for _, v in MansionRobbery.Lasers:GetChildren() do
		v:Destroy()
	end

	for _, v in MansionRobbery.LaserTraps:GetChildren()	 do
		v:Destroy()
	end

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Triggering cutscene...")
	end

	UpdateStatus("Triggering cutscene...")

	Delay(12.5, function()
		FailedStart = true
	end)

	repeat
		Root.CFrame = MansionActivateDoor
		FireTouchInterest(TriggerCutcene)
	until MansionRobbery:GetAttribute("MansionRobberyProgressionState") == 3 or Humanoid.Health <= 0 or not Character or FailedStart

	if FailedStart then
		Humanoid.Health = 0
		return
	end
	
	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Waiting for cutscene...")
	end

	UpdateStatus("Waiting for cutscene...")
	Modules.MansionRobberyUtils.getProgressionStateChangedSignal(MansionRobbery):Wait()

	local OldRootAxisY = Root.CFrame.Y

	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.P = math.huge
	BodyVelocity.MaxForce = Vector3New(9e9, 9e9, 9e9)
	BodyVelocity.Parent = Root
	BodyVelocity.Velocity = Vector3New()

	Root.CFrame = CFrameNew(Root.CFrame.X, Root.CFrame.Y + 9, Root.CFrame.Z)

	for _, v in ReplicatedStorage.Game.Item:GetChildren() do
		require(v).ReloadDropAmmoVisual = function() end
		require(v).ReloadDropAmmoSound = function() end
		require(v).ReloadRefillAmmoSound = function() end
		require(v).ShootSound = function() end
	end

	getfenv(Modules.BulletEmitter.Emit).Instance = {
		new = function()
			return {
				Destroy = function() end
			}
		end
	}

	local ActiveBoss = MansionRobbery:WaitForChild("ActiveBoss")

	LPH_NO_VIRTUALIZE(function()
		hookfunction(Modules.NPC.GetTarget, function(...)
			return MansionRobbery and MansionRobbery:FindFirstChild("ActiveBoss") and MansionRobbery:FindFirstChild("ActiveBoss").Head or ...
		end)

		Modules.RayCast.RayIgnoreNonCollideWithIgnoreList = function(...)
			local arg = {RayIgnore(...)}
	
			if (Tostring(getfenv(2).script) == "BulletEmitter" or Tostring(getfenv(2).script) == "Taser") then
				arg[1] = ActiveBoss.Head
				arg[2] = ActiveBoss.Head.Position
				arg[3] = ActiveBoss.Head.Position
			end
	
			return unpack(arg)
		end
	end)()
	
	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Killing boss...")
	end

	UpdateStatus("Killing boss...")

	while ActiveBoss and ActiveBoss:FindFirstChild("HumanoidRootPart") and ActiveBoss.Humanoid.Health ~= 1 and Humanoid.Health >= 0 and Humanoid do
		EquipGun(true)
		pcall(ShootGun)
		Wait(0.1)
	end

	Modules.RayCast.RayIgnoreNonCollideWithIgnoreList = RayIgnore
	BodyVelocity:Destroy()
	Root.CFrame = CFrameNew(Root.CFrame.X, OldRootAxisY, Root.CFrame.Z)
	MansionRobbery.GuardsFolder:Destroy()
	EquipGun(false)

	repeat Wait() until PlayerGui.AppUI:FindFirstChild("RewardSpinner")

	UpdateStatus("Waiting for the reward...")
	WaitForReward()

	if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
		Spawn(LogWebhook, "Robbed mansion!")
	end

	UpdateStatus("Robbed mansion!")
	Wait(0.1)
end

--> [[ Load Main ]] <--

local MoneyEarned, ElapsedTime = 0, 0

Spawn(LPH_JIT_MAX(function()
	while true do
		pcall(function()
			MoneyEarned = Leaderstats.Money.Value - getgenv().StartingMoney
		end)

		pcall(function()
			ElapsedTime = tick() - getgenv().StartingTime
		end)

		UpdateStats(MoneyEarned, ElapsedTime)

		Wait(0.01)
	end
end))

Spawn(function()
	Workspace.Terrain.WaterWaveSize = 0
	Workspace.Terrain.WaterWaveSpeed = 0
	Workspace.Terrain.WaterReflectance = 0
	Workspace.Terrain.WaterTransparency = 0
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.Brightness = 0
	settings().Rendering.QualityLevel = "Level01"

	for _, object in game:GetDescendants() do
		if object:IsA("Part") or object:IsA("Union") or object:IsA("CornerWedgePart") or object:IsA("TrussPart") then
			object.Material = "Plastic"
			object.Reflectance = 0
		elseif object:IsA("Decal") or object:IsA("Texture") then
			object.Transparency = 1
		elseif object:IsA("ParticleEmitter") or object:IsA("Trail") then
			object.Lifetime = NumberRange.new(0)
		elseif object:IsA("Explosion") then
			object.BlastPressure = 1
			object.BlastRadius = 1
		elseif object:IsA("Fire") or object:IsA("SpotLight") or object:IsA("Smoke") then
			object.Enabled = false
		elseif object:IsA("MeshPart") then
			object.Material = "Plastic"
			object.Reflectance = 0
			object.TextureID = 10385902758728957
		end
	end

	for _, effect in Lighting:GetChildren() do
		if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
			effect.Enabled = false
		end
	end
end)

repeat Wait(0.1) until Character and Humanoid and Root
repeat pcall(function() Modules.TeamChooseUI.Hide() end) Wait() until PlayerGui:FindFirstChild("TeamSelectGui") == nil or PlayerGui:FindFirstChild("TeamSelectGui").Enabled == false or Player.TeamColor == BrickColor.new("Bright red") or Humanoid.Health == 0

while Humanoid == nil do
	Wait(0.1)
end

Loaded = true

Spawn(LPH_JIT_MAX(function()
	while true do
		pcall(function()
			if (IsArrested() or (not CanDeathFree and Humanoid and Humanoid.Health == 0)) and Settings.Enabled then
				if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
					Spawn(LogWebhook, "Server hopping...")
				end
	
				UpdateStatus("Server hopping...")
	
				return ServerHop()
			end
		end)

		Wait(0.01)
	end
end))

Spawn(LPH_JIT_MAX(function()
	while Wait(0.1) do
		RunService:Set3dRenderingEnabled((not Settings.FpsBooster))
	end
end))

Spawn(function()
	if Settings.AutoOpenSafes then
		local SafeAmount = #Modules.Store._state.safesInventoryItems

		if SafeAmount ~= 0 then
			CanServerHop = false

			UpdateStats("Opening safes...")

			for _ = 1, SafeAmount do
				local CurrentSafe = Modules.Store._state.safesInventoryItems[1]

				ReplicatedStorage[Modules.SafesConsts.SAFE_OPEN_REMOTE_NAME]:FireServer(CurrentSafe.itemOwnedId)
				Wait(3)

				if not Settings.AutoOpenSafes then break end
			end

			CanServerHop = true
		end
	end
end)

if Settings.RobAirdrop then
	ScanMap()
end

Spawn(function()
	while Wait(300) do
		if Settings.Enabled then
			if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
				Spawn(LogWebhook, "Server hopping...")
			end

			UpdateStatus("Server hopping...")

			return ServerHop()
		end
	end
end)

Spawn(function()
	while not pcall(function()
		CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
			if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame") then
				if Settings.Enabled then
					if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
						Spawn(LogWebhook, "Server hopping...")
					end

					UpdateStatus("Server hopping...")

					return ServerHop()
				end
			end
		end)
	end) do
		Wait(0.01)
	end
end)

while Wait() do
	if Settings.RobCargoShip and Robberies.Ship.Open and not Robberies.Ship.HasRobbed and Settings.Enabled then
		pcall(RobShip)
	elseif Settings.RobAirdrop and Robberies.Airdrop.Open and (not Settings.SkipBasicCrates or (Settings.SkipBasicCrates and Workspace:FindFirstChild("Drop").Top.BrickColor ~= BrickColor.new("Dark orange"))) and Settings.Enabled then
		pcall(RobAirdrop, Workspace:FindFirstChild("Drop"))
		WaitForReward()
	elseif Settings.RobMansion and Robberies.Mansion.Open and Settings.Enabled then
		pcall(RobMansion)
	elseif Settings.Enabled then
		if Settings.LogWebhook and Settings.WebhookUrl ~= "" then
			Spawn(LogWebhook, "Server hopping...")
		end

		UpdateStatus("Server hopping...")

		return ServerHop()
	end
end