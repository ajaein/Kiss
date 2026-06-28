local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/ajaein/Kiss/main/'..select(1, path:gsub('newKiss/', '')), true)
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

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after Kiss updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'newKiss', 'newKiss/games', 'newKiss/profiles', 'newKiss/assets', 'newKiss/libraries', 'newKiss/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.KissDeveloper then
	local _, subbed = pcall(function()
		return error('Github downloads disabled')
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('newKiss/profiles/commit.txt') and readfile('newKiss/profiles/commit.txt') or '') ~= commit then
		wipeFolder('newKiss')
		wipeFolder('newKiss/games')
		wipeFolder('newKiss/guis')
		wipeFolder('newKiss/libraries')
	end
	writefile('newKiss/profiles/commit.txt', commit)
end

return loadstring(downloadFile('newKiss/main.lua'), 'main')()
