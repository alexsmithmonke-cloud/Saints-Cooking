include("shared.lua")

net.Receive("ToSendGradeOfFood", function()

    local GradeOfFood = net.ReadFloat()
    local FoodItem = net.ReadEntity()
    if FoodItem:IsValid() then
        FoodItem.GradeOfFood = GradeOfFood
    end

end)

function ENT:Draw()

    self:DrawModel()
    local pos = self:GetPos()
    local mins, maxs = self:OBBMins(), self:OBBMaxs()
    local center = (mins + maxs) / 2
    local heightoffset = 5
    local pos = self:WorldSpaceCenter() + Vector(0, 0, maxs.z + heightoffset)

    local ang = self:GetAngles()
    local ply = LocalPlayer()
    local plyeyeangle = ply:EyeAngles()
    ang.y = plyeyeangle.y
    ang.x = plyeyeangle.x
    ang.z = plyeyeangle.z
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    local GradeOfFood = self.GradeOfFood or 0
    local color = Color(68,45,24)
    local quality = "Its from a 0-100, stop using weird numbers"

    ------ Welcome to elseif hell CL verison
    if GradeOfFood == -1 then
        quality = "Burnt"
        color = Color(59,15,15)
    elseif GradeOfFood == -2 then
        quality = "Raw"
        color = Color(202,104,104)
    elseif GradeOfFood == 100 then
        quality = "Perfect"
        color = Color(129,234,69)
    elseif GradeOfFood < 100 and GradeOfFood >= 90 then
        quality = "Excellent"
        color = Color(68,243,132)
    elseif GradeOfFood < 90 and GradeOfFood >= 70 then
        quality = "Great"
        color = Color(28,173,3)
    elseif GradeOfFood < 70 and GradeOfFood >= 50 then
        quality = "Good"
        color = Color(167,255,45)
    elseif GradeOfFood < 50 and GradeOfFood >= 40 then
        quality = "Average"
        color = Color(229,250,69)
    elseif GradeOfFood < 40 and GradeOfFood >= 30 then
        quality = "Bad"
        color = Color(242,152,55)
    elseif GradeOfFood < 30 and GradeOfFood >= 10 then
        quality = "Awful"
        color = Color(255,38,30)
    elseif GradeOfFood < 10 and GradeOfFood >= 0 then
        quality = "Inedible"
        color = Color(255,0,0)
    end
    ------
    local TextSizeW, TextSizeH = surface.GetTextSize(quality) --So the box fits neatly
    TextSizeW = TextSizeW + 4 --Padding
    TextSizeH = TextSizeH + 2 --Padding
    cam.Start3D2D(pos,ang, 0.1)
    draw.RoundedBox(2, -TextSizeW / 2 - 1, -1, TextSizeW + 2, TextSizeH + 2, Color(0,0,0))
        draw.RoundedBox(2, -TextSizeW / 2, 0, TextSizeW, TextSizeH, color)
        draw.DrawText(quality, "NormalText", 0,0, Color(0,0,0), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
