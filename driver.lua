require "Udp"
require "Pack"
require "Aircondition"
require "Freshair"


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
    print("cmd:",cmd)
    if cmd == nil then return end
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
      hexdump(pkt, function(s) print("------> " .. s) end)
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
		QueueCommand(sCommand,tParams)
	else
		Dbg:Alert("ExecuteCommand: Unhandled command = " .. sCommand)
	end
end

EX_CMD["TEMPTURE"] = function(tParams)
    local degree = tParams["degree"]
    local addr = Properties["Addr"]
    if(tParams and tParams["addr"]) then
	    addr = string.format("%04x",tonumber(tParams["addr"]))
    end
    local air = Aircondition:create(addr)
    local command = air["SETEMP"](air,degree)
    airControl(command)
end

function QueueCommand(strCommand,tParams)
    local addr = Properties["Addr"]
    if(tParams and tParams["addr"]) then
	    addr = string.format("%04x",tonumber(tParams["addr"]))
    end
    local s,_=string.find(strCommand, "FRESH")
    local air = Aircondition:create(addr)
    if (s==1) then
	   air = Freshair:create()
	   local index,_ =string.find(strCommand, "_")
	   strCommand = strCommand:sub(index+1)
    end
    local cmd = nil
    if air[strCommand] and type(air[strCommand]) == "function" then
       cmd = air[strCommand](air)
    end
    
    airControl(cmd)
end

function EX_CMD.LUA_ACTION(tParams)
    local action = string.upper(tParams["ACTION"])

    local air = Aircondition:create(Properties["Addr"])
    local cmd = nil

    if air[action] and type(air[action]) == "function" then
	   cmd = air[action](air)
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
    
    if action == "FRESH_ON" then
	   local fresh = Freshair:create()
	   cmd = fresh:ON()
    end
    
    if action == "FRESH_OFF" then
	   local fresh = Freshair:create()
	   cmd = fresh:OFF()
    end
    
    if action == "FRESH_HIGH" then
	   local fresh = Freshair:create()
	   cmd = fresh:HIGH()
    end
    
    if action == "FRESH_MIDDLE" then
	   local fresh = Freshair:create()
	   cmd = fresh:MIDDLE()
    end
    
    if action == "FRESH_LOW" then
	   local fresh = Freshair:create()
	   cmd = fresh:LOW()
    end
    
    if action == "FRESH_WIND" then
	   local fresh = Freshair:create()
	   cmd = fresh:WIND()
    end
    
    if action == "FRESH_READ" then
	   local fresh = Freshair:create()
	   cmd = fresh:READ()
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

--Init
gDbgTimer, gDbgPrint, gDbgLog = 0, false, false
gQueue,gSendTimer = {},0
OnPropertyChanged("Debug Mode")

C4:AddVariable("IS_ON", "1", "BOOL")
C4:AddVariable("CURRENT_MODE", "0", "NUMBER")
C4:AddVariable("CURRENT_TEMPRETURE", "0", "NUMBER")
C4:AddVariable("CURRENT_SPEED", "0", "NUMBER")

C4:AddVariable("CURRENT_FAULT", "0", "NUMBER")

C4:AddVariable("KEY_ID", "0", "NUMBER")

C4:AddVariable("FRESH_POWER", "1", "BOOL")
C4:AddVariable("SETTING_TEMPRETURE", "0", "NUMBER")
