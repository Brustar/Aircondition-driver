require "Udp"
require "Pack"
AIR = {}

AIR["ON"] = "31 01"
AIR["OFF"] = "31 02"

AIR["QUERY_ALL"] = "01 50 FF FF FF FF 52"
AIR["QUERY"] = "50 01"
AIR["SETEMP"] = "32"
AIR["HEAT"] = "33 08"
AIR["COOL"] = "33 01"

AIR["DRY"] = "33 02"
AIR["FAN"] = "33 04"

AIR["HIGH"] = "34 01"
AIR["MIDDLE"] = "34 02"
AIR["LOW"] = "34 04"

AIR["AWAY"] = "01 31 02 FF FF FF 31"

SERVER = nil
EX_CMD = {}
function OnDriverInit()
    Udp:create().client()
    SERVER = tcpServer()
end

function dbg(strDebugText)
  if (gDbgPrint) then print(strDebugText) end
  if (gDbgLog) then C4:ErrorLog("kohler_RainPanel: " .. strDebugText) end
end


function dbgStatus(strStatus)
  dbg("-----> Status: " .. strStatus)
  C4:UpdateProperty("Status", strStatus)
end

function airControl(cmd)
    local pkt = tohex(cmd)
    SendToAir(pkt)
end

function SendToAir(data, norepeat)
  norepeat = norepeat or false
  gQueue = gQueue or {}
  local dupfound = false

  if (norepeat) then
    -- Check queue for duplicate data... Used for repeat commands, to ensure not more than one get queued up...
    for k,v in pairs(gQueue) do if (v == data) then dupfound = true end end
  end
  if (dupfound == false) then
    table.insert(gQueue, data)
  end
  ProcessQueue()
end

function ProcessQueue()
  gSendTimer = gSendTimer or 0
  if (gSendTimer == 0) then
    local pkt = table.remove(gQueue, 1)
    if (pkt ~= nil) then
      --gSendTimer = C4:AddTimer(3000, "MILLISECONDS")
      hexdump(pkt, function(s) dbg("------> " .. s) end)
      -- Track Enquiry going out...
      if (string.byte(string.sub(pkt, 1, 1)) == 0x83) then
        gLastEnquiry = string.byte(string.sub(pkt, 3, 3))  -- Track Enquiries...
      end
	 if (Properties["Connect Category"] == "TCP") then
	   SERVER:sendAll(pkt)
	 else
	   C4:SendToSerial(1, pkt)
	 end
    end
  end
end

function hexArray(data)
    local ret = {}
    for i=1 , string.len(data) do
	   local bitfield = string.byte(string.sub(data, i, i))
	   ret[i] = bit.band(bitfield, 0xFF)
    end
    return ret
end

function checksum(strPkt)
  local cs = 0
  string.gsub(strPkt, "(.)", function(c) cs = cs + string.byte(c) end)
  return bit.band(cs, 0xff)
end

function createCMD(cmd,value)
    local ret = Properties["Gateway"]
    if value == nil then
	   ret = ret .. " " .. cmd
    else
	   ret = ret .. " " .. cmd .. " " .. value
    end
    
    ret = ret .. " 01 " .. Properties["Addr"]
    local sum = checksum(tohex(ret))
    local cs = string.sub(string.format("%#x",sum),3)
    ret = ret .. " " .. cs
    
    return ret
end

function setTempture(value)
    return createCMD(AIR["SETEMP"],value)
end

function heatMode()
    return createCMD(AIR["HEAT"])
end

function coolMode()
    return createCMD(AIR["COOL"])
end

function dryMode()
    return createCMD(AIR["DRY"])
end

function fanMode()
    return createCMD(AIR["FAN"])
end

function highMode()
    return createCMD(AIR["HIGH"])
end

function middleMode()
    return createCMD(AIR["MIDDLE"])
end

function lowMode()
    return createCMD(AIR["LOW"])
end

function query()
    return createCMD(AIR["QUERY"])
end

function poweron()
    return createCMD(AIR["ON"])
end

function poweroff()
    return createCMD(AIR["OFF"])
end

function ExecuteCommand(sCommand, tParams)

	-- Remove any spaces (trim the command)
	local trimmedCommand = string.gsub(sCommand, " ", "")

	-- if function exists then execute (non-stripped)
	if (EX_CMD[sCommand] ~= nil and type(EX_CMD[sCommand]) == "function") then
		EX_CMD[sCommand](tParams)
	-- elseif trimmed function exists then execute
	elseif (EX_CMD[trimmedCommand] ~= nil and type(EX_CMD[trimmedCommand]) == "function") then
		EX_CMD[trimmedCommand](tParams)
	-- handle the command
	elseif (sCommand ~= nil) then
		QueueCommand(sCommand)
	else
		Dbg:Alert("ExecuteCommand: Unhandled command = " .. sCommand)
	end
end

