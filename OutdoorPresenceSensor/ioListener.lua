GPIO = 1

local debounceDelay = 150
local debounceAlarmId = 2

function inputDown()
    -- don't react to any interupts from now on and wait 50ms until the interrupt for the up event is enabled
    -- within that 50ms the switch may bounce to its heart's content
    gpio.trig(GPIO, "none")
    tmr.alarm(debounceAlarmId, debounceDelay, tmr.ALARM_SINGLE, function()
        gpio.trig(GPIO, "up", inputUp)
    end)
    -- finally react to the down event
    sendData(0)
end

function inputUp()
    -- don't react to any interupts from now on and wait 50ms until the interrupt for the down event is enabled
    -- within that 50ms the switch may bounce to its heart's content
    gpio.trig(GPIO, "none")
    tmr.alarm(debounceAlarmId, debounceDelay, tmr.ALARM_SINGLE, function()
        gpio.trig(GPIO, "down", inputDown)
    end)
    -- finally react to the up event
    sendData(1)
end


function registerIOEvent()
	print("Registering IO Events.")
      
    gpio.mode(GPIO, gpio.INT, gpio.PULLUP)
    gpio.trig(GPIO, "down", inputDown)
end

function setupMQTTClient()
    
    borkerIp = "192.168.1.220";
    brokerPort = 1883;
 
    print("-------------------")
    print("Connecting to MQTT Broker " .. borkerIp .. ":" .. brokerPort)
    print("-------------------")
    
    m = mqtt.Client("OutdoorSensorBoard", 120);
    m:lwt("myHome/OutdoorSensor/status", "offline", 0, 1);
    m:on("connect", function(client) m:publish("myHome/OutdoorSensor/status","online",0,1, function(client) print("Updated will to online") end) end);
    m:on("offline", function(client) print ("Disconnected from Broker") end); 
    -- for TLS: m:connect("192.168.11.118", secure-port, 1)
    m:connect(borkerIp, brokerPort, 0, 0, function(client) print("Connected to Broker") end,
        function(client, reason) print("failed reason: " .. reason) end)
end


function sendData(level)
   
    local tm = rtctime.epoch2cal(rtctime.get())
		
	local bodyRequest = "{\"Level\":" .. "\"" .. level .. "\"" ..
			",\"Timestamp\":\"" .. tm .. "\"}"

    m:publish("myHome/OutdoorSensor",bodyRequest,0,1, function(client) print("Data Sent: ".. level) end)
    
end

setupMQTTClient();
registerIOEvent();
