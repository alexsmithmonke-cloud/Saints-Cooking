include("shared.lua")
surface.CreateFont( "NormalText", {
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

net.Receive("PanContents",function(PanContent)
    local pan = net.ReadEntity()
    local InPan = net.ReadTable()
    if IsValid(pan) then
        pan.PanContents = InPan or {}
    end
end)

function ENT:Draw()

    self:DrawModel()
    local pos = self:GetPos() + (self:GetUp() * 20) + self:GetForward() * 4
    local ang = self:GetAngles()
    local ply = LocalPlayer()
    local plyeyeangle = ply:EyeAngles()
    ang.y = plyeyeangle.y
    ang.x = plyeyeangle.x
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    local contents = self.PanContents or {}
    
    cam.Start3D2D(pos,ang, 0.1)
        for v,PropData in ipairs(contents) do
            local name = PropData.displayname
            local textY = v * 40
            draw.WordBox(6,0,textY,name,"NormalText",Color(92,88,88,178),Color(190,187,187),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end