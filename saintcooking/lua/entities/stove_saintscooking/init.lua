AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("StoveOn/Off")
util.AddNetworkString("PanCaught")
util.AddNetworkString("PanRemoved")
util.AddNetworkString("SendPan")
util.AddNetworkString("EjectPan")
util.AddNetworkString("SendRecipeInUse")
util.AddNetworkString("HaltCooking")

function ENT:Initialize()
    self:SetModel("models/props_c17/furniturestove001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
    
    self:SetFuelInStove(0)
    self:SetStoveState("Off")
    self.IsPanFilled = false
    self.AbleToTakeBackFood = true 
    
end

function ENT:PhysicsCollide(data, phys) --Adding fuel
    local IsFuel = data.HitEntity
    if IsValid(IsFuel) and not IsFuel.IsFuelUsed and IsFuel:GetModel() == "models/illusion/eftcontainers/propanetank.mdl" then
        IsFuel.IsFuelUsed = true
        IsFuel:Remove()
        local fuelToAdd = 55
        local newFuelValue = math.min(100, self:GetFuelInStove() + fuelToAdd)
        self:SetFuelInStove(newFuelValue)
    end
end

function ENT:Think() --using fuel
    if self:GetStoveState() == "On" then 
        local fuel = self:GetFuelInStove()
        if fuel > 0 then
            self:SetFuelInStove(math.max(0,fuel - 1))
            if not self.AbleToTakeBackFood then
            else
                self.AbleToTakeBackFood = false
            end
        end
        if self:GetFuelInStove() <= 0 then
            self:SetStoveState("Off")
            self:StopSound("ambient/fire/fire_small_loop1.wav")
            self.AbleToTakeBackFood = true
            return false
        end
        self:NextThink(CurTime() + 3)
        return true
    end
    return false
end

function ENT:ChangeState(stove)
    local State = stove:GetStoveState()
    if State == "Off" then
        if stove:GetFuelInStove() ~= 0 then
            stove:SetStoveState("On")
            stove:EmitSound("ambient/fire/fire_small_loop1.wav",70,100,1)
            stove:NextThink(CurTime() + 1)
            self:StartCooking(stove)
            net.Start("HaltCooking")
                net.WriteEntity(stove)
                net.WriteBool(false)
            net.Broadcast()
        end
    else
        stove:SetStoveState("Off")
        stove:StopSound("ambient/fire/fire_small_loop1.wav")
        self.AbleToTakeBackFood = true
        net.Start("HaltCooking")
            net.WriteEntity(stove)
            net.WriteBool(true)
        net.Broadcast()
        
    end
    stove:EmitSound("buttons/lightswitch2.wav", 70, 100, 1)
end

net.Receive("StoveOn/Off", function(len,ply)
    local Stove = net.ReadEntity()
    Stove:ChangeState(Stove)
end)

function ENT:ReceivePanContent(pan, pancontent)
    if self.IsPanFilled == false then
        self.IsPanFilled = true 
        self.PanContains = pancontent
        self.PanID = pan


        net.Start("PanCaught")
            net.WriteBool(true)
            net.WriteEntity(pan)
            net.WriteEntity(self)
            net.WriteTable(pancontent)
        net.Broadcast()

        pan:Remove()
    end
end

net.Receive("EjectPan", function()
    local stove = net.ReadEntity()
    stove.RequestedEjectionOfPan = true
    stove:EjectPan(stove)
end)

function ENT:EjectPan(stove)
    if stove.IsPanFilled then
        stove.IsPanFilled = false
        local contents = stove.PanContains
        local newprop = ents.Create("pan_saintscooking")
        local pos = stove:GetPos() + stove:GetForward() * 50
        newprop:SetPos(pos) 
        newprop:SetModel("models/props_c17/metalpot002a.mdl")
        newprop:Spawn()
        newprop.InPan = contents
        net.Start("PanContents")
            net.WriteEntity(newprop)
            net.WriteTable(contents)
        net.Broadcast()
        net.Start("PanCaught")
            net.WriteBool(false)
            net.WriteEntity(newprop)
            net.WriteEntity(stove)
            net.WriteTable(contents)
        net.Broadcast()
        net.Start("SendRecipeInUse")
            net.WriteTable({})
            net.WriteEntity(stove)
            net.WriteBool(false)
        net.Broadcast()
    end
end

function ENT:StartCooking(stove)
    if stove:GetStoveState() == "On" then 
        local checkingrecipe = cookinrecipes
        local contents = stove.PanContains or {}
        local toexit = false --okay for future refernce because this will be edited alot, the toexit var is only turned to ture if the recipe is wrong.
        --checking all saved recipes
        for _, RecipeData in pairs(checkingrecipe) do -- cycles through the recipes
            local neededitems = RecipeData.recipe
            local checklist = table.Copy(neededitems)
            toexit = false
            if #checklist ~= #contents then
                toexit = true --we first check here if the amount of items is right or not as there is no reason to check a recipe if the amount of items is invalid, we break off later, we don't break off here as it will exit out of the recipe loop and we aren't done with that.
            end
            --loading the checklist for the recipe
            for _, checking in ipairs(contents) do --cycles through items in pan
                local notinlist = false
                local item = string.lower(checking.name or "")
                if toexit then
                    break --Now this is where the breaking off happens, first it can break off due to invalid amount of items as above, or if there is an item that is not part of the recipe like below.
                end
                for i = #checklist, 1, -1 do --cycles through the checklist
                    local itemat = string.lower(checklist[i])
                    --checkin recipe
                    if item == itemat then
                        
                        table.remove(checklist, i)
                        notinlist = false --turns to true if it was found later on.
                        break
                    else
                        notinlist = true -- turns to false if it wasn't found at first.
                    end
                end
                if notinlist then --In the case it was never found it would break off here without going through the rest of the pan.
                    
                    toexit = true
                    break
                end
            end
            if not toexit then -- When the recipe is correct this function is executed to form the food/extract the recipeData
                
                local NumberOfSecondsToCook = RecipeData.cooktime
                local timeCookingStarted = CurTime()
                net.Start("SendRecipeInUse")
                    net.WriteTable(RecipeData)
                    net.WriteEntity(stove)
                    net.WriteBool(true)
                net.Broadcast()
                local id = self:EntIndex()
                local nameTimerUsedToMakeSureOvenIsStillOn = "nameTimerUsedToMakeSureOvenIsStillOn"..id
                local nameTimerUsedToSeeIfRecipeIsReady = "TimerUsedToSeeIfRecipeIsReady"..id
                timer.Create(nameTimerUsedToMakeSureOvenIsStillOn,1,0,function()
                    if stove:GetStoveState() == "Off" then
                        timer.Remove(nameTimerUsedToMakeSureOvenIsStillOn)
                        timer.Remove(nameTimerUsedToSeeIfRecipeIsReady)
                    end
                
                end)
                timer.Create(nameTimerUsedToSeeIfRecipeIsReady, 0, 1, function()

                    local TimePassedSinceCookingStarted = CurTime() - timeCookingStarted
                    if TimePassedSinceCookingStarted >= 3 then
                        self.AbleToTakeBackFood = false
                    end
                    if self.RequestedEjectionOfPan then
                        stove.PanContains = {}
                        table.insert(stove.PanContains, RecipeData)
                        stove:EjectPan(stove)
                    end
                end)
                break  
            end 
        end
        if toexit then -- when the recipe is wrong
            local cooktimein = 3
            net.Start("SendRecipeInUse")
                net.WriteTable({name = "Mess", cooktime = 3})
                net.WriteEntity(stove)
                net.WriteBool(true)
            net.Broadcast()
            local id = self:EntIndex()
            local watchtimer = "watchtimer"..id
            local cooktimer = "cooktimer"..id
            timer.Create(watchtimer,1,0,function()
                if stove:GetStoveState() == "Off" then
                    timer.Remove(watchtimer)
                    timer.Remove(cooktimer)
                end
                
            end)
            timer.Create(cooktimer,cooktimein, 1, function()

                local newfood = ents.Create("fooditem")
                local pos = stove:GetPos() + stove:GetForward() * 50
                local model = "models/props_junk/shoe001a.mdl"
                newfood:SetPos(pos)
                newfood:Spawn()
                newfood:SetModel(model)
                newfood:PhysicsInit(SOLID_VPHYSICS)
                newfood:SetMoveType(MOVETYPE_VPHYSICS)
                newfood:SetSolid(SOLID_VPHYSICS)
                newfood:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                stove.PanContains = {}
                stove:EjectPan(stove)
                
            end)
        end
    end
end