AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("StoveOn/Off")
util.AddNetworkString("PanCaught")
util.AddNetworkString("PanRemoved")
util.AddNetworkString("SendPan")
util.AddNetworkString("EjectPan")
util.AddNetworkString("SendRecipeInUse")
util.AddNetworkString("EmptyPanDetected")
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
    self.HasPan = false
    self.PanContains = {}
    self.PanID = nil
    self.AbleToTakeBackFood = true
    self.LastTickOfFuelBurnt = 0
    self.LastTickOfRecipeBeingCooked = 0
    self.CurrentRecipe = {}
    self.RequestedEjectionOfPan = false
    self.AmountOfTimePanHasBeenCooked = 0
    self.MomentPanStartedBeingCooked = 0
    self.IsTheStoveCooking = false

    self:ToUpdateCookingProcess(cookinrecipes.EmptyPan) --This is used to make sure the client is synced up with the server
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

function ENT:Think() --Used To check when the self is "On" and to do the functions that is required while its on, such as fuel being used and the recipe being updated/cooked.
    if self:GetStoveState() == "On" then 
        local fuel = self:GetFuelInStove()

        local LastTickForFuel = math.floor(CurTime() - self.LastTickOfFuelBurnt)
        local amountOfTicksNeededForFuelUsage = 3
        local LastTickForRecipe = math.floor(CurTime() - self.LastTickOfRecipeBeingCooked)
        local amountOfTicksNeededForRecipeCooking = 1
        local LastTickForFoodTakeBack = math.floor(CurTime() - self.LastTickForFoodTakeBack)
        local amountOfTicksNeededForFoodTakeBack = 3

        if fuel > 0 then
            if self.HasPan and self.PanContains then
                if LastTickForRecipe >= amountOfTicksNeededForRecipeCooking then
                    self:ToUpdateCookingProcess(self.CurrentRecipe, "LastTickForRecipe")
                end
                
            end
            if LastTickForFuel >= amountOfTicksNeededForFuelUsage then
                self:ToUpdateCookingProcess(self.CurrentRecipe, "LastTickForFuel")
            end
            if LastTickForFoodTakeBack >= amountOfTicksNeededForFoodTakeBack then
                self:ToUpdateCookingProcess(self.CurrentRecipe, "LastTickForFoodTakeBack")
            end
        end
        if self:GetFuelInStove() <= 0 then
            self:SetStoveState("Off")
            self:StopSound("ambient/fire/fire_small_loop1.wav")
        end
    end
end

function ENT:ChangeState(self)
    local State = self:GetStoveState()
    if State == "Off" then
        if self:GetFuelInStove() ~= 0 then
            self:SetStoveState("On")
            self:EmitSound("ambient/fire/fire_small_loop1.wav",70,100,1)

            self.LastTickOfFuelBurnt = math.floor(CurTime())
            self.LastTickOfRecipeBeingCooked = math.floor(CurTime())
            self.LastTickForFoodTakeBack = math.floor(CurTime())

            if self.HasPan then
                self.MomentPanStartedBeingCooked = math.floor(CurTime())
            end

            self:StartCooking(self)
            net.Start("HaltCooking")
                net.WriteEntity(self)
                net.WriteBool(false)
            net.Broadcast()
        end
    else
        self:SetStoveState("Off")
        self:StopSound("ambient/fire/fire_small_loop1.wav")
        if self.AbleToTakeBackFood then
            self.AmountOfTimePanHasBeenCooked = 0
        end

        net.Start("HaltCooking")
            net.WriteEntity(self)
            net.WriteBool(true)
        net.Broadcast()
        
    end
    self:EmitSound("buttons/lightswitch2.wav", 70, 100, 1)
end

net.Receive("StoveOn/Off", function(len,ply)
    local Stove = net.ReadEntity()
    Stove:ChangeState(Stove)
end)

function ENT:ReceivePanContent(pan, pancontent)
    if self.HasPan == false then
        self.HasPan = true 
        self.PanContains = pancontent
        self.PanID = pan
        self.AmountOfTimePanHasBeenCooked = 0
        self.AbleToTakeBackFood = true
        self:ToUpdateCookingProcess(pancontent)

        if self:GetStoveState() == "On" then
            self.MomentPanStartedBeingCooked = math.floor(CurTime())
        end

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
    local self = net.ReadEntity()
    self.RequestedEjectionOfPan = true
    self:EjectPan(self)
end)

function ENT:EjectPan(self)
    
    self:ToGradeTheFood()

    self.RequestedEjectionOfPan = false
    self.AbleToTakeBackFood = true

    
end

function ENT:StartCooking(self)
    if self:GetStoveState() == "On" then 
        local checkingrecipe = cookinrecipes
        local contents = self.PanContains or {}
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
                self:ToUpdateCookingProcess(RecipeData)
                self.CurrentRecipe = RecipeData
                break
            end 
        end
        if toexit then -- when the recipe is wrong
            if #contents <= 0 then
                self:ToUpdateCookingProcess(checkingrecipe.EmptyPan)
                self.CurrentRecipe = checkingrecipe.EmptyPan
            else
                self:ToUpdateCookingProcess(checkingrecipe.mess)
                self.CurrentRecipe = checkingrecipe.mess
            end
        end
    end
end

