------------------------------------------
--DATA ACQUISITION AND WEB SERVICE REQUEST

DHT_Humidity = 0
DHT_Temperature = 0
DHT_Quality = 0

DHT_PIN = 4
DHT_Attempt = 0


BMP_Pressure = 0
BMP_Temperature= 0
BMP_Quality = 0

BMP_OSS = 2 -- oversampling setting (0-3)
BMP_SCL_PIN = 1 -- scl pin, GPIO15
BMP_SDA_PIN = 2 -- sda pin, GPIO2

TLS_LUX = 0
TLS_LUX_Quality = 0

TLS_SCL_PIN = 5
TLS_SDA_PIN = 3
	
function getLuxValue()
	
	local status = tsl2561.init(TLS_SDA_PIN, TLS_SCL_PIN, tsl2561.ADDRESS_FLOAT, tsl2561.PACKAGE_T_FN_CL)

	if status == tsl2561.TSL2561_OK then
		status = tsl2561.settiming(tsl2561.INTEGRATIONTIME_101MS, tsl2561.GAIN_1X)

		if status == tsl2561.TSL2561_OK then		
			TLS_LUX = tsl2561.getlux()
			TLS_LUX_Quality = 1
		else
			TLS_LUX_Quality = 0
		end
	else
		TLS_LUX_Quality = 0
	end
	
	print("Illuminance: " .. TLS_LUX .. " lx")
	print("Illuminance Quality: " .. TLS_LUX_Quality) 

end
	

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


function getPressureBMP180()
	BMP_Pressure = 0
	BMP_Temperature = 0
	
	--bmp180 = require("bmp180")
	--bmp180.init(BMP_SDA_PIN, BMP_SCL_PIN)
	--bmp180.read(BMP_OSS)
	--t = bmp180.getTemperature()
	--p = bmp180.getPressure()

    bmp085.init(BMP_SDA_PIN, BMP_SCL_PIN)
    t = bmp085.temperature()
    p = bmp085.pressure(3)
    
	BMP_Pressure  = (p / 100)
	BMP_Temperature  = (t / 10)
	BMP_Quality = 1
	
	-- temperature in degrees Celsius  and Farenheit
	print("BMP Temperature: ".. BMP_Temperature .." deg C")
	-- pressure in differents units
	print("BMP Pressure: ".. BMP_Pressure .." mbar")	
	print("BMP Quality: ".. BMP_Quality)	
end


function collectData()
    
	print("-------------------")
	print("Executing Capture Data")
	print("-------------------")
		
	local timeNow = rtctime.get()	
	timeNow = 	timeNow .. "000"
	print("Time now is " .. timeNow)
		
	getTempDHT()
	getPressureBMP180()	
	getLuxValue()	
	
	sendData(timeNow)
	
end

function setupMQTTClient()
    
    borkerIp = "77.95.143.115";
    brokerPort = 1883;
 
    print("-------------------")
    print("Connecting to MQTT Broker " .. borkerIp .. ":" .. brokerPort)
    print("-------------------")
    
    m = mqtt.Client("GenoaOfficeEnvBoard001", 120);
    m:lwt("GenoaOffice/EnvBoard001/status", "offline", 0, 1);
    m:on("connect", function(client) m:publish("GenoaOffice/EnvBoard001/status","online",0,1, function(client) print("Updated will to online") end) end);
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
        
    m:publish("/GenoaOffice/EnvBoard001/DHT_Temperature",DHT_Temperature,0,1, function(client) print("DHT_Temperature Sent") end)
	m:publish("/GenoaOffice/EnvBoard001/DHT_Humidity",DHT_Humidity,0,1, function(client) print("DHT_Humidity Sent") end)
	m:publish("/GenoaOffice/EnvBoard001/DHT_Quality",DHT_Quality,0,1, function(client) print("DHT_Quality Sent") end)
	m:publish("/GenoaOffice/EnvBoard001/BMP_Pressure",BMP_Pressure,0,1, function(client) print("BMP_Pressure Sent") end)
	m:publish("/GenoaOffice/EnvBoard001/BMP_Temperature",BMP_Temperature,0,1, function(client) print("BMP_Temperature Sent") end)
    m:publish("/GenoaOffice/EnvBoard001/BMP_Quality",BMP_Quality,0,1, function(client) print("BMP_Temperature Sent") end)
    m:publish("/GenoaOffice/EnvBoard001/TLS_LUX",TLS_LUX,0,1, function(client) print("TLS_LUX Sent") end)
	m:publish("/GenoaOffice/EnvBoard001/TLS_LUX_Quality",TLS_LUX_Quality,0,1, function(client) print("TLS_LUX_Quality Sent") end)
    
	print("-------------------")
	print("Data Sent")
	print("-------------------")
end



setupMQTTClient();

print("Setting and starting the polling Timer...");
tmr.alarm(2, 15000, tmr.ALARM_AUTO, function() collectData() end );
