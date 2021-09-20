Table temperature;
int index = 0;   
int dayCounter = 0;   
float skyHue;    // skyHue changes as the index changes
float theta1, theta2 = 0;
int day = 0;

void setup() {
  size(1200, 700);
  frameRate = 30;
  temperature = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-02-17T06%3A00&rToDate=2021-02-24T06%3A00&rFamily=weather&rSensor=AT", "csv");

  ellipseMode(CENTER);
}

void draw() {
  if (index < temperature.getRowCount()) {
    if (dayCounter >= 286) { 
      dayCounter = 0;
    }
    /* This is a simple explanation on how the dayCounter works in relation to time
                     Initially index and dayCounter is the same
           When they reach intervals of 286, the dayCounter resets back to 0
                     Here is a chart that explains both counters
    
                  |---------Time Chart in relation to dayCounter---------|
                  |                                                      |
                  |       dayCounter = 0          Time: 6:00AM           |
                  |       dayCounter = 72         Time: 12:00PM          |
                  |       dayCounter = 143        Time: 6:00PM           |
                  |       dayCounter = 215        Time: 12:00AM          |
                  |                                                      |
                  |-------Time and Day Chart in relation to Index--------|
                  |                                                      |    
                  |       index = 0      -->   Day 0    6:00AM           |
                  |       index = 358    -->   Day 1   12:00PM           |
                  |        (286+72)                                      |
                  |       index = 644    -->   Day 2   12:00PM           |
                  |        (2*286+72)                                    |
                  |------------------------------------------------------|
          
          The code below will display the day number and the index in real time
                      Uncomment the lines below to display this                    */
    //int dayCount = 284;
    //if (index == day*dayCount) {
    //  println( "Day: " + day);
    //  day++;
    //}      
    //if (dayCounter == 0) {
    //  println("Index: "+index+ " | Morning 6:00AM");
    //}
    //else if (dayCounter == 72) {
    //  println("Index: "+index+ " | Noon 12:00PM");
    //}
    //else if (dayCounter == 143) {
    //  println("Index: "+index+ " | Night 6:00PM");
    //}
    //else if (dayCounter == 215){
    //  println("Index: "+index+ " | Midnight 12:00AM");
    //}
    
        
    // SkyHue changing depending on time
    
    
    if (dayCounter > 0 && dayCounter < 36) {      // When the dayCounter is between 6:00AM - 9:00AM
      skyHue = map(dayCounter, 0, 36, 0, 255);
    } 
    else if (dayCounter > 143 && dayCounter < 179) {      // When the dayCounter is between 6:00PM - 9:00PM
      skyHue = map(dayCounter, 143, 179, 255, 0);
    }
    fill(skyHue/2, 2*skyHue, 3*skyHue);
    rect(0, 0, width, height);


    // Sun and Moon Cycle
    int currentTemp = temperature.getInt(index, 1);
    int minTemp = 26;      // Please replace this with code that can detect the lower 
    int maxTemp = 33;      // and higher range of the temperature
    int sunSizeLow = 200;  // The minimum size of the sun when temp is low
    int sunSizeHigh = 250; // The maximum size of the sun when temp is high
    float intensity = map(currentTemp, minTemp, maxTemp, 240, 120);
    float sunRadius = map(currentTemp, minTemp, maxTemp, sunSizeLow, sunSizeHigh);
    moon(200, 0);
    sun(sunRadius, intensity, 0);
    

    // The Ground
    fill(100, 100, 100);
    noStroke();
    rect(0, 400, width, height);

        
    index++;
    dayCounter++;
  }
}

void sun(float sunRadius, float intensity, int sunMovement) {
  if (dayCounter < 214) {
    pushMatrix();
    fill(255, intensity, 0);
    translate(width/2, 6*height/7);
    rotate(theta1/5);
    circle(cos(theta1)-width/2, sunMovement, sunRadius);
    sunMovement += 20;
    theta1 += 0.1;
    popMatrix();
  }
  else {
    sunMovement = 0;
    theta1 = 0;
  }
}

void moon(float moonRadius, int moonMovement) {
  if (dayCounter >= 146 || dayCounter < 20) {
    pushMatrix();
    fill(255);
    translate(width/2, 6*height/7);
    rotate(theta2/5);
    circle(cos(theta2)-width/2, moonMovement, moonRadius);
    moonMovement += 20;
    theta2 += 0.1;
    popMatrix();
  }
  else {
    moonMovement = 0;
    theta2 = 0;
  }
}
