
import processing.serial.*;

Serial myPort;        // The serial port
//int xPos = 1;         // horizontal position of the graph
//float inByte = 0;
//int sensor;

int[] sensor;
int width = 1024;
int height = 600;
float zoom = 0.0;

void setup () {
  // set the window size:
  size(1024, 600, P3D);
  // List all the available serial ports
  // if using Processing 2.1 or later, use Serial.printArray()
  //println(Serial.list());
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600 );
  myPort.write(65);
  myPort.bufferUntil('\n'); // wait for a new signal until the end (arduino)

  // set initial background:
  background(0);
  //turn on the lights!
  lights();
}

void draw() {  
  background(0);
  myPort.bufferUntil('\n');
  
  // draw box 100 size
  box(300);
  
  pushMatrix(); // Store current coordinate system
  
  // Electrode 0
  // handle the rotate sensor input
  float rotate = map(sensor[0], 0, 1023, 0, TWO_PI);
  // rotate cube based on sensor value
  rotateY(rotate);

  // Electrode 3
  // handle the pan sensor input
  float pan = map(sensor[2], 0, 1023, 0, width);
  translate(pan, 0, 0);
  
  // Electrode 5 
  // handle the zoom sensor input
  if (sensor[1] < 400) {
    zoom += 1;
  } else {
    zoom -= 1;
  }
  zoom = constrain(zoom, -300.0, 200.0);
  translate(0, 0, zoom);
  
  // Electrode 7
  
  // Electrode 9
  
  // ELectrode 11
  // handle the rotatedown sensor input electrode 11 
  float rotatedown = map(sensor[3], 500, 300, 0, -1.0);
  // rotate cube downwards to get a better angle
  rotateX(rotatedown);
  
  
  // pan cube left/right based on sensor value
  // zoom cube forwards/backwards based on sensor value
  translate(0, height/2, 0);
  
  // fill cube white with black stroke
  fill(255,255,255);
  stroke(0,0,0);
  
  
  // move to the corner of the box
  translate(-150,50,300);
  
  // set the sphere to red
  stroke(255,0,0);
  // draw a small sphere; how to draw the red circle move?
  sphere(5);
  
  // draw sphere 100 size
  //sphere(100);
  //stroke(100,0,255);
  //translate(-30, 300, 100);
  
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
