#include <WaspSensorPrototyping_v20.h>
/*
#=======================================#
 |SUPERCODI QUE HO PETA PEL PSEUDOLLAC   |
 #=======================================#
 
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
#define	SW_COND_CAL_01		0.0271
#define	SW_COND_CAL_02		0.0365
#define	SW_COND_CAL_03		0.0478
#define	SW_COND_CAL_04		0.0676
#define	SW_COND_CAL_05		0.1151
#define	SW_COND_CAL_06		0.1997
#define	SW_COND_CAL_07		0.3190
#define	SW_COND_CAL_08		0.3698
#define	SW_COND_CAL_09		0.5047
#define	SW_COND_CAL_10		0.5990
#define	SW_COND_CAL_11		0.6860
#define	SW_COND_CAL_12		0.7642
#define	SW_COND_CAL_13		0.8694
#define	SW_COND_CAL_14		0.8754
#define	SW_COND_CAL_15		0.9076
#define	SW_COND_CAL_16		0.9931
#define DO_CHANNEL 		    2
#define FILTER_SAMPLES   	    7
#define zero_calibration            0 
#define air_calibration             0.035 
float value, value2, value3, value4;
float point_1_cond, point_2_cond, point_1_cal, point_2_cal;
//We are going to int;
//Filter the values due the fast variations that they can suffer during the day that are not real info just exceptional facts
float dist[FILTER_SAMPLES];
float temp[FILTER_SAMPLES];
float cond[FILTER_SAMPLES];
float dens[FILTER_SAMPLES];

//We will fill the stacks with some ref values taken each (CAL_INTERVAL)
int CAL_INTERVAL = 100;//in miliseconds
int LOOP_INTERVAL= 1000;//in miliseconds

SdFile LOGfile; 
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
}

void loop()
{
  uint8_t writeState;

  //Read the ADC 
  //value = SensorProtov20.readADC();
  value=SensorProtov20.readAnalogSensor(ANALOG7);
  //Print the result through the USB and the SD
  writeState = SD.appendln("LOGS.TXT","SONAR    ");
  //   writeState = SD.appendln("LOGS.TXT",value);
  writeState = SD.appendln("LOGS.TXT","V");

  USB.print(F("SONAR    "));
  USB.print(value);
  USB.println(F("V"));


  value2=SensorProtov20.readAnalogSensor(ANALOG5);
  //Print the result through the USB
  writeState = SD.appendln("LOGS.TXT","TEMPERATURE    ");
  //writeState = SD.appendln("LOGS.TXT",value2);
  writeState = SD.appendln("LOGS.TXT","V");
  USB.print(F("TEMPERATURE    "));
  USB.print(value2);
  USB.println(F("V"));

  value3= getDOMeasure();

  writeState = SD.appendln("LOGS.TXT","DO    ");
  //writeState = SD.appendln("LOGS.TXT",value3);
  writeState = SD.appendln("LOGS.TXT","");
  USB.print(F("DO    "));
  USB.print(value3);
  USB.println(F("V"));

  value4= getCONDMeasure();
  value4= resistanceConversion(value4);
  value4= conductivityConversion(value4);

  writeState = SD.appendln("LOGS.TXT","CONDUCTIVITY    ");
  //writeState = SD.appendln("LOGS.TXT",value4);
  writeState = SD.appendln("LOGS.TXT","");
  USB.print(F("CONDUCTIVITY    "));
  USB.print(value4);
  USB.println(F(""));

   SensorProtov20.OFF();
  //Turn on the RTC
  RTC.OFF();  //We scroll the serial terminal
  SD.OFF();
  for (int i=0;i<25;i--){
    USB.println(F(" "));
  }
  //Wait loop interval to read again
  delay(LOOP_INTERVAL);
  //=================== NEW INITIALIZATION =================
   int ch;
  while(ch==1){
    ch=SDsetup();
  }  
   SensorProtov20.ON();
  //Turn on the RTC
  RTC.ON();
  delay(100);//We set an stabilization interval for the sensoers
  
}
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
  //================================ SD CARD =================================
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
      if(SD.getFileSize("LOGS.TXT")>SD.diskSize-50)
      {
        USB.println("Less than 50 Bytes less in your memory card");
      }
    }
    SD.openFile( "LOGS.TXT", &LOGfile, O_READ);
    USB.println("FILE OPENED");
    return (0);

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
}

