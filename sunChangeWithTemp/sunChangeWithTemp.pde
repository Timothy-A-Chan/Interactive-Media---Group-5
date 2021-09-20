Table temperature;
int index = 0;    // In 24 hours, the index will loop 286 times
int dayCounter = 0;    // In 24 hours, the index will loop 286 times
float skyHue;    // skyHue changes as the index changes
float theta = 0;
int day = 0;

void setup() {
  size(1200, 700);
  frameRate = 30;
  temperature = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-02-17T06%3A00&rToDate=2021-02-24T06%3A00&rFamily=weather&rSensor=AT", "csv");

  ellipseMode(CENTER);
}

void draw() {
  if (index < temperature.getRowCount()) {
    if (dayCounter > 285) {
      dayCounter = 0;
    }
    // SkyHue changing depending on time
    int dayCount = 284;
    
    if (dayCounter <= dayCount/4) {
      skyHue = map(dayCounter, 0, dayCount/4, 0, 255);
    } 
    else if (dayCounter > dayCount/2 && dayCounter < 3*dayCount/4) {
      skyHue = map(dayCounter, dayCount/2, 3*dayCount/4, 255, 0);
    }
    fill(0, 2*skyHue, 3*skyHue);
    rect(0, 0, width, height);




    // Sun
    int currentTemp = temperature.getInt(index, 1);
    int minTemp = 26;      // Please replace this with code that can detect the lower 
    int maxTemp = 33;      // and higher range of the temperature
    int sunSizeLow = 200;  // The minimum size of the sun when temp is low
    int sunSizeHigh = 250; // The maximum size of the sun when temp is high
    float intensity = map(currentTemp, minTemp, maxTemp, 240, 120);
    float sunRadius = map(currentTemp, minTemp, maxTemp, sunSizeLow, sunSizeHigh);
    sun(sunRadius, intensity, 0);

    // The Ground
    fill(100, 100, 100);
    noStroke();
    rect(0, 400, width, height);

    
    if (index == day*dayCount) {
      day++;
    }
    else {
      //println(index);
    }
    if (dayCounter == 0) {
      println("----- Day: " + day + "  Morning 6:00AM");
    }
    else if (dayCounter == 71) {
      println("----- Day: " + day + "  Noon 12:00PM");
    }
    else if (dayCounter == 143) {
      println("----- Day: " + day + "  Night 6:00PM");
    }
    else if (dayCounter == 214){
      println("----- Day: " + day + "  Midnight 12:00AM");
    }
    index++;
    dayCounter++;
  }
}

void sun(float sunRadius, float intensity, int sunMovement) {
  if (dayCounter < 230) {
    pushMatrix();
    fill(255, intensity, 0);
    translate(width/2, 6*height/7);
    rotate(theta/7);
    circle(cos(theta)-width/2, sunMovement, sunRadius);
    sunMovement += 20;
    theta += 0.1;
    popMatrix();
  }
  else {
    sunMovement = 0;
    theta = 0;
  }
}
