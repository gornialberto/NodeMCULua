------------------------------------------
--DATA ACQUISITION AND WEB SERVICE REQUEST

DHT_Humidity = 0
DHT_Temperature = 0
DHT_Quality = 0

DHT_PIN = 4
DHT_Attempt = 0

		
	
function getTempDHT()
	local Humidity = 0
    local HumidityDec=0
    local Temperature = 0
    local TemperatureDec=0
	local status
	
	if ( DHT_Attempt < 5 ) then
		
		DHT_Attempt = DHT_Attempt + 1
				
		status, Temperature, Humidity, TemperatureDec, HumidityDec = dht.read(DHT_PIN)
				
		if status == dht.OK then		
			DHT_Attempt = 0
		
			--for the time being this sensor doesn't have decimals
			DHT_Temperature = Temperature
			DHT_Humidity = Humidity		
			DHT_Quality = 1
								
		elseif status == dht.ERROR_CHECKSUM then
			print( "DHT Checksum error." )
			getTempDHT()
		elseif status == dht.ERROR_TIMEOUT then
			print( "DHT timed out." )
			getTempDHT()
		end	
		
	else
		DHT_Quality = 0
	end
	
	print("DHT Temperature: " .. DHT_Temperature)
	print("DHT Humidity: " .. DHT_Humidity)
	print("DHT Quality: " .. DHT_Quality)	
end




function collectData()
    
	print("-------------------")
	print("Executing Capture Data")
	print("-------------------")
		
	local timeNow = rtctime.get()	
	timeNow = 	timeNow .. "000"
	print("Time now is " .. timeNow)
		
	getTempDHT()
    
    sendData(timeNow)
    
end

function setupMQTTClient()
    
    borkerIp = "192.168.1.220";
    brokerPort = 1883;
 
    print("-------------------")
    print("Connecting to MQTT Broker " .. borkerIp .. ":" .. brokerPort)
    print("-------------------")
    
    m = mqtt.Client("BedroomBoard", 120);
    m:lwt("myHome/BedroomBoard/status", "offline", 0, 1);
    m:on("connect", function(client) m:publish("myHome/BedroomBoard/status","online",0,1, function(client) print("Updated will to online") end) end);
    m:on("offline", function(client) print ("offline") end); 
    -- for TLS: m:connect("192.168.11.118", secure-port, 1)
    m:connect(borkerIp, brokerPort, 0, 0, function(client) print("connected") end,
        function(client, reason) print("failed reason: " .. reason) end)
end



function sendData(timeNow)
    print("-------------------")
    print("Executing Send Data")
    print("-------------------")
  
    local tm = rtctime.epoch2cal(timeNow)
        
    m:publish("myHome/BedroomBoard/DHT_Temperature",DHT_Temperature,0,1, function(client) print("DHT_Temperature Sent") end)
    m:publish("myHome/BedroomBoard/DHT_Humidity",DHT_Humidity,0,1, function(client) print("DHT_Humidity Sent") end)
    m:publish("myHome/BedroomBoard/DHT_Quality",DHT_Quality,0,1, function(client) print("DHT_Quality Sent") end)
      
    print("-------------------")
    print("Data Sent")
    print("-------------------")
end



setupMQTTClient();

print("Setting and starting the polling Timer...")
tmr.alarm(2, 15000, tmr.ALARM_AUTO, function() collectData() end )

