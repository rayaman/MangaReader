local mangaReader = require("manga")
local multi,thread = require("multi"):init()
local function init(page,workspace)
    local nav = page:newFrame(10,10,-20,40,0,0,1)
    nav.Color = theme.header
    nav:setRoundness(5,5,60)
    local search = nav:newTextButton("Search","Search",5,5,60,-10,0,0,0,1)
    search.Color = theme.button--Color.new("2196F3")
    search:fitFont()
    local func = thread:newFunction(function()
        mangaReader.storeList(mangaReader.init())
        local title = mangaReader.getList()[643]
        local manga = mangaReader.getManga(title)
        local page = mangaReader.getPages(manga,1)
        
    end)
    search:OnReleased(function()
        func()
    end)
    local bar = nav:newTextBox("","",70,5,-75,-10,0,0,1,1)
    bar:fitFont()
    bar.Color = theme.input
    bar.XTween = 1
    return page
end
return {
    init = init
}