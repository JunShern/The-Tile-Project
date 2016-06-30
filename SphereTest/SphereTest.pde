import processing.serial.*;

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
int[][] slider = {
  {0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0}
};
int latchValue = 0;

// Trig lookup tables borrowed from Toxi; cryptic but effective.
float sinLUT[];
float cosLUT[];
float SINCOS_PRECISION=1.0;
int SINCOS_LENGTH= int((360.0/SINCOS_PRECISION));

Globe globe1, globe2;

int bounceCounter = 0;

// Control variables
float[] rotateX={0,0}, rotateY={0,0}, rotateZ={0,0};
float pan = 0;
float[] zoom={0,0};
float[] prevLayerZoom={50,50};
float[] layerZoom={50,50};
int focus = 0; // Focus on which ball? Blue = 0, Orange = 1  

void setup() {
  size(1024, 700, P3D);
  background(255);
  
  // Fill the look-up tables (LUTs)
  sinLUT= new float[SINCOS_LENGTH];
  cosLUT= new float[SINCOS_LENGTH];
  for (int i = 0; i < SINCOS_LENGTH; i++) {
    sinLUT[i]= (float)Math.sin(i*DEG_TO_RAD*SINCOS_PRECISION);
    cosLUT[i]= (float)Math.cos(i*DEG_TO_RAD*SINCOS_PRECISION);
  }
  
  globe1 = new Globe(color(5,162,106), 0);
  globe2 = new Globe(color(255,140,30), 1);
  
  // List all the available serial ports
  //printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600 );
  myPort.bufferUntil('\n'); // wait for a new signal until the end (arduino)
  for (int i=0; i<6; i++) {
    slider[0][i] = height/2;
    slider[1][i] = height/2;
  }
  calibrateUntouched();
}

void draw() {
  background(255);
  
  drawLayerZoomSlider();
  
  hint(ENABLE_DEPTH_TEST);

  pushMatrix();
  // Rotate X,Y,Z
  rotateX[focus] = slider[focus][0]*6*PI/height;
  rotateY[focus] = slider[focus][1]*6*PI/height;
  rotateZ[focus] = slider[focus][4]*6*PI/height;
  // Pan (rotate between two balls)
  pan = slider[focus][3]*8;
  if (sin(pan*2*PI/width) < 0) focus = 0;
  else focus = 1;
  // Zoom
  zoom[focus] = int(map(slider[focus][5], 0, height, -width*3, width*3));
  translate(0,0,zoom[focus]);
  // Layer zoom (unwrapping)
  prevLayerZoom[focus] = layerZoom[focus];
  layerZoom[focus] = int(map(slider[focus][2], 0, height, 0, 100));
  zoomGlobeLayers(globe1, layerZoom[0], prevLayerZoom[0]);
  globe1.crustLayer.force += abs(layerZoom[0] - prevLayerZoom[0]);
  zoomGlobeLayers(globe2, layerZoom[1], prevLayerZoom[1]);
  globe2.crustLayer.force += abs(layerZoom[1] - prevLayerZoom[1]);

  // Graphics
  bounceCounter = (bounceCounter+3) % 360;
  directionalLight(150, 150, 150, -1, 0, -1);
  directionalLight(150, 150, 150, 0, -1, 0);
  lightSpecular(50, 50, 50);
  emissive(80, 80, 80);
  shininess(12);
  
  translate(width/2, height/2, -width/2);
  
  pushMatrix();
  pushStyle();
  rotateY(pan*2*PI/width); // Panning
  translate(width/2, 10*sinLUT[bounceCounter], 10*cosLUT[bounceCounter]);
  globe1.drawGlobe();
  popStyle();
  popMatrix();

  pushMatrix();
  pushStyle();
  rotateY(pan*2*PI/width); // Panning
  translate(-width/2, 10*cosLUT[bounceCounter], 10*sinLUT[bounceCounter]);
  globe2.drawGlobe();
  popStyle();
  popMatrix();

  popMatrix();
  hint(DISABLE_DEPTH_TEST); // Allows 2D layer to be always on top of 3D
  
  // Reading values
  myPort.bufferUntil('\n');
  noStroke();
  for (int i=0; i<6; i++) {
    float val = map(sensor[i], 0, 1023, 0, height);
    boolean touched = false;
    // Check for touched or untouched
    if (abs(val-untouched[i]) > 10) touched = true; 
    // Incremental change based on derivative
    if (touched) {
/*      if (i==0 || i==1 || i==4) { // A more sensitive, fluid input for rotations
        slider[focus][i] += val-currentAverage;
*/
      if (abs(val-currentAverage[i]) <= 10) {
        slider[focus][i] += latchValue;
      } else {
        slider[focus][i] += sgn(val-currentAverage[i]);
      }
      
      // Handle constraints or loop arounds
      if (i == 2 || i == 5) { // Zoom and layerZoom
        slider[focus][i] = constrain(slider[focus][i], 0, height);
      } else { // Rotations and panning
        // Loop around
        if (slider[focus][i] > height) slider[focus][i] = 0;
        else if (slider[focus][i] < 0) slider[focus][i] = height;
      }
      
      if (i == 3) slider[1-focus][i] = slider[focus][i]; // SUUUPER HACKY but it works - pan should be the same for both focuses
      else if (i == 5) slider[1-focus][i] = slider[focus][i]; // Same for zoom
    }
    //drawIndicator(i, slider[focus][i], touched);
    // Compute currentAverage
    currentAverage[i] = currentAverage[i]*9/10 + val/10;
  }
  
}

