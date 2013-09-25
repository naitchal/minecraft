args = {...}
 
local updateAll = false
 
if args[1] == "--all" then
    updateAll = true
end

local static = _G

if not http then print("HTTP is not enabled") error("HTTP is not enabled") end
screenX, screenY = term.getSize()
 
function wrap(str, limit, indent, indent1)
	indent = indent or ""
	indent1 = indent1 or indent
	limit = limit or 72
	local here = 1-#indent1
	return indent1..str:gsub("(%s+)()(%S+)()",
		function(sp, st, word, fi)
			if fi-here > limit then
				here = st - #indent
				return "\n"..indent..word
			end
		end)
end
function updateScript(oScript, sBranch)
    local git = static.git
	if not sBranch then
		sBranch = "master"
	end
	
	if oScript.file == "Exit" then
		print("")
    else
        local sFile = oScript.file
        local sLocalFile = oScript.rename
        if not sLocalFile then sLocalFile = sFile end
        local sDir = oScript.dir
        if not sDir then sDir = "/" end
        --todo: double check that sDir ends with a path char
        print( sDir .. sFile )
        local url = git.gitUrl .. git.baseUrl .. "/" .. sBranch .. sDir .. sFile .. "?access_token=" .. git.accessToken
        local response = http.get( url )

        if response then
            print( "success" )
        else
            error( "failure... url: " + url )
        end
        local script = response.readAll()
        response.close()

        if not fs.exists( sDir ) then
            fs.makeDir( sDir )
        end

        local file = fs.open( sDir .. sLocalFile , "w" )
        file.write( script )
        file.close()
        print("script updated")
    end
end
function menu(oScripts)
    --indicates the currently selected script in the menu
    n = 1
	while true do
		term.clear()
		term.setCursorPos(1,1)
		if term.isColor() == true then
			term.setTextColor(colors.cyan)
			term.write("###################################################")
			term.setCursorPos(1,2)
			term.write("#         ")
			term.setTextColor(colors.blue)
			term.write("THUNDERGROOVE's  Script updater")
			term.setTextColor(colors.cyan)
			term.write("         #")
			term.setCursorPos(1,3)
			term.setTextColor(colors.cyan)
			term.write("###################################################")
		else
			print("#######################################")
			print("#   THUNDERGROOVE's  Script updater #")
			print("#######################################")
        end

        local l = #oScripts
        -- Get longest key
		local longestLen = 0
		for i=1, l do
            local len = #oScripts[i].name;
			if len > longestLen then longestLen = len end
		end
		for i=1, l do
			if i == n then
                local script = oScripts[i]
                local name = script.name
				local spaceCount = #name - longestLen
				if spaceCount < 0 then spaceCount = -(spaceCount) end
				local printStr = i .. " [ " .. name
				for k = 1,spaceCount do
                    printStr = printStr.." "
				end
				printStr = printStr.." ]"
				oldX, oldY = term.getCursorPos()
				term.setTextColor(colors.cyan)
				term.setCursorPos(1, 17)
				print(wrap(script.desc,45,"",""))
				term.setCursorPos(oldX,oldY)
				term.setTextColor(colors.blue)
			else
				printStr = i .. "   " .. script.desc
			end
			if term.isColor() == true then term.setTextColor(colors.lightBlue) end
			print( printStr )
		end
		if term.isColor() == true then term.setTextColor(colors.yellow) end
		print("Select script to update.")
		-- print("LongestStr:"..LongestStr)
		-- print("longestLen:"..spaceCount)
		a, b= os.pullEventRaw()
		if a == "key" then
			if b==200 and n>1 then n=n-1 end
			if b==208 and n<l then n=n+1 end
			if b==28 then break end
		end
	end
	term.clear() term.setCursorPos(1,1)
	return n
end
--todo: prompt for data if git.config doesn't exist
--load config data for git, should bind a table named 'git' to global with .baseUrl and .accessToken
-- accessToken needs to be a valid oAuth token from git
shell.run("/data/update/git.config")

print("Grabbing list of scripts...")
updateScript( { file="scripts.data" , dir="/data/update/" } )
 
shell.run("/data/update/scripts.data")

local scripts = static.scripts
option = menu( scripts )
if option == #scripts then
	error("invalid selection")
else
	updateScript( scripts[ n ] )
end