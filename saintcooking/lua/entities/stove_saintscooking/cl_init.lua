include("shared.lua")
surface.CreateFont( "SmallText", {
            font = "Arial",
            extended = false,
            size = 25,
            weight = 500,
            blursize = 0,
            scanlines = 0,
            antialias = true,
            underline = false,
            italic = false,
            strikeout = false,
            symbol = false,
            rotary = false,
            shadow = false,
            additive = false,
            outline = false,
}   )


net.Receive("PanCaught",function(PanContent)
    local paninside = net.ReadBool()
    local pan = net.ReadEntity()
    local stove = net.ReadEntity()
    local InPan = net.ReadTable()
    if pan then
        stove.PanContents = InPan or {}
        stove.IsPanFilled = paninside
        stove.PanCaught = pan
    end
end)

net.Receive("SendRecipeInUse", function() --Starting the cookin' process
    local recipe = net.ReadTable()
    local stoveRecipeVer = net.ReadEntity()
    local cooking = net.ReadBool()
    if stoveRecipeVer then
        stoveRecipeVer.recipeData = recipe or {}
        stoveRecipeVer.Cooking = cooking
        stoveRecipeVer.CookingTimeStart = CurTime()

    end
end)

net.Receive("HaltCooking", function()
    local stove = net.ReadEntity()
    local halt = net.ReadBool()
    if stove then
        stove.halt = halt
    end
end)

function ENT:DrawPanModel(Exist) --to make the prop of the pan
    if Exist then
        if not IsValid(self.PanProp) then
            self.PanProp = ClientsideModel("models/props_c17/metalpot002a.mdl",RENDERGROUP_OPAQUE)
        end
    else
        if IsValid(self.PanProp)  then
            self.PanProp:SetNoDraw()
            self.PanProp:Remove()
            self.PanProp = nil
        end
    end
end


function ENT:Draw()
    
    self:DrawModel()
    local pos1 = self:GetPos() + (self:GetForward() * 15) + (self:GetUp() * 10) + (self:GetRight() * 11)
    local ang1 = self:GetAngles()
    ang1:RotateAroundAxis(ang1:Up(), 90)
    ang1:RotateAroundAxis(ang1:Forward(), 90)
    -- Fuel + State
    cam.Start3D2D(pos1, ang1, 0.1)
        local StoveStateToBeUsedInButton
        if self:GetStoveState() == "On" then
            StoveStateToBeUsedInButton = "Off"
        else
            StoveStateToBeUsedInButton = "On"
        end
        draw.RoundedBox(1,-65,0,130,30,Color(68,61,61))
        draw.DrawText("Fuel: " .. self:GetFuelInStove() .. "%", "NormalText", 0, 0, Color(0, 0, 0), TEXT_ALIGN_CENTER)
        draw.RoundedBox(1,-50,40,95,30,Color(68,61,61))
        draw.DrawText("Turn "..StoveStateToBeUsedInButton, "NormalText", -1, 40, Color(0, 0, 0), TEXT_ALIGN_CENTER)
        draw.RoundedBox(1,175,-15,120,30,Color(68,61,61))
        draw.DrawText("Eject Pan ", "NormalText", 240, -15, Color(0, 0, 0), TEXT_ALIGN_CENTER)
    cam.End3D2D()
    --
    local pos = self:GetPos() + (self:GetUp() * 10) + self:GetForward() * 4
    local ang = self:GetAngles()
    local ply = LocalPlayer()
    local plyeyeangle = ply:EyeAngles()
    ang.y = plyeyeangle.y
    ang.x = plyeyeangle.x
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    local contents = self.PanContents or {}
    local panInside = self.IsPanFilled or false
    local beingcooked = self.Cooking or false
    local halt = self.halt or false
    if halt then
        beingcooked = false
    end
    local recipebeingused = self.recipeData or {}
    local CookTimeStart = self.CookingTimeStart or 0
    -- Drawing Pan ontop of stove
    if panInside then
        self:DrawPanModel(true)
        if IsValid(self.PanProp) then
            local PanPos = self:LocalToWorld(Vector(5, 15, 21))
            local PanAng = self:GetAngles()
            PanAng:RotateAroundAxis(self:GetUp(), -120)
            self.PanProp:SetPos(PanPos)
            self.PanProp:SetAngles(PanAng)
            self.PanProp:DrawModel()
        end
    else
        self:DrawPanModel(false)
    end
    -- Drawing text on top of pan
    cam.Start3D2D(pos,ang1, 0.1)
        local textpos = (#contents * -40) - 200 -- This is being used to make sure there is enough space between each stated item
        if panInside then
            if not beingcooked then
                for v,PropData in ipairs(contents) do -- To state what items are in the pan
                    textpos = (-200) - (v * 40)
                    local name = PropData.name
                    local textY = v * 40
                    draw.WordBox(6,100,textpos,name,"NormalText",Color(92,88,88,178),Color(190,187,187),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end
            else
                textpos = -220
                local timepassed = 0
                if CookTimeStart then
                    timepassed = math.floor(CurTime() - CookTimeStart)
                end
                local displaytime = math.min(recipebeingused.cooktime, timepassed)
                draw.WordBox(6,100,textpos,"Cooking.. "..displaytime,"NormalText",Color(92,88,88,178),Color(190,187,187),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) --Using this to state how much time has passed
                if timepassed >= 3 then
                    draw.WordBox(6,100,textpos + 40,recipebeingused.name,"NormalText",Color(92,88,88,178),Color(190,187,187),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) --Using this to state what is being cooked
                end
            end
            draw.WordBox(4,100, textpos - 40,"Pan","NormalText",Color(92,88,88,178),Color(190,187,187),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) -- Writing "Pan" above the Pan
        end

    cam.End3D2D()
end


hook.Add("KeyPress", "Stove", function(ply, key)
    if ply ~= LocalPlayer() or key ~= IN_USE then return end
    
    local trace = ply:GetEyeTrace()
    local target = trace.Entity
    
    if IsValid(target) and target:GetClass() == "stove_saintscooking" and ply:GetPos():DistToSqr(target:GetPos()) < 10000 then 
        local sight = target:WorldToLocal(trace.HitPos)

        local Locater = (target:GetForward() * 15) + (target:GetUp() * 10) + (target:GetRight() * 11)
        local PropLoc = target:GetPos() + Locater

        local sight = trace.HitPos - PropLoc

        local sightX = sight:Dot(target:GetRight()) * -10
        local sightY = sight:Dot(target:GetUp()) * -10
        if sightX >= -50 and sightX <= 45 and sightY >= 40 and sightY <= 70 then
            net.Start("StoveOn/Off")
                net.WriteEntity(target)
            net.SendToServer()
        end
        if sightX >= 175 and sightX <= 295 and sightY >= -15 and sightY <= 15 then
            net.Start("EjectPan")
                net.WriteEntity(target)
            net.SendToServer()
        end
    end
end)