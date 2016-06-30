
import processing.serial.*;

Serial myPort;        // The serial port
//int xPos = 1;         // horizontal position of the graph
//float inByte = 0;

PWindowRotate win; //gesture_0_rotate
PWindowSlider win2; 
PWindowZoom win3;


//int sensor;

int[] sensor;

void setup () {
  // set the window size:
  //size(400, 300,P3D);
  size(1024, 600);
  // List all the available serial ports
  // if using Processing 2.1 or later, use Serial.printArray()
  //println(Serial.list());
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600 );
  myPort.write(65);
  myPort.bufferUntil('\n'); //wait for a new signal until the end (arduino)

  win = new PWindowRotate();
  win2 = new PWindowSlider();
  win3 = new PWindowZoom();
  
  // set inital background:
  background(0);
}
void draw() {
  myPort.bufferUntil('\n');
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
