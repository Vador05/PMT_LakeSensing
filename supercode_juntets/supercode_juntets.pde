#include <WaspSensorPrototyping_v20.h>
/*
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
*/
float value, value2;
//We are going to integrate the values due the fast variations that they can suffer during the day that are not real info just exceptional facts
  float dist[50];
  float temp[50];

//We will fill the stacks with some ref values taken each (CAL_INTERVAL)
int CAL_INTERVAL = 100;//in miliseconds
int LOOP_INTERVAL= 1000;//in miliseconds

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
  for (int i=0; i<50;i++){
    USB.print(F("CALIBRATING, PLEASE WAIT "));
    USB.print((50-i)*CAL_INTERVAL);
    USB.println(F(" ms"));
   dist[i]= SensorProtov20.readAnalogSensor(ANALOG7);
   temp[i]= SensorProtov20.readAnalogSensor(ANALOG5);
   delay(CAL_INTERVAL);
  }
}



 void loop()
{
  //Read the ADC 
  //value = SensorProtov20.readADC();
  value=SensorProtov20.readAnalogSensor(ANALOG7);
  value2=SensorProtov20.readAnalogSensor(ANALOG5);
//Print the result through the USB
setNewVal(value2, value);

value = distMean;
 USB.print(F("SONAR    "));
 USB.print(value);
 USB.println(F("V"));
//Print the result through the USB
 USB.print(F("TEMPERATURE    "));
// USB.print(value2);
 USB.println(F("V"));
    for (int i=0;i<25;i--){
      USB.println(F(" "));
    }
 
//  USB.print(F("Value: "));
  //USB.print(sensorValue);
  //USB.println(F("V"));
  delay(LOOP_INTERVAL);
}

void setNewVal (float tempo, float dista){
 for (int i=0;i<50;i++)
 {
   dist[i]=dist[i+1];
   temp[i]=temp[i+1];
 }
 temp[50]=tempo;
 dist[50]=dista;
 
}

float distMean (){
  float superDist;
    for(int i=0;i<50;i++){
     superDist+=dist[i]; 
    }
  return (superDist/50);
}
float tempMean (){
  float superTemp;
    for(int i=0;i<50;i++){
     superTemp+=temp[i]; 
    }
  return (superTemp/50);
}
