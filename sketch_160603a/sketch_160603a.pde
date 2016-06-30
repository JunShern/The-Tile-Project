
import processing.serial.*;

Serial myPort;        // The serial port
int[] sensor;

int xPos = 0; 
int yPos = 0; 

int w;
int y;
int h;

int width = 500;
int height = 500;

float radius_start = 50;
float radius_min = 50;
float radius_max = 250;

float angle_start = PI*2 - QUARTER_PI;

float background_radius = 250;

float threshold_0 = 400;//0
float threshold_5 = 500;//1
float threshold_9 = 500;//2
float threshold_11 = 500;//3
float threshold_3 = 0; //4
float threshold_7 = 0; //5, 4 and 5 tgt become a mouse controller


float threshold_on_off = 300;

int sensor_zoom = 0; //white circle
int sensor_slide = 1; //arc
int sensor_rotate = 2;//red circle rotate on x axis
int sensor_select = 3;//blue spinning wheel
int sensor_cursorY = 4; // extra ball, mouseY
int sensor_cursorX = 5; // controlling the big call ;mouseX

void setup() {
  size(500, 500, P3D);
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600 );
  myPort.write(65);
  myPort.bufferUntil('\n'); //wait for a new signal until the end (arduino)
  background(0);
}

void mouse_ellipse (int w, int h)
{
  fill(255, sensor[sensor_cursorY], sensor[sensor_cursorY]); 
  //stroke(150, mouseX, 230); 
  ellipse(sensor[sensor_cursorX], sensor[sensor_cursorY], w, h);
}

void draw() {
  myPort.bufferUntil('\n');

  // zoom
  float radius = radius_start;
  if (sensor[sensor_zoom] < threshold_0) {

    ////on off
    //if (sensor[sensor_zoom] > threshold_on_off) {
    //  radius_start--;
    //}
    //else {
    //   radius_start++; 
    //}

    //continuous mapping
    radius = map(sensor[sensor_zoom], 100, 500, radius_min, radius_max);
  }

  // slide
  float angle = angle_start;
  if (sensor[sensor_slide] < threshold_5) {
    angle = map(sensor[sensor_slide], 100, 500, -HALF_PI, PI*2 - HALF_PI); 

    angle += 0.01;
  }

  //rotate
  float rotate = 0;
  if (sensor[sensor_rotate] < threshold_9) {
    rotate = map(sensor[sensor_rotate], 100, 500, 0, PI*2);
  }

  //select
  float select_rotate = 0;
  if (sensor[sensor_select] < threshold_11) {
    select_rotate = map(sensor[sensor_select], 100, 500, 0, PI*2);
  }


  background(0);
  stroke(0);
  
    pushMatrix();
    
     background(125);
  //ellipse(xPos, 200, 80, 40);
  //ellipse(width/2, yPos, 50, 50);
  stroke(100, 200, 300, 4);
  mouse_ellipse(100, 100);


  if (sensor_cursorY > 350)
  {
    ellipse(100, 150, sensor[sensor_cursorX], sensor[sensor_cursorY]);
    //xPos=xPos+1; //if xpos is greater than half the screen, stagnant circle grows bigger to attract attention
    
    
  } else   {
    
    ellipse(250, 250, 300, 300);
  }
  popMatrix();
  

  pushMatrix();
  translate(width/2, height/2, 0);

  rotateX(rotate);


  fill(255, 0, 0);
  ellipse(0, 0, background_radius, background_radius); 


  fill(255, 255, 255);
  translate(0, 0, 1);
  //ellipse(width/2, height/2, radius, radius);
  arc(0, 0, radius, radius, -HALF_PI, angle, PIE);

  popMatrix();

//cicular cylinder full screen
  pushMatrix();
  translate(width/2, height/2, 0);
  //rotateY(HALF_PI);
  rotateX(PI);
  rotateZ(select_rotate);

  fill(0, 0, 255, 100);
  drawCylinder(20, radius_max, 50);

  popMatrix();
 

  pushMatrix();
  translate(width/2, height/2, 0);
  //rotateY(HALF_PI);
  rotateX(HALF_PI);
  rotateZ(select_rotate);
  fill(100, 200, 255, 100);

  drawCylinder(20, radius_max, 50);


  popMatrix();
  

}

void serialEvent (Serial myPort) {

  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString);  // trim off any whitespace:  
    //String[] sensor = split(inString, ',');
    sensor = int(split(inString, ','));
    println(sensor);
  }
}

void drawCylinder(int sides, float r, float h)
{
  float angle = 360 / sides;
  float halfHeight = h / 2;
  // draw top shape
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, -halfHeight );
  }
  endShape(CLOSE);
  // draw bottom shape
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight );
  }
  endShape(CLOSE);
  // draw body
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 2; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight);
    vertex( x, y, -halfHeight);  
    //x += 0.1;

    
  }
  endShape(CLOSE); 

  //draw red dot
  //move to the corner of the box
  translate(150, -200, 0);

  //set the sphere to red
  stroke(255, 255, 0);

  //draw a small sphere; how to draw the red circle move?
  sphere(5);
}
