ingredients = ingredients or {}

surface.CreateFont( "SaintCookingText", {
            font = "Arial",
            extended = false,
            size = 20,
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

net.Receive("OpenSpawnFoodMenuAdmin", function(ply)

    DrawAdminFoodMenu(ply)

end)

function DrawAdminFoodMenu(ply)
    
    local width = 1000 --The higher the smaller
    local length = 1000

    local sizeX = ScrW() - width
    local sizeY = ScrH() - length
    local PosX = ScrW() / 2 - sizeX / 2
    local PosY = ScrW() / 2 - sizeX / 2
    local Menu = vgui.Create( "DFrame" )
    Menu:SetPos( PosX, PosY ) 
    Menu:SetSize( sizeX, sizeY ) 
    Menu:SetTitle( "" ) 
    Menu:SetVisible( true ) 
    Menu:SetDraggable( true ) 
    Menu:ShowCloseButton( false )
    Menu:MakePopup()
    function Menu:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,Color(0,0,0,239)) --Edge
        draw.RoundedBox(4,10,10,w - 20,h - 20,Color(56,53,53,222)) --Fill
        draw.RoundedBox(4, sizeX - 310, 30, 10,410, Color(0,0,0,239)) --Border Between The two sections
        draw.DrawText("Enter the grade of the food:", "SaintCookingText", sizeX - 290, 370, Color(255,255,255)) --text to say grade for food
    end
    
    local CloseButton = vgui.Create("DButton", Menu)
    CloseButton:SetPos(sizeX - 310, 10)
    CloseButton:SetSize(300,30)
    CloseButton:SetText("Close")
        
    CloseButton.DoClick = function()
        Menu:Close()
    end
    function CloseButton:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,Color(14,8,8))
    end

    local GradeTextBox = vgui.Create("DTextEntry", Menu)
    GradeTextBox:SetPos(sizeX - 290, 400)
    GradeTextBox:SetSize(150, 20)

    GradeTextBox:SetText("") 
    GradeTextBox:SetPlaceholderText("From 0 to 100.....") 
    GradeTextBox:SetEditable(true) 
    GradeTextBox:SetMultiline(false)
    GradeTextBox:SetNumeric(true) 
    GradeTextBox:SetTextColor(Color(0, 0, 0))
    GradeTextBox:SetCursorColor(Color(0, 0, 0))

    ------
    local ListedIngrediants = vgui.Create("DHorizontalScroller", Menu)
    ListedIngrediants:SetPos(20,0)
    ListedIngrediants:SetSize(sizeX - 340,600)
    ListedIngrediants:SetOverlap(-10)

    ListedIngrediants.btnLeft.Paint = function() end
    ListedIngrediants.btnLeft:SetVisible(false)
    ListedIngrediants.btnRight.Paint = function() end
    ListedIngrediants.btnRight:SetVisible(false)

    for _, Ingrediant in pairs(cookinIngrediants) do

        local ModelPanel = vgui.Create("DModelPanel", ListedIngrediants)
        ModelPanel:SetSize(200, 300)
        ModelPanel:SetModel(Ingrediant.model)
        ModelPanel:SetLookAt(Vector(0, 0, 0))
        local entity = ModelPanel:GetEntity()
        if IsValid(entity) then
           
            local mn, mx = entity:GetRenderBounds()
            local size = 0
            size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
            size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
            size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
            
            
            ModelPanel:SetCamPos(Vector(size * 1, size * 1, size * 0.2))
            ModelPanel:SetLookAt((mn + mx) * 0.5)
        end
        ModelPanel:SetAmbientLight(Color(255, 255, 255))
        ListedIngrediants:AddPanel(ModelPanel)

        local Item = vgui.Create("DButton", ModelPanel)
        Item:SetSize(200,30)
        Item:SetPos(0,390)
        Item:SetText(Ingrediant.name)
        function Item:Paint(w,h)
            draw.RoundedBox(4,0,0,w,h,Color(13,8,8,237))
        end
        Item.DoClick = function()
            local GradeToTransfer = tonumber(GradeTextBox:GetText()) or 100
          
            net.Start("SpawnInFoodAdmin")
                net.WriteTable(Ingrediant)
                net.WriteFloat(GradeToTransfer)
            net.SendToServer()
        end
    end
    ------
end