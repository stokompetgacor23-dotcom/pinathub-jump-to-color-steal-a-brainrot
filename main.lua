repeat task.wait() until game:IsLoaded()

-- =======================================================
-- PINATHUB - Jump Color Block Steal Brainrots (WINDUI v2)
-- =======================================================

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ============================================
-- REMOTES
-- ============================================
local RS = ReplicatedStorage
local Remotes = RS:WaitForChild("Remotes")

-- ============================================
-- PLAYER VARIABLES
-- ============================================
local player = LocalPlayer
local UIS = UserInputService

-- Settings
local flags = {
    autoGodly = false,
    autoCollect = false,
    autoUpgrade = false,
    autoBuyJump = false,
    infiniteJump = false
}
local jumpAmount = 10 
local uiVisible = true
local walkSpeedValue = 16

-- Reset Character variables
local resetCooldown = false

-- ============================================
-- LOGO LAUNCHER
-- ============================================
local logoGui = Instance.new("ScreenGui")
logoGui.Name = "PinatHubLogo"
logoGui.ResetOnSpawn = false
logoGui.Parent = player:WaitForChild("PlayerGui", 5)

local logoButton = Instance.new("ImageButton")
logoButton.Name = "LogoButton"
logoButton.Size = UDim2.new(0, 50, 0, 50)
logoButton.Position = UDim2.new(0.5, -25, 0.5, -25)
logoButton.BackgroundTransparency = 1
logoButton.Image = "rbxassetid://118264723961739"
logoButton.ImageColor3 = Color3.fromRGB(180, 0, 255)
logoButton.ScaleType = Enum.ScaleType.Fit
logoButton.Parent = logoGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = logoButton

-- Animasi kecil
local hoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})
local unhoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50)})

logoButton.MouseEnter:Connect(function()
    hoverTween:Play()
end)

logoButton.MouseLeave:Connect(function()
    unhoverTween:Play()
end)

-- Fitur drag
local dragging = false
local dragInput, dragStart, startPos

logoButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = logoButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

logoButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        logoButton.Position = newPos
    end
end)

-- ============================================
-- WIND UI v2 SETUP
-- ============================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "PinatHub",
    Author = "@viunze on tiktok",
    Folder = "pinathub",
    Size = UDim2.fromOffset(500, 350),
    Transparent = true,
    Theme = "Dark",
    IsOpenButtonEnabled = false,
    UserEnabled = true,
    HasOutline = true,
    SideBarWidth = 150,
})

Window:Tag({ Title = "@viunze on tiktok", Icon = "star", Color = Color3.fromHex("#BA00FF"), Border = true })

-- Fungsi untuk buka/tutup via logo
local guiVisible = true
logoButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    if Window then
        pcall(function()
            if guiVisible then
                Window:Open()
            else
                Window:Minimize()
            end
        end)
    end
end)

-- Create Tabs
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local AutoTab = Window:Tab({ Title = "Auto", Icon = "zap" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })
local CommunityTab = Window:Tab({ Title = "Community", Icon = "users" })

-- ============================================
-- RESET CHARACTER FUNCTION
-- ============================================
local function resetCharacter()
    if resetCooldown then
        return
    end
    resetCooldown = true
    player.Character:BreakJoints()
    task.wait(6) 
    resetCooldown = false
end

-- ============================================
-- WALKSPEED FUNCTION
-- ============================================
local function setWalkSpeed(value)
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

-- WalkSpeed loop
local walkSpeedConn = nil
local walkSpeedActive = false

local function startWalkSpeed()
    if walkSpeedActive then return end
    walkSpeedActive = true
    walkSpeedConn = RunService.RenderStepped:Connect(function()
        setWalkSpeed(walkSpeedValue)
    end)
end

local function stopWalkSpeed()
    walkSpeedActive = false
    if walkSpeedConn then
        walkSpeedConn:Disconnect()
        walkSpeedConn = nil
    end
    setWalkSpeed(16)
end

-- ============================================
-- INFINITE JUMP (LOGIA ASLI)
-- ============================================
local InfiniteJumpEnabled = false

UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState("Jumping")
            end
        end
    end
