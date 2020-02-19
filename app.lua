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
-- keep at top
local head
function app.createPage(name,path)
    local page = app.workspace:newFullFrame(name)
    local bg = page:newImageLabel("images/bg.jpg",0,0,0,0,0,0,1,1)
    multi:newThread(function()
        thread.hold(function()
            return bg.Image
        end)
        bg:repeatImage("repeat","repeat")
    end)
    bg.Color = theme.menu
    require("pages/"..path).init(page,app.workspace)
    table.insert(app.pages,page)
    page.Visible = false
    function page:Goto()
        for i,v in pairs(app.pages) do
            v.Visible = false
        end
        page.Visible = true
    end
    local button
    if head == app.header then
        button = head:newTextLabel(name,name,5,0,100,60)
    else
        button = head:newTextLabel(name,name,5,0,100,60,1)
    end
    button:centerY()
    head = button
    button:fitFont()
    button.Color = theme.menuitem
    button:OnReleased(function()
        page:Goto()
    end)
    return page, button
end
local function init(a)
    love.filesystem.setIdentity("MangaPro")
    app.workspace = a:newFrame(0,headersize,0,-headersize,0,0,1,1)
    app.header = a:newFrame(0,0,0,headersize,0,0,1)
    head = app.header
    app.header.Color = theme.header
    app.menu = a:newFrame(0,headersize,menusize,-headersize,0,0,0,1)
    app.menu.Color = theme.menu
    app.menu:OnReleasedOuter(function(b,self)
        if self.Visible then
            slider()
        end
    end)
    app.workspace.Color = Color.Black
    app.menu.Visible = false
    app.workspace.search = app.createPage("Search","search")
    app.workspace.view, app.workspace.button = app.createPage("Viewer","view")
    --app.workspace.button.Visible = false
    app.workspace.search:Goto()
end
return {
    init = init
}
