/* template for your amusement
    This is for recipes
burgergtaiv = { 
    recipe = {"bacon", "bread_slice"}, 
    cooktime = 10, 
    name = "Burger!",
    model = "models/foodnhouseholditems/cheerios.mdl" 
    }
    This is for ingeridents
flour = {
        name = "Flour",
        model = "models/hlvr/food/bag_flour_1.mdl"
        eat = 0 --This number is an ID and must not equal any other.
    },
NOTE: For the recipe if it contains custom ingreditants or renamed ingrediants they are letter sensetive, they *must* match up excatly, caps doesn't matter.
I reccomend for each recipe you add an ingeridnat with the name of the result of the recipe so when put in a pan it gives a proper name and not stuff like burgergtaiv
    */

if SERVER then
    print("[Saint's Cooking] Server-side addon loaded")
elseif CLIENT then
    print("[Saint's Cooking] Client-side addon loaded")
end


cookinrecipes = {
    burgergtaiv = {
        recipe = {"Cooked Meat", "bread slice"},
        cooktime = 10,
        name = "Burger",
        model = "models/foodnhouseholditems/burgergtaiv.mdl"
    },
    bananna_bunch = {
        recipe = {"bananna", "bananna", "bananna"},
        cooktime = 15,
        name = "Banannas",
        model = "models/foodnhouseholditems/bananna_bunch.mdl"
    },

    bread = {
        recipe = {"Flour", "Flour"},
        cooktime = 10,
        name = "Bread",
        model = "models/foodnhouseholditems/bread-3.mdl"
    },
    cake = {
        recipe = {"Egg", "Egg", "Milk", "Flour" },
        cooktime = 30,
        name = "Cake",
        model = "models/foodnhouseholditems/cake.mdl"
    },
    cookedmeat = {
        recipe = {"Cooking Oil", "Raw Meat"},
        cooktime = 10,
        name = "Cooked Meat",
        model = "models/foodnhouseholditems/meat8.mdl"
    },
    cookies = {
        recipe = {"Sugar", "Sugar", "Butter", "Butter", "Flour", "Flour", "Kinder"},
        cooktime = 20,
        name = "Noors Cookies!",
        model = "models/lil_prin/monsterhunter/iceborne/food/platters/individual/cookie1.mdl"
    }
}


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

foodeffects = {

    cookies = {
        id = 11,
        eat = function(ply)
            ply:ChatPrint("I've never had better sweets!")
            ply:SetHealth(ply:Health() + 50)
            ply:SetArmor(ply:Armor() + 20)
            ply:SetRunSpeed(ply:GetRunSpeed() + 20)
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",75,100,1)
        end
    },

    sugar = {
        id = 12,
        eat = function(ply)
            ChatPrint("Why am I eating sugar standalone, what am I five?")
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",75,100,1)
        end
    },

    butter = {
        id = 13,
        eat =  function(ply)
            ChatPrint("Butta")
            ply:EmitSound("npc/barnacle/barnacle_crunch2.wav",75,100,1)
        end
    },

    kinder =  {
        id = 14,
        eat = function(ply)
            ply:ChatPrint("Tastes like am six again.")
            ply:SetHealth(ply:Health() + 10)
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
        eat = function(ply)
            ply:ChatPrint("God damn this is good.")
            ply:SetHealth(ply:Health() + 20)
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
        eat = function(ply)
            ply:ChatPrint("A Whole damn loaf!")
            ply:SetHealth(ply:Health() + 5)
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
        eat = function(ply)
            ply:ChatPrint("My bones feel stronger!")
            ply:SetHealth(ply:Health() + 20)
            ply:EmitSound("npc/barnacle/barnacle_gulp1.wav",60,100,1)
        end
    },
    cake = {
        id = 7,
        eat = function(ply)
            ply:ChatPrint("Man I love cake, I need more!")
            ply:SetHealth(ply:Health() + 50)
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

ItemsInAddon = {
    Pan = {
        itemclass = "pan_cooking",
        name = "Pan"
    },

    Stove = {
        itemclass = "cooking",
        name = "Stove"
    },

    CuttingBoard = {
        itemclass = "cutting_cooking",
        name = "Cutting Board"
    },

    GasStove = {
        itemclass = "prop_physics",
        name = "Gas Tank",
        model = "models/illusion/eftcontainers/propanetank.mdl"
    }
}