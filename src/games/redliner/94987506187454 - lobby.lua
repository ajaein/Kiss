local Kiss = shared.Kiss
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and Kiss then
		Kiss:CreateNotification('Kiss', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
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

Kiss.Place = 115875349872417
if isfile('newKiss/games/'..Kiss.Place..'.lua') then
	loadstring(readfile('newKiss/games/'..Kiss.Place..'.lua'), 'redliner')(...)
else
	if not shared.KissDeveloper then
		local suc, res = pcall(function()
			return error('Github downloads disabled')..'/games/'..Kiss.Place..'.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('newKiss/games/'..Kiss.Place..'.lua'), 'redliner')(...)
		end
	end
end
