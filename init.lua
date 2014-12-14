-- Fails mod By Mg <mg[dot]minetest[at]gmail[dot]com>
--[[
  
     /-----\-\
    /  /--] \-\
    |  |-]  |-|
    \  |    /-/
     \-----/-/

    "Congratulation, you won a failpoint."

]]--

-- The FailPoint mod by Mg.
-- The principal purpose of this mod is to allow FailPnts give, and the storage of them

fp_file = minetest.get_worldpath().."/failpoints"
failpoints = {}
fp_version = 0.0 -- It looks like a face, you see?

-- fp_create priv to create failpoints
minetest.register_privilege("fp_create","Is able to create FailPoints and give them to anybody else")

-- Loading failpoints
pntf = io.open(fp_file,"r")
if pntf == nil then
    pntf = io.open(fp_file,"w")
else
	repeat
		local line = pntf:read()
		if line == nil or line == "" then break end
		print(line)
		failpoints[line:split(" ")[1]] = line:split(" ")[2]+0
	until 1 == 0 -- Ok, not the best way to create a loop..
end
minetest.log("action","[FailPoints] Loaded")

-- Global callbacks
minetest.register_on_shutdown(function() 
    -- Saving failpoints
    pntf = io.open(fp_file,"w")
    for i,v in pairs(failpoints) do
		if v ~= 0 then
			pntf:write(i.." "..v.."\n")
		end
	end
end)

minetest.register_chatcommand("fail", {
	params = "<subcommand> <subcommandparam> | <playername>",
	description = "Fail command",
	privs = {shout = true},
	func = function(name, parameters)
		paramlist = parameters:split(" ")
		param = paramlist[1]
		param2 = paramlist[2]
		if param == "version" then
			core.chat_send_player(name,"-FP- Fail mod version: "..fp_version)
			return true
		elseif param == "help" then
			core.chat_send_player(name,"Failpoints available help :")
			core.chat_send_player(name,"/fail <subcommand> | <playername>")
			core.chat_send_player(name,"Available subcommands :")
			core.chat_send_player(name,"  - help : show this help")
			core.chat_send_player(name,"  - version : show actual fail version")
			core.chat_send_player(name,"  - view | view <playername> : View player's failpoints amount") 
			return
		elseif param == "view" then
			if param2 == "" or param2 == nil then
				core.chat_send_player(name,"-FP- You own "..failpoints[name].." FailPoints.")
				return true
			end
			
			if failpoints[param2] ~= nil and failpoints[param2] > 0 then
				core.chat_send_player(name,"-FP- Player "..param2.." owns "..failpoints[param2].." FailPoints.")
			else
				core.chat_send_player(name,"-FP- Player "..param2.." doesn't seem to own any FailPoint.")
			end
		else
		
			-- If not any known command
			if name == param then
				if minetest.get_player_privs(name)["fp_create"] == true then
					minetest.log("error",name.." tried to create failpoint by giving to himself")
					core.chat_send_player(name,"-FP- Congratulation, you failed. Don't try to give to yourself :p")
				else
					minetest.log("action",name.."gave himself a FailPoint")
					core.chat_send_player(name,"-FP- You failed: It appears the name you entered is yours")
					core.chat_send_player(name,"Don't try to give yourself failpoints, it's useless :p")
				end
				return false
			end
		
			if param == "" then
				minetest.chat_send_player(name,"-FP- You failed: Not enough parameters given, type /fail help for help")
				return false
			end

			if not minetest.get_player_by_name(param) then
				core.chat_send_player(name,"-FP- You failed: Sorry, "..param.." isn't online.")
				return false
			end
		
			-- Take, or not, failpoints to name's account to give them to param
			if minetest.get_player_privs(name)["fp_create"] ~= true then
				if failpoints[name] == nil or failpoints[name] == 0 then
					core.chat_send_player(name,"You failed: You don't have enough failpoints..")
					return false
				elseif failpoints[name] > 0 then
					failpoints[name] = failpoints[name] -1
				end
			else
				minetest.log("action","[FailPoints] "..name.." has created a FailPoint.")
			end
		
			-- Give/Add the failpoint to param' account
			if failpoints[param] == nil then
				failpoints[param] = 1
			else
				failpoints[param] = failpoints[param]+1
			end
		
			minetest.log("action","[FailPoints] "..name.." has given a failpoint to "..param)
			minetest.log("action","[FailPoints] "..param.." now own "..failpoints[param].."FPs")
			minetest.log("action","[FailPoints] "..name.." now own "..(failpoints[name] or 0).."FPs")
			core.chat_send_player(param,"Congratulations "..param..", you won a failpoint.")
			core.chat_send_player(name,"FP sent.")
		end
	end
})