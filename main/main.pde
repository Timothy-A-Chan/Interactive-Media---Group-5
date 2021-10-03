import beads.*;
import controlP5.*;

ControlP5 cp5;
Table temperature, peopleCounter, rain;
// Values related to time
int index = 0;  
int dayCounter;
int currentDay = 1;

// Colour changing variables
float skyHue, windowHue, buildingHue, glassHue;

// Orbit variable
float theta1, theta2 = 0;

// Rain variable
float[] rainXPos = new float[300];
float[] rainYPos = new float[300];
float[] rainSpeed = new float[300];
float[] rainWeight = new float[300];
float[] rainLine = new float[300];
int rainDroplet = 300;

// Pause button variable
boolean paused = false;
boolean showText1, showText2 = true;

// Images
PImage pause, play, person, hottest, coldest, rainiest, crowded;

// Sound Function Stuff at line 135
AudioContext ac;
SamplePlayer p1, p2, p3, p4;
Glide gl1, gl2, gl3, gl4;
float Volume = 1;

void setup() {
  size(1200, 700);
  frameRate = 30;
  temperature = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-06-14T06%3A00&rToDate=2021-06-21T06%3A00&rFamily=weather&rSensor=AT", "csv");
  peopleCounter = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2020-06-14T06%3A00&rToDate=2020-12-24T06%3A00&rFamily=people_sh&rSensor=CB11.PC02.14.Broadway&rSubSensor=CB11.02.Broadway.East+In", "csv");
  rain = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-06-14T06%3A00&rToDate=2021-06-21T06%3A00&rFamily=weather&rSensor=RT", "csv");
  play = loadImage("play.png");
  pause = loadImage("pause.png");
  person = loadImage("person1.png");
  hottest = loadImage("hottest.png");
  coldest = loadImage("coldest.png");
  rainiest = loadImage("rainy.png");
  crowded = loadImage("crowd.png");
  play.resize(50, 50);
  pause.resize(50, 50);
  person.resize(36, 56); //Ratio (9:14)
  hottest.resize(30, 100); //Ratio (3:10)
  coldest.resize(30, 100); //Ratio (3:10)
  rainiest.resize(70, 60); //Ratio (7:6)
  crowded.resize(70, 56); //Ratio (5:4)
  cp5 = new ControlP5(this);

  cp5.addSlider("Volume")
    .setPosition(20, 540)
    .setSize(20, 130)
    .setRange(0, 1);

  cp5.addButton("Pause")
    .setPosition(575, 625)
    .setSize(50, 50)
    .setImage(pause);

  cp5.addButton("Hot")
    .setPosition(1025, 500)
    .setImage(hottest)
    .setSize(30, 100);

  cp5.addButton("Cold")
    .setPosition(1100, 500)
    .setImage(coldest)
    .setSize(30, 100);

  cp5.addButton("Rain")
    .setPosition(1000, 425)
    .setImage(rainiest)
    .setSize(70, 60);

  cp5.addButton("Crowded")
    .setPosition(1085, 425)
    .setImage(crowded)
    .setSize(70, 56);

  cp5.addButton("ToggleText")
    .setPosition(1000, 625)
    .setSize(150, 50)
    .setColorForeground(color(61, 161, 77))
    .setColorActive(color(61, 161, 77))
    .setColorBackground(color(78, 210, 110));

  ellipseMode(CENTER);
  ac = new AudioContext();
  sound();
}

void draw() {  
  if (index < temperature.getRowCount() && paused == false) {      // index goes up to 2010
    if (dayCounter >= 286) { 
      currentDay++;
      dayCounter = 0;
    }
    int currentTemp = temperature.getInt(index, 1);
    int currentPeople = peopleCounter.getInt(index, 1);
    float currentRainfall = rain.getInt(index, 1);

    // Hues changing depending on time   
    if (dayCounter > 0 && dayCounter < 36) {      // When the dayCounter is between 6:00AM - 9:00AM
      skyHue = map(dayCounter, 0, 36, 0, 255);
      windowHue = map(dayCounter, 0, 36, 255, 0);
      glassHue = map(dayCounter, 0, 36, 0, 255);
      buildingHue = map(dayCounter, 0, 36, 107, 180);
    } else if (dayCounter > 143 && dayCounter < 179) {      // When the dayCounter is between 6:00PM - 9:00PM
      skyHue = map(dayCounter, 143, 179, 255, 0);
      windowHue = map(dayCounter, 143, 179, 0, 255);
      buildingHue = map(dayCounter, 143, 179, 180, 107);
    }
    fill(skyHue/2, 2*skyHue, 3*skyHue);
    rect(0, 0, width, height);

    // Sun and Moon Cycle
    orbit();

    // The Ground
    fill(120, 120, 120);
    noStroke();
    rect(0, 400, width, height);

    // The Building
    drawBuilding(skyHue, buildingHue);

    // Time Slider
    timeSlider();

    // People Counter
    peopleCounterGenerator();

    // Weather
    rainDroplets();

    // Debugging Tools    
    textSize(25);

    // Mouse Position
    //println("X: " + mouseX + " Y: " + mouseY);

    // Time Bar
    //String info = (temperature.getString(index, 0) + " Temp: ");
    //text(info, 10, 680);   

    index++;
    dayCounter++;

    //Sound changes based on day parameter
    gl1.setValue(0.1 * Volume);
    if (dayCounter > 143 & dayCounter < 285) {//night time
      gl2.setValue(0.2 * Volume);
      gl3.setValue(0.5 * Volume);
    } else {//day time
      gl2.setValue(1 * Volume);
      gl3.setValue(0 * Volume);
    }

    if (currentRainfall > 0) gl4.setValue(Volume);
    else gl4.setValue(0);

    //mouse hover check
    hover(currentTemp, currentRainfall, currentPeople);
  }
  if (index > 2010) {
    resetDay(0, 1);
  }
}

