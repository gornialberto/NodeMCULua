GPIO1 = 1
GPIO2 = 2

local debounceDelay = 150
local debounceAlarmId1 = 2
local debounceAlarmId2 = 3

function inputDown1()
    -- don't react to any interupts from now on and wait 50ms until the interrupt for the up event is enabled
    -- within that 50ms the switch may bounce to its heart's content
    gpio.trig(GPIO1, "none")
    tmr.alarm(debounceAlarmId1, debounceDelay, tmr.ALARM_SINGLE, function()
        gpio.trig(GPIO1, "up", inputUp1)
    end)
    -- finally react to the down event
    sendData(1,0)
end

function inputUp1()
    -- don't react to any interupts from now on and wait 50ms until the interrupt for the down event is enabled
    -- within that 50ms the switch may bounce to its heart's content
    gpio.trig(GPIO1 "none")
    tmr.alarm(debounceAlarmId1, debounceDelay, tmr.ALARM_SINGLE, function()
        gpio.trig(GPIO1, "down", inputDown1)
    end)
    -- finally react to the up event
    sendData(1,1)
end

function inputDown2()
    -- don't react to any interupts from now on and wait 50ms until the interrupt for the up event is enabled
    -- within that 50ms the switch may bounce to its heart's content
    gpio.trig(GPIO2, "none")
    tmr.alarm(debounceAlarmId2, debounceDelay, tmr.ALARM_SINGLE, function()
        gpio.trig(GPIO2, "up", inputUp2)
    end)
    -- finally react to the down event
    sendData(2,0)
end

function inputUp2()
    -- don't react to any interupts from now on and wait 50ms until the interrupt for the down event is enabled
    -- within that 50ms the switch may bounce to its heart's content
    gpio.trig(GPIO2 "none")
    tmr.alarm(debounceAlarmId2, debounceDelay, tmr.ALARM_SINGLE, function()
        gpio.trig(GPIO2, "down", inputDown2)
    end)
    -- finally react to the up event
    sendData(2,1)
end


function registerIOEvent()
    print("Registering IO Events.")
      
    gpio.mode(GPIO1, gpio.INT, gpio.PULLUP)
    gpio.trig(GPIO1, "down", inputDow1)

    gpio.mode(GPIO2, gpio.INT, gpio.PULLUP)
    gpio.trig(GPIO2, "down", inputDow2)
end

function setupMQTTClient()
    
    borkerIp = "192.168.1.220";
    brokerPort = 1883;
 
    print("-------------------")
    print("Connecting to MQTT Broker " .. borkerIp .. ":" .. brokerPort)
    print("-------------------")
    
    m = mqtt.Client("RemoteKeyfobBoard", 120);
    m:lwt("myHome/RemoteKeyfob/status", "offline", 0, 1);
    m:on("connect", function(client) m:publish("myHome/RemoteKeyfob/status","online",0,1, function(client) print("Updated will to online") end) end);
    m:on("offline", function(client) print ("Disconnected from Broker") end); 
    -- for TLS: m:connect("192.168.11.118", secure-port, 1)
    m:connect(borkerIp, brokerPort, 0, 0, function(client) print("Connected to Broker") end,
        function(client, reason) print("failed reason: " .. reason) end)
end


function sendData(channel, level)
   
    local tm = rtctime.epoch2cal(rtctime.get())
        
    local bodyRequest = "{\"Level\":" .. "\"" .. level .. "\"" ..
            ",\"Timestamp\":\"" .. tm .. "\"}"

    m:publish("myHome/RemoteKeyfob/" .. channel, bodyRequest, 0, 1, function(client) print("Data Sent for Channel  " .. channel .. " - " .. level) end)
    
end

setupMQTTClient();
registerIOEvent();
