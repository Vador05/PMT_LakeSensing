

// Put your libraries here (#include ...)
#include <WaspSensorPrototyping_v20.h>

   SdFile LOGfile; 

void setup() {
  // put your setup code here, to run once
  SensorProtov20.ON();
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
        if (SD.isFile(“LOGS.TXT”)=-1)
        {
          USB.println("FILE DOES NOT EXIST");

          if(SD.create(“LOGS.TXT”)=0)
          {
            USB.println("ERROR CREATING FILE");
            SD.OFF();
            setup();
          }
        }
        else 
        {
          if(SD.getFileSize(“FILE.TXT”)>SD.diskSize-50)
          {
            USB.println("Less than 50 Bytes less in your memory card");
          }
        }
     SD.openFile( "LOGS.TXT", &file, O_READ);
            USB.println("FILE OPENED");

  }
  else
  {
    SD.OFF();
    USB.println("NO SD try again 5 s later");
    delay (5000);
    setup();
  }
}


void loop() {
     // It writes “hello” at end of file with EOL
   writeState = SD.appendln(file,”Holis”);
  // put your main code here, to run repeatedly:

}


