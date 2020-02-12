local Set = require("set")
local mangaReader = require("manga")
local multi,thread = require("multi"):init()
local titles
multi:newThread(function()
    titles = mangaReader.storeList(mangaReader.init())
end)
local scale = 2
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
local function init(page,workspace)
    local holder = page:newFrame("",15,80,-30,-95,0,0,1,1)
    holder.Visibility = 0
    holder.BorderSize = 0
    page.ClipDescendants = true
    holder:OnUpdate(function()
        local c = holder:getChildren()
        for i=1,#c do
            local x,y = InGridX(i,holder.width,0,mangaSize.x+5,mangaSize.y+5)
            c[i]:SetDualDim(x,y+5)
        end
        local size = math.floor(holder.width/(mangaSize.x+5))*(mangaSize.x+5)
        holder:SetDualDim((page.width-size)/2)
    end)
    local nav = page:newFrame(10,10,-20,40,0,0,1)
    local SBL = page:newFrame(0,55,540,20)
    for i,v in pairs(chars) do
        local temp = SBL:newTextLabel(v,v,(i-1)*20,0,20,20)
        temp.Color = theme.button
        temp:fitFont()
        temp:OnReleased(thread:newFunction(function()
            thread.hold(function() return titles end)
            local list = searchBy(temp.text)
            local c = holder:getChildren()
            for i=#c,1,-1 do
                c[i]:Destroy()
            end
            for i,v in pairs(list) do
                thread.sleep(.5)
                local manga = mangaReader.getManga(v).connect(function(manga)
                    print(v.Title,manga.Cover)
                    local temp = holder:newImageButton(nil,0,0,mangaSize.x,mangaSize.y)
                    temp.BorderSize = 2
                    temp:SetImage(manga.Cover)
                end)
            end
        end))
    end
    --[[
        local temp = holder:newImageLabel("images/test.jpg",0,0,mangaSize.x,mangaSize.y)
        temp.BorderSize = 2
    ]]
    SBL:centerX()
    nav.Color = theme.header
    nav:setRoundness(5,5,60)
    local search = nav:newTextButton("Search","Search",5,5,60,-10,0,0,0,1)
    search.Color = theme.button
    search:fitFont()
    local bar = nav:newTextBox("","",70,5,-75,-10,0,0,1,1)
    search:OnReleased(thread:newFunction(function()
        thread.hold(function() return titles end)
        -- tprint(searchBy("a"))
        -- tprint(searchFor(bar.text))
        -- local manga = mangaReader.getManga(title)
        -- local page = mangaReader.getPages(manga,1)
        -- print(page)
    end))
    bar:fitFont()
    bar.Color = theme.input
    bar.XTween = 1
    return page
end
return {
    init = init
}