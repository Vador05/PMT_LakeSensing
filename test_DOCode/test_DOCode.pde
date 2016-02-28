#define DO_CHANNEL 		2
#define FILTER_SAMPLES 		7
#define zero_calibration        0 
#define air_calibration         10 


//We will fill the stacks with some ref values taken each (CAL_INTERVAL)
int CAL_INTERVAL = 100;//in miliseconds
int LOOP_INTERVAL= 1000;//in milisecon


void setup() {
    // put your setup code here, to run once:
myADC.begin();
	delay(100);
}


void loop() {
    // put your main code here, to run repeatedly:
    Serial.println(getDOMeasure);

}
float getDOMeasure()
{
	float value_array[FILTER_SAMPLES];

	// Take some measurements to filter the signal noise and glitches
	for(int i = 0; i < FILTER_SAMPLES; i++)
	{
		//Read from the ADC channel selected
		value_array[i] = myADC.readADC(DO_CHANNEL);
	}
	float input= myFilter.median(value_array,FILTER_SAMPLES);
	return (input - zero_calibration)/(air_calibration - zero_calibration) * 100;
}


