Table temperature;
int index = 0;    // In 13 hours, the index will loop 152 times
float skyHue;    // skyHue changes as the index changes
int dayCount;
float theta = 0;

void setup() {
  size(1000,700);
  temperature = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2020-12-24T06%3A29%3A44&rToDate=2020-12-24T19%3A29%3A44&rFamily=weather&rSensor=AT", "csv");

  ellipseMode(CENTER);
}

void draw() {
  if (index < (dayCount = temperature.getRowCount())) {
    println(index);
    // SkyHue changing depending on time
    if (index <= dayCount/2) {
      skyHue = map(index, 0, dayCount/2, 0, 255);
    }
    else {
      skyHue = map(index, dayCount/2, dayCount, 255, 0);
    }
    fill(skyHue/2, 2*skyHue, 3*skyHue);
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
    rect(0, 400, 1000, 1000);
    
    index++;
  }
}

void sun(float sunRadius, float intensity, int sunMovement) {
  pushMatrix();
  fill(255, intensity, 0); // Sun colour from 220 -> 150
  translate(width/2, 6*height/7);
  rotate(theta/5);
  circle(cos(theta)-width/2, sunMovement, sunRadius);
  sunMovement += 20;
  theta += 0.1;
  popMatrix();
}