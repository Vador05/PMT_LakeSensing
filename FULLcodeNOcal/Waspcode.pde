#include <WaspSX1272.h>
#include <WaspFrame.h>
#include <WaspSensorPrototyping_v20.h>
/*
#=======================================#
 |SUPERCODI QUE HO PETA PEL PSEUDOLLAC   |
 #=======================================#
 V.SD ok! lora ? sensors ok!
 #============================#==========#
 || SENSOR                   ||     PIN  ||
 #============================#==========#
 | Temperature                |  ANALOG5 |
 +----------------------------+----------+
 | Ultrasounds distance-meter |  ANALOG7 |
 +----------------------------+----------+
 | Dissolved Oxygen-meter     |  ANALOG3 |
 +----------------------------+----------+
 | Conductivity-meter         |  ADC PORT|
 +----------------------------+----------+
 | Water volume-meter (stupid)|  DESTROY |
 +----------------------------+----------+
 */

// Define private key to encrypt message
char nodeID[] = "node_001";

// define the destination address to send packets
uint8_t rx_address = 1;

// status variable
int8_t e;


void setup()
{

//Turn on the USB and print a start message
USB.ON();
USB.println(F("starting ..."));
//Turn on the sensor board
SensorProtov20.ON();
//Turn on the RTC
RTC.ON();
//============================================ SENSORS ======================================
delay(100);//We set an stabilization interval for the sensoers
USB.println(F("board started ..."));
for (int i=0; i<FILTER_SAMPLES;i++){
  USB.print(F("CALIBRATING, PLEASE WAIT "));
  USB.print((FILTER_SAMPLES-i)*CAL_INTERVAL);
  USB.println(F(" ms"));
  dist[i]= SensorProtov20.readAnalogSensor(ANALOG7);
  temp[i]= SensorProtov20.readAnalogSensor(ANALOG5);
  delay(CAL_INTERVAL);
}
int ch;
while(ch==1){
  ch=SDsetup();
}
timer=0;
 USB.println(F("Semtech SX1272 module. TX LoRa with Waspmote Frame"));

  // set the node ID
  frame.setID(nodeID);


  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:"));
  USB.println(F("----------------------------------------"));

  // Init SX1272 module
  sx1272.ON();

  // Select frequency channel
  e = sx1272.setChannel(CH_12_868);
  USB.print(F("Setting Channel CH_12_868.\t state "));
  USB.println(e);

  // Select implicit (off) or explicit (on) header mode
  e = sx1272.setHeaderON();
  USB.print(F("Setting Header ON.\t\t state "));
  USB.println(e);

  // Select mode: from 1 to 10
  e = sx1272.setMode(1);
  USB.print(F("Setting Mode '1'.\t\t state "));
  USB.println(e);

  // select CRC on or off
  e = sx1272.setCRC_ON();
  USB.print(F("Setting CRC ON.\t\t\t state "));
  USB.println(e);

  // Select output power (Max, High or Low)
  e = sx1272.setPower('M');
  USB.print(F("Setting Power to 'M'.\t\t state "));
  USB.println(e);

  // Select the node address value: from 2 to 255
  e = sx1272.setNodeAddress(4);
  USB.print(F("Setting Node Address to '4'.\t state "));
  USB.println(e);
  USB.println();

  delay(1000);

  USB.println(F("----------------------------------------"));
  USB.println(F("Sending:"));
  USB.println(F("----------------------------------------"));
}

