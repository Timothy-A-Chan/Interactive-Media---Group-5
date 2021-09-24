import controlP5.*;
import java.util.ArrayList;

Table temperature;
int index = 0;    // In 13 hours, the index will loop 152 times
float skyHue;    // skyHue changes as the index changes
int dayCount;
float theta = 0;


void setup() {
  size(1000, 700);
  temperature = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2020-12-24T06%3A29%3A44&rToDate=2020-12-24T19%3A29%3A44&rFamily=weather&rSensor=AT", "csv");

  ellipseMode(CENTER);
}

void draw() {  

  if (index < (dayCount = temperature.getRowCount())) {
    println(index);
    // SkyHue changing depending on time
    if (index <= dayCount/2) {
      skyHue = map(index, 0, dayCount/2, 0, 255);
    } else {
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
    fill(255, 255, 255);
    noStroke();
    rect(0, 400, 1000, 1000);

    drawBuilding(skyHue);
    //drawRandomWindow(index);

    //index++;
    //if (index == day*dayCount) {
    //  println("----- Day: " + day);
    //  day++;
    //}
    //else {
    //  println(index);
    //}
    index++;
  }

  println("X: " + mouseX + " Y: " + mouseY);
  
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



void drawBuilding(float skyHue) {//Top Left Starting Point: (80, 100);

  stroke(0, 0, 0);
  fill(207, 207, 207);

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

  drawWindow(255, 255, 0, skyHue);//changes color based on input RGB value

  drawBuildingOpensLarge(150, 370);
  drawBuildingOpensSmall(220, 340);
  drawBuildingOpensLarge(290, 360);
}

void drawBuildingOpensLarge(int X, int Y) {//input parameter only specifies position

  //start point 150, 400
  fill(0, 255, 0);
  beginShape();
  vertex(X, Y);//150, 400
  vertex(X + 30, Y - 110);//180, 290
  vertex(X + 90, Y - 170);//240, 230
  //vertex();
  endShape(CLOSE);
}

void drawBuildingOpensSmall(int X, int Y) {//same as above but smaller

  //start point 150, 400
  fill(0, 255, 0);
  beginShape();
  vertex(X, Y);//150, 400
  vertex(X + 15, Y - 55);//180, 290
  vertex(X + 45, Y - 85);//240, 230
  //vertex();
  endShape(CLOSE);
}

void drawWindow(int R, int G, int B, float skyHue) {//input value represents RGB value and skyHue for background

  //Window & Doorthat changes color based on the input parameter
  stroke(0, 0, 0);
  fill(R, G, B);

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
  //rect(580, 400, 40, 50);
  beginShape();
  vertex(580, 400);
  vertex(620, 395);
  vertex(620, 450);
  vertex(580, 450);
  endShape(CLOSE);

  //Wall Part, They will not change color
  fill(207, 207, 207);
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
  fill(255);
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
