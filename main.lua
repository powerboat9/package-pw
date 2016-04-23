local tArgs = {...}
local dir = assert(tArgs[1] and fs.isDir(dir), "Please Specify A Directory")
if dir:sub(-1, -1) == "/" then
    dir = dir:sub(1, -2)
end
local preventHTTP = tArgs[2] or ((not http) and (function() printError("[WARN] HTTP API unavailable"); return true end))

function getName(s)
    return s:sub(s:find("[^/]*$"))
end

local location = tArgs[2] or (getName(dir) .. ".xtract")

local saveFile = "--------Generated by \"package-pw\"--------\n\nlocal current = shell.getRunningProgram()\n\nlocal extract = ""\ndo\n    local start, end = current:find(\"[^/]*$\")\n    extract = current:sub(end - 2, -1)\nend\n\n--------Generated Code--------\n\n"

function escape(s)
    local escapes = {"\a" = "\\a", "\b" = "\\b", "\f" = "\\f", "\n" = "\\n", "\r" = "\\r", "\t" = "\\t", "\v" = "\\v", "\\" = "\\\\", "'" = "\\'", "\"" = "\\\"", "\[" = "\\[", "\]" = "\\]"}
    for get, replace in pairs(escapes) do
        s = s:gsub(get, replace)
    end
    return s
end

local fileFormat = "do\n    local file = fs.open(%s, \"w\")\n    file.write(%s)\n    file.close()\nend\n"
local httpFileFormat = "do\n    local file = fs.open(%s, \"w\")\n    local handle = http.get(%s)\n    local data = handle.readAll()\n    handle.close()\n    file.write(data)\n    file.close()\nend\n"

function appendFile(file)
    local fileHandle = fs.open(file, "r")
    saveFile = saveFile .. fileFormat:format("extract .. \"/\" .. " .. getName(file), escape(fileHandle.readAll()))
    fileHandle.close()
end

function appendURL(url, file)
    if preventHTTP then
        saveFile = saveFile .. httpFileFormat:format(file:sub(#dir + 2, -1), url)
    else
        local handle = http.get(url)
        saveFile = saveFile .. fileFormat:format("extract .. \"/\" .. " .. getName(file), escape(handle.readAll()))
        handle.close()
    end
end

for k, v in ipairs(fs.list(dir)) do
    

