import processing.serial.*;

Serial myPort;        // The serial port

int[] sensor = {0,0,0,0,0,0};
float[] currentAverage = {0,0,0,0,0,0};
float[] untouched = {0,0,0,0,0,0};
int[] slider = {0,0,0,0,0,0};
int width = 1024;
int height = 600;
float zoom = 0.0;
int latchValue = 0;

void setup () {
  // set the window size:
  size(1024, 600);
  // List all the available serial ports
  // if using Processing 2.1 or later, use Serial.printArray()
  //println(Serial.list());
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600 );
  //myPort.write(65);
  myPort.bufferUntil('\n'); // wait for a new signal until the end (arduino)

  // set initial background:
  background(0);
  
  for (int i=0; i<6; i++) {
    slider[i] = height*3/4;
  }
  
  calibrateUntouched();
}

void calibrateUntouched() {
  // Calibrate untouched
  for (int j=0; j<100; j++) {
    for (int i=0; i<6; i++) {
      float val = map(sensor[i], 0, 1023, 0, height);
      // Compute currentAverage
      untouched[i] = untouched[i]*9/10 + val/10;
    }
    delay(10);
  }
}

void draw() {  
  background(0);
  myPort.bufferUntil('\n');
  
  noStroke();
  for (int i=0; i<6; i++) {
    float val = map(sensor[i], 0, 1023, 0, height);
    boolean touched = false;
    
    // Draw untouched thresholds
    rect(i*width/6, untouched[i], width/6, 2);
    
    // Evaluate continuous values 
    fill(255, 200, i*50);
    // Draw absolute values
    int w = width/10;
    int pad = (width/6-w)/2;
    rect(pad+i*width/6, 0, w, val);
    // Draw derivative
    fill(255, 230, i*50);
    w = width/8;
    pad = (width/6-w)/2;
    rect(pad+i*width/6, val, w, val-currentAverage[i]);
    
    // Check for touched or untouched
    if (abs(val-untouched[i]) > 10) {
      fill(235, 160, i*50);
      w = width/12;
      pad = (width/6-w)/2;
      rect(pad+i*width/6, 0, w, val-10);
      touched = true;
    } 
    
    // Incremental change based on derivative
    if (touched) {
      if (abs(val-currentAverage[i]) <= 10) {
        slider[i] += latchValue;
      } else {
        slider[i] += sgn(val-currentAverage[i]);
      }
    }
    fill(255);
    strokeWeight(4);
    stroke(255, 255, i*50);
    ellipse(width/12 + i*width/6, slider[i], 20, 20); 
    noStroke();
    
    // Compute currentAverage
    currentAverage[i] = currentAverage[i]*9/10 + val/10;
  }
}

float sgn(float num) {
  if (abs(num) <= 0) {
    latchValue = 0;
  } else {
    latchValue = int(num/abs(num));
  }
  return latchValue;
} 

void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString);  // trim off any whitespace:  
    //String[] sensor = split(inString, ',');
    sensor = int(split(inString, ','));
    println(sensor);
    println("");
  }
}
