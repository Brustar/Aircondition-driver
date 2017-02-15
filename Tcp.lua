function tcpClient(timeout, done)
    local timer
    local completed = false
    local complete = function(data, errMsg)
	   if (not completed) then
		  completed = true
		  if (timer ~= nil) then
			 timer:Cancel()
		  end
		  done(data, errMsg)
	   end
    end
    local cli = C4:CreateTCPClient()
              :OnConnect(function(client)
                     local remote = client:GetRemoteAddress()
                     print("Connected to " .. remote.ip .. ":" .. remote.port)
				 C4:UpdateProperty("Tcp Status", "tcp connected success")
                     --client:Write("<c4soap name=\"GetVersionInfo\" async=\"False\"/>\0"):ReadUntil("\0")
              end)
              :OnResolve(function(client, endpoints, choose)
                     -- Implementing this callback is optional
                     print("Resolved.  Artificially delay choosing endpoint by one second...")
                     C4:SetTimer(1000, function()
                           --choose(1) -- This would choose the first endpoint in the endpoints array
                           --choose(0) -- Abort the connection request
                           choose() -- Default behavior, this chooses the first endpoint (if available)
                     end)
              end)
              :OnDisconnect(function(client, errCode, errMsg)
                     if (errCode ~= 0) then
                           complete(nil, "Disconnected with error " .. errCode .. ": " .. errMsg)
                     else
                           complete(nil, "Disconnected and no response received")
					  client:Connect(Properties["TCP Address"],tonumber(Properties["TCP Port"]))
                     end

              end)
              :OnRead(function(client, data)
                     done(data)
              end)
              :OnError(function(client, errCode, errMsg)
                     complete(nil, "Error " .. errCode .. ": " .. errMsg)
              end)
              :Connect(Properties["TCP Address"],tonumber(Properties["TCP Port"]))
    if (timeout > 0) then
	   timer = C4:SetTimer(timeout, function()
		  cli:Close()
		  complete(nil, "Timed out!")
	   end)
    end
    
    return cli
end