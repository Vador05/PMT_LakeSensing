 #include <WaspSX1272.h>
// Put your libraries here (#include ...)

void setup() {
    // put your setup code here, to run once:
    sx1272.ON()
>    // put your main code here, to run repeatedly:
    sx1272.getTemp();//obtenir la temperatura del waspmote;
    sx1272.setMode(3);
   /* Mode BW CR SF Sensitivity
                    (dB)
      1 125 4/5 12 -134 4245 5781 max range, slow data rate
      2 250 4/5 12 -131 2193 3287 -
      3 125 4/5 10 -129 1208 2120 -
      4 500 4/5 12 -128 1167 2040 -
      5 250 4/5 10 -126 674 1457 -
      6 500 4/5 11 -125,5 715 1499 -
      7 250 4/5 9 -123 428 1145 -
      8 500 4/5 9 -120 284 970 -
      9 500 4/5 8 -117 220 890 -
      10 500 4/5 7 -114 186 848 min range, fast
      data rate, minimum
      battery impact*/
    sx1272.setNodeAddress(2);
    sx1272.setChannel(CH_10_868);
    sx1272.setRetries(5);
}


void loop() {

    
    	 sx1272.sendPacketTimeout(5, "Holi, aixo es una proveta");
}

