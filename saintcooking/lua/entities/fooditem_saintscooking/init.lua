AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("ToSendGradeOfFood")

function ENT:Initialize()
    self:SetModel("models/food/burger.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
    if not self.GradeOfFood then self.GradeOfFood = 100 end
    net.Start("ToSendGradeOfFood")
        net.WriteFloat(self.GradeOfFood)
        net.WriteEntity(self)
    net.Broadcast()
end

function ENT:Use(a)
    a.EatingTheFood = self
end

hook.Add("KeyRelease", "FoodEating", function(ply, key)
    if key == IN_USE and IsValid(ply.EatingTheFood) then
        local food = ply.EatingTheFood
        local modifer = (food.GradeOfFood - 50) / 2 -- this will ensure that the max health gained by a modifer is 25 and the min is -25
        local IDMatching = false -- When the IDs match this will be true, will be used as a failsafe
        if ply:GetPos():DistToSqr(food:GetPos()) <10000 then
            for _, fooddata in pairs(cookinIngrediants) do -- will find out which food item this is to do the effects
                if fooddata.model == food:GetModel() then
                    for _, effectdata in pairs(foodeffects) do --will match food item ID with food effect ID
                        if effectdata.id == fooddata.id then
                            IDMatching = true -- This is to stop the failsafe
                            effectdata.eat(ply, modifer)
                            food:Remove()
                            break
                        end
                    end
                end
            end
            if not IDMatching then --failsafe if food has no set data
                food:Remove()
                ply:ChatPrint("Eh.. I've eaten better.")
                ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",75,100,1)
            end
        end
        ply.EatingTheFood = nil
    end
end)