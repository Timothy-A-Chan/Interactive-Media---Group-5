Table temperature;
int index = 0;    // In 13 hours, the index will loop 152 times
float skyHue;    // skyHue changes as the index changes
int dayCount;
float theta = 0;
int day = 0;

Table peopleCounter;


void setup() {
  size(1000,700);
  temperature = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-02-17T06%3A00&rToDate=2021-02-24T06%3A00&rFamily=weather&rSensor=AT", "csv");
  
  ellipseMode(CENTER);
  
  peopleCounter = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-02-17T06%3A00&rToDate=2021-08-24T06%3A00&rFamily=people_sh&rSensor=CB11.PC02.14.Broadway&rSubSensor=CB11.02.Broadway.East+In", "csv");
  frameRate(1);
}

void draw() {
  if (index < (dayCount = temperature.getRowCount())) {
    //println(index);
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
    
    if(index < peopleCounter.getRowCount()) {
    // read the 2nd column (the 1), and read the row based on index which increments each draw()
    int y = peopleCounter.getInt(index, 1); // index is the row, 1 is the column with the data.
    String x = peopleCounter.getString(index, 0); 
    
    int i = 0;
    
    while(i < y){ // loop to create the correct amount of feet for each person
    
    float x1 = random(20, 650); //50, 700
    float y1 = random(450, 600); // 500, 700
    float w = (50);
    float h = (10);
    
    
    fill(#8f5c3d);
    stroke(1.5);
    
    ellipse(x1, y1, w, h);
    ellipse(x1, y1 + 40, w, h); // duplicates the shoe and randomly places next to the other shoe 
    
    i++;
    }
   
    fill(255, 0, 0);
    textSize(25);
    text("There is " + y + " person(s) at " + x, 10, 50); // text indicating amount of people and when
    noFill();
  }
    
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

void mouseClicked(){
   noLoop(); // pauses the drawing
}


void keyPressed(){
  loop(); // unpauses the drawing
}
