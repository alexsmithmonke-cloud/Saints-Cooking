util.AddNetworkString("SpawnInFoodAdmin")
util.AddNetworkString("SpawnInItemAdmin")


net.Receive("SpawnInFoodAdmin", function(len, ply)
    if not ply:IsAdmin() then return end
    local fooddata = net.ReadTable()
    local newfood = ents.Create("fooditem_saintscooking")
    local plyeye = ply:GetEyeTrace()
    local pos = plyeye.HitPos
    pos = pos + Vector(0,0,10)
    local model = fooddata.model
    newfood:SetPos(pos)
    newfood:Spawn()
    newfood:SetModel(model)
    newfood:PhysicsInit(SOLID_VPHYSICS)
    newfood:SetMoveType(MOVETYPE_VPHYSICS)
    newfood:SetSolid(SOLID_VPHYSICS)
    newfood:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    local phys = newfood:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end)

net.Receive("SpawnInItemAdmin", function(len, ply)
    if not ply:IsAdmin() then return end
    local itemdata = net.ReadTable()
    local itemclass = itemdata.itemclass
    local newitem = ents.Create(itemclass)
    local plyeye = ply:GetEyeTrace()
    local pos = plyeye.HitPos
    pos = pos + Vector(0,0,10)
    newitem:SetPos(pos)
    if itemdata.model == "models/illusion/eftcontainers/propanetank.mdl" then
        newitem:SetModel("models/illusion/eftcontainers/propanetank.mdl")
    end
    newitem:Spawn()
    newitem:PhysicsInit(SOLID_VPHYSICS)
    newitem:SetMoveType(MOVETYPE_VPHYSICS)
    newitem:SetSolid(SOLID_VPHYSICS)
    local phys = newitem:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end)