void sound() {

  String sample1 = sketchPath("") + "data/Traffic_Light_2.aiff";
  String sample2 = sketchPath("") + "data/People_Sound.wav";
  String sample3 = sketchPath("") + "data/Night_Sound.wav";
  String sample4 = sketchPath("") + "data/Rain.wav";

  p1 = new SamplePlayer(ac, SampleManager.sample(sample1));
  p2 = new SamplePlayer(ac, SampleManager.sample(sample2));
  p3 = new SamplePlayer(ac, SampleManager.sample(sample3));
  p4 = new SamplePlayer(ac, SampleManager.sample(sample4));

  p1.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  p2.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  p3.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  p4.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

  gl1 = new Glide(ac, 1, 100);
  Gain g1 = new Gain(ac, 1, gl1);
  g1.addInput(p1);

  gl2 = new Glide(ac, 1, 100);
  Gain g2 = new Gain(ac, 1, gl2);
  g2.addInput(p2);

  gl3 = new Glide(ac, 1, 100);
  Gain g3 = new Gain(ac, 2, gl3);
  g3.addInput(p3);

  gl4 = new Glide(ac, 1, 100);
  Gain g4 = new Gain(ac, 2, gl4);
  g4.addInput(p4);

  ac.out.addInput(g1);
  ac.out.addInput(g2);
  ac.out.addInput(g3);
  ac.out.addInput(g4);

  ac.start();
}

void hover(int currentTemp, float currentRainfall, int currentPeople) {
  int fillColor;
  int textX = 0;
  int textY = 0;

  if (dayCounter > 0 && dayCounter < 180) {
    fillColor = 0;
    fill(fillColor);
  } else {
    fillColor = 235;
    fill(fillColor);
  }

  if (mouseX > width/2 && mouseY > height/2) {
    textX = mouseX - 300;
    textY = mouseY - 30;
    //println("bottom right hand side");
  } else if (mouseX > width/2 && mouseY < height/2) {
    textX = mouseX - 300;
    textY = mouseY + 100;
    //println("top right hand side");
  } else if (mouseX < width/2 && mouseY > height/2) {
    textX = mouseX + 15;
    textY = mouseY - 30;
    //println("bottom left hand side");
  } else if (mouseX < width/2 && mouseY < height/2) {
    textX = mouseX + 15;
    textY = mouseY + 100;
    //println("top left hand side");
  }
  if (mouseX > 575 && mouseY > 625 && mouseX < 625 && mouseY <675) showText1 = false;
  else if (mouseX > 200 && mouseX < 1000 && mouseY > 50 && mouseY < 75) showText1 = false;
  else showText1 = true;

  if (showText1 && showText2) {
    if (mouseX > 80 && mouseX < 680 && mouseY > 100 && mouseY < 450 && index < 2011) {//Check for hovering above UTS building
      //texts
      text("UTS Building Status", textX, textY);//695, 230
      text("'Put some parameter related to building here'", textX, textY - 30);//695, 260
      text("'UTS parameter' stuff", textX, textY - 60);//695, 290
      //Outlines the building to indicate that the mouse is hovering above the building
      fill(255, 255, 255, 0);
      strokeWeight(0.5);
      rect(80, 100, 600, 350);
    } else if (mouseY < 400 && index < 2011) {//check for hovering above sky
      //texts
      text(temperature.getString(index, 0), textX, textY-60);  
      text("Temperature: " + currentTemp + "°C", textX, textY - 30);
      text("Rainfall: " + currentRainfall + " mm", textX, textY);
    } else if (mouseX>1025 && mouseX<1055 && mouseY>500 && mouseY < 600) {
      int hottest[] = getMax(temperature);
      text("Hottest during " + temperature.getString(hottest[0], 0) + " at " + hottest[1] + "°C", textX-300, mouseY);
    } else if (mouseX>1100 && mouseX<1130 && mouseY>500 && mouseY < 600) {
      int coldest[] = getMax(temperature);
      text("Coldest during " + temperature.getString(coldest[0], 0) + " at " + coldest[1] + "°C", textX-400, mouseY);
    } else if (mouseX>1000 && mouseX<1070 && mouseY>425 && mouseY < 485) {
      int rainiest[] = getMax(rain);
      text("Rainiest during " + rain.getString(rainiest[0], 0) + " at " + rainiest[1] + "mm",textX-300, mouseY+50);
    } else if (mouseX>1085 && mouseX<1155 && mouseY>425 && mouseY < 481) {
      int people[] = getMax(rain);
      text("Most people during " + rain.getString(people[0], 0) + " at " + people[1] + " people",textX-500, mouseY+50);
    } else if (index < 2011) {//check for hovering above ground
      //texts
      text("People Counter Status: " + currentPeople + " Person/s", textX, textY);
    }
  }
}

