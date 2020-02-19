local Set = require("set")
local mangaReader = require("manga")
local multi,thread = require("multi"):init()
local titles
multi:newThread(function()
    titles = mangaReader.storeList(mangaReader.init())
end)
local scale = 1
local mangaSize = {
    x=200/scale,
    y=288/scale
}
function tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent+1)
		elseif type(v) == 'boolean' then
			print(formatting .. tostring(v))      
		else
			print(formatting .. v)
		end
	end
end
function searchFor(query)
	query = Set(query:split(" "))
	local list = {}
	for i,v in pairs(titles) do
		local t = Set(v.Title:split(" "))
		local tab = {}
		for k in Set.elements(query*t) do table.insert(tab,k) end
		if #tab==Set.card(query) then
			table.insert(list,v)
		end
	end
	return list
end
function searchBy(char)
    local list = {}
    for i,v in pairs(titles) do
        if v.Title:sub(1,1):lower()==char:sub(1,1):lower() or (char=="#" and tonumber(v.Title:sub(1,1))~=nil) then
            table.insert(list,v)
        end
    end
    return list
end
local chars = {"#"}
for i=65,90 do
    table.insert(chars,string.char(i))
end
local onNav = false
function saveFavs(favs)
    local f = bin.new()
    f:addBlock(favs or {})
    f:tofile("favs.dat")
end
function getFavs()
    if bin.fileExists("favs.dat") then
        return bin.load("favs.dat"):getBlock("t")
    else
        return {}
    end
end

