-- Script updater by THUNDERGROOVE
 
args = {...}
 
local updateAll = false
 
if args[1] == "--all" then
        updateAll = true
end

local baseLink = "https://dl.dropboxusercontent.com/u/your dropbox stuff here"
 
if not http then print("HTTP is not enabled") os.shutdown() end
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
function updateScript(n)
        if n == "Exit" then
                print("")
        else
                print(s[n])
                local response = http.get(baseLink..s[n])
 
                if response then
                        print("Huzzaaa we got the script")
                else
                        print("You broke it.... shutting down")
                        os.shutdown()
                end
 
                local script = response.readAll()
                response.close()
 
                local file = fs.open(s[n], "w")
                file.write(script)
                file.close()
                print("script updated")
        end
end
function menu(m)
        n=1
        l=#m
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
                -- Get longest key
                local longestLen = 0
                for i=1, l do
                        if #m[i] > longestLen then longestLen = #m[i] end
                end
                for i=1, l do
                        if i==n then
                                spaceCount = #m[i] - longestLen
                                if spaceCount < 0 then spaceCount = -(spaceCount) end
                                printStr = i.." [ "..m[i]
                                for k = 1,spaceCount do
                                        printStr = printStr.." "
                                end
                                printStr = printStr.." ]"
                                oldX, oldY = term.getCursorPos()
                                term.setTextColor(colors.cyan)
                                term.setCursorPos(1, 17)
                                print(wrap(d[i],45,"",""))
                                term.setCursorPos(oldX,oldY)
                                term.setTextColor(colors.blue)
                        else
                                printStr = i.."   "..m[i]
                        end
                        if term.isColor() == true then term.setTextColor(colors.lightBlue) end
                       
                        print(printStr)
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
 
 
print("Grabbing list of scripts...")
local response = http.get(baseLink.."scripts")
 
if response then
        print("Huzzaaa we got the scripts list")
else
        print("You broke it.... shutting down")
        os.shutdown()
end
 
local scripts = response.readAll()
response.close()
 
local file = fs.open("scripts", "w")
file.write(scripts)
file.close()
 
shell.run("scripts")
 
option = menu(n)
if option == #s then
        error()
else
        updateScript(option)
end