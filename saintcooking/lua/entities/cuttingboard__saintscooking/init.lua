AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
util.AddNetworkString("StartCutting")

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate05x075.mdl")
    self:SetMaterial("phoenix_storms/wood")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
    self.empty = true
    self.itemcontained = {}
end

function ENT:StartTouch(ent) -- Food touchs the board to enter it.
    if IsValid(ent) and self.empty then
        local useable = false
        for _, cuttingdata in pairs (cuttable) do
            if ent:GetModel() == cuttingdata.model then
                local beingcut = ent:GetModel()
                self.itemcontained = cuttingdata
                self.GradeOfFood = ent.GradeOfFood
                self.empty = false
                net.Start("StartCutting")
                    net.WriteEntity(self)
                    net.WriteEntity(ent)
                    net.WriteBool(true)
                    net.WriteTable(cuttingdata)
                net.Broadcast()
                self:CuttingFood()
                ent:Remove() 
                break 
            end
        end
    end
end

function ENT:Use(a,c) -- we interact with it to eject items.
    if IsValid(self) and not self.empty then
        net.Start("StartCutting")
            net.WriteEntity(self)
            net.WriteEntity()
            net.WriteBool(false)
            net.WriteTable({})
        net.Broadcast()
        self.empty = true
        local newfood = ents.Create("fooditem_saintscooking")
        local pos = self:GetPos() + self:GetForward() * 50
        local cuttingdata = self.itemcontained
        local model = cuttingdata.model
        local Grade = self.GradeOfFood
        newfood:SetPos(pos)
        newfood.GradeOfFood = Grade
        newfood:Spawn()
        newfood:SetModel(model)
        newfood:PhysicsInit(SOLID_VPHYSICS)
        newfood:SetMoveType(MOVETYPE_VPHYSICS)
        newfood:SetSolid(SOLID_VPHYSICS)
        newfood:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self.itemcontained = {}
        local phys1 = newfood:GetPhysicsObject()
        if IsValid(phys1) then
            phys1:Wake()
        end

    end
end

function ENT:CuttingFood()
    if IsValid(self) and not self.empty then
        local cuttingdata = self.itemcontained
        local Grade = self.GradeOfFood
        local selfID = self:EntIndex()
        local timerwatch = "Watch" .. selfID
        local timercut = "Cut".. selfID
        timer.Create(timerwatch, 1, 0, function()
            if self.empty then
                timer.Remove(timercut)
                timer.Remove(timerwatch)
            end
        end)
        timer.Create(timercut,5,1,function()
            if not self.empty then
                for i = 0, cuttingdata.num, 1 do
                    local ranr = math.Rand(0,20)
                    local rand = math.Rand(0, math.pi * 2)

                    local locRight = math.cos(rand) * ranr
                    local locLeft = math.sin(rand) * ranr
                    local loc = i * 10
                    local newfood = ents.Create("fooditem_saintscooking")
                    local pos = self:GetPos() + self:GetForward() * 20
                    pos = pos + Vector(locRight, locLeft, 0)
                    local cuttingdata = self.itemcontained
                    local model = cuttingdata.output
                    newfood:SetPos(pos)
                    print(Grade)
                    newfood.GradeOfFood = Grade
                    newfood:Spawn()
                    newfood:SetModel(model)
                    newfood:PhysicsInit(SOLID_VPHYSICS)
                    newfood:SetMoveType(MOVETYPE_VPHYSICS)
                    newfood:SetSolid(SOLID_VPHYSICS)
                    newfood:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                    local phys1 = newfood:GetPhysicsObject()
                    if IsValid(phys1) then
                        phys1:Wake()
                    end
                end
                self.itemcontained = {}
                self.empty = true
                net.Start("StartCutting")
                    net.WriteEntity(self)
                    net.WriteEntity()
                    net.WriteBool(false)
                    net.WriteTable({})
                net.Broadcast()
                
            end
        end)
    end
end