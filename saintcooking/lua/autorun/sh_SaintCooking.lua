/* template for your amusement
This is for recipes
burgergtaiv = { 
    recipe = {cookinIngrediants.cookedmeat.name, cookinIngrediants.breadslice.name}, 
    cooktime = 10, 
    name = "Burger!",
    model = "models/foodnhouseholditems/cheerios.mdl" 
    }
This is for ingeridents
flour = {
        name = "Flour",
        model = "models/hlvr/food/bag_flour_1.mdl"
        id = 0 --This number is an ID and must not equal any other.
    },
This is for effects
cookies = {
        id = 11,
        eat = function(ply, modifer)
            ply:ChatPrint("I've never had better sweets!")
            ply:SetHealth(ply:Health() + 50 + modifer)
            ply:SetArmor(ply:Armor() + 20)
            ply:SetRunSpeed(ply:GetRunSpeed() + 20)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",75,100,1)
        end
    },
    */

if SERVER then
    print("[Saint's Cooking] Server-side addon loaded")
elseif CLIENT then
    print("[Saint's Cooking] Client-side addon loaded")
end

cookinIngrediants = {

    flour = {
        name = "Flour",
        model = "models/hlvr/food/bag_flour_1.mdl",
        id = 0
    },
    breadslice = {
        name = "Bread Slice",
        model = "models/foodnhouseholditems/bread_slice.mdl",
        id = 1
    },
    burgerone ={
        name = "Classic Burger",
        model = "models/foodnhouseholditems/burgergtaiv.mdl",
        id = 2
    },
    mess = {
        name = "Disgusting mess",
        model = "models/props_junk/shoe001a.mdl",
        id = 3
    },
    LoafBread = {
        name = "Loaf Of Bread",
        model = "models/foodnhouseholditems/bread-3.mdl",
        id = 4
    },
    egg = {
        name = "Egg",
        model = "models/foodnhouseholditems/egg1.mdl",
        id = 5
    },
    milk = {
        name = "Milk",
        model = "models/foodnhouseholditems/milk.mdl",
        id = 6
    },
    cake = {
        name = "Cake",
        model = "models/foodnhouseholditems/cake.mdl",
        id = 7
    },
    uncookedmeat ={
        name = "Raw Meat",
        model = "models/foodnhouseholditems/meat7.mdl",
        id = 8
    },
    cookedmeat = {
        name = "Cooked Meat",
        model = "models/foodnhouseholditems/meat8.mdl",
        id = 9
    },
    cookingoil = {
        name = "Cooking Oil",
        model = "models/foodnhouseholditems/lemoncleaner.mdl",
        id = 10
    },
    cookies = {
        name = "Noors Cookies",
        model = "models/lil_prin/monsterhunter/iceborne/food/platters/individual/cookie1.mdl",
        id = 11
    },
    sugar = {
        name = "Sugar",
        model = "models/illusion/eftcontainers/sugar.mdl",
        id = 12
    },
    butter = {
        name = "Butter",
        model = "models/griim/foodpack/twinkie.mdl",
        id = 13
    },
    kinder = {
        name = "Kinder",
        model = "models/foodnhouseholditems/kinderbox.mdl",
        id = 14
    }
}

cookinrecipes = {
-------------------------------------------------------Do not touch the Below
    EmptyPan = {
        recipe = {"EmptyPan"},
        cooktime = 0,
        name = "EmptyPan",
        model = ""
    },
    mess = {
        recipe = {"Disgusting mess"},
        cooktime = 0,
        name = "Disgusting mess",
        model = "models/props_junk/shoe001a.mdl"
    },
 -------------------------------------------------------Do not touch the above
    burgergtaiv = {
        recipe = {cookinIngrediants.cookedmeat.name, cookinIngrediants.breadslice.name},
        cooktime = 10,
        name = "Burger",
        model = "models/foodnhouseholditems/burgergtaiv.mdl"
    },

    bread = {
        recipe = {cookinIngrediants.flour.name, cookinIngrediants.flour.name},
        cooktime = 10,
        name = "Bread",
        model = "models/foodnhouseholditems/bread-3.mdl"
    },
    cake = {
        recipe = {cookinIngrediants.egg.name, cookinIngrediants.egg.name, cookinIngrediants.milk.name, cookinIngrediants.flour.name},
        cooktime = 30,
        name = "Cake",
        model = "models/foodnhouseholditems/cake.mdl"
    },
    cookedmeat = {
        recipe = {cookinIngrediants.cookingoil.name, cookinIngrediants.uncookedmeat.name},
        cooktime = 10,
        name = "Cooked Meat",
        model = "models/foodnhouseholditems/meat8.mdl"
    },
    cookies = {
        recipe = {cookinIngrediants.sugar.name, cookinIngrediants.sugar.name, cookinIngrediants.butter.name, cookinIngrediants.butter.name, cookinIngrediants.flour.name, cookinIngrediants.flour.name, cookinIngrediants.kinder.name},
        cooktime = 20,
        name = "Noors Cookies!",
        model = "models/lil_prin/monsterhunter/iceborne/food/platters/individual/cookie1.mdl"
    }
}

