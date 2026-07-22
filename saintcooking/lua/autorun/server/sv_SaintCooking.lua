util.AddNetworkString("SpawnInFoodAdmin")
util.AddNetworkString("SpawnInItemAdmin")
util.AddNetworkString("OpenSpawnFoodMenuAdmin")

net.Receive("SpawnInFoodAdmin", function(len, ply)
    if ply:IsAdmin() then 
        
        local CheckingIfValidRequest = net.ReadTable()
        local Grade = net.ReadFloat()
        for _, Checking in pairs(cookinIngrediants) do
            if Checking.id == CheckingIfValidRequest.id then 
                SpawnFoodPostChecks(ply, CheckingIfValidRequest, Grade)
                break 
            end
        end
    end
end)

function SpawnFoodPostChecks(ply, fooddata, Grade)

    local newfood = ents.Create("fooditem_saintscooking")
    local plyeye = ply:GetEyeTrace()
    local pos = plyeye.HitPos
    pos = pos + Vector(0,0,10)
    local model = fooddata.model
    newfood:SetPos(pos)
    newfood.GradeOfFood = Grade
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

end

concommand.Add("SspawnInFood", function(ply)
    if ply:IsAdmin() then 
        net.Start("OpenSpawnFoodMenuAdmin")
        net.Send(ply)
    else
        ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have acesse to this command") 
        return
    end
end)