import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class New3D extends PApplet {



Serial myPort;        // The serial port

int[] sensor = {
  0, 0, 0, 0, 0, 0
};
float[] currentAverage = {
  0, 0, 0, 0, 0, 0
};
float[] untouched = {
  0, 0, 0, 0, 0, 0
};
int[] slider = {
  0, 0, 0, 0, 0, 0
};
int width = 1024;
int height = 600;
int latchValue = 0;

public void setup () {
  // set the window size:
  size(1024, 600, P3D);
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
    slider[i] = height/2;
  }

  calibrateUntouched();
}

public void calibrateUntouched() {
  // Calibrate untouched
  for (int j=0; j<200; j++) {
    for (int i=0; i<6; i++) {
      float val = map(sensor[i], 0, 1023, 0, height);
      // Compute currentAverage
      untouched[i] = untouched[i]*9/10 + val/10;
    }
    delay(20);
  }
}

public void draw() {  
  background(0);
  myPort.bufferUntil('\n');

  // Drawing
  fill(200-random(20), 200+random(20), 200+random(20));
  pushMatrix();
  translate(width/2, height/2, 0); // Move box to centre of screen
  // E0
  int zoom = slider[0] - height/2;
  translate(0, 0, zoom);
  // E3
  int panX = slider[1] - height/2;
  translate(panX, 0, 0);
  // E5
  int panY = slider[2] - height/2;
  translate(0, panY, 0);
  // E7
  float rX = slider[3] - height/2;
  rotateX(rX*2*PI/height);
  // E9 
  float rY = slider[4] - height/2;
  rotateY(rY*2*PI/height);
  // E11
  float rZ = slider[5] - height/2;
  rotateZ(rZ*2*PI/height);
  noFill();
  stroke(255);
  strokeWeight(4);
  box(200);
  popMatrix();


  // Reading values
  noStroke();
  for (int i=0; i<6; i++) {
    float val = map(sensor[i], 0, 1023, 0, height);
    boolean touched = false;

    // Check for touched or untouched
    if (abs(val-untouched[i]) > 10) {
      fill(255, 240, i*50);
      //ellipse(width/12+i*width/6, 0, width/15, width/15);
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
    fill(i*40, 240, slider[i]*255/height);
    if (touched) ellipse(width/12 + i*width/6, slider[i], 40, 40);
    else ellipse(width/12 + i*width/6, slider[i], 20, 20); 
    /*switch (i) {
      case 0: text("Zoom", width/12 + i*width/6, slider[i], 20, 20);
      case 1: text("PanX", width/12 + i*width/6, slider[i], 20, 20);
      case 2: text("PanYwidth/12 + i*width/6, slider[i], 20, 20);
      case 3: text(width/12 + i*width/6, slider[i], 20, 20);
      case 4: text(width/12 + i*width/6, slider[i], 20, 20);
      case 5: text(width/12 + i*width/6, slider[i], 20, 20);
    }*/

    // Compute currentAverage
    currentAverage[i] = currentAverage[i]*9/10 + val/10;
  }
}

public float sgn(float num) {
  if (abs(num) <= 0) {
    latchValue = 0;
  } else {
    latchValue = PApplet.parseInt(num/abs(num));
  }
  return latchValue;
} 

public void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString);  // trim off any whitespace:  
    //String[] sensor = split(inString, ',');
    sensor = PApplet.parseInt(split(inString, ','));
    println(sensor);
    println("");
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "New3D" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