end)

-- ============================================
-- UI: PLAYER TAB
-- ============================================
local movementSection = PlayerTab:Section({ Title = "Movement" })

movementSection:Toggle({
    Title = "WalkSpeed",
    Value = false,
    Callback = function(value)
        if value then
            startWalkSpeed()
        else
            stopWalkSpeed()
        end
    end
})

movementSection:Slider({
    Title = "WalkSpeed Value",
    Desc = "Custom walk speed (16-120)",
    Value = { Min = 16, Default = 50, Max = 120 },
    Rounding = 0,
    Callback = function(value)
        walkSpeedValue = value
        if walkSpeedActive then
            setWalkSpeed(value)
        end
    end
})

movementSection:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(value)
        InfiniteJumpEnabled = value
    end
})

-- ============================================
-- RESET CHARACTER SECTION (DI TAB PLAYER)
-- ============================================
local resetSection = PlayerTab:Section({ Title = "Character" })

resetSection:Button({
    Title = "Reset Character",
    Callback = function()
        resetCharacter()
    end
})

-- ============================================
-- UI: AUTO TAB (LOGIA ASLI TIDAK DIUBAH)
-- ============================================

-- Auto Godly Section
local godlySection = AutoTab:Section({ Title = "Auto Godly" })

godlySection:Toggle({
    Title = "Auto Godly",
    Value = false,
    Callback = function(value)
        flags.autoGodly = value
    end
})

-- Auto Collect Section
local collectSection = AutoTab:Section({ Title = "Auto Collect & Upgrade" })

collectSection:Toggle({
    Title = "Auto Collect",
    Value = false,
    Callback = function(value)
        flags.autoCollect = value
    end
})

collectSection:Toggle({
    Title = "Auto Upgrade",
    Value = false,
    Callback = function(value)
        flags.autoUpgrade = value
    end
})

-- Auto Buy Jump Section
local buyJumpSection = AutoTab:Section({ Title = "Auto Buy Jump" })

buyJumpSection:Toggle({
    Title = "Auto Buy Jump",
    Value = false,
    Callback = function(value)
        flags.autoBuyJump = value
    end
})

buyJumpSection:Dropdown({
    Title = "Jump Amount",
    Values = { "1", "5", "10" },
    Value = "10",
    Callback = function(value)
        jumpAmount = tonumber(value)
    end
})

-- Remove VIP Wall Section
local vipSection = AutoTab:Section({ Title = "VIP Wall" })

vipSection:Button({
    Title = "Remove VIP Wall",
    Callback = function()
        local wall = workspace:FindFirstChild("W_01") 
            and workspace.W_01:FindFirstChild("LobbyBase") 
            and workspace.W_01.LobbyBase:FindFirstChild("Collision")
        
        if wall then
            wall:Destroy()
            Window:Notify("VIP Wall", "Wall removed successfully!", 2)
        else
            Window:Notify("VIP Wall", "Wall not found!", 2)
        end
    end
})

-- ============================================
-- UI: MISC TAB
-- ============================================

-- Anti AFK Section
local afkSection = MiscTab:Section({ Title = "Utilities" })

local antiAFKActive = false
local antiAFKConn = nil

afkSection:Toggle({
    Title = "Anti-AFK",
    Value = false,
    Callback = function(value)
        antiAFKActive = value
        if value then
            antiAFKConn = player.Idled:Connect(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        else
            if antiAFKConn then
                antiAFKConn:Disconnect()
                antiAFKConn = nil
            end
        end
    end
})

-- Server Tools Section
local serverSection = MiscTab:Section({ Title = "Server Tools" })

local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    local req = syn and syn.request or http_request or request or httprequest

    if req then
        local cursor = ""
        for _ = 1, 3 do
            local url = "https://games.roblox.com/v1/games/" .. placeId
                .. "/servers/Public?sortOrder=Asc&limit=100"
                .. (cursor ~= "" and ("&cursor=" .. cursor) or "")

            local ok, response = pcall(req, { Url = url, Method = "GET" })
            if not ok or not response or not response.Body then break end

            local ok2, data = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)
            if not ok2 or not data or not data.data then break end

            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end

            local nextCursor = data.nextPageCursor
            if not nextCursor or nextCursor == "" or nextCursor == "null" then break end
            cursor = tostring(nextCursor)
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], player)
    else
        TeleportService:Teleport(placeId, player)
    end
