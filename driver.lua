
gCurrentMode = ""

COOL_CMD_BUF = {}

HEAT_CMD_BUF = {}

OFF_CMD_BUF = {}

function OnPropertyChanged(strProperty) 
    prop = Properties[strProperty]
    if(strProperty == "Debug Mode") then
	   if(prop == "true") then
		  C4:AllowExecute(true)
	   else
	      C4:AllowExecute(false)
	   end
    elseif(strProperty == "SCALE") then 
	   C4:SendToProxy(5001,"SCALE_CHANGED",{SCALE = prop},"NOTIFY")
    else
	   COOL_CMD_BUF = {[28] = Properties["Cool 28"],[27] = Properties["Cool 27"],[26] = Properties["Cool 26"],[25] = Properties["Cool 25"],[24] = Properties["Cool 24"],[23] = Properties["Cool 23"],[22] = Properties["Cool 22"],[21] = Properties["Cool 21"],[20] = Properties["Cool 20"]}

	   HEAT_CMD_BUF = {[30] = Properties["Heat 30"],[29] = Properties["Heat 29"],[28] = Properties["Heat 28"],[27] = Properties["Heat 27"],[26] = Properties["Heat 26"],[25] = Properties["Heat 25"]}

	   OFF_CMD_BUF = {["OFF"] = Properties["OFF"]}
    end
end


function ReceivedFromProxy(idBinding, strCommand, tParams) 
    print("Recived From Proxy : " .. "idBinding is : " .. idBinding .. "strCommand is: " .. strCommand)
    if(tParams ~= nil) then
	   for k,v in pairs(tParams) do 
		  print(k,v)
	   end
    end
    
    if(idBinding == 5001) then
	   if(strCommand == "SET_SCALE") then
		  C4:SendToProxy(idBinding,"SCALE_CHANGED",{SCALE = tParams.SCALE},"NOTIFY")
	   elseif(strCommand == "SET_MODE_HVAC") then
	   		if(tParams.MODE == "Cool") then
	   			gCurrentMode = "Cool"
	   			C4:SendToProxy(1,"command",{data = COOL_CMD_BUF[26]})
	   			--print(COOL_CMD_BUF[26])
	   		elseif(tParams.MODE == "Heat") then
	   			gCurrentMode = "Heat"
	   			C4:SendToProxy(1,"command",{data = HEAT_CMD_BUF[30]})
	   		elseif(tParams.MODE == "Off") then
	   			gCurrentMode = "Off"
	   			C4:SendToProxy(1,"command",{data = OFF_CMD_BUF["OFF"]})
	   		end
	   		C4:SendToProxy(idBinding,"HVAC_MODE_CHANGED",{MODE = tParams.MODE},"NOTIFY")
	   		C4:SendToProxy(idBinding,"HVAC_STATE_CHANGED",{STATE = tParams.MODE},"NOTIFY")
	   elseif(strCommand == "SET_SETPOINT_SINGLE") then
	   		if(gCurrentMode == "Cool") then
	   			C4:SendToProxy(1,"command",{data = COOL_CMD_BUF[tonumber(tParams.CELSIUS)]})
	   		elseif(gCurrentMode == "Heat") then
	   			C4:SendToProxy(1,"command",{data = HEAT_CMD_BUF[tonumber(tParams.CELSIUS)]})
	   		end
	   		C4:SendToProxy(idBinding,"TEMPERATURE_CHANGED",{TEMPERATURE = tonumber(tParams.CELSIUS),SCALE = "CELSIUS"},"NOTIFY")
	   end
    end
end
C4:UpdateProperty("SCALE", "C")
C4:UpdateProperty("Driver Version", "1.01")