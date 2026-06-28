repeat task.wait() until game:IsLoaded()
if shared.Kiss then shared.Kiss:Uninject() end

local Kiss
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and Kiss then
		Kiss:CreateNotification('Kiss', 'Failed to load : '..err, 30, 'alert')
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
			return error('Github downloads disabled')..'/'..select(1, path:gsub('newKiss/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after Kiss updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	Kiss.Init = nil
	Kiss:Load()
	task.spawn(function()
		repeat
			Kiss:Save()
			task.wait(10)
		until not Kiss.Loaded
	end)

	local teleportedServers
	Kiss:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.KissIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.Kissreload = true
				if shared.KissDeveloper then
					loadstring(readfile('newKiss/loader.lua'), 'loader')()
				else
					loadstring(error('Github downloads disabled')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.KissDeveloper then
				teleportScript = 'shared.KissDeveloper = true\n'..teleportScript
			end
			if shared.KissCustomProfile then
				teleportScript = 'shared.KissCustomProfile = "'..shared.KissCustomProfile..'"\n'..teleportScript
			end
			Kiss:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.Kissreload then
		if not Kiss.Categories then return end
		if Kiss.Categories.Main.Options['GUI bind indicator'].Enabled then
			Kiss:CreateNotification('Finished Loading', Kiss.KissButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(Kiss.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('newKiss/profiles/gui.txt') then
	writefile('newKiss/profiles/gui.txt', 'vape')
end
local gui = readfile('newKiss/profiles/gui.txt')

if not isfolder('newKiss/assets/'..gui) then
	makefolder('newKiss/assets/'..gui)
end
Kiss = loadstring(downloadFile('newKiss/guis/'..gui..'.lua'), 'gui')()
shared.Kiss = Kiss

if not shared.KissIndependent then
	loadstring(downloadFile('newKiss/games/universal.lua'), 'universal')()
	if isfile('newKiss/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('newKiss/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.KissDeveloper then
			local suc, res = pcall(function()
				return error('Github downloads disabled')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('newKiss/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	Kiss.Init = finishLoading
	return Kiss
end
