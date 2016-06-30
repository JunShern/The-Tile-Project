
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
  
  for (int i=0; i<6; i++) {
    slider[0][i] = height/2;
    slider[1][i] = height/2;
  }

}

void draw() {
  background(255);
  
  drawLayerZoomSlider();
  
  hint(ENABLE_DEPTH_TEST);

  pushMatrix();
  // Rotate X,Y,Z
  /*rotateX[focus] = slider[focus][0]*6*PI/height;
  rotateY[focus] = slider[focus][1]*6*PI/height;
  rotateZ[focus] = slider[focus][4]*6*PI/height;*/
  rotateZ[focus] = 2*PI*mouseY/height;
  // Pan (rotate between two balls)
  pan = mouseX*2; //slider[focus][3]*8;
  if (sin(pan*2*PI/width) < 0) focus = 0;
  else focus = 1;
  // Zoom
  zoom[focus] = int(map(slider[focus][5], 0, height, -width*3, width*3));
  translate(0,0,zoom[focus]);
  // Layer zoom (unwrapping)
  prevLayerZoom[focus] = layerZoom[focus];
  //layerZoom[focus] = int(map(slider[focus][2], 0, height, 0, 100));
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
    ellipse(xpos+map(layerZoom[0], 0, 100, 0, w), ypos+h/2, h, h);
    fill(245,112,10);
    ellipse(xpos+map(layerZoom[1], 0, 100, 0, w), ypos+h/2, h, h);
  } else {
    fill(245,112,10);
    ellipse(xpos+map(layerZoom[1], 0, 100, 0, w), ypos+h/2, h, h);
    fill(0,206,132);
    ellipse(xpos+map(layerZoom[0], 0, 100, 0, w), ypos+h/2, h, h);
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

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      layerZoom[focus] = constrain(layerZoom[focus]-1.0, 0, 100);
    } else if (keyCode == RIGHT) {
      layerZoom[focus] = constrain(layerZoom[focus]+1.0, 0, 100);
    }
  }
}

void mouseMoved() {
  globe1.crustLayer.force += dist(mouseX, mouseY, pmouseX, pmouseY)/(width/12);
  globe2.crustLayer.force += dist(mouseX, mouseY, pmouseX, pmouseY)/(width/12);
}
