-------------------------------------------------
--
-- logger.lua
--
-- Creates a logging class 
--
-------------------------------------------------
if devilsquid == nil then
	devilsquid = {}
	if devilsquid.requirepath == nil then devilsquid.requirepath = "devilsquid." end
	if devilsquid.filepath == nil then devilsquid.filepath = "devilsquid/" end
end

local json 		= require( "json" )
local network 	= require( "network" )
local Helper    = require( devilsquid.requirepath .. "util.helper" )


local Logger = {}

Logger.showPrefix 		= false
Logger.showSuffix 		= false
Logger.showLogLevel 	= true
Logger.showChannelName 	= true
Logger.showToDo 		= true 		-- if TODO logs should be printed
Logger.showLogs 		= true 		-- set to true if no log should be printed anymore

Logger.LEVELS = {}

Logger.LEVELS.DUMP      = 5
Logger.LEVELS.DEBUG     = 4
Logger.LEVELS.LOG       = 3
Logger.LEVELS.WARNING   = 2
Logger.LEVELS.ERROR     = 1
Logger.LEVELS.TODO      = 0
Logger.LEVELS.OFF       = -1

Logger.channelSettings 	= {}

Logger.logglySetting 			= Logger.LEVELS.OFF
Logger.logglySendFromSimulator 	= false
Logger.logglySendRuntimeErrors 	= false

Logger.prefix = "-------------------------------------------------------------------\n"
Logger.suffix = "\n-------------------------------------------------------------------"

-----------------------------------------------------------------------------
-- print_r ( t )
-- prints the content of a table t
-----------------------------------------------------------------------------
local function printf_r ( t ) 
	local result = ""

	local print_r_cache={}
	local function sub_printf_r(t,indent)
		if (print_r_cache[tostring(t)]) then
			result = result .. indent.."*"..tostring(t)
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") then
						result = result .. indent.."["..pos.."] => "..tostring(t).." {"
						sub_printf_r(val,indent..string.rep(" ",string.len(pos)+8))
						result = result .. indent..string.rep(" ",string.len(pos)+6).."}"
					elseif (type(val)=="string") then
						result = result .. indent.."["..pos..'] => "'..val..'"'
					else
						result = result .. indent.."["..pos.."] => "..tostring(val)
					end
				end
			else
				result = result .. indent..tostring(t)
			end
		end
	end

	if (type(t)=="table") then
		result = result .. tostring(t).." \n{"
		sub_printf_r(t,"\n  ")
		result = result .. "\n}\n"
	else
		sub_printf_r(t,"\n  ")
	end

	return result
end