end

local function rejoinServer()
    local placeId = game.PlaceId
    local jobId = game.JobId

    if not jobId or jobId == "" then
        pcall(function() TeleportService:Teleport(placeId, player) end)
        return
    end

    local ok1, err1 = pcall(function()
        local opts = Instance.new("TeleportOptions")
        opts.ServerInstanceId = jobId
        TeleportService:TeleportAsync(placeId, { player }, opts)
    end)
    if ok1 then return end

    local ok2, err2 = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end)
    if ok2 then return end

    pcall(function() TeleportService:Teleport(placeId, player) end)
end

serverSection:Button({
    Title = "Server Hop",
    Callback = function()
        serverHop()
        Window:Notify("Server Hop", "Joining new server...", 3)
    end
})

serverSection:Button({
    Title = "Rejoin Server",
    Callback = function()
        rejoinServer()
        Window:Notify("Rejoin", "Rejoining server...", 2)
    end
})

-- ============================================
-- UI: COMMUNITY TAB (DIKEEP)
-- ============================================

local whatsappSection = CommunityTab:Section({ Title = "WhatsApp Group" })

whatsappSection:Button({
    Title = "Join WhatsApp Group",
    Callback = function()
        if setclipboard then
            setclipboard("https://chat.whatsapp.com/I8hG44FLgrRAwQcS3lvEft")
            Window:Notify("Success", "WhatsApp link copied to clipboard!", 3)
        else
            Window:Notify("Error", "Clipboard not supported!", 2)
        end
    end
})

local discordSection = CommunityTab:Section({ Title = "Discord Server" })

discordSection:Button({
    Title = "Join Discord Server",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/eDbaHKEf7G")
            Window:Notify("Success", "Discord link copied to clipboard!", 3)
        else
            Window:Notify("Error", "Clipboard not supported!", 2)
        end
    end
})

-- ============================================
-- LOGIC LOOPS (LOGIA ASLI TIDAK DIUBAH)
-- ============================================

task.spawn(function()
    while true do
        task.wait(0.1)
        if flags.autoGodly then
            pcall(function()
                local level9Base = workspace.W_01.LobbyBase.Level.Level9.Base
                for _, base in pairs(level9Base:GetChildren()) do
                    if not flags.autoGodly then break end
                    local prompt = base:FindFirstChild("Prompt") and base.Prompt:FindFirstChild("UserPrompt")
                    if prompt then
                        for _, obj in pairs(base:GetChildren()) do
                            if not flags.autoGodly then break end
                            if obj.Name:match("^Pet/") then
                                local part = obj:FindFirstChild("Base") or obj:FindFirstChildWhichIsA("BasePart", true)
                                if part then
                                    local hrp = player.Character.HumanoidRootPart
                                    local oldPos = hrp.CFrame
                                    hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.2)
                                    fireproximityprompt(prompt)
                                    task.wait(0.2)
                                    hrp.CFrame = oldPos
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if flags.autoCollect then
            for i = 0, 100 do
                if not flags.autoCollect then break end
                Remotes.ClaimOutputRE:FireServer(i, "Pet")
            end
        end
        if flags.autoUpgrade then
            for i = 0, 100 do
                if not flags.autoUpgrade then break end
                Remotes.UpgradePetRE:FireServer(i)
            end
        end
        if flags.autoBuyJump then
            Remotes.UpgradeAttributeRE:FireServer("Power", jumpAmount)
        end
    end
end)

-- ============================================
-- CHARACTER RESPAWN HANDLER
-- ============================================
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.5)
    if walkSpeedActive then
        setWalkSpeed(walkSpeedValue)
    end
end)

-- ============================================
-- INITIAL NOTIFICATION
-- ============================================
task.wait(1)
Window:Open()

print("PinatHub Loaded")
Window:Notify("PinatHub", "Loaded", 3)
