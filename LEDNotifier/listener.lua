GPIO_RED = 1
GPIO_GREEN = 2
GPIO_BLUE = 3

    
function setupGPIO()
	print("Configuring GPIO...")
      
    gpio.mode(GPIO_RED, gpio.OUTPUT)
    gpio.mode(GPIO_GREEN, gpio.OUTPUT)
    gpio.mode(GPIO_BLUE, gpio.OUTPUT)

    --gpio.HIGH or gpio.LOW
    gpio.write(GPIO_RED, gpio.LOW)
    gpio.write(GPIO_GREEN, gpio.HIGH)
    gpio.write(GPIO_BLUE, gpio.LOW)
end

setupGPIO()