void drawLayerZoomSlider() {
  // Draw layerZoom slider at bottom
  int w = width-2*width/40;
  int h = 10;
  int xpos = (width-w)/2;
  int ypos = height-height/30;
  pushStyle();
  noStroke();
  colorMode(RGB, 255);
  fill(220);
  rect(xpos, ypos, w, h);
  // Order matters - draw the focused globe's slider on top
  if (focus == 1) {
    fill(0,206,132);
    ellipse(xpos+map(slider[0][2], 0, height, 0, w), ypos+h/2, h, h);
    fill(245,112,10);
    ellipse(xpos+map(slider[1][2], 0, height, 0, w), ypos+h/2, h, h);
  } else {
    fill(245,112,10);
    ellipse(xpos+map(slider[1][2], 0, height, 0, w), ypos+h/2, h, h);
    fill(0,206,132);
    ellipse(xpos+map(slider[0][2], 0, height, 0, w), ypos+h/2, h, h);
  }
  popStyle();
}

void drawIndicator(int i, int sliderValue, boolean touched) {
  pushStyle();
  int xpos = width/12 + i*width/6;
  int ypos = sliderValue;
  
  //fill(i*40, 240, slider[focus][i]*255/height);
  if (touched) ellipse(xpos, ypos, 40, 40);
  else ellipse(xpos, ypos, 20, 20); 
  fill(20);
  textAlign(CENTER, CENTER);
  switch (i) {
    case 0: {
      text("Rotate X", xpos, ypos+20);
      text(str(rotateX[focus]), xpos+40, ypos+40);
    }
    case 1: {
      text("Rotate Y", xpos, ypos+20);
      text(str(rotateY[focus]), xpos+40, ypos+40);
    }
    case 2: {
      text("Rotate Z", xpos, ypos+20);
      text(str(rotateZ[focus]), xpos+40, ypos+40);
    }
    case 3: {
      text("Navigate", xpos, ypos+20);
      text(str(pan), xpos+40, ypos+40);
    }
    case 4: {
      text("Zoom", xpos, ypos+20);
      text(str(zoom[focus]), xpos+40, ypos+40);
    }
    case 5: {
      text("Unwrap layers", xpos, ypos+20);
      text(str(layerZoom[focus]), xpos+40, ypos+40);
    }
  }
  popStyle();
}

void zoomGlobeLayers(Globe globe, float layerZoom, float prevLayerZoom) {
  if (layerZoom > 70) { // Crust
    if (prevLayerZoom <= 70) globe.crustLayer.reset(); // Just crossed over from Mantel 
    globe.privateLayerZoom = layerZoom; 
  } else if (layerZoom < 70) {// Mantel
    if (prevLayerZoom >= 70) globe.crustLayer.unwrap = true; // Just crossed over from Crust 
    globe.privateLayerZoom = layerZoom;
  } 
}

void calibrateUntouched() {
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
    //println(sensor);
    //println("");
  }
}

