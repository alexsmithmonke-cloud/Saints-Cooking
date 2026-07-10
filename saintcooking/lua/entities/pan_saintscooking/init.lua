AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("PanContents")


function ENT:Initialize()
    self:SetModel("models/props_c17/metalpot002a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
    if self.InPan then return else self.InPan = {} end
end

function ENT:StartTouch(ent)
    if IsValid(ent) and not ent.IsCookingIngredient then
        if ent:GetClass() == "stove_saintscooking"   then
            ent:ReceivePanContent(self, self.InPan)
            return 
        end
        local stringpath = string.lower(ent:GetModel())
        local permade = cookinIngrediants
        local ispremade = false
        local chosenpremade = {}
        for _,ingerdiant in pairs(permade) do -- This is to check if its a premade ingeridants you can find this in the sh_myaddon.lua file
            if ingerdiant.model == stringpath then
                ispremade = true 
                chosenpremade = ingerdiant
            end
        end

        if ispremade then
            
            ent.IsCookingIngredient = true
            local nameFirst = string.GetFileFromFilename(ent:GetModel())
            local nameSecond = string.StripExtension(nameFirst)
            local nameThird = string.SetChar(nameSecond,1, string.upper(string.sub(nameSecond,1,1)))
            local PropData = {}
            if ispremade then
                PropData = {
                    model = ent:GetModel(),
                    name = chosenpremade.name,
                    pos = ent:GetPos(),
                    ang = ent:GetAngles()
                }
            else
                PropData = {
                    model = ent:GetModel(),
                    name = nameThird,
                    pos = ent:GetPos(),
                    ang = ent:GetAngles()
                }
            end
            table.insert(self.InPan, PropData)
            net.Start("PanContents")
                net.WriteEntity(self)
                net.WriteTable(self.InPan)
            net.Broadcast()
            ent:Remove()
        end
    end

end

function ENT:Use(activator,caller,useType,value)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    for v, PropData in ipairs(self.InPan) do
        local spew = ents.Create("fooditem_saintscooking")
    
        local randomAngle = math.Rand(0, math.pi * 2)
        local randomRadius = math.Rand(20, 35)

        local posX = math.cos(randomAngle) * randomRadius
        local posY = math.sin(randomAngle) * randomRadius
        
        local pos = self:GetPos() + Vector(posX,posY,20)
        spew:SetPos(pos)
        spew:Spawn()
        spew:SetModel(PropData.model)
        spew:SetCollisionGroup(COLLISION_GROUP_NONE)
        spew:PhysicsInit(SOLID_VPHYSICS)
        spew:SetMoveType(MOVETYPE_VPHYSICS)
        spew:SetSolid(SOLID_VPHYSICS)
        spew:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        local phys = spew:GetPhysicsObject()
            if IsValid(phys) then
            phys:Wake()
        end
    end 
    self.InPan = {}
    net.Start("PanContents")
        net.WriteEntity(self)
        net.WriteTable(self.InPan)
    net.Broadcast()
    
end