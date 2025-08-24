local registry = {
  ['6872274481'] = 'Bedwars Match',
}

registry.__index = function(...): boolean return false end

while not _G.GhostVape do task.wait() end
local GhostVape = _G.GhostVape
if not registry[tostring(GhostVape.Place)] then return end
local GAME_NAME = tostring(GhostVape.Place)

local function downloadFile(path, func)
	if not isfile(path) and not _G.GhostVapeDeveloper then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/zerovsskids/GhostVape/'..isfile('GhostVape/Profiles/Commit.txt') and readfile('GhostVape/Profiles/Commit.txt') or 'main'..'/'..(string.gsub(path, 'GhostVape/', '')), true)
		end)
		if res == '404: Not Found' or res == '' then
			warn(string.format('Error while downloading file %s: %s', path, res)); return
		elseif not suc then
			warn(string.format('Error while downloading file %s: %s', path, res)); return
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after GhostVape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local Dir = string.format('GhostVape/Extra/Profiles/%s', registry[GAME_NAME])
if not isfolder(Dir) then makefolder(Dir) end

local Files = loadstring(downloadFile(Dir .. '/Files.lua'))()
if not isfolder('GhostVape/Profiles') then makefolder('GhostVape/Profiles') end
if Files then
	for _, File in Files do
		if isfile('GhostVape/Profiles/' .. File) then continue end
		writefile('GhostVape/Profiles/' .. File, downloadFile(string.format('GhostVape/Profiles/%s/%s', registry[GAME_NAME], File)))
	end
end
