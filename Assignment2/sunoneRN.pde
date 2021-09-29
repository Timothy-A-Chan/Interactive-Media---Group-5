Table temperature;
Table rain;
int index = 0;   
int dayCounter = 0;
int rainDroplet = 300;
float[] rainXPos = new float[300];
float[] rainYPos = new float[300];
float[] rainSpeed = new float[300];
float[] rainWeight = new float[300];
float[] rainLine = new float[300];

int rainlevel = 0;
float skyHue, windowHue, buildingHue, glassHue, rainHue;    // skyHue changes as the index changes
float theta1, theta2 = 0;
int day = 0;

void setup() {
  size(1200, 700);
  frameRate = 30;
  temperature = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-02-17T06%3A00&rToDate=2021-02-24T06%3A00&rFamily=weather&rSensor=AT", "csv");
  rain = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-02-17T06%3A00&rToDate=2021-02-24T06%3A00&rFamily=weather&rSensor=RT", "csv");

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
    
        
    // Hues changing depending on time
    
    
    if (dayCounter > 0 && dayCounter < 36) {      // When the dayCounter is between 6:00AM - 9:00AM
      skyHue = map(dayCounter, 0, 36, 0, 255);
      windowHue = map(dayCounter, 0, 36, 255, 0);
      glassHue = map(dayCounter, 0, 36, 0, 255);
      buildingHue = map(dayCounter, 0, 36, 107, 180);
    } 
    else if (dayCounter > 143 && dayCounter < 179) {      // When the dayCounter is between 6:00PM - 9:00PM
      skyHue = map(dayCounter, 143, 179, 255, 0);
      windowHue = map(dayCounter, 143, 179, 0, 255);
      buildingHue = map(dayCounter, 143, 179, 180, 107);
    }
    fill(skyHue/2, 2*skyHue, 3*skyHue);
    rect(0, 0, width, height);
    
    // Weather
    int currentRain = rain.getInt(index, 1);
    //float weatherIntensity = map(currentRain, 0, 20, 0, 100);
    
    
    
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
    fill(120,120,120);
    noStroke();
    rect(0, 400, width, height);
    
    // The Building
    drawBuilding(skyHue, buildingHue);

    textSize(25);
    println("X: " + mouseX + " Y: " + mouseY);
    String info = (temperature.getString(index, 0) + " Temp: ");
    text(info, 10, 50);
    if (currentRain > 0){
      rainDroplets(currentRain);
    }
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

void rainDroplets(float currentRain){
  for (int i=0; i<currentRain; i++) {
    rainXPos[i] = random(0, width);
    rainYPos[i] =random(0, height);
    rainSpeed[i] = random(5, 30);
    rainWeight[i]=random(1, 3);
    rainLine[i]=random(5, 10);
  }
  for (int i=0; i<currentRain; i++) {
    strokeWeight(rainWeight[i]);
    stroke(30*rainSpeed[i], 150);
    line(rainXPos[i], rainYPos[i], rainXPos[i]+rainLine[i]*sin(PI/3), rainYPos[i]-rainLine[i]);
    rainYPos[i] += rainSpeed[i]/2;
    rainXPos[i]=rainXPos[i]-rainSpeed[i]/3;
  }
}
void drawBuilding(float skyHue, float buildingHue) {  //Top Left Starting Point: (80, 100);
  

  stroke(0, 0, 0);
  fill(buildingHue, buildingHue, buildingHue);

  rect(80, 150, 20, 300);

  beginShape();//rect(100, 150, 600, 300);
  vertex(100, 450);//Bottom Left
  vertex(100, 160);//Top Left
  vertex(660, 120);//Top Right
  vertex(660, 450);//Bottom Right
  endShape(CLOSE);

  rect(660, 100, 20, 350);

  fill(255, 255, 255);//UTS text
  textSize(50);
  text("UTS", 490, 180);

  drawWindow(windowHue, skyHue, buildingHue);//changes color based on input RGB value
  fill(150, 150, 150);
  drawBuildingOpensLarge(150, 370, windowHue);
  drawBuildingOpensSmall(220, 340, windowHue);
  drawBuildingOpensLarge(290, 360, windowHue);
}

void drawBuildingOpensLarge(int X, int Y, float windowHue) {//input parameter only specifies position

  //start point 150, 400
  fill(0, windowHue, 0);
  beginShape();
  vertex(X, Y);//150, 400
  vertex(X + 30, Y - 110);//180, 290
  vertex(X + 90, Y - 170);//240, 230
  //vertex();
  endShape(CLOSE);
}

void drawBuildingOpensSmall(int X, int Y, float windowHue) {//same as above but smaller

  //start point 150, 400
  fill(0, windowHue, 0);
  beginShape();
  vertex(X, Y);//150, 400
  vertex(X + 15, Y - 55);//180, 290
  vertex(X + 45, Y - 85);//240, 230
  //vertex();
  endShape(CLOSE);
}

void drawWindow(float windowHue, float skyHue, float buildingHue) {//input value represents RGB value and skyHue for background

  //Window & Doorthat changes color based on the input parameter
  stroke(0, 0, 0);
  fill(windowHue+100, windowHue+100, 100);

  //Window
  beginShape();
  //vertex(620, 124);// 20, 1 / (270, 10)
  vertex(660, 120);
  vertex(660, 450);
  vertex(120, 450);// 2, 26 / (20, 260)
  vertex(280, 390);// 10, 21.5 / (100, 215)
  vertex(580, 342);// 25, 18 / (250, 180)
  //vertex(290, 195);// 29, 19.5 / (290, 195)
  endShape(CLOSE);

  line(580, 342, 660, 360);

  //Door
  fill(windowHue+60, windowHue+60, 60);
  beginShape();
  vertex(580, 400);
  vertex(620, 395);
  vertex(620, 450);
  vertex(580, 450);
  endShape(CLOSE);

  //Wall Part, They will not change color
  fill(buildingHue, buildingHue, buildingHue);
  beginShape();
  vertex(540, 348);
  vertex(560, 345);
  vertex(560, 450);
  vertex(540, 450);
  endShape(CLOSE);

  beginShape();
  vertex(410, 370);
  vertex(430, 366);
  vertex(430, 450);
  vertex(410, 450);
  endShape(CLOSE);

  beginShape();
  vertex(280, 390);
  vertex(300, 387);
  vertex(300, 450);
  vertex(280, 450);
  endShape(CLOSE);

  beginShape();
  vertex(180, 428);
  vertex(200, 420);
  vertex(200, 450);
  vertex(180, 450);
  endShape(CLOSE);

  //Hollow near door
  //The color of this shape should follow the background HUE
  beginShape();
  fill(skyHue/2, 2*skyHue, 3*skyHue);
  vertex(640, 356);
  vertex(660, 360);
  vertex(660, 450);
  vertex(640, 450);
  endShape(CLOSE);
  //below is the while group background
  noStroke();
  fill(120,120,120);
  rect(640, 400, 20, 51);
  stroke(1);
  
  line(640, 400, 640, 450);
  
  //Lines on the window to represent floors
  line(660, 330, 591, 313);
  line(660, 310, 599, 293);
  line(660, 290, 606, 275);
  line(660, 270, 612, 256);
  line(660, 250, 619, 238);
  line(660, 230, 626, 220);
  line(660, 210, 631, 202);
  line(660, 190, 639, 185);
  line(660, 170, 644, 166);
  
  //Ground windows
  line(485, 450, 485, 359);
  line(355, 450, 355, 378);
  line(240, 450, 240, 406);
  
  line(540, 430, 430, 430);
  line(410, 430, 300, 430);
  line(280, 430, 200, 430);
}