int[] getMax(Table table) {
  int[] maxInfo = new int[2];
  int maxValue = Integer.MIN_VALUE;
  int maxValueIndex = 0;
  for (int i = 0; i < table.getRowCount(); i++) {
    if (table.getInt(i, 1) > maxValue) {
      maxValue = table.getInt(i, 1);
      maxValueIndex = i;
    }
  }
  maxInfo[0] = maxValueIndex;
  maxInfo[1] = maxValue;
  return maxInfo;
} 

int[] getMin(Table table) {
  int[] minInfo = new int[2];
  int minValue = Integer.MAX_VALUE;
  int minValueIndex = 0;
  for (int i = 0; i < table.getRowCount(); i++) {
    if (table.getInt(i, 1) < minValue) {
      minValue = table.getInt(i, 1);
      minValueIndex = i;
    }
  }
  minInfo[0] = minValueIndex;
  minInfo[1] = minValue;
  return minInfo;
} 

void timeSlider() {
  fill(100);
  int barWidth = 800;
  rect(200, 50, barWidth, 25);
  float filledBar = map(index, 0, 2010, 0, barWidth);
  if (currentDay == 1) fill(#FF0000);
  else if (currentDay == 2) fill(#F2E756);
  else if (currentDay == 3) fill(#E189C9);
  else if (currentDay == 4) fill(#44D24D);
  else if (currentDay == 5) fill(#CC46D5);
  else if (currentDay == 6) fill(#E4870E);
  else if (currentDay == 7) fill(#476ADC);
  rect(200, 50, filledBar, 25);
  float interval = barWidth/7;
  int numDay = 1;
  if (dayCounter < 160)
    fill(0);
  else 
  fill(200);
  textSize(20);
  while (interval < barWidth) {
    line(200+interval, 50, 200+interval, 75);
    text("Day " + numDay, 115+interval, 46);
    interval = interval+barWidth/7;
    numDay++;
  }
}

void ToggleText() {
  if (showText2 == true) {
    cp5.getController("ToggleText").setColorForeground(color(161, 61, 61));
    cp5.getController("ToggleText").setColorActive(color(61, 161, 77));    
    cp5.getController("ToggleText").setColorBackground(color(245, 50, 50));

    showText2 = false;
  } else {
    cp5.getController("ToggleText").setColorActive(color(161, 61, 61));
    cp5.getController("ToggleText").setColorForeground(color(61, 161, 77));
    cp5.getController("ToggleText").setColorBackground(color(2, 193, 20));
    showText2 = true;
  }
}

void Pause() {
  if (paused == false) {
    cp5.getController("Pause").setImage(play);
    fill(255, 0, 0);
    text("Click play to see changes", 30, 670);
    paused = true;
  } else if (paused == true) {
    cp5.getController("Pause").setImage(pause);
    paused = false;
  }
}

void Hot() {
  int hottest[] = getMax(temperature);
  println("Hottest during " + temperature.getString(hottest[0], 0) + " at " + hottest[1] + "°C");
  resetDay(getDay(hottest[0])*286, getDay(hottest[0]));
}

void Cold() {
  int coldest[] = getMin(temperature);
  println("Coldest during " + temperature.getString(coldest[0], 0) + " at " + coldest[1] + "°C");
  resetDay(getDay(coldest[0])*286, getDay(coldest[0]));
}

void Rain() {
  int rainiest[] = getMax(rain);
  println("Rainiest during " + rain.getString(rainiest[0], 0) + " at " + rainiest[1] + "mm");
  resetDay(getDay(rainiest[0])*286, getDay(rainiest[0]));
}

void Crowded() {
  int crowd[] = getMax(peopleCounter);
  println("Most people during " + rain.getString(crowd[0], 0) + " at " + crowd[1] + " people");
  resetDay(getDay(crowd[0])*286, getDay(crowd[0]));
}

void rainDroplets() {
  stroke(1);
  strokeWeight(1);
  fill(10, 189, 197);
  int currentRain = rain.getInt(index, 1);
  if (currentRain > 0) {
    for (int i=0; i<currentRain*2; i++) {
      rainXPos[i] = random(0, width);
      rainYPos[i] =random(0, height);
      rainSpeed[i] = random(5, 30);
      rainWeight[i]=random(1, 5);
      rainLine[i]=random(5, 20);
    }
    for (int i=0; i<currentRain*2; i++) {
      strokeWeight(rainWeight[i]);
      stroke(30*rainSpeed[i], 150);
      line(rainXPos[i], rainYPos[i], rainXPos[i]+rainLine[i]*sin(PI/3), rainYPos[i]-rainLine[i]);
      rainYPos[i] += rainSpeed[i]/2;
      rainXPos[i]=rainXPos[i]-rainSpeed[i]/3;
    }
  }
  stroke(1);
  strokeWeight(1);
}

int getDay(int index) {
  if (index < 286) return 1;
  else if (index < 2*286) return 2;
  else if (index < 3*286) return 3;
  else if (index < 4*286) return 4;
  else if (index < 5*286) return 5;
  else if (index < 6*286) return 6;
  else return 7;
}

void resetDay(int newIndex, int newDay) {
  index = newIndex;
  currentDay = newDay;
  dayCounter = 0;
}

void mouseClicked() {
  int barWidth = 800;
  float interval = barWidth/7;
  if (mouseX > 200 && mouseX < 200+interval && mouseY > 50 && mouseY < 75)
    resetDay(0, 1);
  else if (mouseX > 200+interval && mouseX < 200+2*interval && mouseY > 50 && mouseY < 75)
    resetDay(287, 2);
  else if (mouseX > 200+2*interval && mouseX < 200+3*interval && mouseY > 50 && mouseY < 75)
    resetDay(573, 3);
  else if (mouseX > 200+3*interval && mouseX < 200+4*interval && mouseY > 50 && mouseY < 75)
    resetDay(859, 4);
  else if (mouseX > 200+4*interval && mouseX < 200+5*interval && mouseY > 50 && mouseY < 75)
    resetDay(1144, 5);
  else if (mouseX > 200+5*interval && mouseX < 200+6*interval && mouseY > 50 && mouseY < 75)
    resetDay(1430, 6);
  else if (mouseX > 200+6*interval && mouseX < 200+7*interval && mouseY > 50 && mouseY < 75)
    resetDay(1716, 7);
}



void orbit() {
  int r = 600;
  int currentTemp = temperature.getInt(index, 1);
  float intensity = map(currentTemp, getMin(temperature)[1], getMax(temperature)[1], 240, 120);
  float sunRadius = map(currentTemp, getMin(temperature)[1], getMax(temperature)[1], 200, 250);

  float sunOrbitX = map(dayCounter, 0, 143, 0, 1200);
  float sunOrbitY = (sqrt(r*r-(sunOrbitX-r)*(sunOrbitX-r)) - r)*-1;
  fill(255, intensity, 0);
  circle(sunOrbitX, sunOrbitY, sunRadius);

  float moonOrbitX = map(dayCounter, 143, 286, 0, 1200);
  float moonOrbitY = (sqrt(r*r-(moonOrbitX-r)*(moonOrbitX-r)) - r)*-1;
  fill(255);
  circle(moonOrbitX, moonOrbitY, 200);
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
  fill(120, 120, 120);
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

void peopleCounterGenerator() {
  //Shows number of people and time
  if (index < peopleCounter.getRowCount()) {
    // read the 2nd column (the 1), and read the row based on index which increments each draw()
    int people = peopleCounter.getInt(index, 1); // index is the row, 1 is the column with the data.
    String date = peopleCounter.getString(index, 0); 

    //Generates people
    int i = 0;

    while (i < people) { // loop to create the correct amount of feet for each person

      int randomX = (int) random(0, 1200);
      int randomY = (int) random(350, 650);
      person = loadImage("person"+int(random(1, 10))+".png");
      image(person, randomX, randomY);

      i++;
    }
  }
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
 Move following lines to draw() to display this                    */

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
