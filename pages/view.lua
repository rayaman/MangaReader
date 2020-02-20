local mangaReader = require("manga")
local chapters
local current
local function init(page)
    local holder
    local masterI
    page:OnMouseWheelMoved(function(self,x,y)
        holder:Move(0,y*60)
    end)
    function getNextChapter()
        for i=1,#chapters do
            if chapters[i].Link==current.Link then
                return chapters[i+1]
            end
        end
    end
    function buildPages(img,i)
        masterI = masterI + 1
        local temp = holder:newImageLabel(nil,0,(masterI-1)*1210,800,1200)
        temp:SetImage(img)
        temp:centerX()
        return temp
    end
    queuePages = thread:newFunction(function(list,link)
        local last
        for i = 1,#list do
            local img = mangaReader.getImage(list[i]).wait()
            last = buildPages(img,i)
        end
        last:OnUpdate(function()
            if last.loaded then return end
            if last.y<_GuiPro.height then
                last.loaded = true
                current = getNextChapter()
                if not current then print("Manga End") end
                local pages = mangaReader.getPages(current)
                queuePages(pages).wait()
            end
        end)
    end)
    page.doChapter = thread:newFunction(function(chap)
        local chapter = chap.chapter
        chapters = chap.manga.Chapters
        current = chapter
        masterI = 0
        if holder then
            holder:Destroy()
        else
            holder = page:newFrame("",15,80,-30,-95,0,0,1,1)
        end
        print(masterI,current,chapters)
        holder.Visibility = 0
        holder.BorderSize = 0
        local pages = mangaReader.getPages(chapter)
        queuePages(pages,chapter.Link).wait()
    end)
    return page
end
return {
    init = init
}