include("shared.lua")

net.Receive("StartCutting", function()
    local board = net.ReadEntity()
    local beingcut = net.ReadEntity()
    local cutting = net.ReadBool()
    local cuttingdata = net.ReadTable()
    if IsValid(board) then
        board.beingcut = beingcut
        board.cutting = cutting
        board.cuttingdata = cuttingdata
        board.StartedCutting = CurTime()
    end
end)

function ENT:DrawFoodModel(Exist) --tomake the prop of the food
    if Exist then
        local cuttingdata = self.cuttingdata
        local cutting = self.cutting
        if not IsValid(self.FoodProp) and cutting then
            self.FoodProp = ClientsideModel(cuttingdata.model,RENDERGROUP_OPAQUE)
        end
    else
        if IsValid(self.FoodProp) then
            self.FoodProp:SetNoDraw()
            self.FoodProp:Remove()
            self.FoodProp = nil
        end
    end
end

function ENT:Draw()
    self:DrawModel()
    local pos = self:GetPos() + self:GetUp() * 20 + self:GetRight() * 5
    local ang = self:GetAngles()
    ang:RotateAroundAxis(self:GetForward(), 90)
    ang:RotateAroundAxis(self:GetUp(), 90)
    local cutting = self.cutting or false
    local beingcut = self.beingcut
    self:DrawFoodModel(beingcut)
    local cuttingdata = self.cuttingdata or {}
    local foodpos = self:GetPos() + self:GetUp() * 3 + self:GetRight() * 5
    local foodang = self:GetAngles()
    local startedcutting = self.StartedCutting or 0
    foodang:RotateAroundAxis(self:GetUp(),90)
    if cutting then
        self.FoodProp:SetPos(foodpos)
        self.FoodProp:SetAngles(foodang)
        self.FoodProp:DrawModel()
        cam.Start3D2D(pos,ang, 0.1)
            draw.WordBox(10,0,0,cuttingdata.name, "NormalText", Color(90,81,81,164), Color(0,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.WordBox(10,0,50, "Cutting..." .. math.floor(math.min(CurTime() - startedcutting, 5)), "NormalText", Color(90,81,81,164), Color(0,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        cam.End3D2D()
    else
        self:DrawFoodModel(false)
    end

end