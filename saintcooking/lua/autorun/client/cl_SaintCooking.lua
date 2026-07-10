ingredients = ingredients or {}

function DrawMenu(ply)

    local sizeX = ScrW() - 300
    local sizeY = ScrH() - 300
    local F4Menu = vgui.Create( "DFrame" )
    F4Menu:SetPos( ScrW() / 2 - sizeX / 2, ScrH() / 2 - sizeY / 2  ) 
    F4Menu:SetSize( sizeX, sizeY ) 
    F4Menu:SetTitle( "" ) 
    F4Menu:SetVisible( true ) 
    F4Menu:SetDraggable( false ) 
    F4Menu:ShowCloseButton( false )
    F4Menu:MakePopup()
    function F4Menu:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,Color(190,174,174))
        draw.RoundedBox(4,10,10,w - 20,h - 20,Color(41,38,38))
        
    end
    
    local CloseButton = vgui.Create("DButton", F4Menu)
    CloseButton:SetPos(sizeX - 310, 10)
    CloseButton:SetSize(300,30)
    CloseButton:SetText("Close")
    
    CloseButton.DoClick = function()
        F4Menu:Close()
    end
    function CloseButton:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,Color(14,8,8))
    end

    local ChefMenu = vgui.Create("DButton", F4Menu)
    ChefMenu:SetPos(10,10)
    ChefMenu:SetSize(300,30)
    ChefMenu:SetText("Open Chef Section")
    function ChefMenu:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,Color(14,8,8))
    end
    ChefMenu.DoClick = function()
        local Chef = vgui.Create("DFrame", F4Menu)
        Chef:SetPos(310,10)
        Chef:SetSize(sizeX - 610, sizeY - 20)
        Chef:SetTitle("")
        Chef:SetDraggable(false)
        Chef:ShowCloseButton(false)
        function Chef:Paint(w,h)
            draw.RoundedBox(4,0,0,w,h,Color(15,15,15))
            draw.RoundedBox(4,10,10,w - 20,h - 20,Color(32,10,10))
            
        end
        -- Spawn food section
        local SpawnFood = vgui.Create("DButton", Chef)
        SpawnFood:SetPos(10,10)
        SpawnFood:SetSize(200,30)
        SpawnFood:SetText("Spawn food items")
        SpawnFood:SetTextColor(Color(0,0,0))
        function SpawnFood:Paint(w,h)
            draw.RoundedBox(4,0,0,w,h,Color(138,108,155))
        end
        SpawnFood.DoClick = function()
            local foodmenu = vgui.Create("DFrame", Chef)
            foodmenu:SetPos(210,10)
            foodmenu:SetSize(1000,400)
            foodmenu:SetTitle("")
            foodmenu:ShowCloseButton(false)
            foodmenu:SetDraggable(false)
            function foodmenu:Paint(w,h)
                draw.RoundedBox(4,0,0,w,h,Color(58,45,45))
            end
            local stage = 0
            for _, fooddata in pairs(cookinIngrediants) do --This will draw buttons for each food item that is saved in the 'cookinIngrediants' table.
                
                local itemfood = vgui.Create("DButton", Chef)
                local foodpos = stage * 20
                itemfood:SetPos(220,20 + foodpos)
                itemfood:SetSize(120,20)
                itemfood:SetText(fooddata.name)
                itemfood.DoClick = function()
                    net.Start("SpawnInFoodAdmin")
                        net.WriteTable(fooddata)
                    net.SendToServer()
                end
                stage = stage + 1
            end

        end -- Spawning food section

        -- spawn cooking items section
        local SpawnItems = vgui.Create("DButton", Chef)
        SpawnItems:SetPos(10,50)
        SpawnItems:SetSize(200,30)
        SpawnItems:SetText("Spawn cooking items")
        SpawnItems:SetTextColor(Color(0,0,0))
        function SpawnItems:Paint(w,h)
            draw.RoundedBox(4,0,0,w,h,Color(138,108,155))
        end
        SpawnItems.DoClick = function ()
            local itemmenu = vgui.Create("DFrame", Chef)
            itemmenu:SetPos(210,10)
            itemmenu:SetSize(1000,400)
            itemmenu:SetTitle("")
            itemmenu:ShowCloseButton(false)
            itemmenu:SetDraggable(false)
            function itemmenu:Paint(w,h)
                draw.RoundedBox(4,0,0,w,h,Color(58,45,45))
            end
            local stage = 0
            for _, itemdata in pairs(ItemsInAddon) do --This will draw buttons for each cooking item that is saved in the 'ItemsInAddon' table.
                
                local itemfood = vgui.Create("DButton", Chef)
                local itempos = stage * 20
                itemfood:SetPos(220,20 + itempos)
                itemfood:SetSize(120,20)
                itemfood:SetText(itemdata.name)
                itemfood.DoClick = function()
                    net.Start("SpawnInItemAdmin")
                        net.WriteTable(itemdata)
                        net.WriteEntity(LocalPlayer())
                    net.SendToServer()
                end
                stage = stage + 1
            end
        end -- Spawning cooking items section

        -- Showing recipes section
        local ShowRecipes = vgui.Create("DButton", Chef)
        ShowRecipes:SetPos(10,90)
        ShowRecipes:SetSize(200,30)
        ShowRecipes:SetText("Show Recipes")
        ShowRecipes:SetTextColor(Color(0,0,0))
        function ShowRecipes:Paint(w,h)
            draw.RoundedBox(4,0,0,w,h,Color(138,108,155))
        end
        ShowRecipes.DoClick = function ()
            local recipemenu = vgui.Create("DFrame", Chef)
            recipemenu:SetPos(210,10)
            recipemenu:SetSize(1000,400)
            recipemenu:SetTitle("")
            recipemenu:ShowCloseButton(false)
            recipemenu:SetDraggable(false)
            function recipemenu:Paint(w,h)
                draw.RoundedBox(4,0,0,w,h,Color(58,45,45))
            end
            local recipescroll = vgui.Create("DScrollPanel", Chef)
            recipescroll:SetPos(220,20)
            recipescroll:SetSize(980,400)
            for _, recipedata in pairs(cookinrecipes) do
                local itemrow = vgui.Create("DPanel", recipescroll)
                itemrow:Dock(TOP)
                itemrow:DockMargin(0,0,0,5)
                itemrow:SetHeight(30)

                local listing = table.concat(recipedata.recipe, " + ")
                local fullRecipeText = string.format("%s = %s", recipedata.name, listing)

                function itemrow:Paint(w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(133, 115, 115))
                    draw.SimpleText(fullRecipeText, "SmallText", 10, h / 2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

            end
        end -- Showing recipes section


    end -- Chef section

end --main draw 

hook.Add("PlayerBindPress", "Menu", function(ply,bind,pressed)
    if string.find(bind, "showspare2") then
        DrawMenu(ply)
    end

end)