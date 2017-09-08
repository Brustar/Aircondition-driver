Visualintercom = {}

VI_HEAD = 0XAA

function Visualintercom:create()
    local visualintercom = {}

    function visualintercom:lightContol(deviceID,state)
        if state == 0 then 
            C4:SendToDevice(deviceID,"ON",{})
        elseif state == 1 then
            C4:SendToDevice(deviceID,"OFF",{})
        elseif state>=2 and state<=11 then
            C4:SendToDevice(deviceID,"RAMP_TO_LEVEL", {LEVEL = (state-1)*10), TIME = 1000})
        end
        local variable = C4:GetVariable(deviceID, 1000) or "0"
        return pack.updateOne(0x30,deviceID,variable)
    end 

    function visualintercom:lightQuery(deviceID)

    end

    function visualintercom:curtainContol(deviceID,state)
        local control = ""
        if state == 0 then 
            control = "UP"
        elseif state == 1 then
            control = "DOWN"
        elseif state == 2 then
            control = "STOP"
        end
        C4:SendToDevice(deviceID,control,{})

        local variable = C4:GetVariable(deviceID, 1000) or "0"
        return pack.updateOne(0x31,deviceID,variable) 
    end

    function visualintercom:curtainQuery(deviceID)
    end

    function visualintercom:airControl(deviceID,power,mode,tempture,speed)
        if power==0 then
            C4:SendToDevice(deviceID,"OFF",{})
        end

        if power==1 then
            C4:SendToDevice(deviceID,"ON",{})
        end

        if mode==0 then
            C4:SendToDevice(deviceID,"COOL",{})
        end

        if mode==1 then
            C4:SendToDevice(deviceID,"HEAT",{})
        end

        if mode==2 then
            C4:SendToDevice(deviceID,"FAN",{})
        end

        if mode==3 then
            C4:SendToDevice(deviceID,"DRY",{})
        end


        if tempture>=20 and tempture<=60 then
            C4:SendToDevice(deviceID,"SETEMP",{degree = math.floor(tempture/2)})
        end

        if speed==0 then
            C4:SendToDevice(deviceID,"LOW",{})
        end

        if speed==1 then
            C4:SendToDevice(deviceID,"MIDDLE",{})
        end

        if speed==2 then
            C4:SendToDevice(deviceID,"HIGH",{})
        end

        return pack.airUpdate(deviceID)
    end

    function visualintercom:airQuery(deviceID)
    end

    function visualintercom:sceneControl(sceneID)
        C4:SetVariable("SCENE_ID", tostring(pack.deviceID))
        C4:FireEvent("scene event")
    end
    
    return visualintercom
end