function ENT:ToUpdateCookingProcess(RecipeData, FooCallingThisFoo)
    if FooCallingThisFoo == "LastTickForRecipe" then
        self.AmountOfTimePanHasBeenCooked = self.AmountOfTimePanHasBeenCooked + 1
        if #self.PanContains > 0 then
            self.IsTheStoveCooking = true
        else
            self.IsTheStoveCooking = false
        end
        self.LastTickOfRecipeBeingCooked = math.floor(CurTime())

    elseif FooCallingThisFoo == "LastTickForFuel" then

        local fuel = self:GetFuelInStove()
        self:SetFuelInStove(math.max(0,fuel - 1))
        self.LastTickOfFuelBurnt = CurTime()

    elseif FooCallingThisFoo == "LastTickForFoodTakeBack" then

        if RecipeData == cookinrecipes.EmptyPan then
            self.AbleToTakeBackFood = true
        else
            self.AbleToTakeBackFood = false
        end
        self.LastTickForFoodTakeBack =  math.floor(CurTime())
    end
    if RecipeData == cookinrecipes.EmptyPan then
        net.Start("EmptyPanDetected")
            net.WriteBool(true)
            net.WriteEntity(self)
        net.Broadcast()
    else
        net.Start("EmptyPanDetected")
            net.WriteBool(false)
            net.WriteEntity(self)
        net.Broadcast()
    end
    net.Start("SendRecipeInUse")
        net.WriteTable(RecipeData) -- Recipe being used
        net.WriteEntity(self) --Which Stove?
        net.WriteBool(self.IsTheStoveCooking) --Is cooking?
        net.WriteBool(self.AbleToTakeBackFood) -- Used to see if It should display "Cooking..." or what is in the pan.
        net.WriteFloat(self.MomentPanStartedBeingCooked) --Pretty self explaining
        net.WriteFloat(self.AmountOfTimePanHasBeenCooked) --Pretty self explaining
    net.Broadcast()
    
end

function ENT:ToGradeTheFood()
    local GradeOfFood = 0 -- It starts with a base of 100 and will lower if there were mistakes and slightly go up if there is perfection.
    local RecipeData = self.CurrentRecipe
    local contents = self.PanContains

    local NeededCookTime = RecipeData.cooktime 
    local TimePanHasBeenCooking = self.AmountOfTimePanHasBeenCooked
    local SpecialStatus -- Will be used if something is burnt or raw

    if not self.AbleToTakeBackFood and self.HasPan then 
        for _, item in pairs(contents) do -- The math that will be done to take into account the grade of the items used in making the food
            local GradeOfItem = item.Grade - 50
            local GradeToAdd = math.Round(GradeOfItem / #contents)
            GradeOfFood = GradeOfFood + GradeToAdd
        end
        --- welcome to elseif hell
        if TimePanHasBeenCooking == NeededCookTime then -- If cooktime is perfect
            GradeOfFood = GradeOfFood + 50
        elseif TimePanHasBeenCooking > NeededCookTime and TimePanHasBeenCooking < NeededCookTime + 5 then-- If slightly overcooked
            GradeOfFood = GradeOfFood + 30
        elseif TimePanHasBeenCooking < NeededCookTime and TimePanHasBeenCooking > NeededCookTime - 5 then -- If slightly undercooked
            GradeOfFood = GradeOfFood + 25
        elseif TimePanHasBeenCooking >= NeededCookTime + 5 and TimePanHasBeenCooking < NeededCookTime + 10 then -- Greatly overcooked
            GradeOfFood = GradeOfFood + 10
        elseif TimePanHasBeenCooking <= NeededCookTime - 5 and TimePanHasBeenCooking > NeededCookTime - 10 then -- Greatly undercooked
            GradeOfFood = GradeOfFood + 5
        elseif TimePanHasBeenCooking >= NeededCookTime + 10 then -- Burnt
            GradeOfFood = -1
        elseif TimePanHasBeenCooking <= NeededCookTime - 10 then -- Raw
            GradeOfFood = -2
        end
        
        if RecipeData.name == "Disgusting mess" then
            GradeOfFood = 0
        end
    end
    --- THIS ALWAYS HAS TO BE THE LAST THING RAN.
    if self.HasPan then -- This is just to spawn in the time which has been ejected.
        self.HasPan = false
        local newprop = ents.Create("pan_saintscooking")
        local pos = self:GetPos() + self:GetForward() * 50
        local PropData
        newprop:SetPos(pos) 
        newprop:SetModel("models/props_c17/metalpot002a.mdl")
        newprop:Spawn()
        if not self.AbleToTakeBackFood then
            
            newprop.GradeOfFood = GradeOfFood
            newprop.InPan = {}
            PropData = {
                model = RecipeData.model,
                name = RecipeData.name,
                Grade = GradeOfFood 
            }
            contents = {}
            table.insert(contents, PropData)
            table.insert(newprop.InPan, PropData)
        else
            newprop.InPan = {}
            newprop.InPan = contents
        end
        net.Start("PanContents") --Updates Pan CL
            net.WriteEntity(newprop)
            net.WriteTable(contents)
        net.Broadcast()
        net.Start("PanCaught") --Resets Stove CL
            net.WriteBool(false)
            net.WriteEntity({})
            net.WriteEntity(self)
            net.WriteTable({})
        net.Broadcast()
        net.Start("SendRecipeInUse") --Resets Stove CL
            net.WriteTable({})
            net.WriteEntity(self)
            net.WriteBool(false)
        net.Broadcast()
    end

end