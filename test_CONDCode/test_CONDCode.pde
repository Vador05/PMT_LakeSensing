#define DO_CHANNEL 		2
#define FILTER_SAMPLES 		7
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


//We will fill the stacks with some ref values taken each (CAL_INTERVAL)
int CAL_INTERVAL = 100;//in miliseconds
int LOOP_INTERVAL= 1000;//in milisecon


void setup() {
    // put your setup code here, to run once:
      SensorProtov20.ON();
	delay(100);
}


void loop() {
    // put your main code here, to run repeatedly:
   float res=getCONDMeasure();
   res= resistanceConversion(res);
   res= conductivityConversion(res);
  USB.println(res);

}
float getCONDMeasure()
{
	float value_array[FILTER_SAMPLES];

	// Take some measurements to filter the signal noise and glitches
	for(int i = 0; i < FILTER_SAMPLES; i++)
	{
		//Read from the ADC channel selected
		value_array[i] = SensorProtov20.readADC(adcChannel);
	}
	//Switch OFF the corresponding sensor circuit
	delay(100);

	return median(value_array,FILTER_SAMPLES);
}


//!*************************************************************************************
//!	Name:	conductivityConversion()
//!	Description: Converts the voltage value into a resistance value
//!	Param: float: input: the voltage measured
//!	Returns: 	float: resistance of the conductivity sensor
//!*************************************************************************************
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
