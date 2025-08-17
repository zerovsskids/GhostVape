repeat task.wait() until game:IsLoaded()
if shared.GhostVape then shared.GhostVape:Uninject() end

-- why do exploits fail to implement anything correctly? Is it really that hard?
if identifyexecutor then
	if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local GhostVape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and GhostVape then
		GhostVape:CreateNotification('GhostVape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/zerovsskids/GhostVape/'..readfile('GhostVape/profiles/commit.txt')..'/'..select(1, path:gsub('GhostVape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after GhostVape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	GhostVape.Init = nil
	GhostVape:Load()
	task.spawn(function()
		repeat
			GhostVape:Save()
			task.wait(10)
		until not GhostVape.Loaded
	end)

	local teleportedServers
	GhostVape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.GhostVapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.GhostVapereload = true
				if shared.GhostVapeDeveloper then
					loadstring(readfile('GhostVape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/zerovsskids/GhostVape/'..readfile('GhostVape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.GhostVapeDeveloper then
				teleportScript = 'shared.GhostVapeDeveloper = true\n'..teleportScript
			end
			if shared.GhostVapeCustomProfile then
				teleportScript = 'shared.GhostVapeCustomProfile = "'..shared.GhostVapeCustomProfile..'"\n'..teleportScript
			end
			GhostVape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.GhostVapereload then
		if not GhostVape.Categories then return end
		if GhostVape.Categories.Main.Options['GUI bind indicator'].Enabled then
			GhostVape:CreateNotification('Finished Loading', GhostVape.GhostVapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(GhostVape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('GhostVape/profiles/gui.txt') then
	writefile('GhostVape/profiles/gui.txt', 'new')
end
local gui = readfile('GhostVape/profiles/gui.txt')

if not isfolder('GhostVape/assets/'..gui) then
	makefolder('GhostVape/assets/'..gui)
end
GhostVape = loadstring(downloadFile('GhostVape/guis/'..gui..'.lua'), 'gui')()
shared.GhostVape = GhostVape

if not shared.GhostVapeIndependent then
	loadstring(downloadFile('GhostVape/games/universal.lua'), 'universal')()
	if isfile('GhostVape/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('GhostVape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.GhostVapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet(''..readfile('GhostVape/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('GhostVape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	GhostVape.Init = finishLoading
	return GhostVape
end