foodeffects = {

    cookies = {
        id = 11,
        eat = function(ply, modifer)
            ply:ChatPrint("I've never had better sweets!")
            ply:SetHealth(ply:Health() + 50 + modifer)
            ply:SetArmor(ply:Armor() + 20)
            ply:SetRunSpeed(ply:GetRunSpeed() + 20)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",75,100,1)
        end
    },

    sugar = {
        id = 12,
        eat = function(ply, modifer)
            ply:ChatPrint("Why am I eating sugar standalone, what am I five?")
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",75,100,1)
        end
    },

    butter = {
        id = 13,
        eat =  function(ply)
            ply:ChatPrint("Butta")
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",75,100,1)
        end
    },

    kinder =  {
        id = 14,
        eat = function(ply, modifer)
            ply:ChatPrint("Tastes like am six again.")
            ply:SetHealth(ply:Health() + 10 + modifer)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",75,100,1)
        end
    },

    flour = {
        id = 0,
        eat = function(ply)
            ply:ChatPrint("Augh.. this doesn't tasty good at all, I feel like am going to choke")
            ply:SetHealth(ply:Health() - 5)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",60,100,1)
        end
    },
    breadslice = {
        id = 1,
        eat = function(ply)
            ply:ChatPrint("I wish I could afford the whole loaf.")
            ply:SetHealth(ply:Health() + 1)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",60,100,1)
        end
    },
    burgerone = {
        id = 2,
        eat = function(ply, modifer)
            ply:ChatPrint("God damn this is good.")
            ply:SetHealth(ply:Health() + 20 + modifer)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",60,100,1)
            ply:SetRunSpeed(ply:GetRunSpeed() * 2)
            timer.Simple(10, function ()
                ply:SetRunSpeed(ply:GetRunSpeed() / 2)
            end)
        end
    },
    mess = {
        id = 3,
        eat = function(ply)
            ply:ChatPrint("Oh god this tastes awful... I don't feel good...")
            ply:SetHealth(ply:Health() - 15)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",60,100,1)
            timer.Create("FoodHarm1", 6, 3,function()
                ply:ScreenFade(SCREENFADE.OUT, Color(0,0,0), 2, 1)
                timer.Simple(3, function()
                    ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), 2, 1)
                end)
            end)
        end
    },
    LoafBread = {
        id = 4,
        eat = function(ply, modifer)
            ply:ChatPrint("A Whole damn loaf!")
            ply:SetHealth(ply:Health() + 5 + modifer)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",60,100,1)
        end
    },
    egg = {
        id = 5,
        eat = function(ply)
            ply:ChatPrint("I should really cook this next time...")
            ply:SetHealth(ply:Health() - 1)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",60,100,1)
        end
    },
    milk = {
        id = 6,
        eat = function(ply, modifer)
            ply:ChatPrint("My bones feel stronger!")
            ply:SetHealth(ply:Health() + 20 + modifer)
            ply:EmitSound("npc/barnacle/barnacle_gulp1.wav",60,100,1)
        end
    },
    cake = {
        id = 7,
        eat = function(ply, modifer)
            ply:ChatPrint("Man I love cake, I need more!")
            ply:SetHealth(ply:Health() + 50 + modifer)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",60,100,1)
        end
    }
}

cuttable = {
    bread = {
        name = "Bread",
        model = "models/foodnhouseholditems/bread-3.mdl",
        output = "models/foodnhouseholditems/bread_slice.mdl",
        num = 4
    },
    cake = {
        name = "Cake",
        model = "models/foodnhouseholditems/cake.mdl",
        output = "models/foodnhouseholditems/cakepiece.mdl",
        num = 8
    }
}
