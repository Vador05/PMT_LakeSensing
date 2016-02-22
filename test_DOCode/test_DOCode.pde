#define DO_CHANNEL 		2
#define FILTER_SAMPLES 		7


void setup() {
    // put your setup code here, to run once:
	//Switch ON the corresponding sensor circuit
	delay(100);
}


void loop() {
    // put your main code here, to run repeatedly:

}
float getDOMeasure(uint8_t digitalPin)
{

	
	float value_array[FILTER_SAMPLES];

	// Take some measurements to filter the signal noise and glitches
	for(int i = 0; i < FILTER_SAMPLES; i++)
	{
		//Read from the ADC channel selected
		value_array[i] = myADC.readADC(DO_CHANNEL);
	}
	float inpput= myFilter.median(value_array,FILTER_SAMPLES);
	return (input - zero_calibration)/(air_calibration - zero_calibration) * 100;

}


