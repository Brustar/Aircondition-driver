require "Pack"

SERVER_PORT = 5009
MASTER_AUTH = 0x84

local server = {
      clients = {},
      clientsCnt = 0,
      --socket = nil,
	 sendAll = function(self, message)
             for cli,info in pairs(self.clients) do
			 cli:Write(message)
             end
      end,
      notifyOthers = function(self, client, message)
             for cli,info in pairs(self.clients) do
                    if (cli ~= client) then
                          cli:Write(message)
                    end
             end
      end,
      broadcast = function(self, client, message)
             local info = self.clients[client]
             print("broadcast for client " .. tostring(client) .. " info: " ..tostring(info))
             if (info ~= nil) then
                    self:notifyOthers(client, message)
                    client:Write(message)
             end
      end,
      stripControlCharacters = function(self, data)
             local ret = ""
             for i in string.gmatch(data, "%C+") do
                    ret = ret .. i
             end
             return ret
      end,
      stop = function(self)
             if (self.socket ~= nil) then
                    self.socket:Close()
                    self.socket = nil
                    -- Make a copy of all clients and reset the map.
                    -- This ensures that calls to self:broadcast() and self:notifyOthers()
                    -- during the shutdown process get ignored.  All we want the clients to
                    -- see is the shutdown message.
                    local clients = self.clients
                    self.clients = {}
                    self.clientsCnt = 0
                    for cli,info in pairs(clients) do
                          print("Disconnecting " .. cli:GetRemoteAddress().ip .. ":" .. cli:GetRemoteAddress().port)
                          cli:Write(""):Close(true)
                    end
             end
      end,
      start = function(self, maxClients, bindAddr, port, done)
             local calledDone = false
             self.socket = C4:CreateTCPServer()
                    :OnResolve(
                          function(srv, endpoints)
                                 -- You do not need to set this callback function if you only want default behavior.
                                 -- You can return an index into the endpoints array that is provided, if you would like to choose
                                 -- listening on a specific address.  By default, the first entry is used.  Note that you can mess
                                 -- with this table as you wish, but any changes will not be looked at.  Not even if you change the
                                 -- ip/port in one of the entries.  All that matters is the index into the original array that was
                                 -- provided.  If you return 0, the server will not bind to any address and will not listen for
                                 -- anything, and it will call the OnError handler with error code 22 (Invalid argument)
                                 -- return 1 -- This is default behavior
                                 -- return 0 -- Abort the listen request
                                 print("Server " .. tostring(srv) .. " resolved listening address")
                                 for i = 1, #endpoints do
                                        print("Available endpoints: [" .. i .. "] ip=" .. endpoints[i].ip .. ":" .. endpoints[i].port)
                                 end
                          end
                    )
                    :OnListen(
                           function(srv, endpoint)
                                 -- Handling this callback is optional.  It merely lets you know that the server is now actually listening.
                                 local addr = srv:GetLocalAddress()
						   C4:UpdateProperty("Server Status", "Server listen success")
                                 print("Server " .. tostring(srv) .. " chose endpoint " .. endpoint.ip .. ":" .. endpoint.port .. ", listening on " .. addr.ip .. ":" .. addr.port)
                                 if (not calledDone) then
                                        calledDone = true
                                        done(true, addr)
                                 end
                          end
                    )
                    :OnError(
                          function(srv, code, msg, op)
                                 -- code is the system error code (as a number)
                                 -- msg is the error message as a string
                                 print("Server " .. tostring(srv) .. " Error " .. code .. " (" .. msg .. ")")
						   C4:UpdateProperty("Server Status", "Server error")
                                 if (not calledDone) then
                                        calledDone = true
                                        done(false, msg)
                                 end
                          end
                    )
                    :OnAccept(
                          function(srv, client)
                                 -- srv is the instance C4:CreateTCPServer() returned
                                 -- client is a C4LuaTcpClient instance of the new connection that was just accepted
                                 C4:UpdateProperty("Server Status", "A client accept success")
						   print("Connection on server " .. tostring(srv) .. " accepted, client: " .. tostring(client))
						   client:ReadUpTo(10)
                                 if (self.clientsCnt >= maxClients) then
                                        client:Write(""):Close(true)
                                        return
                                  end
                                 local info = {}
                                 client:OnRead(
                                              function(cli, strData)
										  local pack = Pack:create()
										  function handle(key)
											 C4:SetVariable("Key_ID", tostring(key))
											 C4:FireEvent("key event")
											 local data =nil
											 for i =1 , 4 do
												C4:SetTimer(500, function()
												    if i==key then
													   data = pack.lightonHex(i)
												    else
													   data = pack.lightoffHex(i) 
												    end
												
												    cli:Write(data)
												end)
											 end
										  end
										  
										  hexdump(strData, function(s) print("server:<------ " .. s) end)
										  if strData == pack.keyHex(1) then
											 handle(1)
										  elseif strData == pack.keyHex(2) then
											 handle(2)
										  elseif strData == pack.keyHex(3) then
											 handle(3)
										  elseif strData == pack.keyHex(4) then
											 handle(4)
										  end
                                               end
                                        )
                                        :OnWrite(
                                               function(cli)
                                                      -- cli is the C4LuaTcpClient instance (same as client in the OnAccept handler).  This callback is called when
                                                      -- all data was sent.
                                                      print("Server " .. tostring(srv) .. " Client " .. tostring(client) .. " Data was sent.")
										    cli:ReadUpTo(10)
                                               end
                                        )
                                        :OnDisconnect(
                                               function(cli, errCode, errMsg)
                                                      -- cli is the C4LuaTcpClient instance (same as client in the OnAccept handler) that the data was read on
                                                      -- errCode is the system error code (as a number).  On a graceful disconnect, this value is 0.
                                                      -- errMsg is the error message as a string.
                                                      if (errCode == 0) then
                                                             print("Server " .. tostring(srv) .. " Client " .. tostring(client) .. " Disconnected gracefully.")
                                                      else
                                                             print("Server " .. tostring(srv) .. " Client " .. tostring(client) .. " Disconnected with error " .. errCode .. " (" .. errMsg .. ")")
                                                      end
                                                      self.clients[cli] = nil
                                                      self.clientsCnt = self.clientsCnt - 1
                                               end
                                        )
                                        :OnError(
                                               function(cli, code, msg, op)
                                                      -- cli is the C4LuaTcpClient instance (same as client in the OnAccept handler) that the data was read on
                                                      -- code is the system error code (as a number)
                                                      -- msg is the error message as a string
                                                      -- op indicates what type of operation failed: "read", "write"
                                                      print("Server " .. tostring(srv) .. " Client " .. tostring(client) .. " Error " .. code .. " (" .. msg .. ") on " .. op)
                                               end
                                        )
                                        :Write("")
                                        :ReadUntil("\r\n")
                          end
                    )
                    :Listen(bindAddr, port)
             if (self.socket ~= nil) then
                    return self
             end
      end
}

-- Start the server with a limit of 5 concurrent connections, listen on all interfaces on a randomly available port.  The server will shut down after 10 minutes.
function tcpServer()
    server:start(10, "*", SERVER_PORT, function(success, info)
		if (success) then
			  print("Server listening on " .. info.ip .. ":" .. info.port)
		else
			  print("Could not start server: " .. info)
		end
    end)
    return server
end