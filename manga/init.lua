multi,thread = require("multi"):init()
THREAD = multi.integration.THREAD
local m = {}
m.azlist = {}
m.init = THREAD:newFunction(function()
    local http = require("socket.http")
    local list = http.request("http://www.mangareader.net/alphabetical")
    return list
end,true)
-- return title
function m.getList()
    return m.azlist
end
function m.storeList(list)
    local go = false
    local titles = {}
    for link,title in list:gmatch("<li><a href=\"([^\"]+)\">([^<]+)[^>]+></li>") do
        if go and link~="/" and link~="/privacy" then
            table.insert(titles,{Title = title,Link = "http://www.mangareader.net"..link})
        end
        if title=="Z" then
            go = true
        end
    end
    m.azlist = titles
    return titles
end
-- returns manga
m.getManga = THREAD:newFunction(function(title)
    local http = require("socket.http")
    local manga = http.request(title.Link)
    local tab = {}
    tab.Cover = manga:match([[<div id="mangaimg"><img src="(.-)"]])
    tab.Title = manga:match([[Name:.-"aname">%s*([^<]*)]])
    tab.AltTitle = manga:match([[Alternate Name:.-<td>([^<]*)]])
    tab.Status = manga:match([[Status:.-<td>([^<]*)]])
    tab.Author = manga:match([[Author:.-<td>([^<]*)]])
    tab.Artist = manga:match([[Artist:.-<td>([^<]*)]])
    tab.ReadingDir = manga:match([[Reading Direction:.-<td>([^<]*)]])
    local data = manga:match([[readmangasum(.*)]])
    tab.Desc = manga:match([[<p>(.-)</p>]])
    tab.Chapters = {}
    for link,chapter in data:gmatch([[<a href="([^"]+)">([^<]+)]]) do
        if link~="/" and link~="/privacy" then
            table.insert(tab.Chapters,{Link = "http://www.mangareader.net"..link,Lead = chapter})
        end
    end
    return tab
end)
local queue = multi:newSystemThreadedJobQueue(16)
queue:doToAll(function()
    multi,thread = require("multi"):init()
    http = require("socket.http") -- This is important
end)
queue:registerFunction("getImage",function(pageurl)
    local page = http.request(pageurl)
    return page:match([[id="imgholder.-src="([^"]*)]])
end)
queue:registerFunction("getPages",function(manga,chapter)
    local tab = {}
    local page = http.request(manga.Chapters[chapter].Link)
    tab.pages = {page:match([[id="imgholder.-src="([^"]*)]])}
    tab.nextChapter = "http://www.mangareader.net"..page:match([[Next Chapter:.-href="([^"]*)]])
    for link,page in page:gmatch([[<option value="([^"]*)">(%d*)</option>]]) do
        table.insert(tab.pages,getImage("http://www.mangareader.net"..link))
    end
    return tab
end)
-- returns pages
m.getPages = function(manga,chapter)
    local http = require("socket.http")
    local tab = {}
    local cc = 0
    local done = false
    local page = http.request(manga.Chapters[chapter].Link)
    tab.pages = {page:match([[id="imgholder.-src="([^"]*)]])}
    tab.nextChapter = "http://www.mangareader.net"..page:match([[Next Chapter:.-href="([^"]*)]])
    local lastJob
    local conn = queue.OnJobCompleted(function(jid,link)
        table.insert(tab.pages,link)
        cc=cc+1
        if jid==lastJob then
            done = true
        end
    end)
    local count = 0
    for link,page in page:gmatch([[<option value="([^"]*)">(%d*)</option>]]) do
        lastJob = queue:pushJob("getImage","http://www.mangareader.net"..link)
        count = count + 1
    end
    thread.hold(function()
        return done
    end)
    return tab
end
return m