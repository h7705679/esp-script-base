local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Nemesis',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Settings = Window:AddTab('UI Settings'), 
}
local modulecomm = {
    boxesp = false,
    healthbar = true,
    healthtext = false
}
local Settings = {
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Tracer_Origin = "Bottom",
    Tracers = true
}

local PlayerESP = Tabs.Visuals:AddLeftGroupbox('Player ESP')

PlayerESP:AddToggle('BOXESPEnabled', {
    Text = 'Enable Box ESP',
    Default = false,
    Callback = function(state)
        if state then
            modulecomm.boxesp = true
        else
            modulecomm.boxesp = false
        end
    end
})

PlayerESP:AddLabel('Box Color'):AddColorPicker('BoxColor', {
    Default = Settings.Box_Color,
    Title = 'Box Color',
    Callback = function(val)
        Settings.Box_Color = val
    end
})

PlayerESP:AddLabel('Tracer Color'):AddColorPicker('TracerColor', {
    Default = Settings.Tracer_Color,
    Title = 'Tracer Color',
    Callback = function(val)
        Settings.Tracer_Color = val
    end
})

PlayerESP:AddToggle('TracerEnabled', {
    Text = 'Enable Tracers',
    Default = Settings.Tracers,
    Callback = function(state)
        Settings.Tracers = state
    end
})

PlayerESP:AddSlider('TracerThickness', {
    Text = 'Tracer Thickness',
    Default = Settings.Tracer_Thickness,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Callback = function(value)
        Settings.Tracer_Thickness = value
    end
})

PlayerESP:AddSlider('BoxThickness', {
    Text = 'Box Thickness',
    Default = Settings.Box_Thickness,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Callback = function(value)
        Settings.Box_Thickness = value
    end
})

PlayerESP:AddDropdown('TracerOrigin', {
    Values = {'Middle', 'Bottom'},
    Default = Settings.Tracer_Origin,
    Multi = false,
    Text = 'Tracer Origin',
    Callback = function(value)
        Settings.Tracer_Origin = value
    end
})

PlayerESP:AddToggle('HealthBarEnabled', {
    Text = 'Enable Health Bar',
    Default = true,
    Callback = function(state)
        if state then
            modulecomm.healthbar = true
        else
            modulecomm.healthbar = false
        end
    end
})

PlayerESP:AddToggle('HealthTextEnabled', {
    Text = 'Enable Health Text (Numbers)',
    Default = false,
    Callback = function(state)
        if state then
            modulecomm.healthtext = true
        else
            modulecomm.healthtext = false
        end
    end
})


local Team_Check = {
    TeamCheck = false, 
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}
local TeamColor = false


local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
player:GetMouse()

local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0,0)
    quad.PointB = Vector2.new(0,0)
    quad.PointC = Vector2.new(0,0)
    quad.PointD = Vector2.new(0,0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color 
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function NewText(text, color)
    local txt = Drawing.new("Text")
    txt.Visible = false
    txt.Text = text
    txt.Color = color
    txt.Size = 16
    txt.Position = Vector2.new(0, 0)
    txt.Transparency = 1
    txt.Center = true
    return txt
end

local function Visibility(state, lib)
    for u, x in pairs(lib) do
        if x ~= lib.healthtext then 
            x.Visible = state
        end
    end
end








local black = Color3.fromRGB(0, 0 ,0)
local function ESP(plr)
    local library = {
        
        blacktracer = NewLine(1, black),
        tracer = NewLine(1, Settings.Tracer_Color),
        
        black = NewQuad(1, black),
        box = NewQuad(1, Settings.Box_Color),
        
        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, black),
        
        healthtext = NewText("100/100", Color3.fromRGB(0, 255, 0))
    }

    local function Colorize(color)
        for u, x in pairs(library) do
            if x ~= library.healthbar and x ~= library.greenhealth and x ~= library.blacktracer and x ~= library.black and x ~= library.healthtext then
                x.Color = color
            end
        end
    end

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not modulecomm.boxesp then
                Visibility(false, library)
                if library.healthtext then library.healthtext.Visible = false end
                return
            end
            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") ~= nil then
                local HumPos, OnScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                library.tracer.Thickness = Settings.Tracer_Thickness
                library.blacktracer.Thickness = Settings.Tracer_Thickness*2
                library.box.Thickness = Settings.Box_Thickness
                library.black.Thickness = Settings.Box_Thickness*2
                if OnScreen then
                    local head = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)
                    
                    local function Size(item)
                        item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY*2)
                        item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2)
                        item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)
                        item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY*2)
                    end
                    Size(library.box)
                    Size(library.black)

                    
                    if Settings.Tracers then
                        if Settings.Tracer_Origin == "Middle" then
                            library.tracer.From = camera.ViewportSize*0.5
                            library.blacktracer.From = camera.ViewportSize*0.5
                        elseif Settings.Tracer_Origin == "Bottom" then
                            library.tracer.From = Vector2.new(camera.ViewportSize.X*0.5, camera.ViewportSize.Y) 
                            library.blacktracer.From = Vector2.new(camera.ViewportSize.X*0.5, camera.ViewportSize.Y)
                        end
                        library.tracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                        library.blacktracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                    else 
                        library.tracer.From = Vector2.new(0, 0)
                        library.blacktracer.From = Vector2.new(0, 0)
                        library.tracer.To = Vector2.new(0, 0)
                        library.blacktracer.To = Vector2.new(0, 0)
                    end

                    
                    if modulecomm.healthbar then
                        local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)).magnitude 
                        local healthoffset = plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth * d

                        library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                        library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2 - healthoffset)
                        library.greenhealth.Visible = true

                        library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                        library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY*2)
                        library.healthbar.Visible = true
                    else
                        library.greenhealth.Visible = false
                        library.healthbar.Visible = false
                    end

                    local green = Color3.fromRGB(0, 255, 0)
                    local red = Color3.fromRGB(255, 0, 0)

                    library.greenhealth.Color = red:lerp(green, plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth);

                    
                    if modulecomm.healthtext then
                        local currentHP = math.floor(plr.Character.Humanoid.Health)
                        local maxHP = math.floor(plr.Character.Humanoid.MaxHealth)
                        library.healthtext.Text = currentHP .. "/" .. maxHP
                        library.healthtext.Position = Vector2.new(HumPos.X, HumPos.Y - DistanceY*2 - 15)
                        library.healthtext.Color = red:lerp(green, plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth)
                        library.healthtext.Visible = true
                    else
                        library.healthtext.Visible = false
                    end

                    if Team_Check.TeamCheck then
                        if plr.TeamColor == player.TeamColor then
                            Colorize(Team_Check.Green)
                        else
                            Colorize(Team_Check.Red)
                        end
                    elseif TeamColor == true then
                        Colorize(plr.TeamColor.Color)
                    else
                        library.tracer.Color = Settings.Tracer_Color
                        library.box.Color = Settings.Box_Color
                    end
                    Visibility(true, library)
                    else 
                    Visibility(false, library)
                    if library.healthtext then library.healthtext.Visible = false end
                end
            else 
                Visibility(false, library)
                if library.healthtext then library.healthtext.Visible = false end
                if game.Players:FindFirstChild(plr.Name) == nil then
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Updater)()
end

for i, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Name ~= player.Name then
        coroutine.wrap(ESP)(v)
    end
end

game.Players.PlayerAdded:Connect(function(newplr)
    if newplr.Name ~= player.Name then
        coroutine.wrap(ESP)(newplr)
    end
end)
