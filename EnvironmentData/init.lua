--Entry Point for the LUA Script!
function entryPoint()
    connectWiFi()
end

function continueNextSteps()
    dofile("setTimeSNTP.lua")
end

function connectWiFi()
    print("Setting up WIFI...")
    wifi.setmode(wifi.STATION)

    station_cfg={}
    station_cfg.ssid="GE Digital Internet"
    station_cfg.pwd="Acc3ssGr@nted"
    station_cfg.auto=false
    station_cfg.save=false
    wifi.sta.config(station_cfg)
    
    wifi.sta.connect()
    
    tmr.alarm(1, 2000, 1, function() 
        if wifi.sta.getip()== nil then 
            print("IP unavaiable - Wifi Status: " ..wifi.sta.status() .. " - Waiting...") 
        else 
            tmr.stop(1)
            print("Config done, IP is "..wifi.sta.getip())
            continueNextSteps()
        end 
    end)
end

print("Initializing the system... waiting 10 seconds for convenience");
--ok just call the entry point after 10 seconds
tmr.alarm(0, 10000, tmr.ALARM_SINGLE, function() 
entryPoint();
end)