function QueueCommand(strCommand)
    local cmd = ""
    if (strCommand == "AWAY") then
	   cmd = AIR["AWAY"]
    end
    if strCommand == "ON" then
	   C4:SetVariable("IS_ON", "1", "BOOL")
	   cmd = poweron()
    end
    
    if strCommand == "OFF" then
	   C4:SetVariable("IS_ON", "0", "BOOL")
	   cmd = poweroff()
    end
    
    if strCommand == "COOL" then
	   cmd = coolMode()
    end
    
    if strCommand == "HEAT" then
	   cmd = heatMode()
    end
    
    if strCommand == "DRY" then
	   cmd = dryMode()
    end
    
    if strCommand == "FAN" then
	   cmd = fanMode()
    end
    
    if strCommand == "HIGH" then
	   cmd = highMode()
    end
    
    if strCommand == "MIDDLE" then
	   cmd = middleMode()
    end
    
    if strCommand == "LOW" then
	   cmd = lowMode()
    end
	   
    if strCommand == "D18" then
	   C4:SetVariable("CURRENT_TEMPRETURE", tostring(18))
	   cmd = setTempture("12")
    end
	   
    if strCommand == "D22" then
	   C4:SetVariable("CURRENT_TEMPRETURE", tostring(22))
	   cmd = setTempture("16")
    end
	   
    if strCommand == "D26" then
	   C4:SetVariable("CURRENT_TEMPRETURE", tostring(26))
	   cmd = setTempture("1A")
    end
    
    if strCommand == "D30" then
	   C4:SetVariable("CURRENT_TEMPRETURE", tostring(30))
	   cmd = setTempture("1E")
    end
    
    if strCommand == "QUERY" then
	   cmd = query()
    end
    
    airControl(cmd)
end

function EX_CMD.LUA_ACTION(tParams)
    local action = tParams["ACTION"]
    if action == "away" then
	   cmd = AIR["AWAY"]
    end
    
    if action == "on" then
	   C4:SetVariable("IS_ON", "1", "BOOL")
	   cmd = poweron()
    end

    if action == "off" then
	   C4:SetVariable("IS_ON", "0", "BOOL")
	   cmd = poweroff()
    end

    if action == "cool" then
	   cmd = coolMode()
    end

    if action == "heat" then
	   cmd = heatMode()
    end

    if action == "dry" then
	   cmd = dryMode()
    end

    if action == "fan" then
	   cmd = fanMode()
    end

    if action == "high" then
	   cmd = highMode()
    end

    if action == "middle" then
	   cmd = middleMode()
    end

    if action == "low" then
	   cmd = lowMode()
    end
    
    if action == "degree18" then
	   C4:SetVariable("CURRENT_TEMPRETURE", tostring(18))
	   cmd = setTempture("12")
    end
    
    if action == "degree22" then
	   C4:SetVariable("CURRENT_TEMPRETURE", tostring(22))
	   cmd = setTempture("16")
    end
    
    if action == "degree26" then
	   C4:SetVariable("CURRENT_TEMPRETURE", tostring(26))
	   cmd = setTempture("1A")
    end

    if action == "degree30" then
	   C4:SetVariable("CURRENT_TEMPRETURE", tostring(30))
	   cmd = setTempture("1E")
    end

    if action == "query" then
	   cmd = query()
    end
    
    if action == "Connect" then
	   Udp:create().client()
	   SERVER = tcpServer()
    end
    
    if action == "Disconnect" then
	   Udp:create().disconnect()
    end
    local pack = Pack:create()
    if action == "K1" then
	   cmd = pack.lightonHex(1)
	   C4:SetVariable("Key_ID", 1)
	   C4:FireEvent("key event")
    end
    
    if action == "K2" then
	   cmd = pack.lightonHex(2)
	   C4:SetVariable("Key_ID", 2)
	   C4:FireEvent("key event")
    end
    
    if action == "K3" then
	   cmd = pack.lightonHex(3)
	   C4:SetVariable("Key_ID", 3)
	   C4:FireEvent("key event")
    end
    
    if action == "K4" then
	   cmd = pack.lightonHex(4)
	   C4:SetVariable("Key_ID", 4)
	   C4:FireEvent("key event")
    end

    airControl(cmd)
end

function ReceivedFromSerial(idBinding, strData)
    hexdump(strData, function(s) dbg("<------ " .. s) end)
    local bits = hexArray(strData)

    if bits[1] == 0x01 and bits[2] == 0x50 and bits[2] == 0x01 then
	   C4:SetVariable("CURRENT_TEMPRETURE", tostring(bit[10]), "NUMBER")
	   C4:SetVariable("IS_ON", tostring(bit[6]), "BOOL")
	   C4:SetVariable("CURRENT_FAULT", tostring(bit[11]), "NUMBER")
    end
end

function OnPropertyChanged(strProperty)
  local prop = Properties[strProperty]
  if (strProperty == "Debug Mode") then
    if (gDbgTimer > 0) then gDbgTimer = C4:KillTimer(gDbgTimer) end
    gDbgPrint, gDbgLog = (prop:find("Print") ~= nil), (prop:find("Log") ~= nil)
    if (prop == "Off") then
      return
    end
    gDbgTimer = C4:AddTimer(240, "MINUTES")
    return
  end

  -- Save Properties that have changed...
  C4:InvalidateState()
end

function OnConnectionStatusChanged(idBinding, nPort, strStatus)
    if (nPort == UDP_PORT) then
	   Udp:create().OnConnectionStatusChanged(idBinding, nPort, strStatus)
    end
end

EX_CMD["TEMPTURE"] = function(tParams)
    local degree = tParams["degree"]
    local command = setTempture(degree)
    airControl(command)
end

--Init
gDbgTimer, gDbgPrint, gDbgLog = 0, false, false
gQueue,gSendTimer = {},0
OnPropertyChanged("Debug Mode")
C4:AddVariable("CURRENT_TEMPRETURE", "0", "NUMBER")
C4:AddVariable("IS_ON", "1", "BOOL")
C4:AddVariable("CURRENT_FAULT", "0", "NUMBER")
C4:AddVariable("CONTROL_CMD", "0", "NUMBER")

C4:AddVariable("KEY_ID", "0", "NUMBER")