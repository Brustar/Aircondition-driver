require "Server"
require "Pack"

Udp = {}

UDP_PORT = tonumber(Properties["UDP Port"])
UDP_CONNECT_ID = 6003
UDP_PORT = 5000

function Udp:create()

    local udp = {}
    
    self.tcp = nil
    self.timer = nil
    self.timout = 5000
    
    --udpServer
    function udp.server()
	   C4:CreateServer(UDP_PORT, "", true)
    end
    
    function udp.OnServerDataIn(nHandle, strData, strclientAddress, strPort)
	   print("Received Data on Handle: " .. nHandle .. ": " .. strData)
	   print("Address: " .. strclientAddress .. ": " .. strPort)
	   
	   local ip ,port = "", 0
	   C4:UpdateProperty("TCP Address", ip)
	   C4:UpdateProperty("TCP Port", tostring(port))
	   if not self.tcp then
		  self.tcp = tcpClient(self.timout, function(info, err)
				if (info ~= nil) then
				    hexdump(info, function(s) dbg("<------ " .. s) end)
				    
				    C4:SetTimer(1000, function()
					   self.tcp:ReadUpTo(7)
				    end)
				else
				    print("ERROR: " .. err)
				end
			 end)
		  self.tcp:ReadUpTo(7)
	   end
    end

    function udp.OnServerConnectionStatusChanged(nHash, nPort, strStatus, strIP)
	  print("OnServerConnectionStatusChanged hash: " .. nHash .. " port: " .. nPort .. " status: " .. strStatus)
    end
    
    function udp.closeServer(nHandle)
	   self.tcp:Close()
	   self.tcp = nil
	   C4:ServerCloseClient(nHandle)
    end
    
    
    function udp.client()
	   C4:CreateNetworkConnection (UDP_CONNECT_ID, "255.255.255.255")
	   C4:NetConnect(UDP_CONNECT_ID, UDP_PORT, 'UDP')
    end
    
    function udp.OnConnectionStatusChanged(idBinding, nPort, strStatus)
	   if (strStatus == "ONLINE") then
		  local pack = Pack:create().broadcastHex()
		  self.timer = C4:SetTimer(5 * 1000, function(timer, skips)
			 C4:SendToNetwork(UDP_CONNECT_ID, UDP_PORT, pack)
		  end,true)
	   end
    end
    
    function udp.disconnect()
	   self.timer:Cancel()
	   C4:NetDisconnect(UDP_CONNECT_ID, UDP_PORT, 'UDP')
    end
   
    return udp
end