void loop()
{
//////////////////////////////////////////////////
// SENSORS
//////////////////////////////////////////////////
timer++;
uint8_t writeState;

/*
+---------------------------------------------+
|                MEASUREMENTS                 |
+---------------------------------------------+
*/
//Read the ADC
//value = SensorProtov20.readADC();

//==================SONAR======================
value=SensorProtov20.readAnalogSensor(ANALOG7);

//==================TEMP=======================
value2=SensorProtov20.readAnalogSensor(ANALOG5);

//==================D.O.=======================
value3= getDOMeasure();

//==================COND=======================
value4= getCONDMeasure();
value4= resistanceConversion(value4);
value4= conductivityConversion(value4);
/*
+---------------------------------------------+
|       SENDING TROUGH USB INTERFACE          |
+---------------------------------------------+
*/
//==================SONAR======================
USB.print(F("SONAR    "));
USB.print(value);
USB.println(F("V"));

//==================TEMP=======================
USB.print(F("TEMPERATURE    "));
USB.print(value2);
USB.println(F("V"));

//==================D.O.=======================
USB.print(F("DO    "));
USB.print(value3);
USB.println(F("V"));

//==================COND=======================
USB.print(F("CONDUCTIVITY    "));
USB.print(value4);
USB.println(F(""));
/*
+---------------------------------------------+
|                SD WRITING                   |
+---------------------------------------------+
*/
//==================SONAR======================
writeState = SD.append("LOGS.TXT","SONAR    ");
//   writeState = SD.append("LOGS.TXT",value);
writeState = SD.appendln("LOGS.TXT","V");

//==================TEMP=======================
writeState = SD.append("LOGS.TXT","TEMPERATURE    ");
//writeState = SD.append("LOGS.TXT",value2);
writeState = SD.appendln("LOGS.TXT","V");

//==================D.O.=======================
writeState = SD.append("LOGS.TXT","DO    ");
//writeState = SD.append("LOGS.TXT",value3);
writeState = SD.appendln("LOGS.TXT","");

//==================COND=======================
writeState = SD.append("LOGS.TXT","CONDUCTIVITY    ");
//writeState = SD.append("LOGS.TXT",value4);
writeState = SD.appendln("LOGS.TXT","");
/*
+---------------------------------------------+
|       SENDING TROUGH LORA INTERFACE         |
+---------------------------------------------+
*/
// 1. Create a new Frame with sensor fields

USB.println(F("Create new Frame:"));
// Creating frame to send
frame.createFrame(ASCII);
// Adding sensor battery
frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());
frame.addSensor(SONAR, (uint8_t) value;
frame.addSensor(TEMPERATURE, (uint8_t) value2);
frame.addSensor(OXYGEN DENSITY, (uint8_t) value3);
frame.addSensor(CONDUCTIVITY, (uint8_t) value4);

// Show frame via USB port
frame.showFrame();

// 2. Send Frame to another Waspmote

// Sending packet
sx1272.sendPacketTimeout( rx_address, frame.buffer, frame.length);
// Check sending status
if( e == 0 )
{
  USB.println(F("Packet sent OK"));
}
else
{
  USB.println(F("Error sending the packet"));
  USB.print(F("state: "));
  USB.println(e, DEC);
}

//======================= SLEEPING ==========================
  USB.println(F("Turning OFF Expansion Board    "));
 SensorProtov20.OFF();
  USB.println(F("Turning OFF RTC    "));
RTC.OFF();  //We scroll the serial terminal
  USB.println(F("Turning OFF SD    "));
SD.OFF();
  USB.println(F("Turning OFF LORA    "));
sx1272.OFF();
for (int i=0;i<25;i++){
  USB.println(F(" "));
}
//Wait loop interval to read again
delay(LOOP_INTERVAL);
//=================== NEW INITIALIZATION =================
/*   writeState = SD.append("LOGS.TXT","Writting num    ");
   //writeState = SD.append("LOGS.TXT",timer*LOOP_INTERVAL);
   writeState = SD.appendln("LOGS.TXT"," s");



     USB.println(F("Waking UP SD   "));
 int ch=1;
while(ch==1){
  ch=SDsetup();
}
     USB.println(F("Waking UP Expansion Board   "));
 SensorProtov20.ON();
//Turn on the RTC
       USB.println(F("Waking UP RTC  "));
RTC.ON();
delay(100);//We set an stabilization interval for the sensoers

}*/
setup();
//======================== FUNCTIONS ==========================
float median(float array[] , int numSamples)
{
float result =0;
for( int i =0; i<numSamples; i++)
{
  result+= array[i];
}
result = result/numSamples;
return (result);
}

void setNewVal (float newval,   float* vals[FILTER_SAMPLES]){
for (int i=0;i<FILTER_SAMPLES;i++)
{
  *vals[i]=*vals[i+1];
}
*vals[FILTER_SAMPLES-1]=newval;
}

float getDOMeasure(){
float value_array[FILTER_SAMPLES];

// Take some measurements to filter the signal noise and glitches
for(int i = 0; i < FILTER_SAMPLES; i++)
{
  //Read from the ADC channel selected
  value_array[i] = SensorProtov20.readADC();
}
float input= median(value_array,FILTER_SAMPLES);
return (input - zero_calibration)/(air_calibration - zero_calibration) * 100;
}

float getCONDMeasure()
{
float value_array[FILTER_SAMPLES];

// Take some measurements to filter the signal noise and glitches
for(int i = 0; i < FILTER_SAMPLES; i++)
{
  //Read from the ADC channel selected
  value_array[i] = SensorProtov20.readADC();
}
//Switch OFF the corresponding sensor circuit
delay(100);

return median(value_array,FILTER_SAMPLES);
}
float conductivityConversion(float input)
{
float value;
float SW_condK;
float SW_condOffset;

// Calculates the cell factor of the conductivity sensor and the offset from the calibration values
SW_condK = point_1_cond * point_2_cond * ((point_1_cal-point_2_cal)/(point_2_cond-point_1_cond));
SW_condOffset = (point_1_cond * point_1_cal-point_2_cond*point_2_cal)/(point_2_cond-point_1_cond);

// Converts the resistance of the sensor into a conductivity value
value = SW_condK * 1 / (input+SW_condOffset);

return value;
}

int SDsetup(){
SD.ON(); // Set SD card on
// Reads associated pin to know if there is a SD in card slot
if(SD.isSD())
{
  USB.println("SD is detected");
  // Get total size of SD card
  USB.print(SD.diskSize);
  USB.println(" Bytes");
  USB.print("This SD Contains ");
  int8_t numfiles = SD.numFiles();
  USB.print(numfiles);
  USB.println(" files");
  /*char* name0 = "LOGS.txt";
   char* name1 = ".txt";
   char* name = new char [strlen(name0)+strlen(name1)+strlen(numfiles)];
   for (int i =0; i<srlen(name0);i++)
   {
   name[i]=name0[i];
   }
   for(int i =0; i<strlen(numfiles);i++)
   {
   name[strlen(name0)+i]=numfiles[i];
   }*/
      SD.goRoot();
      if (SD.isFile("LOGS.TXT")==-1)
      {
        USB.println("FILE DOES NOT EXIST");

        if(SD.create("LOGS.TXT")==0)
        {
          USB.println("ERROR CREATING FILE");
          SD.OFF();
          setup();
          return(1);
        }
      }
      else
      {
        if(SD.getFileSize("FILE.TXT")>SD.diskSize-50)
        {
          USB.println("Less than 50 Bytes less in your memory card");
        }
      }
   SD.openFile( "LOGS.TXT", &LOGfile, O_READ);
          USB.println("FILE OPENED");
          return(0);
}
else
{
  SD.OFF();
  USB.println("NO SD try again 5 s later");
  delay (5000);
  setup();
  return(1);
}
}



float resistanceConversion(float input)
{
float value;

input = input / 2.64;

// These values have been obtained experimentaly
if(input<=SW_COND_CAL_01)
  value = 0;

else if(input<SW_COND_CAL_02)
  value = 100 * (input-SW_COND_CAL_01)/(SW_COND_CAL_02-SW_COND_CAL_01);

else if(input<SW_COND_CAL_03)
  value = 100 + 120 * (input-SW_COND_CAL_02)/(SW_COND_CAL_03-SW_COND_CAL_02);

else if(input<SW_COND_CAL_04)
  value = 220 + 220 * (input-SW_COND_CAL_03)/(SW_COND_CAL_04-SW_COND_CAL_03);

else if(input<SW_COND_CAL_05)
  value = 440 + 560 * (input-SW_COND_CAL_04)/(SW_COND_CAL_05-SW_COND_CAL_04);

else if(input<SW_COND_CAL_06)
  value = 1000 + 1200 * (input-SW_COND_CAL_05)/(SW_COND_CAL_06-SW_COND_CAL_05);

else if(input<SW_COND_CAL_07)
  value = 2200 + 2200 * (input-SW_COND_CAL_06)/(SW_COND_CAL_07-SW_COND_CAL_06);

else if(input<SW_COND_CAL_08)
  value = 4400 + 1200 * (input-SW_COND_CAL_07)/(SW_COND_CAL_08-SW_COND_CAL_07);

else if(input<SW_COND_CAL_09)
  value = 5600 + 4400 * (input-SW_COND_CAL_08)/(SW_COND_CAL_09-SW_COND_CAL_08);

else if(input<SW_COND_CAL_10)
  value = 10000 + 5000 * (input-SW_COND_CAL_09)/(SW_COND_CAL_10-SW_COND_CAL_09);

else if(input<SW_COND_CAL_11)
  value = 15000 + 7000 *(input-SW_COND_CAL_10)/(SW_COND_CAL_11-SW_COND_CAL_10);

else if(input<SW_COND_CAL_12)
  value = 22000 + 11000 * (input-SW_COND_CAL_11)/(SW_COND_CAL_12-SW_COND_CAL_11);

else if(input<SW_COND_CAL_13)
  value = 33000 + 14000 * (input-SW_COND_CAL_12)/(SW_COND_CAL_13-SW_COND_CAL_12);

else if(input<SW_COND_CAL_14)
  value = 47000 + 21000 *(input-SW_COND_CAL_13)/(SW_COND_CAL_14-SW_COND_CAL_13);

else if(input<SW_COND_CAL_15)
  value = 68000 + 32000 * (input-SW_COND_CAL_14)/(SW_COND_CAL_15-SW_COND_CAL_14);

else
  value = 100000+900000*(input-SW_COND_CAL_15)/(SW_COND_CAL_16-SW_COND_CAL_15);

return value;

  ////////////////////////////////////////////////
  // 1. Create a new Frame with sensor fields
  ////////////////////////////////////////////////

  USB.println(F("Create new Frame:"));

  // Creating frame to send
  frame.createFrame(ASCII);

  // Adding sensor battery
  frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());

  // Show frame via USB port
  frame.showFrame();


  ////////////////////////////////////////////////////////////////
  // 2. Send Frame to another Waspmote
  ////////////////////////////////////////////////////////////////

  // Sending packet
  sx1272.sendPacketTimeout( rx_address, frame.buffer, frame.length);

  // Check sending status
  if( e == 0 )
  {
    USB.println(F("Packet sent OK"));
  }
  else
  {
    USB.println(F("Error sending the packet"));
    USB.print(F("state: "));
    USB.println(e, DEC);
  }

  USB.println();
  delay(1000);
}
