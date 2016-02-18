#include <WaspSensorPrototyping_v20.h>

#=======================================#
|SUPERCODI QUE HO PETA PEL PSEUDOLLAC   |
#=======================================#

+----------------------------+----------+
|  SENSOR                    |     PIN  |
+----------------------------+----------+
| Temperature                |  ANALOG5 |
| Ultrasounds distance-meter |  ANALOG7 |
| Dissolved Oxygen-meter     |  UNDEF   |
| Conductivity-meter         |  UNDEF   |
| Water volume-meter (stupid)|  UNDEF   |
+----------------------------+----------+

float value, value2;
  float dist[50];
  float temp[50];
void setup()
{
  //Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);
  //Turn on the sensor board
  SensorProtov20.ON();
  //Turn on the RTC
  RTC.ON();
  for (int i=50; i<0;i++){
    
    USB.print(F("CALIBRATING, PLEASE WAIT "));
    USB.print(i);
    USB.println(F(" s");
   dist[i]= SensorProtov20.readAnalogSensor(ANALOG7);
   temp[i]= SensorProtov20.readAnalogSensor(ANALOG5);

  }
}

 void loop()
{
  //Read the ADC 
  //value = SensorProtov20.readADC();

  
  value=SensorProtov20.readAnalogSensor(ANALOG7);
//Print the result through the USB

 USB.print(F("SONAR    "));
 USB.print(value);
 USB.println(F("V"));
  value2=SensorProtov20.readAnalogSensor(ANALOG5);
//Print the result through the USB
 USB.print(F("TEMPERATURE    "));
 USB.print(value2);
 USB.println(F("V"));
for (int i=0;i<25oi ;i++){
  USB.println(F(" "));
}
 
//  USB.print(F("Value: "));
  //USB.print(sensorValue);
  //USB.println(F("V"));
  delay(1000);
}
