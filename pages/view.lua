local mangaReader = require("manga")
local function init(page)
    local holder
    local masterI
    page:OnMouseWheelMoved(function(self,x,y)
        holder:Move(0,y*60)
    end)
    function buildPages(img,i)
        masterI = masterI + 1
        local temp = holder:newImageLabel(nil,0,(masterI-1)*1210,800,1200)
        temp:SetImage(img)
        temp:centerX()
        return temp
    end
    queuePages = thread:newFunction(function(list)
        local last
        for i = 1,#list do
            local img = mangaReader.getImage(list[i]).wait()
            last = buildPages(img,i)
        end
        last:OnUpdate(function()
            if last.loaded then return end
            if last.y<_GuiPro.height then
                last.loaded = true
                local pages = mangaReader.getPages(list.nextChapter)
                queuePages(pages).wait()
            end
        end)
    end)
    page.doChapter = thread:newFunction(function(chapter)
        masterI = 0
        if holder then
            holder:Destroy()
        else
            holder = page:newFrame("",15,80,-30,-95,0,0,1,1)
        end
        holder.Visibility = 0
        holder.BorderSize = 0
        local pages = mangaReader.getPages(chapter)
        print(queuePages(pages).wait())
    end)
    return page
end
return {
    init = init
}