--udpServer
require "Tcp"

Udp = {}

UDP_PORT = tonumber(Property("UDP Port"))

function Udp:create()

    local udp = {}
    
    self.tcp = nil
    self.timout = 5000
    
    function udp.connect()
	   C4:CreateServer(UDP_PORT, "", true)
    end
    
    function udp.OnServerDataIn(nHandle, strData, strclientAddress, strPort)
	   print("Received Data on Handle: " .. nHandle .. ": " .. strData)
	   print("Address: " .. strclientAddress .. ": " .. strPort)
	   
	   local ip = "",port = 0
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
    
    function udp.close(nHandle)
	   self.tcp:Close()
	   self.tcp = nil
	   C4:ServerCloseClient(nHandle)
    end
   
    return udp
end