local function printLog( prefix, logLevel, channelName, txt, suffix )
	local result = {}

	if Logger.showPrefix == true then result[#result+1] = prefix end
	if Logger.showLogLevel == true then result[#result+1] = logLevel end
	if Logger.showChannelName == true and channelName ~= nil and channelName ~= "" then result[#result+1] = "[" .. channelName .. "]" end
	result[#result+1] = tostring(txt)
	if Logger.showSuffix == true then result[#result+1] = suffix end


	-- print the logs
	if #result == 5 then

		print(result[1] .. " " .. result[2] .. " " .. result[3] .. " " .. result[4] .. " " .. result[5])

	elseif #result == 4 then

		print(result[1] .. " " .. result[2] .. " " .. result[3] .. " " .. result[4])

	elseif #result == 3 then

		print(result[1] .. " " .. result[2] .. " " .. result[3])

	elseif #result == 2 then

		print(result[1] .. " " .. result[2])

	elseif #result == 1 then

		print(result[1])

	end
end



local function createLogText(start, arguments)
	local result = ""

	-- iterate the arguments
	for i=start,#arguments do
		if type(arguments[i]) ~= "table" then
			result = result .. tostring( arguments[i] ) .. " "
		else
			result = result .. "\n" .. printf_r( arguments[i] ) .. "\n"
		end
	end

	return result
end


-----------------------------------------------------------------------------
-- Logger:log( "channel", ... )
-----------------------------------------------------------------------------
function Logger.log(...)
	if Logger.showLogs == false then return end

	local start 		= 1 	
	local txt 			= ""
	local channelName 	= ""
	local logLevel 		= "LOG:" 
	local prefix 		= Logger.prefix
	local suffix 		= Logger.suffix

	-- if more than one argument first argument is the channel name
	if #arg > 1 then
		start = 2
		channelName = arg[1]
		if Logger.channelSettings[channelName] and Logger.channelSettings[channelName] < Logger.LEVELS.LOG then
			return
		end
	end
	
	txt = createLogText(start, arg)

	printLog( prefix, logLevel, channelName, txt, suffix )

	-- check loggly log level
	if Logger.logglySetting < Logger.LEVELS.LOG then return end

	local logEvent = {logLevel=logLevel, name=channelName, message=txt}
	Logger.logglyLog(logEvent)
end


-----------------------------------------------------------------------------
-- Logger:log2( "channel", ... )
-- adds a blank line bfero log output. can be used to start a new block of logging
-----------------------------------------------------------------------------
function Logger.log2(...)
	if Logger.showLogs == false then return end

	local start 		= 1 	
	local txt 			= ""
	local channelName 	= ""
	local logLevel 		= "LOG:" 
	local prefix 		= Logger.prefix
	local suffix 		= Logger.suffix

	-- if more than one argument first argument is the channel name
	if #arg > 1 then
		start = 2
		channelName = arg[1]
		if Logger.channelSettings[channelName] and Logger.channelSettings[channelName] < Logger.LEVELS.LOG then
			return
		end
	end
	
	txt = createLogText(start, arg)

	print("")
	printLog( prefix, logLevel, channelName, txt, suffix )

	-- check loggly log level
	if Logger.logglySetting < Logger.LEVELS.LOG then return end

	local logEvent = {logLevel=logLevel, name=channelName, message=txt}
	Logger.logglyLog(logEvent)
end


-----------------------------------------------------------------------------
-- Logger:dump( "channel", ... )
-----------------------------------------------------------------------------
function Logger.dump( ... )
	local start 		= 1 	
	local txt 			= ""
	local channelName 	= ""
	local logLevel 		= "DUMP:" 
	local prefix 		= Logger.prefix
	local suffix 		= Logger.suffix

	-- if more than one argument first argument is the channel name
	if #arg > 1 then
		start = 2
		channelName = arg[1]
		if Logger.channelSettings[channelName] and Logger.channelSettings[channelName] < Logger.LEVELS.DUMP then
			return
		end
	end
	
	txt = createLogText(start, arg)

	printLog( prefix, logLevel, channelName, txt, suffix )

	-- check loggly log level
	if Logger.logglySetting < Logger.LEVELS.DUMP then return end

	local logEvent = {logLevel=logLevel, name=channelName, message=txt}
	Logger.logglyLog(logEvent)
end


-----------------------------------------------------------------------------
-- Logger:debug( "channel", ... )
-----------------------------------------------------------------------------
function Logger.debug( ... )
	if Logger.showLogs == false then return end

	local start 		= 1 	
	local txt 			= ""
	local channelName 	= ""
	local logLevel 		= "DEBUG:" 
	local prefix 		= Logger.prefix
	local suffix 		= Logger.suffix

	-- if more than one argument first argument is the channel name
	if #arg > 1 then
		start = 2
		channelName = arg[1]
		if Logger.channelSettings[channelName] and Logger.channelSettings[channelName] < Logger.LEVELS.DEBUG then
			return
		end
	end
	
	txt = createLogText(start, arg)

	printLog( prefix, logLevel, channelName, txt, suffix )


	-- check loggly log level
	if Logger.logglySetting < Logger.LEVELS.DEBUG then return end

	local logEvent = {logLevel=logLevel, name=channelName, message=txt}
	Logger.logglyLog(logEvent)
end


-----------------------------------------------------------------------------
-- Logger:warning( "channel", ... )
-----------------------------------------------------------------------------
function Logger.warning( ... )
	if Logger.showLogs == false then return end

	local start 		= 1 	
	local txt 			= ""
	local channelName 	= ""
	local logLevel 		= "WARNING:" 
	local prefix 		= Logger.prefix
	local suffix 		= Logger.suffix

	-- if more than one argument first argument is the channel name
	if #arg > 1 then
		start = 2
		channelName = arg[1]
		if Logger.channelSettings[channelName] and Logger.channelSettings[channelName] < Logger.LEVELS.WARNING then
			return
		end
	end
	
	txt = createLogText(start, arg)

	print("")
	print("------------------------------------------------------------------------")
	printLog( prefix, logLevel, channelName, txt, suffix )
	print("------------------------------------------------------------------------")


	-- check loggly log level
	if Logger.logglySetting < Logger.LEVELS.WARNING then return end

	local logEvent = {logLevel=logLevel, name=channelName, message=txt}
	Logger.logglyLog(logEvent)
end


-----------------------------------------------------------------------------
-- Logger:error( "channel", ... )
-----------------------------------------------------------------------------
function Logger.error( ... )
	if Logger.showLogs == false then return end

	local start 		= 1 	
	local txt 			= ""
	local channelName 	= ""
	local logLevel 		= "ERROR:" 
	local prefix 		= Logger.prefix
	local suffix 		= Logger.suffix

	-- if more than one argument first argument is the channel name
	if #arg > 1 then
		start = 2
		channelName = arg[1]
		if Logger.channelSettings[channelName] and Logger.channelSettings[channelName] < Logger.LEVELS.ERROR then
			return
		end
	end
	
	txt = createLogText(start, arg)

	print("")
	print("########################################################################")
	printLog( prefix, logLevel, channelName, txt, suffix )
	print("########################################################################")

	-- check loggly log level
	if Logger.logglySetting < Logger.LEVELS.ERROR then return end

	local logEvent = {logLevel=logLevel, name=channelName, message=txt}
	Logger.logglyLog(logEvent)
end


-----------------------------------------------------------------------------
-- Logger:todo( "channel", ... )
-----------------------------------------------------------------------------
function Logger.todo( ... )
	if Logger.showLogs == false then return end

	local start 		= 1 	
	local txt 			= ""
	local channelName 	= ""
	local logLevel 		= "TODO:" 
	local prefix 		= Logger.prefix
	local suffix 		= Logger.suffix

	-- if more than one argument first argument is the channel name
	if #arg > 1 then
		start = 2
		channelName = arg[1]
		if Logger.channelSettings[channelName] and Logger.channelSettings[channelName] < Logger.LEVELS.TODO then
			return
		end
	end
	
	txt = createLogText(start, arg)

	if Logger.showToDo == true then
		print("")
		print("TODO: ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~")
		printLog( prefix, logLevel, channelName, txt, suffix )
		print("TODO: ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~")
	end
end


-----------------------------------------------------------------------------
-- Get the current log level for a channel
--
function Logger.getLogLevel( channelName )
	return Logger.channelSettings[channelName]
end


-----------------------------------------------------------------------------
-- Sets the current log level for a channel
--
function Logger.setLogLevel( logLevel, channelName )
	Logger.channelSettings[channelName] = logLevel
end
 



-- -----------------------------------------------------------------------------------------------
-- LOGGLY IMPLEMENTATION
-- -----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Network Listener to Handle replies from Loggly
--
local function logglyNetworkListener( event )
     if ( event.isError ) then
         print( "Response from loggly.com: Network error!" )
     else
     	local response = json.decode( event.response )
     	if response and response.response then
	     	if response.response:lower() ~= "ok" then
	        	print ( "Loggly.com RESPONSE: " .. event.response, 4)
	        end
	    end
     end
end


-----------------------------------------------------------------------------
-- Set the logLevel for all Loggly calls
-- i.e. if the leglevel is set to Logger.LEVELS.WARN the only events like WARN, and ERROR is sent to Loggly
-- @param newLevel  			The log level to use for Loggly
-- @param sendFromSimulator 	If set to false then no Loggly calls are made if playing from simulator (default = false)
-- @param sendFromSimulator 	If set to false then no Loggly calls are made if playing from simulator (default = true)
--
function Logger.setLogglyLevel( newLevel, sendFromSimulator, sendRuntimeErrors )
	Logger.logglySetting = newLevel
	Logger.logglySendFromSimulator = sendFromSimulator or false

	if sendRuntimeErrors == nil then 
		Logger.logglySendRuntimeErrors = true
	else
		Logger.logglySendRuntimeErrors = sendRuntimeErrors
	end

	print("Logger.logglySetting " .. tostring(Logger.logglySetting))
	print("Logger.logglySendFromSimulator " .. tostring(Logger.logglySendFromSimulator))
	print("Logger.logglySendRuntimeErrors " .. tostring(Logger.logglySendRuntimeErrors))
end


-----------------------------------------------------------------------------
-- Settings for the Loggly calls Loggly
-- @param token  				The customer token you get from Loggly
-- @param tag 					A url compatible tag string you can use to identify this app in you Loggly backend
--
function Logger.setLogglyToken( token, tag )
	tagText = ""
	if tag then
		tagText = "/tag/" .. tag .. "/"
	end

	Logger.logglyRestEndpoint = {}
	Logger.logglyRestEndpoint.Single = "http://logs-01.loggly.com/inputs/" .. token .. tagText

	Logger.deviceMetaData = {}
	if system.getInfo("environment") == "device" then
	    Logger.deviceMetaData.gameName 		= system.getInfo("appName")
	    Logger.deviceMetaData.gameVersion 	= system.getInfo("appVersionString")
	    Logger.deviceMetaData.deviceOS 		= system.getInfo("model")
	   	Logger.deviceMetaData.platform 		= system.getInfo("platform")

	elseif system.getInfo("environment") == "simulator" then
	    Logger.deviceMetaData.deviceOS 		= "Simulator"
	end


end


-----------------------------------------------------------------------------
-- The call to the Loggly backend
-- @param logEvent 	The table with datat to send to the Loggly server
--
function Logger.logglyLog( logEvent )
	if Logger.logglyRestEndpoint == nil then return end

	if Logger.logglySetting == Logger.LEVELS.OFF then return end

	if system.getInfo("environment") == "simulator" and Logger.logglySendFromSimulator == false then return end


    --check if log event is contained in a table, if not exit function and send warning message to the console
    if not type(logEvent) == "table" then
        print("log event input is not in a lua table, event not sent, all log event input must be contained in a lua table")
        return
    end

    --Add a field "deviceMetaData" and store device meta data as shown above
    logEvent.deviceMetaData = Logger.deviceMetaData

    --Send message. First create message table (for headers, body, etc.), then within the
    --body, encode log event passed into JSON and then send message with network.request
    local message = {}
    message.body = json.encode(logEvent)
    Helper:print_r(message)

    -- do the call to loggly API
    network.request(Logger.logglyRestEndpoint.Single, "POST", logglyNetworkListener, message)
 end


-----------------------------------------------------------------------------
-- Function for logging stack traces from application crashes, used by subscribing this function to
-- runtime event "unhandledError" via Runtime:addEventListener("unhandledError", loggingController.stackErrorHandler)
-- recommended to subscribe this event to "unhandledError" event in your main.lua file
function Logger.stackErrorHandler( event )
    print("stackErroHandlerCalled event.errormesage is" .. event.errorMessage)

    if Logger.logglySendRuntimeErrors == true and Logger.logglySendFromSimulator == true then
	    --Store error in a lua table
	    local fatalError = {logLevel="RUNTIME ERROR", name="Runtime Error", errorMessage = tostring(event.errorMessage), stackTrace = tostring(event.stackTrace) }

	    --Send logging event with the function developed above
	    Logger.logglyLog(fatalError)
	end
end



return Logger