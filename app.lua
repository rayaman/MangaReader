multi, thread = require("multi").init()
GLOBAL, THREAD = require("multi.integration.loveManager").init()
theme = {}
theme.menu = Color.new("70687C")
theme.header = Color.new("4B566D")
theme.button = Color.new("F45C35")
theme.input = Color.new("F9988B")
theme.menuitem = Color.new("7F5767")

local app = {}
app.pages = {}
local headersize = 80
local menusize = 350
local spdt = .005
local spd = 7
local sliderActive = false
local mm,bb
-- keep at top
local slider = thread:newFunction(function()
    local menu,button = mm,bb
    if sliderActive then return end
    sliderActive = true
    if not menu.Visible then
        menu.Visible = true
        for i=menusize/5,1,-1 do
            menu:SetDualDim(-i*spd)
            thread.sleep(spdt)
        end
        menu:SetDualDim(0)
        button:SetImage("images/menuX.png")
    else
        for i=1,menusize/5 do
            thread.sleep(spdt)
            menu:SetDualDim(-i*spd)
        end
        menu.Visible = false
        button:SetImage("images/menu.png")
    end
    sliderActive = false
end)
function app.createPage(name,path)
    local page = require("pages/"..path).init(app.workspace:newFullFrame(name),app.workspace)
    page.Color = theme.menu
    table.insert(app.pages,page)
    page.Visible = false
    page:SetDualDim(nil,nil,nil,nil,.1,.1,.8,.8)
    page:setRoundness(10,10,180)
    function page:Goto()
        for i,v in pairs(app.pages) do
            v.Visible = false
        end
        page.Visible = true
    end
    local button = app.menu:newTextLabel(name,name,0,(#app.pages-1)*(headersize/2),0,headersize/2,0,0,1)
    button:fitFont()
    button.Color = theme.menuitem
    button:OnReleased(function()
        page:Goto()
        slider()
    end)
    return page
end
local function init(a)
    app.header = a:newFrame(0,0,0,headersize,0,0,1)
    app.header.Color = theme.header
    app.workspace = a:newFrame(0,headersize,0,-headersize,0,0,1,1)
    app.menu = a:newFrame(0,headersize,menusize,-headersize,0,0,0,1)
    app.menu.Color = theme.menu
    app.menu:OnReleasedOuter(function(b,self)
        if self.Visible then
            slider()
        end
    end)
    app.workspace.Color = Color.Black
    app.menu.Visible = false
    local menubutton = app.header:newImageLabel("images/menu.png",0,0,headersize,headersize)
    menubutton.BorderSize = 0
    mm,bb = app.menu,menubutton
    menubutton:OnReleased(function()
        slider()
    end)
    local search = app.createPage("Search","search")
    app.createPage("Favorites","favs")
    search:Goto()
end
return {
    init = init
}
