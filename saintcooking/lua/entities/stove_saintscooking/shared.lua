ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName   = "Cooking Stove"
ENT.Information = "Use this cool ass stove to cook!"
ENT.Author      = "SinningSaint"
ENT.Spawnable   = true
ENT.Category    = "Cookin'"

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "FuelInStove")
    self:NetworkVar("String", 0, "StoveState")
end