local function init(page,workspace)
    local favs = getFavs()
    local holder = page:newFrame("",15,80,-30,-95,0,0,1,1)
    local nav = page:newFrame(10,10,-20,40,0,0,1)
    local SBL = page:newFrame(0,55,0,40,0,0,1)
    local mangaViewer = page:newFrame(0,0,0,0,.1,.1,.8,.8)
    mangaViewer.Visible = false
    local cover = mangaViewer:newImageLabel(nil,10,10,mangaSize.x,mangaSize.y)
    local desc = mangaViewer:newTextLabel("","",15+mangaSize.x,10,-25-mangaSize.x,-13,0,0,1,.5)
    local chaps = mangaViewer:newTextLabel("","",15+mangaSize.x,3,-25-mangaSize.x,-13,0,.5,1,.5)
    local dets = mangaViewer:newTextLabel("","",10,15+mangaSize.y,mangaSize.x,-25-mangaSize.y,0,0,0,1)
    local menu = chaps:newScrollMenu("Chapters")
    local goback = mangaViewer:newTextLabel("Back","Back",0,5,80,40,0,1)
    goback:fitFont()
    goback:OnUpdate(function()  
        goback:centerX()
    end)
    goback:OnReleased(function()
        multi:newThread(function()
            thread.sleep(.1)
            mangaViewer.Visible = false
        end)
    end)
    function MenuItem(b,self)
        multi:newThread(function()
            thread.sleep(.1)
            mangaViewer.Visible = false
        end)
        workspace.view:Goto()
        workspace.view.doChapter(self.chapter)
    end
    goback.Color = theme.button
    function setViewer(manga)
        menu:reset()
        mangaViewer.Visible = true

        mangaViewer:setRoundness(10,10,60)
        mangaViewer.BorderSize = 2
        mangaViewer.Color = theme.menu

        cover:SetImage(manga.Cover,nil,"images/notfound.png")
        
        desc.text = manga.Desc
        desc.TextFormat = "left"
        desc.XTween = 2
        
        dets.text = "Title: " .. manga.Title .. "\n" ..
        "Author: " .. manga.Author .. "\n" ..
        "Artist: " .. manga.Artist .. "\n" ..
        "ReadingDir: " .. manga.ReadingDir .. "\n" ..
        "Chapters: " .. #manga.Chapters .. "\n" ..
        "Status: " .. manga.Status
        dets.XTween = 2
        dets.TextFormat = "left"

        gui.massMutate({
            Visibility = 0,
            BorderSize = 0,
        },desc,chaps,dets)
        
        menu.BorderSize = 0
        menu.scrollM = 4
        menu.scroll.Color = theme.header
        menu.scroll.Mover.Color = theme.menuitem
        menu.first:SetDualDim(nil,13)
        menu:SetDualDim(nil,0)
        menu.header.Color = theme.header
        menu.ref = {
            [[setRoundness(5,5,30)]],
            [[OnReleased(MenuItem)]],
            Color = theme.menuitem
        }
        for i,v in ipairs(manga.Chapters) do
            menu:addItem(v.Lead, 20, 3).chapter = v
        end
    end
    function addManga(manga,v)
        local temp = holder:newImageLabel(nil,0,0,mangaSize.x,mangaSize.y)
        temp.Visible = false
        local text = temp:newTextLabel(v.Title,v.Title,0,-30,0,30,0,1,1)
        local onStar = false
        local fav = false
        local star
        if favs[v.Title] then
            star = temp:newImageLabel("images/star.png",-40,0,40,40,1)
        else
            star = temp:newImageLabel("images/unstar.png",-40,0,40,40,1)
        end
        star:OnMouseEnter(function()
            onStar = true
        end)
        star:OnMouseMoved(function()
            onStar = true
        end)
        star:OnReleasedOuter(function()
            onStar = false
        end)
        star:OnReleased(function()
            fav = not fav
            if fav then
                star:SetImage("images/star.png")
                favs[v.Title] = v
                saveFavs(favs)
            else
                star:SetImage("images/unstar.png")
                favs[v.Title] = nil
                saveFavs(favs)
            end
        end)
        star.BorderSize = 0
        text.Visibility = .6
        text.Color = Color.Black
        text.TextColor = Color.White
        text.TextFormat = "center"
        text:fitFont()
        temp.BorderSize = 2
        temp:SetImage(manga.Cover,nil,"images/notfound.png")
        multi:newThread(function()
            thread.hold(function()
                return temp.Image
            end)
            temp.Visible = true
        end)
        temp:OnReleased(function(b,self)
            if onNav or onStar or mangaViewer:isVisible() then return end
            setViewer(manga)
        end)
    end
    page:OnMouseWheelMoved(function(self,x,y)
        if mangaViewer:isVisible() then return end
        holder:Move(0,y*60)
        if holder.offset.pos.y>85 then
            holder:SetDualDim(nil,85)
        end
    end)
    holder.Visibility = 0
    holder.BorderSize = 0
    holder:OnUpdate(function()
        local c = holder:getChildren()
        for i=1,#c do
            local x,y = InGridX(i,holder.width,0,mangaSize.x+5,mangaSize.y+5)
            c[i]:SetDualDim(x,y+5)
        end
        local size = math.floor(holder.width/(mangaSize.x+5))*(mangaSize.x+5)
        holder:SetDualDim((page.width-size)/2)
    end)
    SBL.BorderSize = 0
    local FAV = SBL:newTextLabel("*","*",0,0,0,0,0/28,0,1/28,1)
    FAV.Color = theme.button
    FAV:OnReleased(thread:newFunction(function()
        if mangaViewer:isVisible() then return end
        holder:SetDualDim(nil,85)
        local c = holder:getChildren()
        for i=#c,1,-1 do
            c[i]:Destroy()
        end
        for i,v in pairs(favs) do
            thread.yield()
            mangaReader.getManga(v).connect(function(manga)
                addManga(manga,{Title=manga.Title,Link=manga.Link})
            end)
        end
    end))
    for i,v in pairs(chars) do
        local temp = SBL:newTextLabel(v,v,0,0,0,0,(i)/28,0,1/28,1)
        temp.Color = theme.button
        multi.setTimeout(function()
            temp:fitFont()
        end,.1)
        temp:OnReleased(thread:newFunction(function()
            if mangaViewer:isVisible() then return end
            holder:SetDualDim(nil,85)
            thread.hold(function() return titles end)
            local list = searchBy(temp.text)
            local c = holder:getChildren()
            for i=#c,1,-1 do
                c[i]:Destroy()
            end
            for i,v in pairs(list) do
                thread.yield()
                mangaReader.getManga(v).connect(function(manga)
                    addManga(manga,{Title=manga.Title,Link=manga.Link})
                end)
            end
        end))
    end
    nav:OnMouseEnter(function()
        onNav = true
    end)
    local function exiter()
        onNav = false
    end
    nav:OnMouseExit(exiter)
    nav:OnReleasedOuter(exiter)
    nav.Color = theme.header
    nav:setRoundness(5,5,60)
    local search = nav:newTextLabel("Search","Search",5,5,60,-10,0,0,0,1)
    search.Color = theme.button
    search:fitFont()
    local bar = nav:newTextBox("","",70,5,-75,-10,0,0,1,1)
    search:OnReleased(thread:newFunction(function()
        if mangaViewer:isVisible() then return end
        local c = holder:getChildren()
        for i=#c,1,-1 do
            c[i]:Destroy()
        end
        holder:SetDualDim(nil,85)
        thread.hold(function() return titles end)
        local list = searchFor(bar.text)
        for i,v in pairs(list) do
            mangaReader.getManga(v).connect(function(manga)
                addManga(manga,{Title=manga.Title,Link=manga.Link})
            end)
        end
    end))
    bar:fitFont()
    bar.Color = theme.input
    bar.XTween = 1
    return page
end
return {
    init = init
}