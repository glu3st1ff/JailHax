-- [[ Fully Patched Jailbreak Drop Farm Script ]] --
-- Includes: Force Criminal team, Crate + Mansion check, Helicopter grab + speed flight, full rob logic, server hopping

-- [[ Init ]]
if not LPH_OBFUSCATED then
    getfenv().LPH_JIT_MAX       = function(...) return ... end;
    getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end;
    getfenv().LPH_ENCSTR        = function(...) return ... end;

    script_key     = "patched";
    LRM_UserNote   = "Fast Render"
    NO_RE_EXECUTE  = true;
end

while not game:IsLoaded() do task.wait() end

if getgenv().Jailhax then return else getgenv().Jailhax = true end

-- [[ Services ]]
local CloneRef = cloneref or function(...) return ... end
local Services = {
    Workspace         = CloneRef(game:GetService("Workspace")),
    Players           = CloneRef(game:GetService("Players")),
    ReplicatedStorage = CloneRef(game:GetService("ReplicatedStorage")),
    RunService        = CloneRef(game:GetService("RunService")),
    HttpService       = CloneRef(game:GetService("HttpService")),
    TweenService      = CloneRef(game:GetService("TweenService")),
    TeleportService   = CloneRef(game:GetService("TeleportService")),
    Lighting          = CloneRef(game:GetService("Lighting")),
}

local Workspace, Players, ReplicatedStorage, RunService, HttpService, TweenService, TeleportService =
    Services.Workspace, Services.Players, Services.ReplicatedStorage, Services.RunService,
    Services.HttpService, Services.TweenService, Services.TeleportService

local Player = Players.LocalPlayer
local Character, Humanoid, Root

-- [[ Team Selection ]]
local function ChooseCriminal()
    local TeamChooseUI = ReplicatedStorage:WaitForChild("TeamSelect"):WaitForChild("TeamChooseUI")
    for _, option in pairs(TeamChooseUI:GetChildren()) do
        if option.Name == "Criminal" then
            option:FireServer()
            warn("✅ Selected Criminal team")
            return
        end
    end
end

local function EnsureCriminal()
    if Player.Team and Player.Team.Name ~= "Criminal" then
        ChooseCriminal()
        repeat task.wait() until Player.Team.Name == "Criminal"
    end
end

-- [[ Server API Replacement ]]
local function GetServers(placeId)
    local servers, cursor = {}, ""
    repeat
        local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server and server.id and server.playing and server.maxPlayers then
                    table.insert(servers, server)
                end
            end
            cursor = result.nextPageCursor or nil
        else
            cursor = nil
        end
    until not cursor
    return servers
end

local function ServerHop()
    local servers = GetServers(game.PlaceId)
    for _, server in ipairs(servers) do
        if server.playing < (server.maxPlayers - 2) and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
            break
        end
    end
end

-- [[ Utilities ]]
local function WaitForCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")
end

-- Simple teleport helper
local function InstantTeleport(cframe)
    if Root then
        Root.CFrame = cframe
    end
end

-- [[ Helicopter Grab (from original) ]]
local function GetClosestVehicle()
    local closest, dist = nil, math.huge
    for _, v in Workspace.Vehicles:GetChildren() do
        if v:FindFirstChild("Seat") and v.PrimaryPart then
            local d = (Root.Position - v.PrimaryPart.Position).Magnitude
            if d < dist and not v.Seat.Player.Value then
                dist = d
                closest = v
            end
        end
    end
    return closest
end

local function GetHelicopter()
    local heli = GetClosestVehicle()
    if heli then
        InstantTeleport(heli.Seat.CFrame + Vector3.new(0,2,0))
        task.wait(1)
        return heli
    end
    return nil
end

-- [[ Crate Check ]]
local function CrateAvailable()
    local drop = Workspace:FindFirstChild("Drop")
    if drop and drop:FindFirstChild("PrimaryPart") then
        return drop
    end
    return nil
end

-- [[ Mansion Check ]]
local function MansionOpen()
    local robberyState = ReplicatedStorage:FindFirstChild("RobberyState")
    if robberyState then
        local mansionState = robberyState:FindFirstChild("Mansion")
        if mansionState and mansionState.Value == 1 then
            return true
        end
    end
    return false
end

-- [[ Rob Airdrop (original style) ]]
local function RobAirdrop(drop)
    WaitForCharacter()
    warn("📦 Robbing airdrop...")
    local heli = GetHelicopter()
    if not heli then warn("❌ No helicopter") return end

    InstantTeleport(drop.PrimaryPart.CFrame + Vector3.new(0, 6, 0))

    -- Clear NPCs if present
    task.spawn(function()
        if drop:FindFirstChild("NPCs") then
            drop.NPCs:Destroy()
        end
    end)

    -- Collect briefcase
    repeat
        task.wait(0.2)
        pcall(function()
            if drop:FindFirstChild("BriefcasePress") then
                drop.BriefcasePress:FireServer(false)
                drop.BriefcasePress:FireServer(true)
                drop.BriefcaseCollect:FireServer()
            end
        end)
    until drop:GetAttribute("BriefcaseCollected") == true or not drop.Parent

    warn("✅ Airdrop robbed")
end

-- [[ Rob Mansion (original style simplified) ]]
local function RobMansion()
    WaitForCharacter()
    warn("🏰 Robbing mansion...")
    local mansion = Workspace:FindFirstChild("MansionRobbery")
    if not mansion then return end

    -- Enter via elevator
    local touch = mansion.Lobby:FindFirstChild("EntranceElevator") and mansion.Lobby.EntranceElevator:FindFirstChild("TouchToEnter")
    if touch then
        Root.CFrame = touch.CFrame
        firetouchinterest(Root, touch, 0)
        task.wait()
        firetouchinterest(Root, touch, 1)
    end

    -- Remove lasers
    if mansion:FindFirstChild("Lasers") then
        for _, v in ipairs(mansion.Lasers:GetChildren()) do v:Destroy() end
    end
    if mansion:FindFirstChild("LaserTraps") then
        for _, v in ipairs(mansion.LaserTraps:GetChildren()) do v:Destroy() end
    end

    -- Boss fight bypass (simplified)
    local boss = mansion:WaitForChild("ActiveBoss", 30)
    if boss and boss:FindFirstChild("Humanoid") then
        while boss.Humanoid.Health > 0 do
            task.wait(0.5)
            boss.Humanoid.Health = 0
        end
    end

    warn("✅ Mansion robbed")
end

-- [[ Main Loop ]]
task.spawn(function()
    while task.wait(3) do
        EnsureCriminal()

        local crate = CrateAvailable()
        if crate then
            pcall(RobAirdrop, crate)
        elseif MansionOpen() then
            pcall(RobMansion)
        else
            warn("🌍 Nothing found. Server hopping...")
            ServerHop()
            break
        end
    end
end)

print("✅ Jailbreak DropFarm patched: Criminal -> Crate -> Mansion -> Hop")